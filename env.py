import os


HOME = os.path.expanduser("~")
DATA_PATH = os.path.join(HOME, 'Dropbox/Uber/Data')


def data_path(*args):
    return os.path.join(DATA_PATH, *args)
