-------------------------------------------------------------------------------
-- agg pickups to tract-zone-provider
-------------------------------------------------------------------------------

-- see https://stackoverflow.com/questions/36959/how-do-you-use-script-variables-in-psql
\set rowcount 10000000000

-- fhv
-- for extracting datetime components see 
-- https://stackoverflow.com/questions/39334814/how-to-extract-hour-from-query-in-postgres
/*
DROP TABLE IF EXISTS fhv_tz_hr_dropoffs;

CREATE TABLE fhv_tz_hr_dropoffs AS
SELECT 
    UPPER(B.dba_category) AS type,
    A.dropoff_location_id AS tz,
    EXTRACT(year FROM A.dropoff_datetime) AS year,
    EXTRACT(month FROM A.dropoff_datetime) AS month,
    EXTRACT(day FROM A.dropoff_datetime) AS day,
    EXTRACT(hour FROM A.dropoff_datetime) AS hour,
    SUM(1) AS count
FROM fhv_trips A
LEFT JOIN fhv_bases B ON A.dispatching_base_num = B.base_number
WHERE A.dropoff_location_id IS NOT NULL
GROUP BY
    type,
    tz,
    year,
    month,
    day,
    hour
LIMIT :rowcount;
*/
 
-- taxi
DROP TABLE IF EXISTS taxi_tz_hr_dropoffs;

CREATE TABLE taxi_tz_hr_dropoffs AS
SELECT 
    CASE WHEN cab_type_id = 1 THEN 'YELLOW' ELSE 'GREEN' END AS type,
    dropoff_location_id AS tz,
    EXTRACT(year FROM dropoff_datetime) AS year,
    EXTRACT(month FROM dropoff_datetime) AS month,
    EXTRACT(day FROM dropoff_datetime) AS day,
    EXTRACT(hour FROM dropoff_datetime) AS hour,
    SUM(1) AS count
FROM trips WHERE dropoff_location_id IS NOT NULL
GROUP BY
    type,
    tz,
    year,
    month,
    day,
    hour
LIMIT :rowcount;
