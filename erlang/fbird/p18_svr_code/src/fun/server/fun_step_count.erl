%% 个人用计数器
-module(fun_step_count).
-include("common.hrl").
-export([transform_type/1,init_step_data/3,get_rank_num/1,transform_re_type/1]).

-define(INIT_TYPE_NUM,0).


transform_type(pass_copy) -> 1;
transform_type(monsters) -> 2;
transform_type(add_friend) -> 3;
transform_type(eqp_lev) -> 4;
transform_type(break_eqp) -> 5;
transform_type(recycle_eqp) -> 6;
transform_type(equip_compose) -> 7;
transform_type(enter_geo) -> 8;
transform_type(hero_lev) -> 9;
transform_type(purple_eqp) -> 10;
transform_type(ride_lev) -> 11;
transform_type(ch_lev) -> 12;
transform_type(skill_lev) -> 13;
transform_type(pass_pk) -> 14;
transform_type(two_star_hero) -> 15;
transform_type(orange_eqp) -> 16;
transform_type(all_star) -> 17;
transform_type(gem_up) -> 18;
transform_type(shenqi_up) -> 19;
transform_type(fighting) -> 20;
transform_type(hero_skill_lev) -> 21;
transform_type(max_gem_lv) -> 22;
transform_type(quick_fight) -> 23;
transform_type(arena_rank) -> 24;
transform_type(arena_rank_8) -> 25;
transform_type(arena_rank_7) -> 26;
transform_type(arena_rank_6) -> 27;
transform_type(arena_rank_5) -> 28;
transform_type(arena_rank_4) -> 29;
transform_type(arena_rank_3) -> 30;
transform_type(arena_rank_2) -> 31;
transform_type(arena_rank_1) -> 32;
transform_type(enter_pk) -> 33;
transform_type(purple_hero) -> 34;
transform_type(orange_hero) -> 35;
transform_type(two_skill_lev) -> 36;
transform_type(three_skill_lev) -> 37;
transform_type(four_skill_lev) -> 38;
transform_type(pass_military_boss) -> 39;
transform_type(_) -> 0.

transform_re_type(1) ->  pass_copy;
transform_re_type(2) ->  monsters;
transform_re_type(3) ->  add_friend;
transform_re_type(4) ->  eqp_lev;
transform_re_type(5) ->  break_eqp;
transform_re_type(6) ->  recycle_eqp;
transform_re_type(7) ->  equip_compose;
transform_re_type(8) ->  enter_geo;
transform_re_type(9) ->  hero_lev;
transform_re_type(10) ->  purple_eqp;
transform_re_type(11) ->  ride_lev;
transform_re_type(12) ->  ch_lev;
transform_re_type(13) ->  skill_lev;
transform_re_type(14) ->  pass_pk;
transform_re_type(15) ->  two_star_hero;
transform_re_type(16) ->  orange_eqp;
transform_re_type(17) ->  all_star;
transform_re_type(18) ->  gem_up;
transform_re_type(19) ->  shenqi_up;
transform_re_type(20) ->  fighting;
transform_re_type(21) ->  hero_skill_lev;
transform_re_type(22) ->  max_gem_lv;
transform_re_type(23) ->  quick_fight;
transform_re_type(24) ->  arena_rank;
transform_re_type(25) ->  arena_rank_8;
transform_re_type(26) ->  arena_rank_7;
transform_re_type(27) ->  arena_rank_6;
transform_re_type(28) ->  arena_rank_5;
transform_re_type(29) ->  arena_rank_4;
transform_re_type(30) ->  arena_rank_3;
transform_re_type(31) ->  arena_rank_2;
transform_re_type(32) ->  arena_rank_1;
transform_re_type(33) ->  enter_pk;
transform_re_type(34) ->  purple_hero;
transform_re_type(35) ->  orange_hero;
transform_re_type(36) ->  two_skill_lev;
transform_re_type(37) ->  three_skill_lev;
transform_re_type(38) ->  four_skill_lev;
transform_re_type(39) ->  pass_military_boss;
transform_re_type(_) -> ok.

