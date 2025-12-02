-- ============================================================================
-- OSM + Zensus 2022 Query Recommendations
-- PostGIS queries combining OpenStreetMap data with German census data
-- ============================================================================

-- ============================================================================
-- ACCESS & PROXIMITY ANALYSIS
-- ============================================================================

-- 1. Public Transport Access by Demographics
-- Population within walking distance (500m) of public transport by age group
WITH transit_buffers AS (
    SELECT ST_Union(ST_Buffer(way, 500)) as geom
    FROM planet_osm_point
    WHERE public_transport IN ('station', 'stop_position')
       OR railway IN ('station', 'halt')
)
SELECT
    SUM(a.unter10) as children_under_10,
    SUM(a.a60bis69 + a.a70bis79 + a.a80undaelter) as seniors_over_60,
    SUM(a.insgesamt_bevoelkerung) as total_population
FROM zensus_2022.alter_in_10er_jahresgruppen_100m a
CROSS JOIN transit_buffers t
WHERE ST_Within(a.geom, t.geom);


-- 2. School Access in High-Child-Population Areas
-- Areas with high child population but no nearby schools
SELECT
    z.gitter_id_100m,
    z.anteilprozentu18 as percent_under_18,
    z.einwohner,
    COUNT(p.osm_id) as nearby_schools
FROM zensus_2022.anteil_unter_18_100m z
LEFT JOIN planet_osm_point p
    ON p.amenity IN ('school', 'kindergarten')
    AND ST_DWithin(z.geom, p.way, 1000)
WHERE z.anteilprozentu18 > 25
GROUP BY z.gitter_id_100m, z.anteilprozentu18, z.einwohner
HAVING COUNT(p.osm_id) = 0
ORDER BY z.einwohner DESC;


-- ============================================================================
-- ECONOMIC & SOCIAL ANALYSIS
-- ============================================================================

-- 3. Rent vs Amenity Density
-- Correlation between average rent and nearby amenities
SELECT
    r.durchschnmieteqm,
    COUNT(DISTINCT CASE WHEN p.amenity = 'restaurant' THEN p.osm_id END) as restaurants,
    COUNT(DISTINCT CASE WHEN p.amenity = 'cafe' THEN p.osm_id END) as cafes,
    COUNT(DISTINCT CASE WHEN p.shop IS NOT NULL THEN p.osm_id END) as shops,
    COUNT(DISTINCT CASE WHEN p.leisure = 'park' THEN p.osm_id END) as parks
FROM zensus_2022.durchschn_nettokaltmiete_100m r
LEFT JOIN planet_osm_point p
    ON ST_DWithin(r.geom, p.way, 500)
WHERE r.durchschnmieteqm IS NOT NULL
GROUP BY r.gitter_id_100m, r.durchschnmieteqm
ORDER BY r.durchschnmieteqm DESC;


-- 4. Food Deserts (Low Supermarket Access)
-- Population without nearby supermarkets
SELECT
    SUM(b.einwohner) as underserved_population,
    AVG(a.durchschnittsalter) as avg_age
FROM zensus_2022.bevoelkerungszahl_100m b
JOIN zensus_2022.durchschnittsalter_100m a
    ON b.gitter_id_100m = a.gitter_id_100m
WHERE NOT EXISTS (
    SELECT 1 FROM planet_osm_point p
    WHERE p.shop = 'supermarket'
      AND ST_DWithin(b.geom, p.way, 1000)
);


-- ============================================================================
-- ENVIRONMENTAL & SUSTAINABILITY
-- ============================================================================

-- 5. Green Space Access by Income (Rent as Proxy)
-- Parks/green space within 300m by rent level
WITH rent_quartiles AS (
    SELECT
        gitter_id_100m,
        geom,
        durchschnmieteqm,
        NTILE(4) OVER (ORDER BY durchschnmieteqm) as rent_quartile
    FROM zensus_2022.durchschn_nettokaltmiete_100m
    WHERE durchschnmieteqm IS NOT NULL
)
SELECT
    r.rent_quartile,
    COUNT(*) as grid_cells,
    AVG(green_area.area) as avg_green_area_sqm
FROM rent_quartiles r
LEFT JOIN LATERAL (
    SELECT SUM(ST_Area(way)) as area
    FROM planet_osm_polygon p
    WHERE (p.leisure IN ('park', 'garden') OR p.landuse = 'forest')
      AND ST_DWithin(r.geom, p.way, 300)
) green_area ON true
GROUP BY r.rent_quartile
ORDER BY r.rent_quartile;


