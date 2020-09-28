-module(db).
-include("common.hrl").
-export([stop/0, do/1]).
-export([delete/2,getlocal/2,put/1,peek/2]).
-export([insert/1, insert/2]).
-export([getOrLoadData/4,getOrFindData/4,getOrKeyFindData/2]).

-export([get_config/1,get_all_config/1]).
-export([get_temp_data/1, set_temp_data/2, del_temp_data/1]).

-export([tran_get/2,tran_get/3,dirty_get/2,dirty_get/3,tran_put/1,dirty_put/1,tran_match/2,dirty_match/2,tran_del/2,dirty_del/2
		,get_new_scene_id/0,get_new_team_id/0,get_new_match_team_id/0,dirty_select/2,dirty_all_keys/1]).

-export([get_usr_by_aid/1,get_usr_by_name/1,get_usr/2,load_usrs_by_aid/1]).


-export([get_uid_mastery/2,
		 load_all/1
		]).




get_new_team_id()-> 
	db_uid:temp_new_id(sys_team).
get_new_scene_id() ->
	db_uid:temp_new_id(sys_scene).
get_new_match_team_id()->
	db_uid:temp_new_id(sys_match_team).

%%config
get_all_config(Key) -> 
	server_config:get_conf(Key).

get_config(Key) ->
	server_config:get_conf(Key).


