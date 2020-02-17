#!/bin/bash

# create schema
psql nyc-taxi-data -f setup_files/create_subway_schema.sql

# copy subway spine
sub_schema="(remote, station, lat, lon)"
cat data/remote_station_from_final.csv | psql nyc-taxi-data -c "COPY remote_station_from_final ${sub_schema} FROM stdin CSV HEADER;"

# add geometry to stations table
psql nyc-taxi-data -f setup_files/populate_subway_stations.sql
