#!/usr/bin/env python3

import sys
import psycopg2
import pandas as pd


def main():
    conn_str = "host='localhost' dbname='nyc-taxi-data' user='postgres'"

    print(f'Connecting to {conn_str}')
    conn = psycopg2.connect(conn_str)

    print(f'Writing {sys.argv[1]} to dta format')
    df = pd.read_sql_query(f'SELECT * FROM {sys.argv[1]};', conn)
    df.to_stata(f'../tables/{sys.argv[1]}.dta', write_index=False, version=114)
    print('Done!\n')

    conn = None

if __name__ == "__main__":
    main()
