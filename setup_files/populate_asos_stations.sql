DROP TABLE IF EXISTS asos_locations;
CREATE TABLE asos_locations AS
SELECT
  DISTINCT station,
  ST_SetSRID(ST_MakePoint(lon, lat), 4326) AS pt,
  lon,
  lat
FROM asos_subhourly;

CREATE INDEX ON asos_locations USING gist (pt);

-- get lat and lon from asos subhourly data
DROP TABLE IF EXISTS asos_precip;
CREATE TABLE asos_precip AS
SELECT
  A.station,
  A.datetime,
  A.precip_in,
  B.lon,
  B.lat
FROM asos_hourly A
INNER JOIN asos_locations B
ON A.station = B.station;
