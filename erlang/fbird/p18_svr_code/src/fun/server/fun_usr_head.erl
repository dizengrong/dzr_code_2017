-module(fun_usr_head).
-include("common.hrl").
-export([check_data/1,check_add_playericon/2,add_playericon/3,req_rebirth_add_head/4]).
-export([get_headid/1]).
-export([req_usr_head/3,req_change_head/4]).
-export([req_head_lev_info/3,req_up_head_lev/4]).
-export([req_head_suit_info/3,req_active_suit_lev/4,req_up_suit_lev/4]).
-export([get_fighting/1,get_property/1]).

-define(OUT_USE, 0).
-define(IN_USE,  1).

check_data(Uid) ->
	case db:dirty_get(usr_head_info, Uid, #usr_head_info.uid) of
		[] ->
			HeadId = get_default_headid(Uid),
			db:insert(usr_head_info,#usr_head_info{uid = Uid, state = ?IN_USE, headid = HeadId}),
			do_check_data(Uid);
		_ -> do_check_data(Uid)
	end.

do_check_data(Uid) ->
	List = db:dirty_get(usr_head_info, Uid, #usr_head_info.uid),
	Prof = util:get_prof_by_uid(Uid),
	Time = fun_usr_misc:get_misc_data(Uid, relife_time),
	Fun = fun(HeadId) ->
		case lists:keyfind(HeadId, #usr_head_info.headid, List) of
			false ->
				#st_player_icon{type = Type, occupation = Oprof, typenum = Typenum} = data_player_icon:get_data(HeadId),
				if
					Type == "REBIRTH" andalso Oprof==Prof andalso Typenum =< Time ->
						db:insert(#usr_head_info{uid = Uid, state = ?OUT_USE, headid = HeadId});
					true -> skip
				end;
			_ -> skip
		end
	end,
	lists:foreach(Fun, data_player_icon:get_all()).

check_add_playericon(Uid, Headid) ->
	List = db:dirty_get(usr_head_info, Uid, #usr_head_info.uid),
	case lists:keyfind(Headid, #usr_head_info.headid, List) of
		false -> true;
		_ -> false
	end.

add_playericon(Uid, Sid, Headid)->
	List = db:dirty_get(usr_head_info,Uid, #usr_head_info.uid),
	case lists:keyfind(Headid, #usr_head_info.headid, List) of
		false -> db:insert(usr_head_info,#usr_head_info{uid=Uid,headid=Headid});
		_ -> skip
	end,	
	req_usr_head(Uid, Sid, 0).

get_headid(Uid)->
	List = db:dirty_get(usr_head_info,Uid, #usr_head_info.uid),
	case lists:keyfind(?IN_USE, #usr_head_info.state, List) of
		#usr_head_info{headid = HeadId} -> HeadId;
		_ -> get_default_headid(Uid)
	end.

get_default_headid(Uid)->
	Prof = util:get_prof_by_uid(Uid),
	case Prof of
		3 -> 1;
		6 -> 2;
		9 -> 3;
		_ ->
			case robot:get_data(Uid rem 100000) of
				#st_robot{headid = HeadId} -> HeadId;
				_ -> 0
			end
	end.

req_usr_head(Uid,Sid,Seq)->
	List = db:dirty_get(usr_head_info,Uid, #usr_head_info.uid),
	Headid = case lists:keyfind(?IN_USE, #usr_head_info.state, List) of
		false -> get_default_headid(Uid);
		#usr_head_info{headid = HeadId} -> HeadId
	end,
	Fun = fun(#usr_head_info{headid = THeadId}) ->
		#pt_public_usrid_list{headid = THeadId}
	end,
	HeadList = lists:map(Fun, List),
	Pt = #pt_usr_head{uid = Uid,useid = Headid,headlist = HeadList},
	?send(Sid, proto:pack(Pt, Seq)).

%%重生不可能是机器 人
req_rebirth_add_head(Uid,Sid,Seq,{Prof,Rebirthnum})->
	Fun = fun(Id) ->
		#st_player_icon{type = Type,occupation = Oprof,typenum = Typenum} = data_player_icon:get_data(Id),
		case Type == "REBIRTH" andalso Oprof == Prof andalso Typenum =< Rebirthnum of
			true -> true;
			_ -> false
		end
	end,
	Headlist = lists:filter(Fun, data_player_icon:get_all()),
	Fun2=fun(Iconid)->	
		List = db:dirty_get(usr_head_info,Uid, #usr_head_info.uid),
		case lists:keyfind(Iconid, #usr_head_info.headid, List) of
			false -> db:insert(usr_head_info,#usr_head_info{uid = Uid,state = ?OUT_USE,headid = Iconid});
			_ -> skip
		end
	end,
	lists:foreach(Fun2, Headlist),
	req_usr_head(Uid, Sid, Seq).
			
req_change_head(Uid,Sid,Seq,HeadId)->
	List = db:dirty_get(usr_head_info, Uid, #usr_head_info.uid),
	case lists:keyfind(?IN_USE, #usr_head_info.state, List) of
		false -> skip;
		Rec1 ->
			NewRec1 = Rec1#usr_head_info{state = ?OUT_USE},
			db:dirty_put(NewRec1)
	end,
	case lists:keyfind(HeadId, #usr_head_info.headid, List) of
		false -> skip;
		Rec2 ->
			NewRec2 = Rec2#usr_head_info{state = ?IN_USE},
			db:dirty_put(NewRec2)
	end,
	req_usr_head(Uid, Sid, Seq).

req_head_lev_info(Uid, Sid, Seq) ->
	List = db:dirty_get(usr_head_info, Uid, #usr_head_info.uid),
	Fun = fun(#usr_head_info{headid = HeadId, lev = Lev}) ->
		#pt_public_head_list{
			id  = HeadId,
			lev = Lev
		}
	end,
	Pt = #pt_head_lev_info{
		head_list = lists:map(Fun, List)
	},
	?send(Sid, proto:pack(Pt, Seq)).

req_up_head_lev(Uid, Sid, Seq, HeadId) ->
	List = db:dirty_get(usr_head_info, Uid, #usr_head_info.uid),
	case lists:keyfind(HeadId, #usr_head_info.headid, List) of
		Rec = #usr_head_info{lev = Lev} ->
			case data_head_lev:get_lev_data(HeadId, Lev) of
				#st_head_lev{cost = Cost} ->
					case data_head_lev:get_lev_data(HeadId, Lev + 1) of
						#st_head_lev{} ->
							SpendItems = [{?ITEM_WAY_HEAD_UP, T, N} || {T, N} <- Cost],
							Succ = fun() ->
								NewRec = Rec#usr_head_info{lev = Rec#usr_head_info.lev + 1},
								db:dirty_put(NewRec),
								fun_property:updata_fighting(Uid),
								req_head_lev_info(Uid, Sid, Seq)
							end,
							fun_item_api:check_and_add_items(Uid, Sid, SpendItems, [], Succ, undefined);
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

req_head_suit_info(Uid, Sid, Seq) ->
	List = db:dirty_get(usr_head_suit, Uid, #usr_head_suit.uid),
	Fun = fun(#usr_head_suit{suit_id = HeadId, lev = Lev}) ->
		#pt_public_head_list{
			id  = HeadId,
			lev = Lev
		}
	end,
	Pt = #pt_head_suit_info{
		suit_list = lists:map(Fun, List)
	},
	?send(Sid, proto:pack(Pt, Seq)).

req_active_suit_lev(Uid, Sid, Seq, SuitId) ->
	SuitList = db:dirty_get(usr_head_suit, Uid, #usr_head_suit.uid),
	HeadList = db:dirty_get(usr_head_info, Uid, #usr_head_info.uid),
	case lists:keyfind(SuitId, #usr_head_suit.suit_id, SuitList) of
		false ->
			case data_player_icon:get_suit(SuitId) of
				[] -> skip;
				L ->
					Fun = fun(HeadId) ->
						lists:keyfind(HeadId, #usr_head_info.headid, HeadList) /= false
					end,
					case length(lists:filter(Fun, L)) == length(L) of
						true ->
							db:insert(usr_head_suit,#usr_head_suit{uid = Uid, suit_id = SuitId}),
							fun_property:updata_fighting(Uid),
							req_head_suit_info(Uid, Sid, Seq);
						_ -> skip
					end
			end;
		_ -> skip
	end.

req_up_suit_lev(Uid, Sid, Seq, SuitId) ->
	List = db:dirty_get(usr_head_suit, Uid, #usr_head_suit.uid),
	case lists:keyfind(SuitId, #usr_head_suit.suit_id, List) of
		Rec = #usr_head_suit{lev = Lev} -> 
			case data_head_lev:get_suit_data(SuitId, Lev) of
				#st_head_suit{need_lev = NeedLev} ->
					case data_head_lev:get_suit_data(SuitId, Lev + 1) of
						#st_head_suit{} ->
							L = data_player_icon:get_suit(SuitId),
							HeadList = db:dirty_get(usr_head_info, Uid, #usr_head_info.uid),
							Fun = fun(HeadId) ->
								case lists:keyfind(HeadId, #usr_head_info.headid, HeadList) of
									#usr_head_info{lev = HeadLev} -> 
										if
											HeadLev >= NeedLev -> true;
											true -> false
										end;
									_ -> false
								end
							end,
							case length(lists:filter(Fun, L)) == length(L) of
								true ->
									NewRec = Rec#usr_head_suit{lev = Rec#usr_head_suit.lev + 1},
									db:dirty_put(NewRec),
									fun_property:updata_fighting(Uid),
									req_head_suit_info(Uid, Sid, Seq);
								_ -> skip
							end;
						_ -> skip
					end;
				_ -> skip
			end;
		_ -> skip
	end.

get_fighting(Uid) ->
	HeadList = db:dirty_get(usr_head_info, Uid, #usr_head_info.uid),
	SuitList = db:dirty_get(usr_head_suit, Uid, #usr_head_suit.uid),
	Fun1 = fun(#usr_head_info{headid = HeadId, lev = Lev}, Acc) ->
		case data_head_lev:get_lev_data(HeadId, Lev) of
			#st_head_lev{gs = Gs} -> Acc + Gs;
			_ -> Acc
		end
	end,
	Fun2 = fun(#usr_head_suit{suit_id = SuitId, lev = Lev}, Acc) ->
		case data_head_lev:get_suit_data(SuitId, Lev) of
			#st_head_suit{gs = Gs} -> Acc + Gs;
			_ -> Acc
		end
	end,
	lists:foldl(Fun1, 0, HeadList) + lists:foldl(Fun2, 0, SuitList).

get_property(Uid) ->
	HeadList = db:dirty_get(usr_head_info, Uid, #usr_head_info.uid),
	SuitList = db:dirty_get(usr_head_suit, Uid, #usr_head_suit.uid),
	Fun1 = fun(#usr_head_info{headid = HeadId, lev = Lev}, Acc) ->
		case data_head_lev:get_lev_data(HeadId, Lev) of
			#st_head_lev{prop = Prop} -> lists:append(Prop, Acc);
			_ -> Acc
		end
	end,
	Fun2 = fun(#usr_head_suit{suit_id = SuitId, lev = Lev}, Acc) ->
		case data_head_lev:get_suit_data(SuitId, Lev) of
			#st_head_suit{prop = Prop} -> lists:append(Prop, Acc);
			_ -> Acc
		end
	end,
	lists:append(lists:foldl(Fun1, [], HeadList), lists:foldl(Fun2, [], SuitList)).