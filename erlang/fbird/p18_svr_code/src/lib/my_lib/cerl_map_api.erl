-module (cerl_map_api).
-export([
	init/0, get_point/0, hello/1, test_check_point/4, test_sleep/1, test_angle2radian/1,
	test_radian2angle/1, test_get_vect_by_dir/1
]).
-export([check_point/4, check_dir_by_point/3, check_dir/4]).
-export([calc_in_rect/9, calc_in_cir/7, calc_in_ring/8, calc_in_sector/9, find_turn_dir_point/3]).


init() ->    
    ok = erlang:load_nif("./deps/bin/cerl_map_api", 0).  

%% =================================== test ==================================== 
get_point() -> 
	erlang:nif_error(undef).

hello(_Double) -> 
	erlang:nif_error(undef).

test_check_point(_MapId, _X, _Y, _Z) ->
	erlang:nif_error(undef).

test_sleep(_Sec) -> 
	erlang:nif_error(undef).

test_angle2radian(_Angle) -> 
	erlang:nif_error(undef).

test_radian2angle(_R) -> 
	erlang:nif_error(undef).

test_get_vect_by_dir(_R) -> 
	erlang:nif_error(undef).
%% =================================== test ==================================== 


%% return: 找到的点{X, Y, Z} | 或失败的整型code
check_point(_MapId, _X, _Y, _Z) ->
	erlang:nif_error(undef).


%% 参数Point格式：{X, Y, Z}
%% return: 找到的点{X, Y, Z} | 或失败的整型code
check_dir_by_point(_MapId, _Point, _ToPoint) ->
	erlang:nif_error(undef).


%% 参数Point格式：{X, Y, Z}
check_dir(_Map, _MaxDis, _Point, _Dir) -> 
	erlang:nif_error(undef).


%% 计算是否在rect内
%% RoleDir:为一个整型 RL:长方形的长 RW:长方形的宽 UpH:上高 DownH:下高
calc_in_rect(_Map, _SrcPos, _TargetPos, _SrcDir, _TargetRadius, _RL, _RW, _UpH, _DownH) ->
	erlang:nif_error(undef).

%% 计算是否在圆形内
calc_in_cir(_Map, _SrcPos, _TargetPos, _TargetRadius, _CirRadius, _UpH, _DownH) -> 
	erlang:nif_error(undef).

%% 计算是否在环形内
calc_in_ring(_Map, _SrcPos, _TargetPos, _TargetRadius, _ORadis, _IRadis, _UpH, _DownH) -> 
	erlang:nif_error(undef).

%% 计算是否在扇形内
calc_in_sector(_Map, _SrcPos, _TargetPos, _SrcDir, _TargetRadius, _Radis, _SegAng, _UpH, _DownH) ->
	erlang:nif_error(undef).

%% 找一个从Pos2到Pos1的转向点
find_turn_dir_point(_MapId, _Pos1, _Pos2) ->	
	erlang:nif_error(undef).

