编译：
打开vs cmd tool
cd bin
cl -I ../include  ../src/data_map_1000.c
注意：cl加-c只编译不链接
与erts一起编译

windows下的编译：
cl -LD -MD -Fe -I ../include -I "D:/programs/erl9.3/usr/include"  ../src/cerl_map_api.c ../src/data_map_1.c ../src/data_map_2.c ../src/data_map_3.c

Linux下的编译：(头文件目录可能不一样)
gcc --std=c99 -fPIC -shared -O3 -o cerl_map_api.so -I ../include -I /usr/local/lib/erlang/lib/erlang/erts-9.3/include  ../src/cerl_map_api.c ../src/data_map_1.c ../src/data_map_2.c ../src/data_map_3.c ../src/data_map_4.c ../src/data_map_5.c ../src/data_map_6.c ../src/data_map_7.c ../src/data_map_8.c ../src/data_map_9.c ../src/data_map_10.c ../src/data_map_11.c ../src/data_map_12.c ../src/data_map_13.c ../src/data_map_14.c ../src/data_map_15.c ../src/data_map_16.c ../src/data_map_17.c  ../src/data_map_18.c ../src/data_map_19.c ../src/data_map_20.c ../src/data_map_21.c ../src/data_map_22.c ../src/data_map_23.c ../src/data_map_24.c ../src/data_map_25.c ../src/data_map_26.c ../src/data_map_27.c ../src/data_map_28.c ../src/data_map_29.c ../src/data_map_30.c ../src/data_map_31.c ../src/data_map_32.c  ../src/data_map_33.c ../src/data_map_34.c ../src/data_map_35.c ../src/data_map_36.c ../src/data_map_37.c ../src/data_map_38.c ../src/data_map_39.c 

新增一个地图掩码文件需要修改的地方：
	map.h
	map_conf.json
	cerl_map_api.c
	lib_c_map_module.erl