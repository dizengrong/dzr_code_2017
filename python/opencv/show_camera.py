# -*- coding: utf-8 -*-

import socket
import cv2

cap = cv2.VideoCapture(0)
clisocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
while(1):
    # get a frame
    ret, frame = cap.read()
    # show a frame
    # cv2.imshow("capture", frame)
    frame.resize(160, 120)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
    clisocket.sendto(frame.tostring(), ("127.0.0.1", 1234))
clisocket.close()
cap.release()
cv2.destroyAllWindows()
