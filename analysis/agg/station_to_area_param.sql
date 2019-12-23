-------------------------------------------------------------------------------
-- gauges, stations => tracts, zones
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- stations: buffered join
-- buffer stations, intersect tracts, find areas of intersection
-------------------------------------------------------------------------------

-- buffer stations by 3000ft
-- could make buffers a function of nearby stations:
-- 1) intersect buffers with station voronoi polys
-- 2) make buffer distance a function of number of nearby stations

-- taxi zones
DROP TABLE IF EXISTS station_buffers;

-- beware literal edge cases => intersect buffers with union of tracts
CREATE TABLE station_buffers AS
WITH tz_union AS (
    SELECT ST_Union(geom) AS geom
    FROM taxi_zones
)
SELECT
    A.remote,
    ST_Intersection(ST_Transform(ST_Buffer(ST_Transform(A.geom, 6539), :feet), 4326), 
        B.geom) AS buffer
FROM station_latlong A, tz_union B;

-- make tz geometries distinct on tz
DROP TABLE IF EXISTS dtz;
CREATE TABLE dtz AS
SELECT
    gid,
    ST_Union(geom) AS geom,
    1000 AS dummy_popn
FROM taxi_zones
GROUP BY gid;

-- intersect station buffers with dtracts and get areas
DROP TABLE IF EXISTS station_to_tz_buff_:feet;
CREATE TABLE station_to_tz_buff_:feet AS
SELECT
    A.remote,
    B.gid AS tz,
    ST_Area(A.buffer) AS buffer_area,
    ST_Area(ST_Intersection(A.buffer, B.geom)) AS inter_area,
    B.dummy_popn
FROM 
    station_buffers A,
    dtz B
WHERE ST_Intersects(A.buffer, B.geom)
ORDER BY A.remote;

-- get dummy entries by station, tract
ALTER TABLE station_to_tz_buff_:feet DROP COLUMN IF EXISTS tz_share;
ALTER TABLE station_to_tz_buff_:feet ADD tz_share numeric;

UPDATE station_to_tz_buff_:feet SET tz_share = inter_area / buffer_area;

-- check tract_share sums by station
-- TODO: figure out numerical precision issue, e.g., sums to 0.99999999999998805077
SELECT 
    remote,
    SUM(tz_share) AS sum_by_station
FROM station_to_tz_buff_:feet
GROUP BY remote;
