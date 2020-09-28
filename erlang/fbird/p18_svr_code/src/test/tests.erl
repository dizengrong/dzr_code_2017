-module (tests).
-compile(export_all).
-include("common.hrl").


init_map() -> 
	cerl_map_api:init(),
	lib_map_module:set_module(s_f_03_01_nav_01),
	lib_c_map_module:set_module(s_f_03_01_nav_01),
	ok.


test_performance() -> 
	init_map(),
	X1 = 32.051495, Y1 = 0.000000, Z1 = 50.226360,
	Times = 10000,
	E_check_point = timer:tc(fun() -> _ = [lib_map_module:check_point(#map_point{x = X1,y = Y1,z = Z1}) || _ <- lists:seq(1, Times)],ok end),
	C_check_point = timer:tc(fun() -> _ = [lib_c_map_module:check_point(#map_point{x = X1,y = Y1,z = Z1}) || _ <- lists:seq(1, Times)],ok end),
	Msg1 = "=============== check_point ===============",
	?DEBUG("~n~s~n\tErlang cost ~w~n\tC cost ~w", [Msg1, E_check_point, C_check_point]),


	X2 = 34.40667, Y2 = 43.52392, Z2 = 48.27333,
	X3 = 33.28, Y3 = 43.52392, Z3 = 55.81333,
	E_check_dir_by_point = timer:tc(fun() -> _ = [lib_map_module:check_dir_by_point(#map_point{x = X2,y = Y2,z = Z2}, #map_point{x = X3,y = Y3,z = Z3}) || _ <- lists:seq(1, Times)],ok end),
	C_check_dir_by_point = timer:tc(fun() -> _ = [lib_c_map_module:check_dir_by_point(#map_point{x = X2,y = Y2,z = Z2}, #map_point{x = X3,y = Y3,z = Z3}) || _ <- lists:seq(1, Times)],ok end),
	Msg2 = "=============== check_dir_by_point ===============",
	?DEBUG("~n~s~n\tErlang cost ~w~n\tC cost ~w", [Msg2, E_check_dir_by_point, C_check_dir_by_point]),


	MaxDis = 3.0,
	E_check_dir = timer:tc(fun() -> _ = [lib_map_module:check_dir(#map_point{x = X2,y = Y2,z = Z2}, #map_point{x = X3,y = Y3,z = Z3}, MaxDis) || _ <- lists:seq(1, Times)],ok end),
	C_check_dir = timer:tc(fun() -> _ = [lib_c_map_module:check_dir(#map_point{x = X2,y = Y2,z = Z2}, #map_point{x = X3,y = Y3,z = Z3}, MaxDis) || _ <- lists:seq(1, Times)],ok end),
	Msg3 = "=============== check_dir ===============",
	?DEBUG("~n~s~n\tErlang cost ~w~n\tC cost ~w", [Msg3, E_check_dir, C_check_dir]),
	ok.	


test_cerl_performance() -> 
	init_map(),
	X1 = 32.051495, Y1 = 0.000000, Z1 = 50.226360,
	Times = 100000,
	C_check_point = timer:tc(fun() -> _ = [lib_c_map_module:check_point(#map_point{x = X1,y = Y1,z = Z1}) || _ <- lists:seq(1, Times)],ok end),
	Msg1 = "=============== check_point ===============",
	?DEBUG("~n~s~n\tC cost ~w", [Msg1, C_check_point]),


	X2 = 34.40667, Y2 = 43.52392, Z2 = 48.27333,
	X3 = 33.28, Y3 = 43.52392, Z3 = 55.81333,
	C_check_dir_by_point = timer:tc(fun() -> _ = [lib_c_map_module:check_dir_by_point(#map_point{x = X2,y = Y2,z = Z2}, #map_point{x = X3,y = Y3,z = Z3}) || _ <- lists:seq(1, Times)],ok end),
	Msg2 = "=============== check_dir_by_point ===============",
	?DEBUG("~n~s~n\tC cost ~w", [Msg2, C_check_dir_by_point]),


	MaxDis = 3.0,
	C_check_dir = timer:tc(fun() -> _ = [lib_c_map_module:check_dir(#map_point{x = X2,y = Y2,z = Z2}, #map_point{x = X3,y = Y3,z = Z3}, MaxDis) || _ <- lists:seq(1, Times)],ok end),
	Msg3 = "=============== check_dir ===============",
	?DEBUG("~n~s~n\tC cost ~w", [Msg3, C_check_dir]),
	ok.	

test_check_point() -> 
	init_map(),
	test_ok = test_check_point(101.90274506047759, 0.0, 173.79469353183018),
	% test_ok = test_check_point(99.13964080810547, 20.066160202026367, 173.0933837890625),
	% test_ok = test_check_point(101, 0, 168),
	% test_ok = test_check_point(101, 0, 132),
	% test_ok = test_check_point(33, 0, 177),
	% test_ok = test_check_point(185, 0, 17),
	% test_ok = test_check_point(32.051495, 0.000000, 50.226360),
	% test_ok = test_check_point(24.40667, 33.52392, 38.27333),
	% test_ok = test_check_point(36.28, 48.52392, 50.81333),
	% test_ok = test_check_point(16.28, 8.52392, 30.81333),
	% test_ok = test_check_point(26.003, 81.0392, 36.81333),
	% test_ok = test_check_point(0, 0, 0),
	% test_ok = test_check_point(1, 1, 1),
	% test_ok = test_check_point(100, 1, 100),
	ok.

test_check_point(X, Y, Z) -> 
	Point = #map_point{x = X,y = Y,z = Z},
	ERet = lib_map_module:check_point(Point),
	timer:sleep(100),
	CRet = lib_c_map_module:check_point(Point),
	timer:sleep(100),
	?DBG(ERet),
	?DBG(CRet),
	case ERet of
		{_, _, #map_point{x = FindX1, y = FindY1, z = FindZ1}} -> 
			case CRet of
				{_, _, #map_point{x = FindX2, y = FindY2, z = FindZ2}} ->
					case abs(FindX1 - FindX2) < 0.0001 andalso 
						 abs(FindY1 - FindY2) < 0.0001 andalso
						 abs(FindZ1 - FindZ2) < 0.0001 of
						true -> test_ok;
						_ -> test_failed1
					end;
				_ -> test_failed2
			end;
		_ -> 
			case is_integer(CRet) of
				true -> 
					test_ok;
				_ -> 
					test_failed3
			end
	end.

test_check_dir_by_point() -> 
	init_map(),
	test_ok = test_check_dir_by_point({185.0,6.809873104095459,17.0}, {184.850192319858,6.769263949405006,10.039005957230184}),
	% test_ok = test_check_dir_by_point({101.972388,20.066160,173.722931}, {100.369310,20.056954,175.374795}),
	% test_ok = test_check_dir_by_point({103.0,20.066160202026367,170.0}, {101.85181543685741,20.066160202026367,170.53679525167226}),
	% test_ok = test_check_dir_by_point({34.40667, 43.52392, 48.27333}, {33.28, 43.52392, 55.81333}),
	% test_ok = test_check_dir_by_point({24.40667, 33.52392, 38.27333}, {36.28, 48.52392, 50.81333}),
	ok.

% lib_c_map_module:check_dir_by_point({map_point,103.0,20.066160202026367,170.0}, {map_point,101.85181543685741,20.066160202026367,170.53679525167226}).
% lib_map_module:find_dir_point({map_point, 101.972388, 20.066160, 173.722931}, {map_point, -1.60308075, 0.000, 1.65187073}, {527, 528, 529}).

test_check_dir_by_point({ X1, Y1, Z1}, {X2, Y2, Z2}) -> 
	P1 = #map_point{x = X1, y = Y1, z = Z1},
	P2 = #map_point{x = X2, y = Y2, z = Z2},
	ERet = lib_map_module:check_dir_by_point(P1, P2),
	% ERet = 1,
	timer:sleep(100),
	CRet = lib_c_map_module:check_dir_by_point(P1, P2),
	% CRet = -1,
	timer:sleep(100),
	io:format("~n~nERet:~p~n", [ERet]),
	io:format("CRet:~p~n", [CRet]),
	case ERet of
		{_, _, #map_point{x = FindX1, y = FindY1, z = FindZ1}} -> 
			case CRet of
				{_, _, #map_point{x = FindX2, y = FindY2, z = FindZ2}} ->
					case abs(FindX1 - FindX2) < 0.0001 andalso 
						 abs(FindY1 - FindY2) < 0.0001 andalso
						 abs(FindZ1 - FindZ2) < 0.0001 of
						true -> test_ok;
						_ -> test_failed1
					end;
				_ -> test_failed2
			end;
		_ -> 
			case is_integer(CRet) of
				true -> 
					test_ok;
				_ -> 
					test_failed3
			end
	end.


test_check_dir() ->
	init_map(),
	test_ok = test_check_dir(1.133593567563211, {98.35931396484375, 20.040956497192383, 172.2711181640625}, {1.64068603515625, 0.025203704833984375, 1.7288818359375}),
	% test_ok = test_check_dir(3.0, {34.40667, 43.52392, 48.27333}, {33.28, 43.52392, 55.81333}),
	% test_ok = test_check_dir(3.0, {24.40667, 33.52392, 38.27333}, {36.28, 48.52392, 50.81333}),
	% test_ok = test_check_dir(1.0, {14.40667, 33.52392, 38.27333}, {46.28, 48.52392, 50.81333}),
	% test_ok = test_check_dir(1.0, {14.40667, 33.52392, 38.27333}, {46.28, 28.52392, 20.81333}),
	ok.

test_check_dir(MaxDis, {X1, Y1, Z1}, {X2, Y2, Z2}) -> 
	P1 = #map_point{x = X1, y = Y1, z = Z1},
	P2 = #map_point{x = X2, y = Y2, z = Z2},
	ERet = lib_map_module:check_dir(P1, P2, MaxDis),
	timer:sleep(100),
	CRet = lib_c_map_module:check_dir(P1, P2, MaxDis),
	% CRet = MapId,
	timer:sleep(100),
	io:format("~n~nERet:~p~n", [ERet]),
	io:format("CRet:~p~n", [CRet]),
	case ERet of
		{_, _, #map_point{x = FindX1, y = FindY1, z = FindZ1}} -> 
			case CRet of
				{_, _, #map_point{x = FindX2, y = FindY2, z = FindZ2}} ->
					case abs(FindX1 - FindX2) < 0.0001 andalso 
						 abs(FindY1 - FindY2) < 0.0001 andalso
						 abs(FindZ1 - FindZ2) < 0.0001 of
						true -> test_ok;
						_ -> test_failed1
					end;
				_ -> test_failed2
			end;
		_ -> 
			case is_integer(CRet) of
				true -> 
					test_ok;
				_ -> 
					test_failed3
			end
	end.


test_c_map() ->
	log:start(),
	cerl_map_api:init(),
	lib_c_map_module:set_module(y_g_s_001_nav_01),
	Point = #map_point{x = 34,y = 0,z = 17},
	lib_c_map_module:check_point(Point),
	ok.


%% 这个测试是为了说明，执行nif调用时是会堵塞erlang调度器的，如果nif是比较耗时的
%% 那么性能会下降的。
%% 如果是8核，启动8个elrang调度器，下面的代码开启8个nif阻塞调用，VM就表现为卡死了
test_nif_sleep() -> 
    io:format("Locking the VM~n", []),
    Count = erlang:system_info(schedulers),
    lists:foreach(
        fun(_) -> spawn(fun() -> cerl_map_api:test_sleep(60000) end) end,
        lists:seq(1, Count)
    ),
	timer:sleep(1000).


test_cerl_api() -> 
	[test_angle2radian(Dir) || Dir <- [10.0, 123.2, 456.4, 840.0, -23.3, -91.9]],
	[test_radian2angle(R) || R <- [0.234, 1.239, 2.7698, 10.0, 123.2, 456.4, 840.0, -23.3, -91.9]],
	[test_get_vect_by_dir(Dir) || Dir <- [10.0, 123.2, 456.4, 840.0, -23.3, -91.9]],

	RolePos = {110.4712, 32.01172, 41.1874},
	Dir = 272.6166385648078,
	TargetPosList = [
		% {110.4712, 32.01172, 42.1874},
		% {104.4712, 32.01172, 40.1874},
		% {105.4712, 32.01172, 43.1874},
		{108.9704, 32.01172, 47.51064}
		% {108.4326, 32.01172, 45.82936},
		% {102.4712, 32.01172, 44.1874}
	],
	[test_calc_in_rect(RolePos, Dir, TPos, 1.25) || TPos <- TargetPosList],
	ok.

test_angle2radian(Dir) ->
	C = cerl_map_api:test_angle2radian(Dir),
	E = tool_vect:angle2radian(Dir),
	case abs(C - E) < 0.0001 of
		false -> 
			?ERROR("test_angle2radian failed, Dir:~p, c val:~p, e val: ~p", [Dir, C, E]);
		_ -> skip
	end.

test_radian2angle(R) ->
	C = cerl_map_api:test_radian2angle(R),
	E = tool_vect:radian2angle(R),
	case abs(C - E) < 0.001 of
		false -> 
			?ERROR("test_radian2angle failed, R:~p, c val:~p, e val: ~p", [R, C, E]);
		_ -> skip
	end.

test_get_vect_by_dir(Dir) ->
	{CX, CY, CZ} = cerl_map_api:test_get_vect_by_dir(Dir),
	#map_point{x = EX, y = EY, z = EZ} = tool_vect:get_vect_by_dir(Dir),
	case abs(CX - EX) < 0.0001 andalso 
		 abs(CY - EY) < 0.0001 andalso
		 abs(CZ - EZ) < 0.0001 of
		true -> test_ok;
		_ -> ?ERROR("test_get_vect_by_dir failed, Dir:~p, c val:~p, e val: ~p", [Dir, {CX, CY, CZ}, {EX, EY, EZ}])
	end.


test_calc_in_rect(Pos, Dir, Pos2, R) -> 
	ParList = [0,0,0,6,4,2,2],
	RL=lists:nth(?RECT_L, ParList), 
	RW=lists:nth(?RECT_W, ParList),
	UH=lists:nth(?RECT_UP_H, ParList), 
	DH=lists:nth(?RECT_DOWN_H, ParList),
	C = lib_c_map_module:calc_in_rect(Pos, Pos2, Dir, R, RL, RW, UH, DH),
	E = erl_calc_in_rect(Pos, Dir, Pos2, R, ParList),
	case C == E of
		false -> 
			?ERROR("test_calc_in_rect failed, ~nPos:~p, Dir:~p, ~nPos2:~p R:~p, c val:~p, e val: ~p", [Pos, Dir, Pos2, R, C, E]);
		_ -> skip
	end.


erl_calc_in_rect({X, Y, Z}, Dir, {X2, Y2, Z2}, R, ParList) ->
	RL=lists:nth(?RECT_L, ParList), 
	RW=lists:nth(?RECT_W, ParList),
	UH=lists:nth(?RECT_UP_H, ParList), 
	DH=lists:nth(?RECT_DOWN_H, ParList),
	NoYStartPos = {X,0,Z},
	NoYMonsterPos = {X2,0,Z2},
	H = Y2-Y,
	CheckHeight=check_collect_height(H,UH,DH),
	if 			  
	  CheckHeight == false -> false;										  
		  true ->
		  VD = tool_vect:get_vect_by_dir(tool_vect:angle2radian(Dir)), %%方向向量
		  ?DBG(VD),
		  ?DBG(tool_vect:dec(tool_vect:to_map_point(NoYMonsterPos),tool_vect:to_map_point(NoYStartPos))),
		  W = tool_vect:dot_line_dis(VD, tool_vect:dec(tool_vect:to_map_point(NoYMonsterPos),tool_vect:to_map_point(NoYStartPos))) - R,%%方向垂直的距离
		  if
			  W*2 > RW -> 
			  	?DBG({W*2, RW}),
			  	false; %%宽度
			  true ->
				  VL = tool_vect:get_vect_by_dir(tool_vect:angle2radian(Dir + 90)),%%方向垂直向量
				  D = tool_vect:dot_line_dis(VL, tool_vect:dec(tool_vect:to_map_point(NoYMonsterPos),tool_vect:to_map_point(NoYStartPos))) - R,%%方向的距离
				  if
					  D*2 > RL -> false; %%长度超出
					  true -> true			
				  end
		  end											  
	end.			

check_collect_height(H,UH,DH) ->
	H_abs=util:abs(H),
	if									
		H >= 0 andalso H > UH -> false;
		H < 0 andalso H_abs > DH -> false;									  
		true -> true		  
	end.

