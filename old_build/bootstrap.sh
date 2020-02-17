#!/usr/bin/env bash
#
# bootstrap subway substitution build
# assumes nyc-taxi-data is built


## get rain gauge data
## assumes asospy/scrape.py has been run and output moved
#./setup_files/import_asos_data.sh
psql -d nyc-taxi-data -f ./setup_files/populate_asos_stations.sql


## get subway stations
./setup_files/import_subway_stations.sh
