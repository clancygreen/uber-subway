DROP TABLE IF EXISTS asos_hourly;
CREATE TABLE asos_hourly (
  station text,
  network text,
  datetime text,
  precip_in numeric
);

DROP TABLE IF EXISTS asos_subhourly;
CREATE TABLE asos_subhourly (
  station text,
  datetime text,
  lon numeric,
  lat numeric,
  p01i numeric
);
