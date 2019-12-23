DROP TABLE IF EXISTS pickups_wo_dropoffs;
CREATE TABLE pickups_wo_dropoffs AS
SELECT
  EXTRACT(year FROM A.pickup_datetime) AS year,
  EXTRACT(month FROM A.pickup_datetime) AS month,
  UPPER(B.dba_category) AS type,
  COUNT(*) AS count
FROM fhv_trips A
LEFT JOIN fhv_bases B ON A.dispatching_base_num = B.base_number
WHERE A.pickup_location_id IS NOT NULL 
  AND A.dropoff_location_id IS NULL
GROUP BY
  year,
  month,
  type;

SELECT
  SUM(count) AS total_pickups_no_dropoffs
FROM pickups_wo_dropoffs;

SELECT
  SUM(count) AS total_pickups
FROM fhv_tz_hr;
