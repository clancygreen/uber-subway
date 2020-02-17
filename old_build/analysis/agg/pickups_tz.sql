-------------------------------------------------------------------------------
-- agg pickups to tract-zone-provider
-------------------------------------------------------------------------------

-- see https://stackoverflow.com/questions/36959/how-do-you-use-script-variables-in-psql
\set rowcount 10000000000

-- fhv
-- for extracting datetime components see 
-- https://stackoverflow.com/questions/39334814/how-to-extract-hour-from-query-in-postgres
DROP TABLE IF EXISTS fhv_tz_hr;

CREATE TABLE fhv_tz_hr AS
SELECT 
    UPPER(B.dba_category) AS type,
    A.pickup_location_id AS tz,
    EXTRACT(year FROM A.pickup_datetime) AS year,
    EXTRACT(month FROM A.pickup_datetime) AS month,
    EXTRACT(day FROM A.pickup_datetime) AS day,
    EXTRACT(hour FROM A.pickup_datetime) AS hour,
    SUM(1) AS count
FROM fhv_trips A
LEFT JOIN fhv_bases B ON A.dispatching_base_num = B.base_number
WHERE A.pickup_location_id IS NOT NULL
GROUP BY
    type,
    tz,
    year,
    month,
    day,
    hour
LIMIT :rowcount;
 

-- uber 2014
-- add geometry to uber trips table
ALTER TABLE uber_trips_2014 DROP COLUMN IF EXISTS pickup_pt;
ALTER TABLE uber_trips_2014 ADD pickup_pt GEOMETRY;

UPDATE uber_trips_2014 
SET pickup_pt = ST_SetSRID(ST_MakePoint(pickup_longitude, pickup_latitude), 4326);

ALTER TABLE uber_trips_2014 DROP COLUMN IF EXISTS tz;
ALTER TABLE uber_trips_2014 ADD tz smallint;

-- join to tz
UPDATE uber_trips_2014 AS A
SET tz = B.locationid
FROM taxi_zones B
WHERE ST_Within(A.pickup_pt, B.geom); 

DROP TABLE IF EXISTS uber_2014_tz_hr;

CREATE TABLE uber_2014_tz_hr AS
SELECT 
    'UBER' AS type,
    tz,
    EXTRACT(year FROM pickup_datetime) AS year,
    EXTRACT(month FROM pickup_datetime) AS month,
    EXTRACT(day FROM pickup_datetime) AS day,
    EXTRACT(hour FROM pickup_datetime) AS hour,
    SUM(1) AS count
FROM uber_trips_2014
WHERE tz IS NOT NULL
GROUP BY
    tz,
    year,
    month,
    day,
    hour
LIMIT :rowcount;
  

-- taxi
DROP TABLE IF EXISTS taxi_tz_hr;

CREATE TABLE taxi_tz_hr AS
SELECT 
    CASE WHEN cab_type_id = 1 THEN 'YELLOW' ELSE 'GREEN' END AS type,
    pickup_location_id AS tz,
    EXTRACT(year FROM pickup_datetime) AS year,
    EXTRACT(month FROM pickup_datetime) AS month,
    EXTRACT(day FROM pickup_datetime) AS day,
    EXTRACT(hour FROM pickup_datetime) AS hour,
    SUM(1) AS count
FROM trips WHERE tz IS NOT NULL
GROUP BY
    type,
    tz,
    year,
    month,
    day,
    hour
LIMIT :rowcount;


-- combined
CREATE TABLE all_tz_hr AS
SELECT * FROM fhv_tz_hr;

INSERT INTO all_tz_hr
SELECT * FROM uber_2014_tz_hr;

INSERT INTO all_tz_hr
SELECT * FROM fhv_tz_hr;
