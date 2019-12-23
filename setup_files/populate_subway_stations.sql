DROP TABLE IF EXISTS remote_station;
CREATE TABLE remote_station AS
SELECT
    remote,
    station,
    lat,
    lon,
    ST_SetSRID(ST_MakePoint(lon, lat), 4326) AS geom
FROM remote_station_from_final;

DROP TABLE IF EXISTS remote_station_from_final;
