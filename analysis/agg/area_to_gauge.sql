-------------------------------------------------------------------------------
-- tracts, zones => gauges
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- gauges: NN
-- joins tract, zone centroids to voronoi polys
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

-- taxi zones
ALTER TABLE taxi_zones DROP COLUMN IF EXISTS gauge;
ALTER TABLE taxi_zones ADD gauge text;

UPDATE taxi_zones AS A 
SET gauge = B.station 
FROM asos_voronoi B
WHERE ST_Within(ST_Centroid(A.geom), B.voronoi);

-- taxi zones not unique on locationid
-- take first gauge (does not vary within locationid by checking)
/*
SELECT
    A.locationid,
    A.gauge 
FROM taxi_zones A
INNER JOIN (
    SELECT 
        locationid
    FROM taxi_zones
    GROUP BY locationid
    HAVING COUNT(locationid) > 1
) B
ON A.locationid = B.locationid
ORDER BY A.locationid;
*/

-- pickup location id in fhv trips appears to correspond best to gid, not locationid
-- 263 non-missing locations in trip data vs 260 unique locationid in taxi_zones
DROP TABLE IF EXISTS tz_to_gauge;
CREATE TABLE tz_to_gauge AS
SELECT 
    gid AS tz,
    gauge
FROM taxi_zones;

-- tracts
ALTER TABLE nyct2010 DROP COLUMN IF EXISTS gauge;
ALTER TABLE nyct2010 ADD gauge text;

UPDATE nyct2010 AS A 
SET gauge = B.station 
FROM asos_voronoi B
WHERE ST_Within(ST_Centroid(A.geom), B.voronoi);

