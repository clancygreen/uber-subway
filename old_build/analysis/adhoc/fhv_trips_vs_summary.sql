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

DROP TABLE IF EXISTS fhv_disagg_monthly;
CREATE TABLE  fhv_disagg_monthly AS
SELECT
  type,
  year,
  month,
  SUM(count) AS disagg_count
FROM fhv_tz_hr
GROUP BY type, year, month;

SELECT
  A.type,
  A.year,
  A.month,
  A.agg_count,
  B.disagg_count,
  A.agg_count - B.disagg_count AS diff,
  ROUND(((A.agg_count - B.disagg_count) / A.agg_count) * 100, 2) AS pct_diff
FROM fhv_monthly_by_type A
LEFT JOIN fhv_disagg_monthly B
ON A.type = B.type AND A.year = B.year AND A.month = B.month
WHERE A.type IS NOT NULL AND A.year < 2019;

SELECT
  A.type,
  A.year,
  A.month,
  A.agg_count,
  B.disagg_count,
  A.agg_count - B.disagg_count AS diff,
  ROUND(((A.agg_count - B.disagg_count) / A.agg_count) * 100, 2) AS pct_diff
FROM fhv_monthly_by_type A
FULL OUTER JOIN fhv_disagg_monthly B
ON A.year = B.year AND A.month = B.month
WHERE A.type IS NULL AND B.type IS NULL AND A.year = B.year;