get_temp_data(Key) -> 
	case dirty_get(t_temp_data, Key) of
		[#t_temp_data{val = Val}] -> Val;
		_ -> undefined
	end.

set_temp_data(Key, Val) -> 
	dirty_put(#t_temp_data{key = Key, val = Val}).

del_temp_data(Key) ->
	dirty_del(t_temp_data, Key).


peek(Table,Key)->
	mnesia:dirty_read({Table, Key}).

insert(Rec) when not is_record(Rec, item) -> 
	Rec2 = setelement(2, Rec, db_uid:new_id(element(1, Rec))),
	mnesia:dirty_write(Rec2),
	[Rec2].
insert(Tab, Rec) when not is_record(Rec, item) -> 
	Rec2 = setelement(2, Rec, db_uid:new_id(Tab)),
	mnesia:dirty_write(Rec2),
	[Rec2].

stop() ->
    mnesia:stop().


delete(Table,Key)->
	 case mnesia:transaction(fun() -> mnesia:delete({Table, Key}) end) of
        {atomic, _} -> ok;
        _ -> []
    end.


getlocal(Table,Key)when erlang:is_integer(Key)->
	case mnesia:transaction(fun() -> mnesia:read({Table, Key}) end) of
        {atomic, Result} -> Result;
        _ -> []
    end;	
getlocal(Table,Pat) ->
	case mnesia:transaction(fun() -> mnesia:match_object(Table, Pat, read) end) of
        {atomic, E} -> E;
        _ -> []
	end.


put(Record) ->	tran_put(Record).


tran_get(Tab,Key) -> 
	case mnesia:transaction(fun() -> mnesia:read(Tab, Key) end) of
		{atomic, E} -> E;
		Other -> ?log_error("tran_get error Tab=~p,Key=~p,Other=~p",[Tab,Key,Other]),[]
	end.
tran_get(Tab,Key,KeyPos) -> 
	case mnesia:transaction(fun() -> mnesia:index_read(Tab, Key, KeyPos) end) of
		{atomic, E} -> E;
		Other -> ?log_error("tran_get error Tab=~p,Key=~p,KeyPos=~p,Other=~p",[Tab,Key,KeyPos,Other]),[]
	end.
dirty_get(Tab,Key) ->
	case mnesia:dirty_read(Tab, Key) of
		L when erlang:is_list(L) -> L;
		Other -> ?log_error("dirty_get error Tab=~p,Key=~p,Other=~p",[Tab,Key,Other]),[]
	end.
				 
dirty_get(Tab,Key,KeyPos) when Tab /= item ->
	case mnesia:dirty_index_read(Tab, Key, KeyPos) of
		L when erlang:is_list(L) -> L;
		Other -> ?log_error("dirty_get error Tab=~p,Key=~p,KeyPos=~p,Other=~p",[Tab,Key,KeyPos,Other]),[]
	end.

tran_put(Rec) ->
	case mnesia:transaction(fun() -> mnesia:write(Rec) end) of
		{atomic, E} -> {atomic, E};
		Other -> 
			?log_error("tran_put error Rec=~p,Other=~p",[Rec,Other]),Other
	end.

dirty_put(Rec) when not is_record(Rec, item) ->
	case mnesia:dirty_write(Rec) of 
		ok -> ok;
		Other -> ?log_error("dirty_put error Rec=~p,Other=~p",[Rec,Other]),fail
	end.

tran_match(Tab,Pat)->
	case mnesia:transaction(fun() -> mnesia:match_object(Tab, Pat, read) end) of
        {atomic, E} -> E;
        Other -> ?log_error("tran_match error Tab=~p,Pat=~p,Other=~p",[Tab,Pat,Other]),[]
	end.

dirty_match(Tab,Pat)->
	case mnesia:dirty_match_object(Tab,Pat) of
		L when erlang:is_list(L) -> L;
		Other -> ?log_error("dirty_match error Tab=~p,Pat=~p,Other=~p",[Tab,Pat,Other]),[]
	end.

tran_del(Tab, Key) ->
  	case mnesia:transaction(fun() -> mnesia:delete({Tab, Key}) end) of
		{atomic, E} -> E;
		Other -> ?log_error("tran_del error Tab=~p,Key=~p,Other=~p",[Tab,Key,Other]),[]
	end.

dirty_del(Tab, Key) when Tab /= item ->
  	mnesia:dirty_delete(Tab, Key).

dirty_select(Tab,MatchSpec)->
	case mnesia:dirty_select(Tab, MatchSpec) of
		L when erlang:is_list(L) -> L;
		Other -> ?log_error("dirty_select error Tab=~p,MatchSpec=~p,Other=~p",[Tab,MatchSpec,Other]),[]
	end.

dirty_all_keys(Tab) ->
	mnesia:dirty_all_keys(Tab).

do(Q) ->
    F = fun() -> qlc:e(Q) end,
    {atomic, Val} = mnesia:transaction(F),
    Val.


getOrLoadData(Tab,Key,KeyPos,_KeyName)->
	dirty_get(Tab,Key,KeyPos).

getOrFindData(Tab,Key,KeyPos,_KeyName)->
	dirty_get(Tab,Key,KeyPos).

getOrKeyFindData(Tab,Key)->
	dirty_get(Tab,Key).

load_usrs_by_aid(Aid) ->
    get_usr_by_aid(Aid).

get_usr_by_aid(Aid) -> tran_get(usr,Aid,#usr.acc_id).
get_usr_by_name(Name) -> tran_get(usr,Name,#usr.name).
get_usr(Uid, ?TRUE) when is_integer(Uid) ->
	get_usr(Uid);
get_usr(Name, ?TRUE) when is_list(Name) ->
    get_usr(Name).


get_usr(Uid) when is_integer(Uid) ->
	dirty_get(usr, Uid);
get_usr(Name) when is_list(Name) ->
	dirty_get(usr,util:to_binary(Name),#usr.name).

get_uid_mastery(Uid,?TRUE)->
	get_uid_mastery(Uid).
get_uid_mastery(Uid) when is_integer(Uid)->
	dirty_get(mastery,Uid,#mastery.pid).

%% 获取所有记录
load_all(Tab) -> 
	List = dirty_all_keys(Tab),
	load_all_help(Tab, List, []).

load_all_help(Tab, [Key | Rest], Acc) ->
	load_all_help(Tab, Rest, [hd(dirty_get(Tab, Key)) | Acc]);
load_all_help(_Tab, [], Acc) -> 
	lists:reverse(Acc).

