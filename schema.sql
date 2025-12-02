--
-- PostgreSQL database dump
--

\restrict XJ3u8sKISIY6i2cCfCo7mrid2VlzI1pbCmIOx42fYqB3cAhTtxbi0kGkdcf0XOt

-- Dumped from database version 16.4 (Debian 16.4-1.pgdg110+2)
-- Dumped by pg_dump version 16.10 (Ubuntu 16.10-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tiger;


--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tiger_data;


--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA topology;


--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: zensus; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA zensus;


--
-- Name: zensus_2022; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA zensus_2022;


--
-- Name: zensus_test; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA zensus_test;


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- Name: planet_osm_index_bucket(bigint[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.planet_osm_index_bucket(bigint[]) RETURNS bigint[]
    LANGUAGE sql IMMUTABLE
    AS $_$  SELECT ARRAY(SELECT DISTINCT    unnest($1) >> 5)$_$;


--
-- Name: planet_osm_line_osm2pgsql_valid(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.planet_osm_line_osm2pgsql_valid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF ST_IsValid(NEW.way) THEN 
    RETURN NEW;
  END IF;
  RETURN NULL;
END;$$;


--
-- Name: planet_osm_member_ids(jsonb, character); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.planet_osm_member_ids(jsonb, character) RETURNS bigint[]
    LANGUAGE sql IMMUTABLE
    AS $_$  SELECT array_agg((el->>'ref')::int8)   FROM jsonb_array_elements($1) AS el    WHERE el->>'type' = $2$_$;


--
-- Name: planet_osm_point_osm2pgsql_valid(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.planet_osm_point_osm2pgsql_valid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF ST_IsValid(NEW.way) THEN 
    RETURN NEW;
  END IF;
  RETURN NULL;
END;$$;


--
-- Name: planet_osm_polygon_osm2pgsql_valid(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.planet_osm_polygon_osm2pgsql_valid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF ST_IsValid(NEW.way) THEN 
    RETURN NEW;
  END IF;
  RETURN NULL;
END;$$;


--
-- Name: planet_osm_roads_osm2pgsql_valid(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.planet_osm_roads_osm2pgsql_valid() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF ST_IsValid(NEW.way) THEN 
    RETURN NEW;
  END IF;
  RETURN NULL;
END;$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: osm2pgsql_properties; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.osm2pgsql_properties (
    property text NOT NULL,
    value text NOT NULL
);


--
-- Name: planet_osm_line; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_osm_line (
    osm_id bigint,
    access text,
    "addr:housename" text,
    "addr:housenumber" text,
    "addr:interpolation" text,
    admin_level text,
    aerialway text,
    aeroway text,
    amenity text,
    area text,
    barrier text,
    bicycle text,
    brand text,
    bridge text,
    boundary text,
    building text,
    construction text,
    covered text,
    culvert text,
    cutting text,
    denomination text,
    disused text,
    embankment text,
    foot text,
    "generator:source" text,
    harbour text,
    highway text,
    historic text,
    horse text,
    intermittent text,
    junction text,
    landuse text,
    layer text,
    leisure text,
    lock text,
    man_made text,
    military text,
    motorcar text,
    name text,
    "natural" text,
    office text,
    oneway text,
    operator text,
    place text,
    population text,
    power text,
    power_source text,
    public_transport text,
    railway text,
    ref text,
    religion text,
    route text,
    service text,
    shop text,
    sport text,
    surface text,
    toll text,
    tourism text,
    "tower:type" text,
    tracktype text,
    tunnel text,
    water text,
    waterway text,
    wetland text,
    width text,
    wood text,
    z_order integer,
    way_area real,
    way public.geometry(LineString,3857)
);


--
-- Name: planet_osm_nodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_osm_nodes (
    id bigint NOT NULL,
    lat integer NOT NULL,
    lon integer NOT NULL,
    tags jsonb
);


--
-- Name: planet_osm_point; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_osm_point (
    osm_id bigint,
    access text,
    "addr:housename" text,
    "addr:housenumber" text,
    "addr:interpolation" text,
    admin_level text,
    aerialway text,
    aeroway text,
    amenity text,
    area text,
    barrier text,
    bicycle text,
    brand text,
    bridge text,
    boundary text,
    building text,
    capital text,
    construction text,
    covered text,
    culvert text,
    cutting text,
    denomination text,
    disused text,
    ele text,
    embankment text,
    foot text,
    "generator:source" text,
    harbour text,
    highway text,
    historic text,
    horse text,
    intermittent text,
    junction text,
    landuse text,
    layer text,
    leisure text,
    lock text,
    man_made text,
    military text,
    motorcar text,
    name text,
    "natural" text,
    office text,
    oneway text,
    operator text,
    place text,
    population text,
    power text,
    power_source text,
    public_transport text,
    railway text,
    ref text,
    religion text,
    route text,
    service text,
    shop text,
    sport text,
    surface text,
    toll text,
    tourism text,
    "tower:type" text,
    tunnel text,
    water text,
    waterway text,
    wetland text,
    width text,
    wood text,
    z_order integer,
    way public.geometry(Point,3857)
);


--
-- Name: planet_osm_polygon; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_osm_polygon (
    osm_id bigint,
    access text,
    "addr:housename" text,
    "addr:housenumber" text,
    "addr:interpolation" text,
    admin_level text,
    aerialway text,
    aeroway text,
    amenity text,
    area text,
    barrier text,
    bicycle text,
    brand text,
    bridge text,
    boundary text,
    building text,
    construction text,
    covered text,
    culvert text,
    cutting text,
    denomination text,
    disused text,
    embankment text,
    foot text,
    "generator:source" text,
    harbour text,
    highway text,
    historic text,
    horse text,
    intermittent text,
    junction text,
    landuse text,
    layer text,
    leisure text,
    lock text,
    man_made text,
    military text,
    motorcar text,
    name text,
    "natural" text,
    office text,
    oneway text,
    operator text,
    place text,
    population text,
    power text,
    power_source text,
    public_transport text,
    railway text,
    ref text,
    religion text,
    route text,
    service text,
    shop text,
    sport text,
    surface text,
    toll text,
    tourism text,
    "tower:type" text,
    tracktype text,
    tunnel text,
    water text,
    waterway text,
    wetland text,
    width text,
    wood text,
    z_order integer,
    way_area real,
    way public.geometry(Geometry,3857)
);


--
-- Name: planet_osm_rels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_osm_rels (
    id bigint NOT NULL,
    members jsonb NOT NULL,
    tags jsonb
);


--
-- Name: planet_osm_roads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_osm_roads (
    osm_id bigint,
    access text,
    "addr:housename" text,
    "addr:housenumber" text,
    "addr:interpolation" text,
    admin_level text,
    aerialway text,
    aeroway text,
    amenity text,
    area text,
    barrier text,
    bicycle text,
    brand text,
    bridge text,
    boundary text,
    building text,
    construction text,
    covered text,
    culvert text,
    cutting text,
    denomination text,
    disused text,
    embankment text,
    foot text,
    "generator:source" text,
    harbour text,
    highway text,
    historic text,
    horse text,
    intermittent text,
    junction text,
    landuse text,
    layer text,
    leisure text,
    lock text,
    man_made text,
    military text,
    motorcar text,
    name text,
    "natural" text,
    office text,
    oneway text,
    operator text,
    place text,
    population text,
    power text,
    power_source text,
    public_transport text,
    railway text,
    ref text,
    religion text,
    route text,
    service text,
    shop text,
    sport text,
    surface text,
    toll text,
    tourism text,
    "tower:type" text,
    tracktype text,
    tunnel text,
    water text,
    waterway text,
    wetland text,
    width text,
    wood text,
    z_order integer,
    way_area real,
    way public.geometry(LineString,3857)
);


--
-- Name: planet_osm_ways; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planet_osm_ways (
    id bigint NOT NULL,
    nodes bigint[] NOT NULL,
    tags jsonb
);


--
-- Name: alter_in_10er_jahresgruppen_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.alter_in_10er_jahresgruppen_100m (
    gitter_id_100m text,
    insgesamt_bevoelkerung integer,
    unter10 integer,
    a10bis19 integer,
    a20bis29 integer,
    a30bis39 integer,
    a40bis49 integer,
    a50bis59 integer,
    a60bis69 integer,
    a70bis79 integer,
    a80undaelter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: alter_in_10er_jahresgruppen_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.alter_in_10er_jahresgruppen_10km (
    gitter_id_10km text,
    insgesamt_bevoelkerung integer,
    unter10 integer,
    a10bis19 integer,
    a20bis29 integer,
    a30bis39 integer,
    a40bis49 integer,
    a50bis59 integer,
    a60bis69 integer,
    a70bis79 integer,
    a80undaelter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: alter_in_10er_jahresgruppen_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.alter_in_10er_jahresgruppen_1km (
    gitter_id_1km text,
    insgesamt_bevoelkerung integer,
    unter10 integer,
    a10bis19 integer,
    a20bis29 integer,
    a30bis39 integer,
    a40bis49 integer,
    a50bis59 integer,
    a60bis69 integer,
    a70bis79 integer,
    a80undaelter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: alter_in_5_altersklassen_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.alter_in_5_altersklassen_100m (
    gitter_id_100m text,
    insgesamt_bevoelkerung integer,
    unter18 integer,
    a18bis29 integer,
    a30bis49 integer,
    a50bis64 integer,
    a65undaelter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: alter_in_5_altersklassen_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.alter_in_5_altersklassen_10km (
    gitter_id_10km text,
    insgesamt_bevoelkerung integer,
    unter18 integer,
    a18bis29 integer,
    a30bis49 integer,
    a50bis64 integer,
    a65undaelter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: alter_in_5_altersklassen_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.alter_in_5_altersklassen_1km (
    gitter_id_1km text,
    insgesamt_bevoelkerung integer,
    unter18 integer,
    a18bis29 integer,
    a30bis49 integer,
    a50bis64 integer,
    a65undaelter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: alter_infr_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.alter_infr_100m (
    gitter_id_100m text,
    insgesamt_bevoelkerung integer,
    unter3 integer,
    a3bis5 integer,
    a6bis9 integer,
    a10bis15 integer,
    a16bis18 integer,
    a19bis24 integer,
    a25bis39 integer,
    a40bis59 integer,
    a60bis66 integer,
    a67bis74 integer,
    a75undaelter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: alter_infr_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.alter_infr_10km (
    gitter_id_10km text,
    insgesamt_bevoelkerung integer,
    unter3 integer,
    a3bis5 integer,
    a6bis9 integer,
    a10bis15 integer,
    a16bis18 integer,
    a19bis24 integer,
    a25bis39 integer,
    a40bis59 integer,
    a60bis66 integer,
    a67bis74 integer,
    a75undaelter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: alter_infr_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.alter_infr_1km (
    gitter_id_1km text,
    insgesamt_bevoelkerung integer,
    unter3 integer,
    a3bis5 integer,
    a6bis9 integer,
    a10bis15 integer,
    a16bis18 integer,
    a19bis24 integer,
    a25bis39 integer,
    a40bis59 integer,
    a60bis66 integer,
    a67bis74 integer,
    a75undaelter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: anteil_auslaender_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.anteil_auslaender_100m (
    gitter_id_100m text,
    anteilauslaender double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: anteil_auslaender_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.anteil_auslaender_10km (
    gitter_id_10km text,
    anteilauslaender double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: anteil_auslaender_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.anteil_auslaender_1km (
    gitter_id_1km text,
    anteilauslaender double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: anteil_ueber_65_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.anteil_ueber_65_100m (
    gitter_id_100m text,
    anteilueber65 double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: anteil_ueber_65_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.anteil_ueber_65_10km (
    gitter_id_10km text,
    anteilueber65 double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: anteil_ueber_65_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.anteil_ueber_65_1km (
    gitter_id_1km text,
    anteilueber65 double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: anteil_unter_18_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.anteil_unter_18_100m (
    gitter_id_100m text,
    anteilunter18 double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: anteil_unter_18_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.anteil_unter_18_10km (
    gitter_id_10km text,
    anteilunter18 double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: anteil_unter_18_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.anteil_unter_18_1km (
    gitter_id_1km text,
    anteilunter18 double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: auslaenderanteil_ab18_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.auslaenderanteil_ab18_100m (
    gitter_id_100m text,
    werterlaeuternde_zeichen text,
    anteilauslaenderab18 double precision,
    geom public.geometry(Point,3857)
);


--
-- Name: auslaenderanteil_ab18_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.auslaenderanteil_ab18_10km (
    gitter_id_10km text,
    werterlaeuternde_zeichen text,
    anteilauslaenderab18 double precision,
    geom public.geometry(Point,3857)
);


--
-- Name: auslaenderanteil_ab18_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.auslaenderanteil_ab18_1km (
    gitter_id_1km text,
    werterlaeuternde_zeichen text,
    anteilauslaenderab18 double precision,
    geom public.geometry(Point,3857)
);


--
-- Name: auslaenderanteil_eu_neu_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.auslaenderanteil_eu_neu_100m (
    gitter_id_100m text,
    werterlaeuternde_zeichen_eu text,
    auslaenderanteil_eu double precision,
    werterlaeuternde_zeichen_nichteu text,
    auslaenderanteil_nichteu double precision,
    geom public.geometry(Point,3857)
);


--
-- Name: baujahr_jz_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.baujahr_jz_100m (
    gitter_id_100m text,
    insgesamt_gebaeude integer,
    vor1919 integer,
    a1919bis1949 integer,
    a1950bis1959 integer,
    a1960bis1969 integer,
    a1970bis1979 integer,
    a1980bis1989 integer,
    a1990bis1999 integer,
    a2000bis2009 integer,
    a2010bis2015 integer,
    a2016undspaeter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: baujahr_jz_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.baujahr_jz_10km (
    gitter_id_10km text,
    insgesamt_gebaeude integer,
    vor1919 integer,
    a1919bis1949 integer,
    a1950bis1959 integer,
    a1960bis1969 integer,
    a1970bis1979 integer,
    a1980bis1989 integer,
    a1990bis1999 integer,
    a2000bis2009 integer,
    a2010bis2015 integer,
    a2016undspaeter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: baujahr_jz_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.baujahr_jz_1km (
    gitter_id_1km text,
    insgesamt_gebaeude integer,
    vor1919 integer,
    a1919bis1949 integer,
    a1950bis1959 integer,
    a1960bis1969 integer,
    a1970bis1979 integer,
    a1980bis1989 integer,
    a1990bis1999 integer,
    a2000bis2009 integer,
    a2010bis2015 integer,
    a2016undspaeter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: baujahresklassen_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.baujahresklassen_100m (
    gitter_id_100m text,
    insgesamt_gebaeude integer,
    a1859undfrueher integer,
    a1860bis1918 integer,
    a1919bis1948 integer,
    a1949bis1957 integer,
    a1958bis1968 integer,
    a1969bis1978 integer,
    a1979bis1983 integer,
    a1984bis1994 integer,
    a1995bis2001 integer,
    a2002bis2009 integer,
    a2010bis2022 integer,
    geom public.geometry(Point,3857)
);


--
-- Name: baujahresklassen_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.baujahresklassen_1km (
    gitter_id_1km text,
    insgesamt_gebaeude integer,
    a1859undfrueher integer,
    a1860bis1918 integer,
    a1919bis1948 integer,
    a1949bis1957 integer,
    a1958bis1968 integer,
    a1969bis1978 integer,
    a1979bis1983 integer,
    a1984bis1994 integer,
    a1995bis2001 integer,
    a2002bis2009 integer,
    a2010bis2022 integer,
    geom public.geometry(Point,3857)
);


--
-- Name: bevoelkerungszahl_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.bevoelkerungszahl_100m (
    gitter_id_100m text,
    einwohner integer,
    geom public.geometry(Point,3857)
);


--
-- Name: bevoelkerungszahl_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.bevoelkerungszahl_10km (
    gitter_id_10km text,
    einwohner integer,
    geom public.geometry(Point,3857)
);


--
-- Name: bevoelkerungszahl_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.bevoelkerungszahl_1km (
    gitter_id_1km text,
    einwohner integer,
    geom public.geometry(Point,3857)
);


--
-- Name: deutsche_staatsangehoerige_ab18_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.deutsche_staatsangehoerige_ab18_100m (
    gitter_id_100m text,
    deutsche_ab18 integer,
    geom public.geometry(Point,3857)
);


--
-- Name: deutsche_staatsangehoerige_ab18_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.deutsche_staatsangehoerige_ab18_10km (
    gitter_id_10km text,
    deutsche_ab18 integer,
    geom public.geometry(Point,3857)
);


--
-- Name: deutsche_staatsangehoerige_ab18_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.deutsche_staatsangehoerige_ab18_1km (
    gitter_id_1km text,
    deutsche_ab18 integer,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_flaeche_je_bewohner_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_flaeche_je_bewohner_100m (
    gitter_id_100m text,
    durchschnflaechejebew double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_flaeche_je_bewohner_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_flaeche_je_bewohner_10km (
    gitter_id_10km text,
    durchschnflaechejebew double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_flaeche_je_bewohner_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_flaeche_je_bewohner_1km (
    gitter_id_1km text,
    durchschnflaechejebew double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_flaeche_je_wohnung_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_flaeche_je_wohnung_100m (
    gitter_id_100m text,
    durchschnflaechejewohn double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_flaeche_je_wohnung_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_flaeche_je_wohnung_10km (
    gitter_id_10km text,
    durchschnflaechejewohn double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_flaeche_je_wohnung_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_flaeche_je_wohnung_1km (
    gitter_id_1km text,
    durchschnflaechejewohn double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_haushaltsgroesse_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_haushaltsgroesse_100m (
    gitter_id_100m text,
    durchschnhhgroesse double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_haushaltsgroesse_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_haushaltsgroesse_10km (
    gitter_id_10km text,
    durchschnhhgroesse double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_haushaltsgroesse_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_haushaltsgroesse_1km (
    gitter_id_1km text,
    durchschnhhgroesse double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_nettokaltmiete_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_nettokaltmiete_100m (
    gitter_id_100m text,
    durchschnmieteqm double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_nettokaltmiete_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_nettokaltmiete_10km (
    gitter_id_10km text,
    durchschnmieteqm double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_nettokaltmiete_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_nettokaltmiete_1km (
    gitter_id_1km text,
    durchschnmieteqm double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_nettokaltmiete_anzahl_der_wohnungen_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_nettokaltmiete_anzahl_der_wohnungen_100m (
    gitter_id_100m text,
    durchschnmieteqm double precision,
    anzahlwohnungen integer,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_nettokaltmiete_anzahl_der_wohnungen_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_nettokaltmiete_anzahl_der_wohnungen_10km (
    gitter_id_10km text,
    durchschnmieteqm double precision,
    anzahlwohnungen double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschn_nettokaltmiete_anzahl_der_wohnungen_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschn_nettokaltmiete_anzahl_der_wohnungen_1km (
    gitter_id_1km text,
    durchschnmieteqm double precision,
    anzahlwohnungen double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschnittsalter_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschnittsalter_100m (
    gitter_id_100m text,
    durchschnittsalter double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschnittsalter_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschnittsalter_10km (
    gitter_id_10km text,
    durchschnittsalter double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: durchschnittsalter_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.durchschnittsalter_1km (
    gitter_id_1km text,
    durchschnittsalter double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: eigentuemerquote_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.eigentuemerquote_100m (
    gitter_id_100m text,
    eigentuemerquote double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: eigentuemerquote_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.eigentuemerquote_10km (
    gitter_id_10km text,
    eigentuemerquote double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: eigentuemerquote_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.eigentuemerquote_1km (
    gitter_id_1km text,
    eigentuemerquote double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: energietraeger_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.energietraeger_100m (
    gitter_id_100m text,
    insgesamt_energietraeger integer,
    gas text,
    heizoel text,
    holz_holzpellets text,
    biomasse_biogas text,
    solar_geothermie_waermepumpen text,
    strom text,
    kohle text,
    fernwaerme text,
    kein_energietraeger text,
    geom public.geometry(Point,3857)
);


--
-- Name: energietraeger_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.energietraeger_10km (
    gitter_id_10km text,
    insgesamt_energietraeger integer,
    gas integer,
    heizoel integer,
    holz_holzpellets integer,
    biomasse_biogas integer,
    solar_geothermie_waermepumpen integer,
    strom integer,
    kohle integer,
    fernwaerme integer,
    kein_energietraeger integer,
    geom public.geometry(Point,3857)
);


--
-- Name: energietraeger_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.energietraeger_1km (
    gitter_id_1km text,
    insgesamt_energietraeger integer,
    gas integer,
    heizoel integer,
    holz_holzpellets integer,
    biomasse_biogas integer,
    solar_geothermie_waermepumpen integer,
    strom integer,
    kohle integer,
    fernwaerme integer,
    kein_energietraeger integer,
    geom public.geometry(Point,3857)
);


--
-- Name: familienstand_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.familienstand_100m (
    gitter_id_100m text,
    insgesamt_bevoelkerung integer,
    ledig integer,
    verheiratet integer,
    verwitwet integer,
    geschieden integer,
    eingetrlebenspartnerschaft integer,
    eingetrlebenspartverstorben integer,
    eingetrlebenspartaufgehoben integer,
    ohneangabe integer,
    geom public.geometry(Point,3857)
);


--
-- Name: familienstand_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.familienstand_10km (
    gitter_id_10km text,
    insgesamt_bevoelkerung integer,
    ledig integer,
    verheiratet integer,
    verwitwet integer,
    geschieden integer,
    eingetrlebenspartnerschaft integer,
    eingetrlebenspartverstorben integer,
    eingetrlebenspartaufgehoben integer,
    ohneangabe integer,
    geom public.geometry(Point,3857)
);


--
-- Name: familienstand_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.familienstand_1km (
    gitter_id_1km text,
    insgesamt_bevoelkerung integer,
    ledig integer,
    verheiratet integer,
    verwitwet integer,
    geschieden integer,
    eingetrlebenspartnerschaft integer,
    eingetrlebenspartverstorben integer,
    eingetrlebenspartaufgehoben integer,
    ohneangabe integer,
    geom public.geometry(Point,3857)
);


--
-- Name: flaeche_der_wohnung_10m2_intervalle_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.flaeche_der_wohnung_10m2_intervalle_100m (
    gitter_id_100m text,
    insgesamt_wohnungen integer,
    unter30 integer,
    _30bis39 integer,
    _40bis49 integer,
    _50bis59 integer,
    _60bis69 integer,
    _70bis79 integer,
    _80bis89 integer,
    _90bis99 integer,
    _100bis109 integer,
    _110bis119 integer,
    _120bis129 integer,
    _130bis139 integer,
    _140bis149 integer,
    _150bis159 integer,
    _160bis169 integer,
    _170bis179 integer,
    _180undmehr integer,
    geom public.geometry(Point,3857)
);


--
-- Name: flaeche_der_wohnung_10m2_intervalle_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.flaeche_der_wohnung_10m2_intervalle_10km (
    gitter_id_10km text,
    insgesamt_wohnungen integer,
    unter30 integer,
    _30bis39 integer,
    _40bis49 integer,
    _50bis59 integer,
    _60bis69 integer,
    _70bis79 integer,
    _80bis89 integer,
    _90bis99 integer,
    _100bis109 integer,
    _110bis119 integer,
    _120bis129 integer,
    _130bis139 integer,
    _140bis149 integer,
    _150bis159 integer,
    _160bis169 integer,
    _170bis179 integer,
    _180undmehr integer,
    geom public.geometry(Point,3857)
);


--
-- Name: flaeche_der_wohnung_10m2_intervalle_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.flaeche_der_wohnung_10m2_intervalle_1km (
    gitter_id_1km text,
    insgesamt_wohnungen integer,
    unter30 integer,
    _30bis39 integer,
    _40bis49 integer,
    _50bis59 integer,
    _60bis69 integer,
    _70bis79 integer,
    _80bis89 integer,
    _90bis99 integer,
    _100bis109 integer,
    _110bis119 integer,
    _120bis129 integer,
    _130bis139 integer,
    _140bis149 integer,
    _150bis159 integer,
    _160bis169 integer,
    _170bis179 integer,
    _180undmehr integer,
    geom public.geometry(Point,3857)
);


--
-- Name: geb_gebaeudetyp_groesse_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.geb_gebaeudetyp_groesse_100m (
    gitter_id_100m text,
    insgesamt_gebaeude integer,
    freiefh integer,
    efh_dhh integer,
    efh_reihenhaus integer,
    freist_zfh integer,
    zfh_dhh integer,
    zfh_reihenhaus integer,
    mfh_3bis6wohnungen integer,
    mfh_7bis12wohnungen integer,
    mfh_13undmehrwohnungen integer,
    anderergebaeudetyp integer,
    geom public.geometry(Point,3857)
);


--
-- Name: geb_gebaeudetyp_groesse_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.geb_gebaeudetyp_groesse_10km (
    gitter_id_10km text,
    insgesamt_gebaeude integer,
    freiefh integer,
    efh_dhh integer,
    efh_reihenhaus integer,
    freist_zfh integer,
    zfh_dhh integer,
    zfh_reihenhaus integer,
    mfh_3bis6wohnungen integer,
    mfh_7bis12wohnungen integer,
    mfh_13undmehrwohnungen integer,
    anderergebaeudetyp integer,
    geom public.geometry(Point,3857)
);


--
-- Name: geb_gebaeudetyp_groesse_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.geb_gebaeudetyp_groesse_1km (
    gitter_id_1km text,
    insgesamt_gebaeude integer,
    freiefh integer,
    efh_dhh integer,
    efh_reihenhaus integer,
    freist_zfh integer,
    zfh_dhh integer,
    zfh_reihenhaus integer,
    mfh_3bis6wohnungen integer,
    mfh_7bis12wohnungen integer,
    mfh_13undmehrwohnungen integer,
    anderergebaeudetyp integer,
    geom public.geometry(Point,3857)
);


--
-- Name: gebaeude_nach_anzahl_der_wohnungen_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.gebaeude_nach_anzahl_der_wohnungen_100m (
    gitter_id_100m text,
    insgesamt_gebaeude integer,
    _1_wohnung integer,
    _2_wohnungen integer,
    _3bis6_wohnungen integer,
    _7bis12_wohnungen integer,
    _13undmehr_wohnungen integer,
    geom public.geometry(Point,3857)
);


--
-- Name: gebaeude_nach_anzahl_der_wohnungen_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.gebaeude_nach_anzahl_der_wohnungen_10km (
    gitter_id_10km text,
    insgesamt_gebaeude integer,
    _1_wohnung integer,
    _2_wohnungen integer,
    _3bis6_wohnungen integer,
    _7bis12_wohnungen integer,
    _13undmehr_wohnungen integer,
    geom public.geometry(Point,3857)
);


--
-- Name: gebaeude_nach_anzahl_der_wohnungen_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.gebaeude_nach_anzahl_der_wohnungen_1km (
    gitter_id_1km text,
    insgesamt_gebaeude integer,
    _1_wohnung integer,
    _2_wohnungen integer,
    _3bis6_wohnungen integer,
    _7bis12_wohnungen integer,
    _13undmehr_wohnungen integer,
    geom public.geometry(Point,3857)
);


--
-- Name: gebaeude_nach_baujahr_in_mz_klassen_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.gebaeude_nach_baujahr_in_mz_klassen_100m (
    gitter_id_100m text,
    insgesamt_gebaeude integer,
    vor1919 integer,
    a1919bis1948 integer,
    a1949bis1978 integer,
    a1979bis1990 integer,
    a1991bis2000 integer,
    a2001bis2010 integer,
    a2011bis2019 integer,
    a2020undspaeter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: gebaeude_nach_baujahr_in_mz_klassen_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.gebaeude_nach_baujahr_in_mz_klassen_10km (
    gitter_id_10km text,
    insgesamt_gebaeude integer,
    vor1919 integer,
    a1919bis1948 integer,
    a1949bis1978 integer,
    a1979bis1990 integer,
    a1991bis2000 integer,
    a2001bis2010 integer,
    a2011bis2019 integer,
    a2020undspaeter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: gebaeude_nach_baujahr_in_mz_klassen_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.gebaeude_nach_baujahr_in_mz_klassen_1km (
    gitter_id_1km text,
    insgesamt_gebaeude integer,
    vor1919 integer,
    a1919bis1948 integer,
    a1949bis1978 integer,
    a1979bis1990 integer,
    a1991bis2000 integer,
    a2001bis2010 integer,
    a2011bis2019 integer,
    a2020undspaeter integer,
    geom public.geometry(Point,3857)
);


--
-- Name: gebaeude_nach_energietraeger_der_heizung_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.gebaeude_nach_energietraeger_der_heizung_100m (
    gitter_id_100m text,
    insgesamt_energietraeger integer,
    gas integer,
    heizoel integer,
    holz_holzpellets integer,
    biomasse_biogas integer,
    solar_geothermie_waermepumpen integer,
    strom integer,
    kohle integer,
    fernwaerme integer,
    kein_energietraeger integer,
    geom public.geometry(Point,3857)
);


--
-- Name: gebaeude_nach_energietraeger_der_heizung_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.gebaeude_nach_energietraeger_der_heizung_10km (
    gitter_id_10km text,
    insgesamt_energietraeger integer,
    gas integer,
    heizoel integer,
    holz_holzpellets integer,
    biomasse_biogas integer,
    solar_geothermie_waermepumpen integer,
    strom integer,
    kohle integer,
    fernwaerme integer,
    kein_energietraeger integer,
    geom public.geometry(Point,3857)
);


--
-- Name: gebaeude_nach_energietraeger_der_heizung_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.gebaeude_nach_energietraeger_der_heizung_1km (
    gitter_id_1km text,
    insgesamt_energietraeger integer,
    gas integer,
    heizoel integer,
    holz_holzpellets integer,
    biomasse_biogas integer,
    solar_geothermie_waermepumpen integer,
    strom integer,
    kohle integer,
    fernwaerme integer,
    kein_energietraeger integer,
    geom public.geometry(Point,3857)
);


--
-- Name: gebaeude_nach_ueberwiegender_heizungsart_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.gebaeude_nach_ueberwiegender_heizungsart_100m (
    gitter_id_100m text,
    insgesamt_heizungsart integer,
    fernheizung integer,
    etagenheizung integer,
    blockheizung integer,
    zentralheizung integer,
    einzel_mehrraumoefen integer,
    keine_heizung integer,
    geom public.geometry(Point,3857)
);


--
-- Name: gebaeude_nach_ueberwiegender_heizungsart_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.gebaeude_nach_ueberwiegender_heizungsart_10km (
    gitter_id_10km text,
    insgesamt_heizungsart integer,
    fernheizung integer,
    etagenheizung integer,
    blockheizung integer,
    zentralheizung integer,
    einzel_mehrraumoefen integer,
    keine_heizung integer,
    geom public.geometry(Point,3857)
);


--
-- Name: gebaeude_nach_ueberwiegender_heizungsart_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.gebaeude_nach_ueberwiegender_heizungsart_1km (
    gitter_id_1km text,
    insgesamt_heizungsart integer,
    fernheizung integer,
    etagenheizung integer,
    blockheizung integer,
    zentralheizung integer,
    einzel_mehrraumoefen integer,
    keine_heizung integer,
    geom public.geometry(Point,3857)
);


--
-- Name: geburtsland_gruppen_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.geburtsland_gruppen_100m (
    gitter_id_100m text,
    insgesamt_bevoelkerung integer,
    deutschland integer,
    ausland_sonstige integer,
    eu27_land integer,
    sonstiges_europa integer,
    sonstige_welt integer,
    sonstige integer,
    geom public.geometry(Point,3857)
);


--
-- Name: geburtsland_gruppen_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.geburtsland_gruppen_10km (
    gitter_id_10km text,
    insgesamt_bevoelkerung integer,
    deutschland integer,
    ausland_sonstige integer,
    eu27_land integer,
    sonstiges_europa integer,
    sonstige_welt integer,
    sonstige integer,
    geom public.geometry(Point,3857)
);


--
-- Name: geburtsland_gruppen_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.geburtsland_gruppen_1km (
    gitter_id_1km text,
    insgesamt_bevoelkerung integer,
    deutschland integer,
    ausland_sonstige integer,
    eu27_land integer,
    sonstiges_europa integer,
    sonstige_welt integer,
    sonstige integer,
    geom public.geometry(Point,3857)
);


--
-- Name: groesse_des_privaten_haushalts_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.groesse_des_privaten_haushalts_100m (
    gitter_id_100m text,
    insgesamt_haushalte integer,
    _1_person integer,
    _2_personen integer,
    _3_personen integer,
    _4_personen integer,
    _5_personen integer,
    _6_personen_und_mehr integer,
    geom public.geometry(Point,3857)
);


--
-- Name: groesse_des_privaten_haushalts_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.groesse_des_privaten_haushalts_10km (
    gitter_id_10km text,
    insgesamt_haushalte integer,
    _1_person integer,
    _2_personen integer,
    _3_personen integer,
    _4_personen integer,
    _5_personen integer,
    _6_personen_und_mehr integer,
    geom public.geometry(Point,3857)
);


--
-- Name: groesse_des_privaten_haushalts_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.groesse_des_privaten_haushalts_1km (
    gitter_id_1km text,
    insgesamt_haushalte integer,
    _1_person integer,
    _2_personen integer,
    _3_personen integer,
    _4_personen integer,
    _5_personen integer,
    _6_personen_und_mehr integer,
    geom public.geometry(Point,3857)
);


--
-- Name: grosse_kernfamilie_bis6undmehrpers_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.grosse_kernfamilie_bis6undmehrpers_100m (
    gitter_id_100m text,
    insgesamt_familien integer,
    a2personen integer,
    a3personen integer,
    a4personen integer,
    a5personen integer,
    a6pers_und_mehr integer,
    geom public.geometry(Point,3857)
);


--
-- Name: grosse_kernfamilie_bis6undmehrpers_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.grosse_kernfamilie_bis6undmehrpers_10km (
    gitter_id_10km text,
    insgesamt_familien integer,
    a2personen integer,
    a3personen integer,
    a4personen integer,
    a5personen integer,
    a6pers_und_mehr integer,
    geom public.geometry(Point,3857)
);


--
-- Name: grosse_kernfamilie_bis6undmehrpers_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.grosse_kernfamilie_bis6undmehrpers_1km (
    gitter_id_1km text,
    insgesamt_familien integer,
    a2personen integer,
    a3personen integer,
    a4personen integer,
    a5personen integer,
    a6pers_und_mehr integer,
    geom public.geometry(Point,3857)
);


--
-- Name: heizungsart_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.heizungsart_100m (
    gitter_id_100m text,
    insgesamt_heizungsart integer,
    fernheizung text,
    etagenheizung text,
    blockheizung text,
    zentralheizung text,
    einzel_mehrraumoefen text,
    keine_heizung text,
    geom public.geometry(Point,3857)
);


--
-- Name: heizungsart_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.heizungsart_10km (
    gitter_id_10km text,
    insgesamt_heizungsart integer,
    fernheizung integer,
    etagenheizung integer,
    blockheizung integer,
    zentralheizung integer,
    einzel_mehrraumoefen integer,
    keine_heizung integer,
    geom public.geometry(Point,3857)
);


--
-- Name: heizungsart_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.heizungsart_1km (
    gitter_id_1km text,
    insgesamt_heizungsart integer,
    fernheizung integer,
    etagenheizung integer,
    blockheizung integer,
    zentralheizung integer,
    einzel_mehrraumoefen integer,
    keine_heizung integer,
    geom public.geometry(Point,3857)
);


--
-- Name: leerstandsquote_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.leerstandsquote_100m (
    gitter_id_100m text,
    leerstandsquote double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: leerstandsquote_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.leerstandsquote_10km (
    gitter_id_10km text,
    leerstandsquote double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: leerstandsquote_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.leerstandsquote_1km (
    gitter_id_1km text,
    leerstandsquote double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: marktaktive_leerstandsquote_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.marktaktive_leerstandsquote_100m (
    gitter_id_100m text,
    marktaktive_leerstandsquote double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: marktaktive_leerstandsquote_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.marktaktive_leerstandsquote_10km (
    gitter_id_10km text,
    marktaktive_leerstandsquote double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: marktaktive_leerstandsquote_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.marktaktive_leerstandsquote_1km (
    gitter_id_1km text,
    marktaktive_leerstandsquote double precision,
    werterlaeuternde_zeichen text,
    geom public.geometry(Point,3857)
);


--
-- Name: religion_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.religion_100m (
    gitter_id_100m text,
    insgesamt_bevoelkerung integer,
    roemisch_katholisch integer,
    evangelisch integer,
    sonstige_keine_ohneangabe integer,
    geom public.geometry(Point,3857)
);


--
-- Name: religion_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.religion_10km (
    gitter_id_10km text,
    insgesamt_bevoelkerung integer,
    roemisch_katholisch integer,
    evangelisch integer,
    sonstige_keine_ohneangabe integer,
    geom public.geometry(Point,3857)
);


--
-- Name: religion_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.religion_1km (
    gitter_id_1km text,
    insgesamt_bevoelkerung integer,
    roemisch_katholisch integer,
    evangelisch integer,
    sonstige_keine_ohneangabe integer,
    geom public.geometry(Point,3857)
);


--
-- Name: seniorenstatus_eines_privaten_haushalts_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.seniorenstatus_eines_privaten_haushalts_100m (
    gitter_id_100m text,
    insgesamt_haushalte integer,
    hh_nursenioren integer,
    hh_mitsenioren integer,
    hh_ohnesenioren integer,
    geom public.geometry(Point,3857)
);


--
-- Name: seniorenstatus_eines_privaten_haushalts_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.seniorenstatus_eines_privaten_haushalts_10km (
    gitter_id_10km text,
    insgesamt_haushalte integer,
    hh_nursenioren integer,
    hh_mitsenioren integer,
    hh_ohnesenioren integer,
    geom public.geometry(Point,3857)
);


--
-- Name: seniorenstatus_eines_privaten_haushalts_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.seniorenstatus_eines_privaten_haushalts_1km (
    gitter_id_1km text,
    insgesamt_haushalte integer,
    hh_nursenioren integer,
    hh_mitsenioren integer,
    hh_ohnesenioren integer,
    geom public.geometry(Point,3857)
);


--
-- Name: staatsangehoerigkeit_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.staatsangehoerigkeit_100m (
    gitter_id_100m text,
    insgesamt_bevoelkerung integer,
    deutschland integer,
    ausland_sonstige integer,
    geom public.geometry(Point,3857)
);


--
-- Name: staatsangehoerigkeit_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.staatsangehoerigkeit_10km (
    gitter_id_10km text,
    insgesamt_bevoelkerung integer,
    deutschland integer,
    ausland_sonstige integer,
    geom public.geometry(Point,3857)
);


--
-- Name: staatsangehoerigkeit_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.staatsangehoerigkeit_1km (
    gitter_id_1km text,
    insgesamt_bevoelkerung integer,
    deutschland integer,
    ausland_sonstige integer,
    geom public.geometry(Point,3857)
);


--
-- Name: staatsangehoerigkeit_gruppen_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.staatsangehoerigkeit_gruppen_100m (
    gitter_id_100m text,
    insgesamt_bevoelkerung integer,
    deutschland integer,
    ausland_sonstige integer,
    eu27_land integer,
    sonstiges_europa integer,
    sonstige_welt integer,
    sonstige integer,
    geom public.geometry(Point,3857)
);


--
-- Name: staatsangehoerigkeit_gruppen_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.staatsangehoerigkeit_gruppen_10km (
    gitter_id_10km text,
    insgesamt_bevoelkerung integer,
    deutschland integer,
    ausland_sonstige integer,
    eu27_land integer,
    sonstiges_europa integer,
    sonstige_welt integer,
    sonstige integer,
    geom public.geometry(Point,3857)
);


--
-- Name: staatsangehoerigkeit_gruppen_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.staatsangehoerigkeit_gruppen_1km (
    gitter_id_1km text,
    insgesamt_bevoelkerung integer,
    deutschland integer,
    ausland_sonstige integer,
    eu27_land integer,
    sonstiges_europa integer,
    sonstige_welt integer,
    sonstige integer,
    geom public.geometry(Point,3857)
);


--
-- Name: typ_der_kernfamilie_nach_kindern_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.typ_der_kernfamilie_nach_kindern_100m (
    gitter_id_100m text,
    insgesamt_familie integer,
    ehep_ohnekind integer,
    ehep_mind_1kind_unter18 integer,
    ehep_kinder_ab18 integer,
    eingetrlp_ohnekind integer,
    eingetrlp_mind_1kind_unter18 integer,
    eingetrlp_kinder_ab18 integer,
    nichtehellg_ohnekind integer,
    nichtehellg_mind_1kind_unter18 integer,
    nichtehellg_kinder_ab18 integer,
    vater_mind_1kind_unter18 integer,
    vater_kinder_ab18 integer,
    mutter_mind_1kind_unter18 integer,
    mutter_kinder_ab18 integer,
    geom public.geometry(Point,3857)
);


--
-- Name: typ_der_kernfamilie_nach_kindern_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.typ_der_kernfamilie_nach_kindern_10km (
    gitter_id_10km text,
    insgesamt_familie integer,
    ehep_ohnekind integer,
    ehep_mind_1kind_unter18 integer,
    ehep_kinder_ab18 integer,
    eingetrlp_ohnekind integer,
    eingetrlp_mind_1kind_unter18 integer,
    eingetrlp_kinder_ab18 integer,
    nichtehellg_ohnekind integer,
    nichtehellg_mind_1kind_unter18 integer,
    nichtehellg_kinder_ab18 integer,
    vater_mind_1kind_unter18 integer,
    vater_kinder_ab18 integer,
    mutter_mind_1kind_unter18 integer,
    mutter_kinder_ab18 integer,
    geom public.geometry(Point,3857)
);


--
-- Name: typ_der_kernfamilie_nach_kindern_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.typ_der_kernfamilie_nach_kindern_1km (
    gitter_id_1km text,
    insgesamt_familie integer,
    ehep_ohnekind integer,
    ehep_mind_1kind_unter18 integer,
    ehep_kinder_ab18 integer,
    eingetrlp_ohnekind integer,
    eingetrlp_mind_1kind_unter18 integer,
    eingetrlp_kinder_ab18 integer,
    nichtehellg_ohnekind integer,
    nichtehellg_mind_1kind_unter18 integer,
    nichtehellg_kinder_ab18 integer,
    vater_mind_1kind_unter18 integer,
    vater_kinder_ab18 integer,
    mutter_mind_1kind_unter18 integer,
    mutter_kinder_ab18 integer,
    geom public.geometry(Point,3857)
);


--
-- Name: typ_priv_hh_familie_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.typ_priv_hh_familie_100m (
    gitter_id_100m text,
    insgesamt_haushalte integer,
    einpershh_singlehh integer,
    paare_ohnekind integer,
    paare_mitkind integer,
    alleinerziehende integer,
    mehrpershhohnekernfam integer,
    geom public.geometry(Point,3857)
);


--
-- Name: typ_priv_hh_familie_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.typ_priv_hh_familie_10km (
    gitter_id_10km text,
    insgesamt_haushalte integer,
    einpershh_singlehh integer,
    paare_ohnekind integer,
    paare_mitkind integer,
    alleinerziehende integer,
    mehrpershhohnekernfam integer,
    geom public.geometry(Point,3857)
);


--
-- Name: typ_priv_hh_familie_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.typ_priv_hh_familie_1km (
    gitter_id_1km text,
    insgesamt_haushalte integer,
    einpershh_singlehh integer,
    paare_ohnekind integer,
    paare_mitkind integer,
    alleinerziehende integer,
    mehrpershhohnekernfam integer,
    geom public.geometry(Point,3857)
);


--
-- Name: typ_priv_hh_lebensform_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.typ_priv_hh_lebensform_100m (
    gitter_id_100m text,
    insgesamt_haushalte integer,
    einpershh_singlehh integer,
    ehepaare integer,
    eingetrlebensp integer,
    nichtehellebensg integer,
    alleinerzmuetter integer,
    alleinerzvaeter integer,
    mehrpershhohnekernfam integer,
    geom public.geometry(Point,3857)
);


--
-- Name: typ_priv_hh_lebensform_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.typ_priv_hh_lebensform_10km (
    gitter_id_10km text,
    insgesamt_haushalte integer,
    einpershh_singlehh integer,
    ehepaare integer,
    eingetrlebensp integer,
    nichtehellebensg integer,
    alleinerzmuetter integer,
    alleinerzvaeter integer,
    mehrpershhohnekernfam integer,
    geom public.geometry(Point,3857)
);


--
-- Name: typ_priv_hh_lebensform_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.typ_priv_hh_lebensform_1km (
    gitter_id_1km text,
    insgesamt_haushalte integer,
    einpershh_singlehh integer,
    ehepaare integer,
    eingetrlebensp integer,
    nichtehellebensg integer,
    alleinerzmuetter integer,
    alleinerzvaeter integer,
    mehrpershhohnekernfam integer,
    geom public.geometry(Point,3857)
);


--
-- Name: wohnung_gebaeudetyp_groesse_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.wohnung_gebaeudetyp_groesse_100m (
    gitter_id_100m text,
    insgesamt_wohnungen integer,
    freiefh integer,
    efh_dhh integer,
    efh_reihenhaus integer,
    freist_zfh integer,
    zfh_dhh integer,
    zfh_reihenhaus integer,
    mfh_3bis6wohnungen integer,
    mfh_7bis12wohnungen integer,
    mfh_13undmehrwohnungen integer,
    anderergebaeudetyp integer,
    geom public.geometry(Point,3857)
);


--
-- Name: wohnung_gebaeudetyp_groesse_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.wohnung_gebaeudetyp_groesse_10km (
    gitter_id_10km text,
    insgesamt_wohnungen integer,
    freiefh integer,
    efh_dhh integer,
    efh_reihenhaus integer,
    freist_zfh integer,
    zfh_dhh integer,
    zfh_reihenhaus integer,
    mfh_3bis6wohnungen integer,
    mfh_7bis12wohnungen integer,
    mfh_13undmehrwohnungen integer,
    anderergebaeudetyp integer,
    geom public.geometry(Point,3857)
);


--
-- Name: wohnung_gebaeudetyp_groesse_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.wohnung_gebaeudetyp_groesse_1km (
    gitter_id_1km text,
    insgesamt_wohnungen integer,
    freiefh integer,
    efh_dhh integer,
    efh_reihenhaus integer,
    freist_zfh integer,
    zfh_dhh integer,
    zfh_reihenhaus integer,
    mfh_3bis6wohnungen integer,
    mfh_7bis12wohnungen integer,
    mfh_13undmehrwohnungen integer,
    anderergebaeudetyp integer,
    geom public.geometry(Point,3857)
);


--
-- Name: wohnungen_nach_zahl_der_raeume_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.wohnungen_nach_zahl_der_raeume_100m (
    gitter_id_100m text,
    insgesamt_wohnungen integer,
    _1raum integer,
    _2raeume integer,
    _3raeume integer,
    _4raeume integer,
    _5raeume integer,
    _6raeume integer,
    _7undmehrraeume integer,
    geom public.geometry(Point,3857)
);


--
-- Name: wohnungen_nach_zahl_der_raeume_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.wohnungen_nach_zahl_der_raeume_10km (
    gitter_id_10km text,
    insgesamt_wohnungen integer,
    _1raum integer,
    _2raeume integer,
    _3raeume integer,
    _4raeume integer,
    _5raeume integer,
    _6raeume integer,
    _7undmehrraeume integer,
    geom public.geometry(Point,3857)
);


--
-- Name: wohnungen_nach_zahl_der_raeume_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.wohnungen_nach_zahl_der_raeume_1km (
    gitter_id_1km text,
    insgesamt_wohnungen integer,
    _1raum integer,
    _2raeume integer,
    _3raeume integer,
    _4raeume integer,
    _5raeume integer,
    _6raeume integer,
    _7undmehrraeume integer,
    geom public.geometry(Point,3857)
);


--
-- Name: zahl_der_staatsangehoerigkeiten_100m; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.zahl_der_staatsangehoerigkeiten_100m (
    gitter_id_100m text,
    insgesamt_bevoelkerung integer,
    einestaatsang integer,
    mehrere_deutsch_und_auslaendisch integer,
    mehrere_nur_auslaendisch integer,
    nicht_bekannt integer,
    geom public.geometry(Point,3857)
);


--
-- Name: zahl_der_staatsangehoerigkeiten_10km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.zahl_der_staatsangehoerigkeiten_10km (
    gitter_id_10km text,
    insgesamt_bevoelkerung integer,
    einestaatsang integer,
    mehrere_deutsch_und_auslaendisch integer,
    mehrere_nur_auslaendisch integer,
    nicht_bekannt integer,
    geom public.geometry(Point,3857)
);


--
-- Name: zahl_der_staatsangehoerigkeiten_1km; Type: TABLE; Schema: zensus_2022; Owner: -
--

CREATE TABLE zensus_2022.zahl_der_staatsangehoerigkeiten_1km (
    gitter_id_1km text,
    insgesamt_bevoelkerung integer,
    einestaatsang integer,
    mehrere_deutsch_und_auslaendisch integer,
    mehrere_nur_auslaendisch integer,
    nicht_bekannt integer,
    geom public.geometry(Point,3857)
);


--
-- Name: osm2pgsql_properties osm2pgsql_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.osm2pgsql_properties
    ADD CONSTRAINT osm2pgsql_properties_pkey PRIMARY KEY (property);


--
-- Name: planet_osm_nodes planet_osm_nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_osm_nodes
    ADD CONSTRAINT planet_osm_nodes_pkey PRIMARY KEY (id);


--
-- Name: planet_osm_rels planet_osm_rels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_osm_rels
    ADD CONSTRAINT planet_osm_rels_pkey PRIMARY KEY (id);


--
-- Name: planet_osm_ways planet_osm_ways_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planet_osm_ways
    ADD CONSTRAINT planet_osm_ways_pkey PRIMARY KEY (id);


--
-- Name: planet_osm_line_osm_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX planet_osm_line_osm_id_idx ON public.planet_osm_line USING btree (osm_id);


--
-- Name: planet_osm_line_way_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX planet_osm_line_way_idx ON public.planet_osm_line USING gist (way);


--
-- Name: planet_osm_point_osm_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX planet_osm_point_osm_id_idx ON public.planet_osm_point USING btree (osm_id);


--
-- Name: planet_osm_point_way_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX planet_osm_point_way_idx ON public.planet_osm_point USING gist (way);


--
-- Name: planet_osm_polygon_osm_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX planet_osm_polygon_osm_id_idx ON public.planet_osm_polygon USING btree (osm_id);


--
-- Name: planet_osm_polygon_way_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX planet_osm_polygon_way_idx ON public.planet_osm_polygon USING gist (way);


--
-- Name: planet_osm_rels_node_members_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX planet_osm_rels_node_members_idx ON public.planet_osm_rels USING gin (public.planet_osm_member_ids(members, 'N'::character(1))) WITH (fastupdate=off);


--
-- Name: planet_osm_rels_way_members_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX planet_osm_rels_way_members_idx ON public.planet_osm_rels USING gin (public.planet_osm_member_ids(members, 'W'::character(1))) WITH (fastupdate=off);


--
-- Name: planet_osm_roads_osm_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX planet_osm_roads_osm_id_idx ON public.planet_osm_roads USING btree (osm_id);


--
-- Name: planet_osm_roads_way_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX planet_osm_roads_way_idx ON public.planet_osm_roads USING gist (way);


--
-- Name: planet_osm_ways_nodes_bucket_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX planet_osm_ways_nodes_bucket_idx ON public.planet_osm_ways USING gin (public.planet_osm_index_bucket(nodes)) WITH (fastupdate=off);


--
-- Name: alter_in_10er_jahresgruppen_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX alter_in_10er_jahresgruppen_100m_geom_idx ON zensus_2022.alter_in_10er_jahresgruppen_100m USING gist (geom);


--
-- Name: alter_in_10er_jahresgruppen_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX alter_in_10er_jahresgruppen_10km_geom_idx ON zensus_2022.alter_in_10er_jahresgruppen_10km USING gist (geom);


--
-- Name: alter_in_10er_jahresgruppen_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX alter_in_10er_jahresgruppen_1km_geom_idx ON zensus_2022.alter_in_10er_jahresgruppen_1km USING gist (geom);


--
-- Name: alter_in_5_altersklassen_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX alter_in_5_altersklassen_100m_geom_idx ON zensus_2022.alter_in_5_altersklassen_100m USING gist (geom);


--
-- Name: alter_in_5_altersklassen_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX alter_in_5_altersklassen_10km_geom_idx ON zensus_2022.alter_in_5_altersklassen_10km USING gist (geom);


--
-- Name: alter_in_5_altersklassen_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX alter_in_5_altersklassen_1km_geom_idx ON zensus_2022.alter_in_5_altersklassen_1km USING gist (geom);


--
-- Name: alter_infr_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX alter_infr_100m_geom_idx ON zensus_2022.alter_infr_100m USING gist (geom);


--
-- Name: alter_infr_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX alter_infr_10km_geom_idx ON zensus_2022.alter_infr_10km USING gist (geom);


--
-- Name: alter_infr_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX alter_infr_1km_geom_idx ON zensus_2022.alter_infr_1km USING gist (geom);


--
-- Name: anteil_auslaender_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX anteil_auslaender_100m_geom_idx ON zensus_2022.anteil_auslaender_100m USING gist (geom);


--
-- Name: anteil_auslaender_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX anteil_auslaender_10km_geom_idx ON zensus_2022.anteil_auslaender_10km USING gist (geom);


--
-- Name: anteil_auslaender_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX anteil_auslaender_1km_geom_idx ON zensus_2022.anteil_auslaender_1km USING gist (geom);


--
-- Name: anteil_ueber_65_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX anteil_ueber_65_100m_geom_idx ON zensus_2022.anteil_ueber_65_100m USING gist (geom);


--
-- Name: anteil_ueber_65_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX anteil_ueber_65_10km_geom_idx ON zensus_2022.anteil_ueber_65_10km USING gist (geom);


--
-- Name: anteil_ueber_65_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX anteil_ueber_65_1km_geom_idx ON zensus_2022.anteil_ueber_65_1km USING gist (geom);


--
-- Name: anteil_unter_18_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX anteil_unter_18_100m_geom_idx ON zensus_2022.anteil_unter_18_100m USING gist (geom);


--
-- Name: anteil_unter_18_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX anteil_unter_18_10km_geom_idx ON zensus_2022.anteil_unter_18_10km USING gist (geom);


--
-- Name: anteil_unter_18_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX anteil_unter_18_1km_geom_idx ON zensus_2022.anteil_unter_18_1km USING gist (geom);


--
-- Name: auslaenderanteil_ab18_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX auslaenderanteil_ab18_100m_geom_idx ON zensus_2022.auslaenderanteil_ab18_100m USING gist (geom);


--
-- Name: auslaenderanteil_ab18_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX auslaenderanteil_ab18_10km_geom_idx ON zensus_2022.auslaenderanteil_ab18_10km USING gist (geom);


--
-- Name: auslaenderanteil_ab18_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX auslaenderanteil_ab18_1km_geom_idx ON zensus_2022.auslaenderanteil_ab18_1km USING gist (geom);


--
-- Name: auslaenderanteil_eu_neu_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX auslaenderanteil_eu_neu_100m_geom_idx ON zensus_2022.auslaenderanteil_eu_neu_100m USING gist (geom);


--
-- Name: baujahr_jz_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX baujahr_jz_100m_geom_idx ON zensus_2022.baujahr_jz_100m USING gist (geom);


--
-- Name: baujahr_jz_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX baujahr_jz_10km_geom_idx ON zensus_2022.baujahr_jz_10km USING gist (geom);


--
-- Name: baujahr_jz_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX baujahr_jz_1km_geom_idx ON zensus_2022.baujahr_jz_1km USING gist (geom);


--
-- Name: baujahresklassen_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX baujahresklassen_100m_geom_idx ON zensus_2022.baujahresklassen_100m USING gist (geom);


--
-- Name: baujahresklassen_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX baujahresklassen_1km_geom_idx ON zensus_2022.baujahresklassen_1km USING gist (geom);


--
-- Name: bevoelkerungszahl_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX bevoelkerungszahl_100m_geom_idx ON zensus_2022.bevoelkerungszahl_100m USING gist (geom);


--
-- Name: bevoelkerungszahl_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX bevoelkerungszahl_10km_geom_idx ON zensus_2022.bevoelkerungszahl_10km USING gist (geom);


--
-- Name: bevoelkerungszahl_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX bevoelkerungszahl_1km_geom_idx ON zensus_2022.bevoelkerungszahl_1km USING gist (geom);


--
-- Name: deutsche_staatsangehoerige_ab18_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX deutsche_staatsangehoerige_ab18_100m_geom_idx ON zensus_2022.deutsche_staatsangehoerige_ab18_100m USING gist (geom);


--
-- Name: deutsche_staatsangehoerige_ab18_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX deutsche_staatsangehoerige_ab18_10km_geom_idx ON zensus_2022.deutsche_staatsangehoerige_ab18_10km USING gist (geom);


--
-- Name: deutsche_staatsangehoerige_ab18_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX deutsche_staatsangehoerige_ab18_1km_geom_idx ON zensus_2022.deutsche_staatsangehoerige_ab18_1km USING gist (geom);


--
-- Name: durchschn_flaeche_je_bewohner_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_flaeche_je_bewohner_100m_geom_idx ON zensus_2022.durchschn_flaeche_je_bewohner_100m USING gist (geom);


--
-- Name: durchschn_flaeche_je_bewohner_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_flaeche_je_bewohner_10km_geom_idx ON zensus_2022.durchschn_flaeche_je_bewohner_10km USING gist (geom);


--
-- Name: durchschn_flaeche_je_bewohner_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_flaeche_je_bewohner_1km_geom_idx ON zensus_2022.durchschn_flaeche_je_bewohner_1km USING gist (geom);


--
-- Name: durchschn_flaeche_je_wohnung_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_flaeche_je_wohnung_100m_geom_idx ON zensus_2022.durchschn_flaeche_je_wohnung_100m USING gist (geom);


--
-- Name: durchschn_flaeche_je_wohnung_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_flaeche_je_wohnung_10km_geom_idx ON zensus_2022.durchschn_flaeche_je_wohnung_10km USING gist (geom);


--
-- Name: durchschn_flaeche_je_wohnung_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_flaeche_je_wohnung_1km_geom_idx ON zensus_2022.durchschn_flaeche_je_wohnung_1km USING gist (geom);


--
-- Name: durchschn_haushaltsgroesse_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_haushaltsgroesse_100m_geom_idx ON zensus_2022.durchschn_haushaltsgroesse_100m USING gist (geom);


--
-- Name: durchschn_haushaltsgroesse_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_haushaltsgroesse_10km_geom_idx ON zensus_2022.durchschn_haushaltsgroesse_10km USING gist (geom);


--
-- Name: durchschn_haushaltsgroesse_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_haushaltsgroesse_1km_geom_idx ON zensus_2022.durchschn_haushaltsgroesse_1km USING gist (geom);


--
-- Name: durchschn_nettokaltmiete_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_nettokaltmiete_100m_geom_idx ON zensus_2022.durchschn_nettokaltmiete_100m USING gist (geom);


--
-- Name: durchschn_nettokaltmiete_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_nettokaltmiete_10km_geom_idx ON zensus_2022.durchschn_nettokaltmiete_10km USING gist (geom);


--
-- Name: durchschn_nettokaltmiete_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_nettokaltmiete_1km_geom_idx ON zensus_2022.durchschn_nettokaltmiete_1km USING gist (geom);


--
-- Name: durchschn_nettokaltmiete_anzahl_der_wohnungen_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_nettokaltmiete_anzahl_der_wohnungen_100m_geom_idx ON zensus_2022.durchschn_nettokaltmiete_anzahl_der_wohnungen_100m USING gist (geom);


--
-- Name: durchschn_nettokaltmiete_anzahl_der_wohnungen_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_nettokaltmiete_anzahl_der_wohnungen_10km_geom_idx ON zensus_2022.durchschn_nettokaltmiete_anzahl_der_wohnungen_10km USING gist (geom);


--
-- Name: durchschn_nettokaltmiete_anzahl_der_wohnungen_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschn_nettokaltmiete_anzahl_der_wohnungen_1km_geom_idx ON zensus_2022.durchschn_nettokaltmiete_anzahl_der_wohnungen_1km USING gist (geom);


--
-- Name: durchschnittsalter_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschnittsalter_100m_geom_idx ON zensus_2022.durchschnittsalter_100m USING gist (geom);


--
-- Name: durchschnittsalter_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschnittsalter_10km_geom_idx ON zensus_2022.durchschnittsalter_10km USING gist (geom);


--
-- Name: durchschnittsalter_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX durchschnittsalter_1km_geom_idx ON zensus_2022.durchschnittsalter_1km USING gist (geom);


--
-- Name: eigentuemerquote_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX eigentuemerquote_100m_geom_idx ON zensus_2022.eigentuemerquote_100m USING gist (geom);


--
-- Name: eigentuemerquote_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX eigentuemerquote_10km_geom_idx ON zensus_2022.eigentuemerquote_10km USING gist (geom);


--
-- Name: eigentuemerquote_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX eigentuemerquote_1km_geom_idx ON zensus_2022.eigentuemerquote_1km USING gist (geom);


--
-- Name: energietraeger_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX energietraeger_100m_geom_idx ON zensus_2022.energietraeger_100m USING gist (geom);


--
-- Name: energietraeger_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX energietraeger_10km_geom_idx ON zensus_2022.energietraeger_10km USING gist (geom);


--
-- Name: energietraeger_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX energietraeger_1km_geom_idx ON zensus_2022.energietraeger_1km USING gist (geom);


--
-- Name: familienstand_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX familienstand_100m_geom_idx ON zensus_2022.familienstand_100m USING gist (geom);


--
-- Name: familienstand_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX familienstand_10km_geom_idx ON zensus_2022.familienstand_10km USING gist (geom);


--
-- Name: familienstand_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX familienstand_1km_geom_idx ON zensus_2022.familienstand_1km USING gist (geom);


--
-- Name: flaeche_der_wohnung_10m2_intervalle_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX flaeche_der_wohnung_10m2_intervalle_100m_geom_idx ON zensus_2022.flaeche_der_wohnung_10m2_intervalle_100m USING gist (geom);


--
-- Name: flaeche_der_wohnung_10m2_intervalle_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX flaeche_der_wohnung_10m2_intervalle_10km_geom_idx ON zensus_2022.flaeche_der_wohnung_10m2_intervalle_10km USING gist (geom);


--
-- Name: flaeche_der_wohnung_10m2_intervalle_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX flaeche_der_wohnung_10m2_intervalle_1km_geom_idx ON zensus_2022.flaeche_der_wohnung_10m2_intervalle_1km USING gist (geom);


--
-- Name: geb_gebaeudetyp_groesse_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX geb_gebaeudetyp_groesse_100m_geom_idx ON zensus_2022.geb_gebaeudetyp_groesse_100m USING gist (geom);


--
-- Name: geb_gebaeudetyp_groesse_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX geb_gebaeudetyp_groesse_10km_geom_idx ON zensus_2022.geb_gebaeudetyp_groesse_10km USING gist (geom);


--
-- Name: geb_gebaeudetyp_groesse_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX geb_gebaeudetyp_groesse_1km_geom_idx ON zensus_2022.geb_gebaeudetyp_groesse_1km USING gist (geom);


--
-- Name: gebaeude_nach_anzahl_der_wohnungen_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX gebaeude_nach_anzahl_der_wohnungen_100m_geom_idx ON zensus_2022.gebaeude_nach_anzahl_der_wohnungen_100m USING gist (geom);


--
-- Name: gebaeude_nach_anzahl_der_wohnungen_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX gebaeude_nach_anzahl_der_wohnungen_10km_geom_idx ON zensus_2022.gebaeude_nach_anzahl_der_wohnungen_10km USING gist (geom);


--
-- Name: gebaeude_nach_anzahl_der_wohnungen_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX gebaeude_nach_anzahl_der_wohnungen_1km_geom_idx ON zensus_2022.gebaeude_nach_anzahl_der_wohnungen_1km USING gist (geom);


--
-- Name: gebaeude_nach_baujahr_in_mz_klassen_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX gebaeude_nach_baujahr_in_mz_klassen_100m_geom_idx ON zensus_2022.gebaeude_nach_baujahr_in_mz_klassen_100m USING gist (geom);


--
-- Name: gebaeude_nach_baujahr_in_mz_klassen_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX gebaeude_nach_baujahr_in_mz_klassen_10km_geom_idx ON zensus_2022.gebaeude_nach_baujahr_in_mz_klassen_10km USING gist (geom);


--
-- Name: gebaeude_nach_baujahr_in_mz_klassen_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX gebaeude_nach_baujahr_in_mz_klassen_1km_geom_idx ON zensus_2022.gebaeude_nach_baujahr_in_mz_klassen_1km USING gist (geom);


--
-- Name: gebaeude_nach_energietraeger_der_heizung_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX gebaeude_nach_energietraeger_der_heizung_100m_geom_idx ON zensus_2022.gebaeude_nach_energietraeger_der_heizung_100m USING gist (geom);


--
-- Name: gebaeude_nach_energietraeger_der_heizung_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX gebaeude_nach_energietraeger_der_heizung_10km_geom_idx ON zensus_2022.gebaeude_nach_energietraeger_der_heizung_10km USING gist (geom);


--
-- Name: gebaeude_nach_energietraeger_der_heizung_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX gebaeude_nach_energietraeger_der_heizung_1km_geom_idx ON zensus_2022.gebaeude_nach_energietraeger_der_heizung_1km USING gist (geom);


--
-- Name: gebaeude_nach_ueberwiegender_heizungsart_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX gebaeude_nach_ueberwiegender_heizungsart_100m_geom_idx ON zensus_2022.gebaeude_nach_ueberwiegender_heizungsart_100m USING gist (geom);


--
-- Name: gebaeude_nach_ueberwiegender_heizungsart_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX gebaeude_nach_ueberwiegender_heizungsart_10km_geom_idx ON zensus_2022.gebaeude_nach_ueberwiegender_heizungsart_10km USING gist (geom);


--
-- Name: gebaeude_nach_ueberwiegender_heizungsart_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX gebaeude_nach_ueberwiegender_heizungsart_1km_geom_idx ON zensus_2022.gebaeude_nach_ueberwiegender_heizungsart_1km USING gist (geom);


--
-- Name: geburtsland_gruppen_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX geburtsland_gruppen_100m_geom_idx ON zensus_2022.geburtsland_gruppen_100m USING gist (geom);


--
-- Name: geburtsland_gruppen_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX geburtsland_gruppen_10km_geom_idx ON zensus_2022.geburtsland_gruppen_10km USING gist (geom);


--
-- Name: geburtsland_gruppen_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX geburtsland_gruppen_1km_geom_idx ON zensus_2022.geburtsland_gruppen_1km USING gist (geom);


--
-- Name: groesse_des_privaten_haushalts_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX groesse_des_privaten_haushalts_100m_geom_idx ON zensus_2022.groesse_des_privaten_haushalts_100m USING gist (geom);


--
-- Name: groesse_des_privaten_haushalts_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX groesse_des_privaten_haushalts_10km_geom_idx ON zensus_2022.groesse_des_privaten_haushalts_10km USING gist (geom);


--
-- Name: groesse_des_privaten_haushalts_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX groesse_des_privaten_haushalts_1km_geom_idx ON zensus_2022.groesse_des_privaten_haushalts_1km USING gist (geom);


--
-- Name: grosse_kernfamilie_bis6undmehrpers_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX grosse_kernfamilie_bis6undmehrpers_100m_geom_idx ON zensus_2022.grosse_kernfamilie_bis6undmehrpers_100m USING gist (geom);


--
-- Name: grosse_kernfamilie_bis6undmehrpers_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX grosse_kernfamilie_bis6undmehrpers_10km_geom_idx ON zensus_2022.grosse_kernfamilie_bis6undmehrpers_10km USING gist (geom);


--
-- Name: grosse_kernfamilie_bis6undmehrpers_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX grosse_kernfamilie_bis6undmehrpers_1km_geom_idx ON zensus_2022.grosse_kernfamilie_bis6undmehrpers_1km USING gist (geom);


--
-- Name: heizungsart_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX heizungsart_100m_geom_idx ON zensus_2022.heizungsart_100m USING gist (geom);


--
-- Name: heizungsart_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX heizungsart_10km_geom_idx ON zensus_2022.heizungsart_10km USING gist (geom);


--
-- Name: heizungsart_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX heizungsart_1km_geom_idx ON zensus_2022.heizungsart_1km USING gist (geom);


--
-- Name: leerstandsquote_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX leerstandsquote_100m_geom_idx ON zensus_2022.leerstandsquote_100m USING gist (geom);


--
-- Name: leerstandsquote_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX leerstandsquote_10km_geom_idx ON zensus_2022.leerstandsquote_10km USING gist (geom);


--
-- Name: leerstandsquote_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX leerstandsquote_1km_geom_idx ON zensus_2022.leerstandsquote_1km USING gist (geom);


--
-- Name: marktaktive_leerstandsquote_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX marktaktive_leerstandsquote_100m_geom_idx ON zensus_2022.marktaktive_leerstandsquote_100m USING gist (geom);


--
-- Name: marktaktive_leerstandsquote_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX marktaktive_leerstandsquote_10km_geom_idx ON zensus_2022.marktaktive_leerstandsquote_10km USING gist (geom);


--
-- Name: marktaktive_leerstandsquote_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX marktaktive_leerstandsquote_1km_geom_idx ON zensus_2022.marktaktive_leerstandsquote_1km USING gist (geom);


--
-- Name: religion_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX religion_100m_geom_idx ON zensus_2022.religion_100m USING gist (geom);


--
-- Name: religion_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX religion_10km_geom_idx ON zensus_2022.religion_10km USING gist (geom);


--
-- Name: religion_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX religion_1km_geom_idx ON zensus_2022.religion_1km USING gist (geom);


--
-- Name: seniorenstatus_eines_privaten_haushalts_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX seniorenstatus_eines_privaten_haushalts_100m_geom_idx ON zensus_2022.seniorenstatus_eines_privaten_haushalts_100m USING gist (geom);


--
-- Name: seniorenstatus_eines_privaten_haushalts_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX seniorenstatus_eines_privaten_haushalts_10km_geom_idx ON zensus_2022.seniorenstatus_eines_privaten_haushalts_10km USING gist (geom);


--
-- Name: seniorenstatus_eines_privaten_haushalts_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX seniorenstatus_eines_privaten_haushalts_1km_geom_idx ON zensus_2022.seniorenstatus_eines_privaten_haushalts_1km USING gist (geom);


--
-- Name: staatsangehoerigkeit_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX staatsangehoerigkeit_100m_geom_idx ON zensus_2022.staatsangehoerigkeit_100m USING gist (geom);


--
-- Name: staatsangehoerigkeit_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX staatsangehoerigkeit_10km_geom_idx ON zensus_2022.staatsangehoerigkeit_10km USING gist (geom);


--
-- Name: staatsangehoerigkeit_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX staatsangehoerigkeit_1km_geom_idx ON zensus_2022.staatsangehoerigkeit_1km USING gist (geom);


--
-- Name: staatsangehoerigkeit_gruppen_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX staatsangehoerigkeit_gruppen_100m_geom_idx ON zensus_2022.staatsangehoerigkeit_gruppen_100m USING gist (geom);


--
-- Name: staatsangehoerigkeit_gruppen_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX staatsangehoerigkeit_gruppen_10km_geom_idx ON zensus_2022.staatsangehoerigkeit_gruppen_10km USING gist (geom);


--
-- Name: staatsangehoerigkeit_gruppen_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX staatsangehoerigkeit_gruppen_1km_geom_idx ON zensus_2022.staatsangehoerigkeit_gruppen_1km USING gist (geom);


--
-- Name: typ_der_kernfamilie_nach_kindern_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX typ_der_kernfamilie_nach_kindern_100m_geom_idx ON zensus_2022.typ_der_kernfamilie_nach_kindern_100m USING gist (geom);


--
-- Name: typ_der_kernfamilie_nach_kindern_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX typ_der_kernfamilie_nach_kindern_10km_geom_idx ON zensus_2022.typ_der_kernfamilie_nach_kindern_10km USING gist (geom);


--
-- Name: typ_der_kernfamilie_nach_kindern_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX typ_der_kernfamilie_nach_kindern_1km_geom_idx ON zensus_2022.typ_der_kernfamilie_nach_kindern_1km USING gist (geom);


--
-- Name: typ_priv_hh_familie_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX typ_priv_hh_familie_100m_geom_idx ON zensus_2022.typ_priv_hh_familie_100m USING gist (geom);


--
-- Name: typ_priv_hh_familie_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX typ_priv_hh_familie_10km_geom_idx ON zensus_2022.typ_priv_hh_familie_10km USING gist (geom);


--
-- Name: typ_priv_hh_familie_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX typ_priv_hh_familie_1km_geom_idx ON zensus_2022.typ_priv_hh_familie_1km USING gist (geom);


--
-- Name: typ_priv_hh_lebensform_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX typ_priv_hh_lebensform_100m_geom_idx ON zensus_2022.typ_priv_hh_lebensform_100m USING gist (geom);


--
-- Name: typ_priv_hh_lebensform_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX typ_priv_hh_lebensform_10km_geom_idx ON zensus_2022.typ_priv_hh_lebensform_10km USING gist (geom);


--
-- Name: typ_priv_hh_lebensform_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX typ_priv_hh_lebensform_1km_geom_idx ON zensus_2022.typ_priv_hh_lebensform_1km USING gist (geom);


--
-- Name: wohnung_gebaeudetyp_groesse_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX wohnung_gebaeudetyp_groesse_100m_geom_idx ON zensus_2022.wohnung_gebaeudetyp_groesse_100m USING gist (geom);


--
-- Name: wohnung_gebaeudetyp_groesse_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX wohnung_gebaeudetyp_groesse_10km_geom_idx ON zensus_2022.wohnung_gebaeudetyp_groesse_10km USING gist (geom);


--
-- Name: wohnung_gebaeudetyp_groesse_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX wohnung_gebaeudetyp_groesse_1km_geom_idx ON zensus_2022.wohnung_gebaeudetyp_groesse_1km USING gist (geom);


--
-- Name: wohnungen_nach_zahl_der_raeume_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX wohnungen_nach_zahl_der_raeume_100m_geom_idx ON zensus_2022.wohnungen_nach_zahl_der_raeume_100m USING gist (geom);


--
-- Name: wohnungen_nach_zahl_der_raeume_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX wohnungen_nach_zahl_der_raeume_10km_geom_idx ON zensus_2022.wohnungen_nach_zahl_der_raeume_10km USING gist (geom);


--
-- Name: wohnungen_nach_zahl_der_raeume_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX wohnungen_nach_zahl_der_raeume_1km_geom_idx ON zensus_2022.wohnungen_nach_zahl_der_raeume_1km USING gist (geom);


--
-- Name: zahl_der_staatsangehoerigkeiten_100m_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX zahl_der_staatsangehoerigkeiten_100m_geom_idx ON zensus_2022.zahl_der_staatsangehoerigkeiten_100m USING gist (geom);


--
-- Name: zahl_der_staatsangehoerigkeiten_10km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX zahl_der_staatsangehoerigkeiten_10km_geom_idx ON zensus_2022.zahl_der_staatsangehoerigkeiten_10km USING gist (geom);


--
-- Name: zahl_der_staatsangehoerigkeiten_1km_geom_idx; Type: INDEX; Schema: zensus_2022; Owner: -
--

CREATE INDEX zahl_der_staatsangehoerigkeiten_1km_geom_idx ON zensus_2022.zahl_der_staatsangehoerigkeiten_1km USING gist (geom);


--
-- Name: planet_osm_line planet_osm_line_osm2pgsql_valid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER planet_osm_line_osm2pgsql_valid BEFORE INSERT OR UPDATE ON public.planet_osm_line FOR EACH ROW EXECUTE FUNCTION public.planet_osm_line_osm2pgsql_valid();


--
-- Name: planet_osm_point planet_osm_point_osm2pgsql_valid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER planet_osm_point_osm2pgsql_valid BEFORE INSERT OR UPDATE ON public.planet_osm_point FOR EACH ROW EXECUTE FUNCTION public.planet_osm_point_osm2pgsql_valid();


--
-- Name: planet_osm_polygon planet_osm_polygon_osm2pgsql_valid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER planet_osm_polygon_osm2pgsql_valid BEFORE INSERT OR UPDATE ON public.planet_osm_polygon FOR EACH ROW EXECUTE FUNCTION public.planet_osm_polygon_osm2pgsql_valid();


--
-- Name: planet_osm_roads planet_osm_roads_osm2pgsql_valid; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER planet_osm_roads_osm2pgsql_valid BEFORE INSERT OR UPDATE ON public.planet_osm_roads FOR EACH ROW EXECUTE FUNCTION public.planet_osm_roads_osm2pgsql_valid();


--
-- PostgreSQL database dump complete
--

\unrestrict XJ3u8sKISIY6i2cCfCo7mrid2VlzI1pbCmIOx42fYqB3cAhTtxbi0kGkdcf0XOt

