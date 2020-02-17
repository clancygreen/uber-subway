#!/usr/bin/env python3
# coding: utf-8

import logging

import psycopg2
import pandas as pd

from env import data_path
from tools import timing


def connect():
    host = 'localhost'
    dbname = 'nyc-taxi-data'
    user = 'cg'
    try:
        conn_str = f"host={host} dbname={dbname} user={user}"
        conn = psycopg2.connect(conn_str)
    except Exception as e:
        print(e)
        conn = None
    return conn


@timing
def od_dhour_clps(conn, year, month):
    # Count dropoffs by O-D-D hour for a given year, month.
    sql = f"""WITH fhv_trips_od AS (SELECT
                    A.pickup_location_id,
                    A.dropoff_location_id,
                    EXTRACT(YEAR FROM A.dropoff_datetime) AS do_year, 
                    EXTRACT(MONTH FROM A.dropoff_datetime) AS do_month, 
                    EXTRACT(DAY FROM A.dropoff_datetime) AS do_day,
                    EXTRACT(HOUR FROM A.dropoff_datetime) AS do_hour
                FROM fhv_trips A 
                LEFT JOIN fhv_bases B 
                ON A.dispatching_base_num = B.base_number
                WHERE (B.dba_category = 'uber' OR B.dba_category = 'lyft') AND 
                      EXTRACT(YEAR FROM A.dropoff_datetime) = {year} AND 
                      EXTRACT(MONTH FROM A.dropoff_datetime) = {month}
            ) 
            SELECT 
               fhv_trips_od.*,
               COUNT(*)
            FROM fhv_trips_od 
            WHERE dropoff_location_id IS NOT NULL
            GROUP BY 
                pickup_location_id,
                dropoff_location_id,
                do_year,
                do_month,
                do_day,
                do_hour;"""
    df = pd.read_sql_query(sql, conn)
    return df


if __name__ == "__main__":
    conn = connect()
    year_months = {2017: (7, 12),
                   2018: (1, 12),
                   2019: (1, 6)}

    for year in range(2017, 2020):
        start, end = year_months[year][0], year_months[year][1]
        for month in range(start, end + 1):
            print(f'Collapsing {month}, {year}')
            df = od_dhour_clps(conn, year, month)
            print(df.head())

            # Write out to Dropbox.
            df.to_stata(path=data_path(f'OriginDestination/od_dhour_{year}_{month}.dta'), write_index=False, version=118)
    conn.close()
