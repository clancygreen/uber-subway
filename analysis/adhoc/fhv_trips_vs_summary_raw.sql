/*
DROP TABLE IF EXISTS fhv_monthly_by_type;
CREATE TABLE fhv_monthly_by_type AS
SELECT
  A.year,
  A.month,
  CASE
    WHEN strpos(UPPER(A.base_number),'B0') > 0 THEN UPPER(B.dba_category) 
    ELSE UPPER(A.base_number)
  END AS type,
  SUM(total_dispatched_trips) AS agg_count
FROM fhv_monthly_reports A
LEFT JOIN fhv_bases B
ON A.base_number = B.base_number
GROUP BY year, month, type;

DROP TABLE IF EXISTS fhv_disagg_monthly_raw;
CREATE TABLE  fhv_disagg_monthly_raw AS
SELECT
  UPPER(B.dba_category) AS type,
  EXTRACT(year from A.pickup_datetime) AS year,
  EXTRACT(month from A.pickup_datetime) AS month,
  SUM(1) AS disagg_count
FROM fhv_trips A
LEFT JOIN fhv_bases B ON A.dispatching_base_num = B.base_number
GROUP BY type, year, month;
*/

DROP TABLE IF EXISTS fhv_monthly_comparison;
CREATE TABLE fhv_monthly_comparison AS
SELECT
  A.type,
  A.year,
  A.month,
  A.agg_count,
  B.disagg_count,
  A.agg_count - B.disagg_count AS diff,
  ROUND((((A.agg_count::float8 - B.disagg_count::float8) / A.agg_count::float8) * 100)::numeric, 2) AS pct_diff
FROM fhv_monthly_by_type A
LEFT JOIN fhv_disagg_monthly_raw B
ON A.type = B.type AND A.year = B.year AND A.month = B.month
WHERE A.type IS NOT NULL AND A.year < 2019;

SELECT * FROM fhv_monthly_comparison;

SELECT
  A.type,
  A.year,
  A.month,
  A.agg_count,
  B.disagg_count,
  A.agg_count - B.disagg_count AS diff,
  ROUND((((A.agg_count::float8 - B.disagg_count::float8) / A.agg_count::float8) * 100)::numeric, 2) AS pct_diff
FROM fhv_monthly_by_type A
FULL OUTER JOIN fhv_disagg_monthly_raw B
ON A.year = B.year AND A.month = B.month
WHERE A.type IS NULL AND B.type IS NULL AND A.year = B.year
ORDER BY year, month;
