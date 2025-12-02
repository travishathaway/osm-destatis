-- ============================================================================
-- OSM + Zensus 2022 Query Recommendations - BERLIN ONLY
-- PostGIS queries combining OpenStreetMap data with German census data
-- Optimized for Berlin to reduce resource usage
-- ============================================================================

-- Note: Berlin is identified as admin_level=4 boundary in OSM
-- All queries use spatial filtering to limit data to Berlin's boundaries

-- ============================================================================
-- ACCESS & PROXIMITY ANALYSIS
-- ============================================================================

-- 1. Public Transport Access by Demographics (Berlin)
-- Population within walking distance (500m) of public transport by age group
WITH berlin_boundary AS (
    SELECT way as geom
    FROM planet_osm_polygon
    WHERE boundary = 'administrative'
      AND admin_level = '4'
      AND name = 'Berlin'
),
transit_buffers AS (
    SELECT ST_Union(ST_Buffer(p.way, 500)) as geom
    FROM planet_osm_point p
    CROSS JOIN berlin_boundary b
    WHERE (p.public_transport IN ('station', 'stop_position')
       OR p.railway IN ('station', 'halt'))
      AND ST_Intersects(p.way, b.geom)
)
SELECT
    SUM(a.unter10) as children_under_10,
    SUM(a.a60bis69 + a.a70bis79 + a.a80undaelter) as seniors_over_60,
    SUM(a.insgesamt_bevoelkerung) as total_population
FROM zensus_2022.alter_in_10er_jahresgruppen_100m a
CROSS JOIN transit_buffers t
CROSS JOIN berlin_boundary b
WHERE ST_Within(a.geom, b.geom)
  AND ST_Within(a.geom, t.geom);


-- 2. School Access in High-Child-Population Areas (Berlin)
-- Areas with high child population but no nearby schools
WITH berlin_boundary AS (
    SELECT way as geom
    FROM planet_osm_polygon
    WHERE boundary = 'administrative'
      AND admin_level = '4'
      AND name = 'Berlin'
)
SELECT
    z.gitter_id_100m,
    e.einwohner,
    z.anteilunter18 as percent_under_18,
    COUNT(p.osm_id) as nearby_schools
FROM zensus_2022.anteil_unter_18_100m z
LEFT JOIN zensus_2022.bevoelkerungszahl_100m e
ON z.geom = e.geom
CROSS JOIN berlin_boundary b
LEFT JOIN planet_osm_point p
    ON p.amenity IN ('school', 'kindergarten')
    AND ST_DWithin(z.geom, p.way, 1000)
    AND ST_Intersects(p.way, b.geom)
WHERE ST_Within(z.geom, b.geom)
  AND z.anteilunter18 > 0.25
GROUP BY z.gitter_id_100m, z.anteilunter18, e.einwohner
HAVING COUNT(p.osm_id) = 0
ORDER BY e.einwohner DESC;


-- ============================================================================
-- ECONOMIC & SOCIAL ANALYSIS
-- ============================================================================

-- 3. Rent vs Amenity Density (Berlin)
-- Correlation between average rent and nearby amenities
WITH berlin_boundary AS (
    SELECT way as geom
    FROM planet_osm_polygon
    WHERE boundary = 'administrative'
      AND admin_level = '4'
      AND name = 'Berlin'
)
SELECT
    r.gitter_id_100m,
    r.durchschnmieteqm,
    COUNT(DISTINCT CASE WHEN p.amenity = 'restaurant' THEN p.osm_id END) as restaurants,
    COUNT(DISTINCT CASE WHEN p.amenity = 'cafe' THEN p.osm_id END) as cafes,
    COUNT(DISTINCT CASE WHEN p.shop IS NOT NULL THEN p.osm_id END) as shops,
    COUNT(DISTINCT CASE WHEN p.leisure = 'park' THEN p.osm_id END) as parks
FROM zensus_2022.durchschn_nettokaltmiete_100m r
CROSS JOIN berlin_boundary b
LEFT JOIN planet_osm_point p
    ON ST_DWithin(r.geom, p.way, 500)
    AND ST_Intersects(p.way, b.geom)