-- 6. Renewable Energy Adoption by Building Age
-- Solar/renewable heating by construction period
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
WHERE e.insgesamt_energietraeger > 0;


-- ============================================================================
-- HEALTHCARE & SOCIAL SERVICES
-- ============================================================================

-- 7. Elderly Population and Healthcare Access
-- Senior citizens (65+) without nearby medical facilities
SELECT
    z.gitter_id_100m,
    z.anteilprozentueber65 as percent_over_65,
    z.einwohner * (z.anteilprozentueber65/100.0) as seniors_count,
    MIN(ST_Distance(z.geom, p.way)) as distance_to_nearest_doctor
FROM zensus_2022.anteil_ueber_65_100m z
CROSS JOIN LATERAL (
    SELECT way
    FROM planet_osm_point
    WHERE amenity IN ('hospital', 'doctors', 'clinic')
    ORDER BY z.geom <-> way
    LIMIT 1
) p
WHERE z.anteilprozentueber65 > 30
ORDER BY seniors_count DESC;


-- 8. Pharmacy Desert Analysis
-- Areas with high elderly population but limited pharmacy access
WITH pharmacy_coverage AS (
    SELECT ST_Union(ST_Buffer(way, 800)) as geom
    FROM planet_osm_point
    WHERE amenity = 'pharmacy'
)
SELECT
    SUM(s.gesamt_privathaushalte) as senior_households_uncovered,
    AVG(a.durchschnittsalter) as avg_age
FROM zensus_2022.seniorenstatus_eines_privaten_haushalts_100m s
JOIN zensus_2022.durchschnittsalter_100m a
    ON s.gitter_id_100m = a.gitter_id_100m
CROSS JOIN pharmacy_coverage pc
WHERE NOT ST_Within(s.geom, pc.geom)
  AND s.haushalte_mit_senioren > 0;


-- ============================================================================
-- HOUSING & URBAN PLANNING
-- ============================================================================

-- 9. Vacancy Rates Near Transit
-- Housing vacancy vs distance to public transport
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
CROSS JOIN LATERAL (
    SELECT MIN(ST_Distance(l.geom, p.way)) as dist
    FROM planet_osm_point p
    WHERE p.public_transport IN ('station', 'stop_position')
) distances
GROUP BY distance_band
ORDER BY distance_band;


-- 10. Building Density and Household Size
-- Correlation between building type and household composition
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
    ON g.gitter_id_1km = f.gitter_id_1km;


-- ============================================================================
-- EDUCATION & DEMOGRAPHICS
-- ============================================================================

-- 11. Religious Diversity Index by Area
-- Religious diversity near places of worship
SELECT
    r.katholisch,
    r.evangelisch,
    r.sonstige_christl_religion,
    r.islam,
    r.sonstige_religion,
    r.keiner_oeffentl_rechtl_religionsgesellschaft,
    COUNT(DISTINCT CASE WHEN p.amenity = 'place_of_worship' THEN p.osm_id END) as places_of_worship
FROM zensus_2022.religion_1km r
LEFT JOIN planet_osm_point p
    ON ST_DWithin(r.geom, p.way, 2000)
GROUP BY r.gitter_id_1km, r.katholisch, r.evangelisch,
         r.sonstige_christl_religion, r.islam, r.sonstige_religion,
         r.keiner_oeffentl_rechtl_religionsgesellschaft;


-- 12. Youth Infrastructure vs Demographics
-- Playgrounds and sports facilities per child
SELECT
    a.gitter_id_1km,
    a.unter10 + a.a10bis19 as youth_population,
    COUNT(CASE WHEN p.leisure = 'playground' THEN 1 END) as playgrounds,
    COUNT(CASE WHEN p.leisure = 'sports_centre' THEN 1 END) as sports_centers,
    COUNT(CASE WHEN p.leisure = 'pitch' THEN 1 END) as sports_pitches
FROM zensus_2022.alter_in_10er_jahresgruppen_1km a
LEFT JOIN planet_osm_point p
    ON ST_DWithin(a.geom, p.way, 1000)
WHERE a.unter10 + a.a10bis19 > 100
GROUP BY a.gitter_id_1km, a.unter10, a.a10bis19
ORDER BY (a.unter10 + a.a10bis19) DESC;
