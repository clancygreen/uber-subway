-------------------------------------------------------------------------------
-- gauges => stations
-- 1) NN
-- 2) KNN
-- 3) Naive NN
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- NN 
-- make voronoi polygons and join
-------------------------------------------------------------------------------

-- asos_voronoi
DROP TABLE IF EXISTS asos_voronoi;

CREATE TABLE asos_voronoi AS
SELECT 
	A.station, 
    A.pt,
    B.geom AS voronoi
FROM asos_locations A,
(
    SELECT ST_SetSRID(
		(ST_Dump(ST_VoronoiPolygons(ST_Collect(pt)))).geom, 4326) AS geom
	FROM asos_locations
) B
WHERE ST_Within(A.pt, B.geom);

CREATE INDEX index_asos_voronoi ON asos_voronoi USING gist (voronoi);

-- subway voronoi
DROP TABLE IF EXISTS subway_voronoi;

CREATE TABLE subway_voronoi AS
SELECT 
	A.remote, 
    A.geom AS pt, 
	B.geom AS voronoi
FROM remote_station A,
	(SELECT ST_SetSRID(
		(ST_Dump(ST_VoronoiPolygons(ST_Collect(geom)))).geom, 4326) AS geom
	FROM remote_station) B
WHERE ST_Within(A.geom, B.geom);

CREATE INDEX index_subway_voronoi ON subway_voronoi USING gist (voronoi);

-- make uber pickup geometry to test
ALTER TABLE uber_trips_2014
DROP COLUMN IF EXISTS pickup;

ALTER TABLE uber_trips_2014
ADD pickup GEOMETRY;

UPDATE uber_trips_2014 
SET pickup = ST_SetSRID(ST_MakePoint(pickup_longitude, pickup_latitude), 4326);

-- join uber pickups to voronoi polys
-- note: this will duplicate pickups since station-remotes overlap
ALTER TABLE uber_trips_2014 
DROP COLUMN IF EXISTS ngauge;

ALTER TABLE uber_trips_2014
ADD ngauge CHAR(3);

UPDATE uber_trips_2014 AS U
SET ngauge = V.station
FROM asos_voronoi V
WHERE ST_Within(U.pickup, V.voronoi); 

-- sanity check
SELECT pickup_latitude, pickup_longitude, ngauge 
FROM uber_trips_2014
LIMIT 10;


-------------------------------------------------------------------------------
-- KNN
-------------------------------------------------------------------------------

-- transform to EPSG 6539 (NAD83) to get distances in ft
SELECT 
    A.remote,
    A.station,
    D.gauge,
    D.dist
FROM remote_station A
JOIN LATERAL (
    SELECT
        B.remote,
        C.station AS gauge,
        ST_Distance(ST_Transform(B.geom, 6539), ST_Transform(C.pt, 6539)) AS dist
    FROM 
        remote_station B,
        asos_locations C
    WHERE A.remote = B.remote
    ORDER BY ST_Transform(B.geom, 6539) <-> ST_Transform(C.pt, 6539)
    LIMIT 3
) D ON true
ORDER BY A.remote, D.dist;


-------------------------------------------------------------------------------
-- Naive NN
-- cross join for inverse distance weighted avg
-------------------------------------------------------------------------------

-- TODO: make columns consistent across NNs
SELECT 
    A.remote,
    B.station AS gauge,
    ST_Distance(ST_Transform(A.geom, 6539), ST_Transform(B.pt, 6539)) AS dist
FROM remote_station A
CROSS JOIN asos_locations B
ORDER BY A.remote, B.station;
