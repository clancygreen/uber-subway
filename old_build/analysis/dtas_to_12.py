import os
import pandas as pd


target = os.path.join(os.path.expanduser('~'), 'dropbox/Uber/Data/new_tables')
print('Converting (naively) all DTAs in ', target, ' to version 12')


for root, dirs, files in os.walk(target):
    for file in files:
        if file.endswith('.dta'):
            abspath = os.path.join(target, root, file)

            print(f'Converting {abspath} to version 12')
            
            df = pd.io.stata.read_stata(abspath)
            
            df = df.drop(['index'], axis=1)
            try:
                df = df.drop(['level_0'], axis=1) 
            except:
                pass

            df.to_stata(abspath, write_index=False, version=114)