WHERE ST_Within(r.geom, b.geom)
  AND r.durchschnmieteqm IS NOT NULL
GROUP BY r.gitter_id_100m, r.durchschnmieteqm
ORDER BY r.durchschnmieteqm DESC;


-- 4. Food Deserts (Low Supermarket Access) (Berlin)
-- Population without nearby supermarkets
WITH berlin_boundary AS (
    SELECT way as geom
    FROM planet_osm_polygon
    WHERE boundary = 'administrative'
      AND admin_level = '4'
      AND name = 'Berlin'
)
SELECT
    SUM(b.einwohner) as underserved_population,
    AVG(a.durchschnittsalter) as avg_age
FROM zensus_2022.bevoelkerungszahl_100m b
JOIN zensus_2022.durchschnittsalter_100m a
    ON b.gitter_id_100m = a.gitter_id_100m
CROSS JOIN berlin_boundary bb
WHERE ST_Within(b.geom, bb.geom)
  AND NOT EXISTS (
    SELECT 1 FROM planet_osm_point p
    WHERE p.shop = 'supermarket'
      AND ST_DWithin(b.geom, p.way, 1000)
      AND ST_Intersects(p.way, bb.geom)
);


-- ============================================================================
-- ENVIRONMENTAL & SUSTAINABILITY
-- ============================================================================

-- 5. Green Space Access by Income (Rent as Proxy) (Berlin)
-- Parks/green space within 300m by rent level
WITH berlin_boundary AS (
    SELECT way as geom
    FROM planet_osm_polygon
    WHERE boundary = 'administrative'
      AND admin_level = '4'
      AND name = 'Berlin'
),
rent_quartiles AS (
    SELECT
        r.gitter_id_100m,
        r.geom,
        r.durchschnmieteqm,
        NTILE(4) OVER (ORDER BY r.durchschnmieteqm) as rent_quartile
    FROM zensus_2022.durchschn_nettokaltmiete_100m r
    CROSS JOIN berlin_boundary b
    WHERE r.durchschnmieteqm IS NOT NULL
      AND ST_Within(r.geom, b.geom)
)
SELECT
    r.rent_quartile,
    COUNT(*) as grid_cells,
    AVG(green_area.area) as avg_green_area_sqm
FROM rent_quartiles r
CROSS JOIN berlin_boundary b
LEFT JOIN LATERAL (
    SELECT SUM(ST_Area(way)) as area
    FROM planet_osm_polygon p
    WHERE (p.leisure IN ('park', 'garden') OR p.landuse = 'forest')
      AND ST_DWithin(r.geom, p.way, 300)
      AND ST_Intersects(p.way, b.geom)
) green_area ON true
GROUP BY r.rent_quartile
ORDER BY r.rent_quartile;


-- 6. Renewable Energy Adoption by Building Age (Berlin)
-- Solar/renewable heating by construction period
WITH berlin_boundary AS (
    SELECT way as geom
    FROM planet_osm_polygon
    WHERE boundary = 'administrative'
      AND admin_level = '4'
      AND name = 'Berlin'
)
SELECT
    b.baujahr_1919u as pre_1919,
    b.baujahr_1919_1945,
    b.baujahr_1946_1960,
    b.baujahr_1961_1970,
    b.baujahr_1971_1980,
    b.baujahr_1981_1990,
    b.baujahr_1991_2000,
    b.baujahr_2001_2010,
    b.baujahr_2011u as post_2011,
    e.solar_geothermie_waermepumpen,
    e.insgesamt_energietraeger
FROM zensus_2022.baujahr_jz_1km b
JOIN zensus_2022.energietraeger_1km e
    ON b.gitter_id_1km = e.gitter_id_1km
CROSS JOIN berlin_boundary bb
WHERE e.insgesamt_energietraeger > 0
  AND ST_Within(b.geom, bb.geom);


-- ============================================================================
-- HEALTHCARE & SOCIAL SERVICES
-- ============================================================================

