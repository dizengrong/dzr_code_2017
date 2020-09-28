%% @doc lib_map_module的nif实现
-module (lib_c_map_module).
-include("common.hrl").
-compile(export_all).

set_module(Name) ->
	put(c_map_id, map_res_2_c_map_id(Name)).


check_point(#map_point{x = InX, y = InY, z = InZ}) -> 
	% ?DEBUG("before call check_point:~w", [{InX, InY, InZ}]),
	case cerl_map_api:check_point(get(c_map_id), float(InX) , float(InY), float(InZ)) of
		{X, Y, Z} -> {true, 0, #map_point{x = X, y = Y, z = Z}};
		_ -> 0
	end.


check_dir_by_point(PointFrom, PointTo) -> 
	% ?DEBUG("before call check_dir_by_point, PointFrom:~w, PointTo:~w", [PointFrom, PointTo]),
	#map_point{x = FromX, y = FromY, z = FromZ} = PointFrom,
	#map_point{x = ToX, y = ToY, z = ToZ} = PointTo,
	case cerl_map_api:check_dir_by_point(get(c_map_id), {float(FromX), float(FromY), float(FromZ)}, {float(ToX), float(ToY), float(ToZ)}) of
		{X, Y, Z} -> {true, 0, #map_point{x = X, y = Y, z = Z}};
		_ -> 0
	end.


check_dir(PointFrom,Dir,MaxDis) ->
	% ?DEBUG("before call check_dir, PointFrom:~w, Dir:~w, MaxDis:~w", [PointFrom, Dir, MaxDis]),
	#map_point{x = FromX, y = FromY, z = FromZ} = PointFrom,
	#map_point{x = DirX, y = DirY, z = DirZ} = Dir,
	case cerl_map_api:check_dir(get(c_map_id), float(MaxDis), {float(FromX), float(FromY), float(FromZ)}, {float(DirX), float(DirY), float(DirZ)}) of
		{X, Y, Z} -> {true, 0, #map_point{x = X, y = Y, z = Z}};
		_ -> 0
	end.

calc_in_rect({SrcX, SrcY, SrcZ}, {TargetX, TargetY, TargetZ}, SrcDir, TargetRadius, RL, RW, UpH, DownH) -> 
	Ret = cerl_map_api:calc_in_rect(get(c_map_id), {float(SrcX), float(SrcY), float(SrcZ)}, 
								{float(TargetX), float(TargetY), float(TargetZ)}, 
								float(SrcDir), float(TargetRadius), float(RL), float(RW), float(UpH), float(DownH)),
	Ret == 1.

calc_in_cir({SrcX, SrcY, SrcZ}, {TargetX, TargetY, TargetZ}, TargetRadius, CirRadius, UpH, DownH) -> 
	Ret = cerl_map_api:calc_in_cir(get(c_map_id), {float(SrcX), float(SrcY), float(SrcZ)}, 
								{float(TargetX), float(TargetY), float(TargetZ)}, 
								float(TargetRadius), float(CirRadius), float(UpH), float(DownH)),
	Ret == 1.

calc_in_ring({SrcX, SrcY, SrcZ}, {TargetX, TargetY, TargetZ}, TargetRadius, ORadis,IRadis, UpH, DownH) -> 
	Ret = cerl_map_api:calc_in_ring(get(c_map_id), {float(SrcX), float(SrcY), float(SrcZ)}, 
								{float(TargetX), float(TargetY), float(TargetZ)}, 
								float(TargetRadius), float(ORadis), float(IRadis), float(UpH), float(DownH)),
	Ret == 1.

calc_in_sector({SrcX, SrcY, SrcZ}, {TargetX, TargetY, TargetZ}, SrcDir, TargetRadius, Radis, SegAng, UpH, DownH) -> 
	Ret = cerl_map_api:calc_in_sector(get(c_map_id), {float(SrcX), float(SrcY), float(SrcZ)}, 
								{float(TargetX), float(TargetY), float(TargetZ)}, 
								float(SrcDir), float(TargetRadius), float(Radis), float(SegAng), float(UpH), float(DownH)),
	Ret == 1.

find_turn_dir_point(X1, Y1, Z1, X2, Y2, Z2) ->
	{X, Y, Z, Dir} = cerl_map_api:find_turn_dir_point(get(c_map_id), {float(X1), float(Y1), float(Z1)}, {float(X2), float(Y2), float(Z2)}),
	{{X, Y, Z}, Dir}.


map_res_2_c_map_id(m_d_003_nav_01) -> 1;
map_res_2_c_map_id(s_f_02_04_nav_01) -> 2;
map_res_2_c_map_id(m_f_001_nav_01) -> 3.