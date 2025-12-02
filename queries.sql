SELECT 
    osm_id,
    lower(name),
    shop,
    brand,
    way as geometry
FROM planet_osm_point
WHERE shop = 'supermarket'
and lower(name) like '%rewe%'

Union all

SELECT 
    osm_id,
    lower(name),
    shop,
    brand,
    St_Centroid(way) as geometry
FROM planet_osm_point
WHERE shop = 'supermarket'
and lower(name) like '%rewe%'

WITH rewe_buffered AS (
    -- Create a single multipolygon from all REWE supermarket buffers
    SELECT ST_Union(ST_Buffer(way, 1000)) as geom
    FROM (
        -- Get REWE supermarkets from point table
        SELECT way
        FROM planet_osm_point
        WHERE shop = 'supermarket'
          AND (brand ilike 'REWE' OR brand ilike 'rewe city' OR brand ilike 'rewe center' OR name ILIKE '%REWE%')
        
        UNION ALL
        
        -- Get REWE supermarkets from polygon table
        SELECT ST_Centroid(way)
        FROM planet_osm_polygon
        WHERE shop = 'supermarket'
          AND (brand = 'REWE' OR name ILIKE '%REWE%')
    ) AS rewe_locations
)
SELECT 
    SUM(einwohner) as einwohner_neben_einem_rewe
FROM zensus_2022.bevoelkerungszahl_100m p
CROSS JOIN rewe_buffered r
WHERE ST_Within(p.geom, r.geom);

select name, brand, count(*)
from planet_osm_point 
where (name ilike 'REWE%' or name is null) and (brand ilike 'rewe city' OR brand ilike 'rewe center' or brand ilike 'rewe')
group by name, brand