-- 7. Elderly Population and Healthcare Access (Berlin)
-- Senior citizens (65+) without nearby medical facilities
WITH berlin_boundary AS (
    SELECT way as geom
    FROM planet_osm_polygon
    WHERE boundary = 'administrative'
      AND admin_level = '4'
      AND name = 'Berlin'
)
SELECT
    z.gitter_id_100m,
    z.anteilprozentueber65 as percent_over_65,
    z.einwohner * (z.anteilprozentueber65/100.0) as seniors_count,
    MIN(ST_Distance(z.geom, p.way)) as distance_to_nearest_doctor
FROM zensus_2022.anteil_ueber_65_100m z
CROSS JOIN berlin_boundary b
CROSS JOIN LATERAL (
    SELECT way
    FROM planet_osm_point
    WHERE amenity IN ('hospital', 'doctors', 'clinic')
      AND ST_Intersects(way, b.geom)
    ORDER BY z.geom <-> way
    LIMIT 1
) p
WHERE ST_Within(z.geom, b.geom)
  AND z.anteilprozentueber65 > 30
ORDER BY seniors_count DESC;


-- 8. Pharmacy Desert Analysis (Berlin)
-- Areas with high elderly population but limited pharmacy access
WITH berlin_boundary AS (
    SELECT way as geom
    FROM planet_osm_polygon
    WHERE boundary = 'administrative'
      AND admin_level = '4'
      AND name = 'Berlin'
),
pharmacy_coverage AS (
    SELECT ST_Union(ST_Buffer(p.way, 800)) as geom
    FROM planet_osm_point p
    CROSS JOIN berlin_boundary b
    WHERE p.amenity = 'pharmacy'
      AND ST_Intersects(p.way, b.geom)
)
SELECT
    SUM(s.gesamt_privathaushalte) as senior_households_uncovered,
    AVG(a.durchschnittsalter) as avg_age
FROM zensus_2022.seniorenstatus_eines_privaten_haushalts_100m s
JOIN zensus_2022.durchschnittsalter_100m a
    ON s.gitter_id_100m = a.gitter_id_100m
CROSS JOIN pharmacy_coverage pc
CROSS JOIN berlin_boundary b
WHERE ST_Within(s.geom, b.geom)
  AND NOT ST_Within(s.geom, pc.geom)
  AND s.haushalte_mit_senioren > 0;


-- ============================================================================
-- HOUSING & URBAN PLANNING
-- ============================================================================

-- 9. Vacancy Rates Near Transit (Berlin)
-- Housing vacancy vs distance to public transport
WITH berlin_boundary AS (
    SELECT way as geom
    FROM planet_osm_polygon
    WHERE boundary = 'administrative'
      AND admin_level = '4'
      AND name = 'Berlin'
)
SELECT
    CASE
        WHEN dist < 250 THEN '0-250m'
        WHEN dist < 500 THEN '250-500m'
        WHEN dist < 1000 THEN '500-1000m'
        ELSE '1000m+'
    END as distance_band,
    AVG(l.leerstandsquote) as avg_vacancy_rate,
    COUNT(*) as sample_size
FROM zensus_2022.leerstandsquote_100m l
CROSS JOIN berlin_boundary b
CROSS JOIN LATERAL (
    SELECT MIN(ST_Distance(l.geom, p.way)) as dist
    FROM planet_osm_point p
    WHERE p.public_transport IN ('station', 'stop_position')
      AND ST_Intersects(p.way, b.geom)
) distances
WHERE ST_Within(l.geom, b.geom)
GROUP BY distance_band
ORDER BY distance_band;


-- 10. Building Density and Household Size (Berlin)
-- Correlation between building type and household composition
WITH berlin_boundary AS (
    SELECT way as geom
    FROM planet_osm_polygon
    WHERE boundary = 'administrative'
      AND admin_level = '4'
      AND name = 'Berlin'
)
SELECT
    g.wohngeb_mit_1_wohnung as single_family,
    g.wohngeb_mit_2_wohnungen as two_family,
    g.wohngeb_mit_3undmehr_wohnungen as multi_family,
    h.durchschnittsanzahl as avg_household_size,
    f.fam_1pers as single_person_households,
    f.fam_paare_ohne_kinder as couples_no_children,
    f.fam_paare_mit_kindern as families_with_children
