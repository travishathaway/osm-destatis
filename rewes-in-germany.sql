-- Counting REWEs in Germany

select * from osm.poi_polygon where name ilike 'rewe%'
	and name not ilike '%to go' 
	and name not ilike '%express'
	and name not ilike '%getränke%'
	and osm_type = 'shop';

WITH rewes AS (
	SELECT 
		poly.name,
		ST_Centroid(poly.geom)
	FROM
		osm.poi_polygon poly
	WHERE 
		name ilike 'rewe%'
	AND name NOT ilike '%to go' 
	AND name NOT ilike '%express'
	--AND name NOT ilike '%getränke%'
  	AND name NOT ilike '%abhol%'
	aND osm_type = 'shop'
	aND osm_subtype = 'supermarket'

	UNION

	SELECT
		pt.name,
		pt.geom
	FROM
		osm.poi_point pt
	WHERE
		name ilike 'rewe%'
	AND name NOT ilike '%to go' 
	AND name NOT ilike '%express'
	AND name NOT ilike '%getränke%'
	--AND name NOT ilike '%abhol%'
	AND osm_type = 'shop'
	AND osm_subtype = 'supermarket'
)

-- Reference value is about 3.800
-- https://www.rewe-group.com/de/unternehmen/struktur-und-vertriebslinien/rewe/
SELECT distinct name FROM rewes;


WITH rewes AS (
	SELECT 
		poly.name,
		ST_Centroid(poly.geom) as geom
	FROM
		osm.poi_polygon poly
	WHERE 
		name ilike 'rewe%'
	AND name NOT ilike '%to go' 
	AND name NOT ilike '%express'
	--AND name NOT ilike '%getränke%'
  	AND name NOT ilike '%abhol%'
	aND osm_type = 'shop'
	aND osm_subtype = 'supermarket'

	UNION

	SELECT
		pt.name,
		pt.geom as geom
	FROM
		osm.poi_point pt
	WHERE
		name ilike 'rewe%'
	AND name NOT ilike '%to go' 
	AND name NOT ilike '%express'
	AND name NOT ilike '%getränke%'
	--AND name NOT ilike '%abhol%'
	AND osm_type = 'shop'
	AND osm_subtype = 'supermarket'
), states AS (
	SELECT 
		name,
		geom,
		ST_Area(geom) AS area
	FROM
		osm.place_polygon_nested
	WHERE 
		nest_level = 2 AND admin_level <=4
)
SELECT
	s.name,
	COUNT(*) AS rewes,
	round((s.area / 1000000)::NUMERIC, 2),
	round((COUNT(*) / (s.area / 1000000))::NUMERIC, 4) AS rewes_per_kilometer
FROM
	states s
JOIN
	rewes r
ON
	ST_Within(r.geom, s.geom)
GROUP BY
	s.name, s.area
ORDER BY
	COUNT(*) / (s.area / 1000000) DESC ;


-- REWEs per Bundesland and REWE density

with states as (
	select 
		name,
		geom,
		ST_Area(geom) as area
	from
		osm.place_polygon_nested
	where 
		nest_level = 2 and admin_level <=4
), rewes as (
	select 
		poly.name,
		ST_Centroid(poly.geom) as geom
	from
		osm.poi_polygon poly
	where 
		poly.name ilike 'rewe%' and name not ilike '%to go' and name not ilike '%express'
	and 
		poly.osm_type = 'shop'
		
	UNION

	select
		pt.name,
		pt.geom as geom
	from
		osm.poi_point pt
	where
		pt.name ilike 'rewe%' and name not ilike '%to go' and name not ilike '%express'
	and
		pt.osm_type = 'shop'
)
select
	s.name,
	count(*) as rewes,
	s.area / 1000000,
	count(*) / (s.area / 1000000) as rewes_per_kilometer
from
	states s
join
	rewes r
on
	ST_Within(r.geom, s.geom)
group by
	s.name, s.area
order by
	count(*) / (s.area / 1000000) desc ;


-- How many people in Germany live within 1 km of a REWE?

with rewes as (
	select 
		poly.name,
		ST_Centroid(poly.geom) as geom
	from
		osm.poi_polygon poly
	where 
		poly.name ilike 'rewe%' and name not ilike '%to go' and name not ilike '%express'
	and 
		poly.osm_type = 'shop'

	UNION

	select
		pt.name,
		pt.geom as geom
	from
		osm.poi_point pt
	where
		pt.name ilike 'rewe%' and name not ilike '%to go' and name not ilike '%express'
	and
		pt.osm_type = 'shop'
), rewe_buffer as (
	select ST_Buffer(r.geom, 1000) as geom from rewes r
)
select
	sum(p.einwohner)
from
	zensus.bevoelkerungszahl_100m p
join
	rewe_buffer b
on
	ST_Within(p.geom, b.geom)
