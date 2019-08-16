import threading
import multiprocessing
from multiprocessing import Process


def loop():
    x = 0
    while True:
        x = x ^ 1


if __name__ == '__main__':
    for i in range(multiprocessing.cpu_count()):
        # t = threading.Thread(target=loop)
        # t.start()
        p = Process(target=loop)
        p.start()