FROM zensus_2022.geb_gebaeudetyp_groesse_1km g
JOIN zensus_2022.durchschn_haushaltsgroesse_1km h
    ON g.gitter_id_1km = h.gitter_id_1km
JOIN zensus_2022.typ_priv_hh_familie_1km f
    ON g.gitter_id_1km = f.gitter_id_1km
CROSS JOIN berlin_boundary b
WHERE ST_Within(g.geom, b.geom);


-- ============================================================================
-- EDUCATION & DEMOGRAPHICS
-- ============================================================================

-- 11. Religious Diversity Index by Area (Berlin)
-- Religious diversity near places of worship
WITH berlin_boundary AS (
    SELECT way as geom
    FROM planet_osm_polygon
    WHERE boundary = 'administrative'
      AND admin_level = '4'
      AND name = 'Berlin'
)
SELECT
    r.gitter_id_1km,
    r.katholisch,
    r.evangelisch,
    r.sonstige_christl_religion,
    r.islam,
    r.sonstige_religion,
    r.keiner_oeffentl_rechtl_religionsgesellschaft,
    COUNT(DISTINCT CASE WHEN p.amenity = 'place_of_worship' THEN p.osm_id END) as places_of_worship
FROM zensus_2022.religion_1km r
CROSS JOIN berlin_boundary b
LEFT JOIN planet_osm_point p
    ON ST_DWithin(r.geom, p.way, 2000)
    AND ST_Intersects(p.way, b.geom)
WHERE ST_Within(r.geom, b.geom)
GROUP BY r.gitter_id_1km, r.katholisch, r.evangelisch,
         r.sonstige_christl_religion, r.islam, r.sonstige_religion,
         r.keiner_oeffentl_rechtl_religionsgesellschaft;


-- 12. Youth Infrastructure vs Demographics (Berlin)
-- Playgrounds and sports facilities per child
WITH berlin_boundary AS (
    SELECT way as geom
    FROM planet_osm_polygon
    WHERE boundary = 'administrative'
      AND admin_level = '4'
      AND name = 'Berlin'
)
SELECT
    a.gitter_id_1km,
    a.unter10 + a.a10bis19 as youth_population,
    COUNT(CASE WHEN p.leisure = 'playground' THEN 1 END) as playgrounds,
    COUNT(CASE WHEN p.leisure = 'sports_centre' THEN 1 END) as sports_centers,
    COUNT(CASE WHEN p.leisure = 'pitch' THEN 1 END) as sports_pitches
FROM zensus_2022.alter_in_10er_jahresgruppen_1km a
CROSS JOIN berlin_boundary b
LEFT JOIN planet_osm_point p
    ON ST_DWithin(a.geom, p.way, 1000)
    AND ST_Intersects(p.way, b.geom)
WHERE ST_Within(a.geom, b.geom)
  AND a.unter10 + a.a10bis19 > 100
GROUP BY a.gitter_id_1km, a.unter10, a.a10bis19
ORDER BY (a.unter10 + a.a10bis19) DESC;


-- ============================================================================
-- PERFORMANCE OPTIMIZATION TIPS
-- ============================================================================

-- For even better performance, consider:
-- 1. Creating a materialized view of the Berlin boundary:
--    CREATE MATERIALIZED VIEW berlin_boundary AS
--    SELECT way as geom FROM planet_osm_polygon
--    WHERE boundary = 'administrative' AND admin_level = '4' AND name = 'Berlin';
--    CREATE INDEX berlin_boundary_geom_idx ON berlin_boundary USING GIST(geom);
--
-- 2. Creating spatial indexes on census tables if they don't exist:
--    CREATE INDEX IF NOT EXISTS idx_bevoelkerungszahl_100m_geom
--    ON zensus_2022.bevoelkerungszahl_100m USING GIST(geom);
--
-- 3. Using ANALYZE to update table statistics:
--    ANALYZE zensus_2022.bevoelkerungszahl_100m;