init_step_data(_Sort, 1, _Uid) -> 1;
init_step_data(_Sort, 2, _Uid) -> ?INIT_TYPE_NUM;
init_step_data(_Sort, 3, _Uid) -> ?INIT_TYPE_NUM;
init_step_data(_Sort, 4, Uid) -> fun_item_improve:get_all_eqp_lev(Uid);
init_step_data(_Sort, 5, _Uid) -> ?INIT_TYPE_NUM;
init_step_data(_Sort, 6, _Uid) -> ?INIT_TYPE_NUM;
init_step_data(_Sort, 7, _Uid) -> ?INIT_TYPE_NUM;
init_step_data(_Sort, 8, _Uid) -> ?INIT_TYPE_NUM;
init_step_data(_Sort, 9, Uid) -> fun_entourage:get_all_entourage_max_lv(Uid);
init_step_data(_Sort, 10, Uid) -> fun_item:get_eqp_color_num(Uid, 4);
init_step_data(_Sort, 11, Uid) -> 
	[Rec] = db:dirty_get(usr_rides, Uid, #usr_rides.uid),
	Rec#usr_rides.type;
init_step_data(_Sort, 12, Uid) -> 
	[Rec] = db:dirty_get(usr, Uid),
	Rec#usr.lev;
init_step_data(_Sort, 13, Uid) -> fun_learn_skill:get_all_skill_max_lv(Uid);
init_step_data(_Sort, 14, _Uid) -> ?INIT_TYPE_NUM;
init_step_data(_Sort, 15, Uid) -> fun_entourage:get_two_star_num(Uid);
init_step_data(_Sort, 16, Uid) -> fun_item:get_eqp_color_num(Uid, 5);
init_step_data(_Sort, 17, Uid) -> fun_item_improve:get_all_star_num(Uid);
init_step_data(_Sort, 18, _Uid) -> ?INIT_TYPE_NUM;
init_step_data(_Sort, 20, Uid) -> fun_property:updata_fighting(Uid);
init_step_data(_Sort, 21, Uid) -> fun_entourage:get_all_entourage_max_skill_lv(Uid);
init_step_data(_Sort, 23, _Uid) -> ?INIT_TYPE_NUM;
init_step_data(_Sort, 24, Uid) -> get_rank(Uid);
init_step_data(_Sort, 25, Uid) -> get_rank(Uid);
init_step_data(_Sort, 26, Uid) -> get_rank(Uid);
init_step_data(_Sort, 27, Uid) -> get_rank(Uid);
init_step_data(_Sort, 28, Uid) -> get_rank(Uid);
init_step_data(_Sort, 29, Uid) -> get_rank(Uid);
init_step_data(_Sort, 30, Uid) -> get_rank(Uid);
init_step_data(_Sort, 31, Uid) -> get_rank(Uid);
init_step_data(_Sort, 32, Uid) -> get_rank(Uid);
init_step_data(_Sort, 33, _Uid) -> ?INIT_TYPE_NUM;
init_step_data(_Sort, 34, Uid) -> fun_entourage:get_purple_num(Uid);
init_step_data(_Sort, 35, Uid) -> fun_entourage:get_orange_num(Uid);
init_step_data(_Sort, 36, Uid) -> fun_relife_task:get_skill_num(Uid, fun_step_count:transform_re_type(36));
init_step_data(_Sort, 37, Uid) -> fun_relife_task:get_skill_num(Uid, fun_step_count:transform_re_type(37));
init_step_data(_Sort, 38, Uid) -> fun_relife_task:get_skill_num(Uid, fun_step_count:transform_re_type(38));
init_step_data(_, _, _) -> ?INIT_TYPE_NUM.


get_rank(Uid) ->
	case fun_arena:get_arena_max_rank(Uid) of
		0 -> 2000;
		Rank -> Rank
	end.

get_rank_num(Type) ->
	case Type of
		25 -> 800;
		26 -> 600;
		27 -> 500;
		28 -> 300;
		29 -> 200;
		30 -> 100;
		31 -> 1000;
		32 -> 900;
		_ -> 0
	end.