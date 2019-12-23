#!/usr/bin/env bash


## write out select tables to csv, dta
for t in $(cat tables_to_csv.txt); do
    psql -d nyc-taxi-data -c "\copy $t to ../tables/${t}.csv csv header"
    python table_to_dta.py $t
done
