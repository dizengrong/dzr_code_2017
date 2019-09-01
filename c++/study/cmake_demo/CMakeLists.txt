#cmake最低版本需求，不加入此行会受到警告信息
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

PROJECT(BASE) #项目名称

ADD_SUBDIRECTORY( src )

#把当前目录(.)下所有源代码文件和头文件加入变量SRC_LIST
AUX_SOURCE_DIRECTORY(. SRC_LIST)

#list(REMOVE_ITEM SRC_LIST "TestCase.cpp")
#list(REMOVE_ITEM SRC_LIST "TestMain.cpp")

#生成应用程序 main (在windows下会自动生成main.exe)
ADD_EXECUTABLE(main ${SRC_LIST})

TARGET_LINK_LIBRARIES( main TestClass )
