#!/usr/bin/env sh

cat data/dbn_to_type.csv | psql nyc-taxi-data -c "COPY dbn_to_type FROM stdin WITH CSV HEADER;"
