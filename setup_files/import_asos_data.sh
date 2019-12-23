#!/bin/bash

# create schema
psql nyc-taxi-data -f setup_files/create_asos_schema.sql

# copy hourly data
asos_hourly="(station, network, datetime, precip_in)"
cat data/hourlyprecip_direct_download.csv | psql nyc-taxi-data -c "COPY asos_hourly ${asos_hourly} FROM stdin CSV HEADER;"

# copy subhourly data
asos_subhourly="(station, datetime, lon, lat, p01i)"
cat data/asos_data.csv | psql nyc-taxi-data -c "COPY asos_subhourly ${asos_subhourly} FROM stdin CSV HEADER;"

# get station locations
psql nyc-taxi-data -f setup_files/populate_asos_stations.sql
