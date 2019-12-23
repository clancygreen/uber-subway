-------------------------------------------------------------------------------
-- agg precip to gauge-hour
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS precip_tz_hr;

CREATE TABLE precip_tz_hr AS 
WITH asos_hourly_temp AS (
    SELECT 
        station AS gauge,
        EXTRACT(year FROM datetime::timestamp) AS year,
        EXTRACT(month FROM datetime::timestamp) AS month,
        EXTRACT(day FROM datetime::timestamp) AS day,
        EXTRACT(hour FROM datetime::timestamp) AS hour,
        precip_in
    FROM asos_precip 
)
SELECT
    A.tz,
    A.gauge,
    B.year,
    B.month,
    B.day,
    B.hour,
    B.precip_in
FROM 
    tz_to_gauge A,
    asos_hourly_temp B
WHERE A.gauge = B.gauge;

