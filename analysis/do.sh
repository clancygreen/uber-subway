#!/usr/bin/env bash

do_nyctd () {
    psql -d nyc-taxi-data -f ${1}
}


## index initial nyc-taxi-data tables
do_nyctd index_init.sql


## build aggregate
do_nyctd agg/area_to_gauge.sql
do_nyctd agg/station_to_area.sql
do_nyctd agg/precip.sql
do_nyctd agg/pickups_tz.sql
do_nyctd agg/pickups_tract.sql


## build donut

