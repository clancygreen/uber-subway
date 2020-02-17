-- trips
DROP INDEX IF EXISTS index_trips_on_cab_type;
DROP INDEX IF EXISTS index_trips_on_pickup_tz;
DROP INDEX IF EXISTS index_trips_on_pickup_ct;

CREATE INDEX index_trips_on_cab_type ON trips (cab_type_id);
CREATE INDEX index_trips_on_pickup_tz ON trips (pickup_location_id);
CREATE INDEX index_trips_on_pickup_ct ON trips (pickup_nyct2010_gid);

-- fhv_trips
DROP INDEX IF EXISTS index_fhv_trips_on_dbn;
DROP INDEX IF EXISTS index_fhv_trips_on_pickup_tz;

CREATE INDEX index_fhv_trips_on_dbn ON fhv_trips (dispatching_base_num);
CREATE INDEX index_fhv_trips_on_pickup_tz ON fhv_trips (pickup_location_id);

-- uber 2014 trips
-- tz/ct indexed after join to tz/ct
