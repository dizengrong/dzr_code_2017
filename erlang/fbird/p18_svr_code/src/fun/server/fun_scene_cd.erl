%% P18开始，所有的cd_check和mp_check一起进行（模块名就先不改了）
-module(fun_scene_cd).
-include("common.hrl").
-export([add_cd/3,get_cd_by_type/2,del_cd_by_type/2,update_skill_cd/2,clear_cd/1]).
-export([update_user_skill/2]).
-export([clear_entourage_cd/1]).

get_skill_mp(SkillType) ->
	#st_skillleveldata_config{mp = MP} = data_skillleveldata:get_skillleveldata(SkillType),
	MP.

add_cd(Obj=#scene_spirit_ex{mp=MP,cds=Cds},Type,Time) ->
	NeedMp = get_skill_mp(Type),
	Now = util:longunixtime(),
	if
		MP >= NeedMp ->
			case lists:keyfind(Type, #scene_cd.type, Cds) of
				#scene_cd{start=Start,lenth=Len} when Start + Len >= Now -> cding;
				_ ->
					List = lists:keystore(Type, #scene_cd.type, Cds, #scene_cd{type=Type,start=Now,lenth=Time*1000}),
					Obj#scene_spirit_ex{mp=MP-NeedMp,cds=List}
			end;
		true -> cding
	end.
 	
get_cd_by_type(#scene_spirit_ex{mp=MP,cds=Cds},Type) ->
	NeedMp = get_skill_mp(Type),
	Fun = fun(#scene_cd{type=ThisType}) ->
		if
			ThisType == Type -> true;
			MP < NeedMp -> true;
			true -> false
		end 
	end,
	lists:filter(Fun, Cds);
get_cd_by_type(_,_)-> [].

del_cd_by_type(Obj=#scene_spirit_ex{cds=Cds},Type) ->
	Fun = fun(#scene_cd{type=ThisType}) ->
		if
			ThisType == Type -> true;
			true -> false
		end 
	end,
	Obj#scene_spirit_ex{cds = lists:filter(Fun, Cds)};
del_cd_by_type(_Obj,_)->_Obj.

update_skill_cd(Obj=#scene_spirit_ex{cds=Cds},Now) ->	
	Fun1 = fun(#scene_cd{start = Start,lenth = Lenth}) ->
				   Dis = Start + Lenth,
				   if
					   Dis > Now -> true;
					   true -> false
				   end 
		   end,
	NCds =  lists:filter(Fun1, Cds),
%% 	?debug("----------------------update_skill_cd,cd=~p~n",[NCds]),
	Obj#scene_spirit_ex{cds = NCds};
update_skill_cd(Obj,_Now) -> Obj.

update_user_skill(Uid, NewSkills) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		Usr=#scene_spirit_ex{} ->
			% OldSkills = fun_scene_obj:get_usr_spc_data(Usr, skill_list),
			fun_scene_obj:update(fun_scene_obj:put_usr_spc_data(Usr, skill_list, NewSkills)),
			ok;	
		_ -> skip
	end.

clear_cd(ObjId) ->
	case fun_scene_obj:get_obj(ObjId,?SPIRIT_SORT_USR) of
		Obj = #scene_spirit_ex{data=#scene_usr_ex{sid=Sid}} ->
			clear_usr_cd_help(Sid, Obj);
		_ -> skip

	end.

clear_entourage_cd(Uid) ->
	case fun_scene_obj:get_obj(Uid, ?SPIRIT_SORT_USR) of
		#scene_spirit_ex{data= #scene_usr_ex{sid=Sid, battle_entourage = EL}} when length(EL) > 0 ->
			Fun = fun(Eid) ->
				case fun_scene_obj:get_obj(Eid, ?SPIRIT_SORT_ENTOURAGE) of
					Obj = #scene_spirit_ex{} ->
						clear_entourage_cd_help(Sid, Obj);
					_ -> skip
				end
			end,
			lists:foreach(Fun, EL);
		_ -> skip
	end.

clear_usr_cd_help(Sid, Obj) ->
	#scene_spirit_ex{data=#scene_usr_ex{skill_list=SkillList}} = Obj,
	NewObj = lists:foldl(
		fun({SkillType,_Lev}, NewObj) ->
			fun_scene_cd:del_cd_by_type(NewObj, SkillType)
		end, Obj, SkillList
	),
	fun_scene_obj:update(NewObj),
	Pt = #pt_clear_skill_cd{sort = ?SPIRIT_CLIENT_TYPE_USR},
	?send(Sid, proto:pack(Pt)).


clear_entourage_cd_help(Sid, Obj) ->
	#scene_spirit_ex{data=#scene_entourage_ex{skills=SkillList}} = Obj,
	NewObj = lists:foldl(
		fun({SkillType,_Lev}, NewObj) ->
			fun_scene_cd:del_cd_by_type(NewObj, SkillType)
		end, Obj, SkillList
	),
	fun_scene_obj:update(NewObj),
	Pt = #pt_clear_skill_cd{sort = ?SPIRIT_CLIENT_TYPE_ENTOURAGE},
	?send(Sid, proto:pack(Pt)).
