#!/usr/bin/env python
# coding: utf-8

import psycopg2
import pandas as pd

host = 'localhost'
dbname = 'nyc-taxi-data'
user = 'cg'

try:
    conn_str = f"host={host} dbname={dbname} user={user}"
    conn = psycopg2.connect(conn_str)
    
except Exception as e:
    print(e)

sql = """SELECT A.id, 
                EXTRACT(YEAR FROM A.pickup_datetime) AS year, 
                EXTRACT(MONTH FROM A.pickup_datetime) AS month, 
                EXTRACT(DOW FROM A.pickup_datetime) AS dow, 
                A.pickup_location_id, 
                CASE 
                    WHEN A.dropoff_location_id IS NULL THEN 1
                    ELSE 0
                END AS no_do_location,
                UPPER(B.dba_category) AS type
            FROM fhv_trips_samp_pt1pct A 
            LEFT JOIN fhv_bases B 
            ON A.dispatching_base_num = B.base_number;"""
df = pd.read_sql_query(sql, conn)
df.head()

pd.crosstab([df.year, df.type], df.no_do_location)
pd.crosstab([df.year, df.type], df.no_do_location).apply(lambda r: r/r.sum(), axis=1)

cursor.close()
conn.close()
