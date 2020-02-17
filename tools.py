from functools import wraps
from time import time


def start_log(log_name):
    """
    Redirects print output to `log_name`.
    """
    logging.basicConfig(level=logging.INFO, format='%(message)s')
    logger = logging.getLogger()
    logger.addHandler(logging.FileHandler(log_name, 'w'))
    print = logger.info


def timing(f):
    """
    See https://codereview.stackexchange.com/questions/169870/decorator-to-measure-execution-time-of-a-function
    """
    @wraps(f)
    def wrapper(*args, **kwargs):
        start = time()
        result = f(*args, **kwargs)
        end = time()
        print(f'Elapsed time running {f.__name__}: {(end - start) / 60} minutes')
        return result
    return wrapper
