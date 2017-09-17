# -*- coding: utf-8 -*-

# 导入cv模块
import cv2 as cv
# 读取图像，支持 bmp、jpg、png、tiff 等常用格式
img = cv.imread(u"E:/我/手机相册/1.jpg".encode("GBK"))
# 创建窗口并显示图像
cv.namedWindow("Image")
cv.imshow("Image", img)
cv.waitKey(0)
# 释放窗口
cv.destroyAllWindows()
