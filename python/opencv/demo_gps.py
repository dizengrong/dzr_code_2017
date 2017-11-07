import threading
import time
from gps3 import *


class GpsPoller(threading.Thread):

    def __init__(self):
        threading.Thread.__init__(self)
        self.session = gps3(mode=WATCH_ENABLE)
        self.current_value = None

    def get_current_value(self):
        return self.current_value

    def run(self):
        try:
            while True:
                self.current_value = session.next()
                # tune this, you might  notget values that quickly
                time.sleep(0.2)
        except StopIteration:
            pass


if __name__ == '__main__':

    gpsp = GpsPoller()
    gpsp.start()
    # gpsp now polls every .2 seconds for new data, storing it in self.current_value
    while 1:
        # In the main thread, every 5 seconds print the current value
        time.sleep(5)
        print gpsp.get_current_value()
