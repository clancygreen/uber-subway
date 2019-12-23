SELECT setseed(0.3);

DROP TABLE IF EXISTS fhv_trips_samp_pt1pct;
CREATE TABLE fhv_trips_samp_pt1pct AS 
WITH R AS (SELECT id, random() AS rand FROM fhv_trips)
SELECT
    A.*
FROM fhv_trips A
INNER JOIN R ON A.id = R.id
WHERE R.rand < 0.001;

SELECT COUNT(*) FROM fhv_trips_samp_1pct;
SELECT COUNT(*) FROM fhv_trips;
