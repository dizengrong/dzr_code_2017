%% @doc 公会boss伤害和击杀奖励
-module (fun_guild_damage).
-include("common.hrl").
-export([add_usr_damage/3]).
-export([req_guild_copy_damage/4, send_damage_reward_to_client/4]).
-export([req_get_guild_damage_reward/6]).
-export([get_usr_damage/2,get_top/2]).
-export([refresh_top_list/1]).

-define(MAX_RANK,20).

get_data(Uid, Id) ->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok, GuildId, _} ->
			List = db:dirty_get(guild_damage, Uid, #guild_damage.uid),
			case lists:keyfind(Id, #guild_damage.copy_id, List) of
				Rec = #guild_damage{} ->
					KillFetched = Rec#guild_damage.kill_fetched,
					DamageFetched = Rec#guild_damage.damage_fetched,
					Rec#guild_damage{
						kill_fetched   = util:string_to_term(util:to_list(KillFetched)),
						damage_fetched = util:string_to_term(util:to_list(DamageFetched))
					};
				_ -> #guild_damage{uid = Uid, copy_id = Id, guild_id = GuildId}
			end;
		_ -> skip
	end.

set_data(Rec) ->
	Rec2 = Rec#guild_damage{
		kill_fetched   = util:term_to_string(Rec#guild_damage.kill_fetched),
		damage_fetched = util:term_to_string(Rec#guild_damage.damage_fetched)
	},
	case Rec#guild_damage.id of
		0 -> db:insert(Rec2);
		_ -> db:dirty_put(Rec2)
	end.


add_usr_damage(Uid, Scene, Damage) when Damage > 0 ->
	case data_dungeons_config:get_dungeons(hd(data_dungeons_config:select(Scene))) of
		#st_dungeons_config{} ->
			Id = hd(data_guild_copy:select(Scene)),
			Rec = get_data(Uid, Id),
			?debug("Rec:~p", [Rec]),
			set_data(Rec#guild_damage{damage = Damage});
		_ -> skip
	end;
add_usr_damage(_Uid, _Scene, _Damage) -> skip.

%% 请求伤害排行
req_guild_copy_damage(Uid, Sid, Id, Seq)->
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok, _GuildId, _}->
			Rec = get_data(Uid, Id),
			List = get_top(Id, ?MAX_RANK),
			PtList = make_damage_rank_pt(List, [], 1),
			Pt =#pt_guild_copy_damage_ranking{
				my_damage                 = Rec#guild_damage.damage,
				guild_copy_damage_ranking = PtList
			},
			?send(Sid, proto:pack(Pt,Seq));
		_->skip
	end.

get_top(Id, GuildId) ->
	get_top(Id, GuildId, ?MAX_RANK).

get_top(Id, GuildId, Len) ->
	?debug("Id : ~p",[Id]),
	List = db:dirty_get(guild_damage, Id, #guild_damage.copy_id),
	Fun = fun(#guild_damage{guild_id = MGuildId}) ->
		MGuildId == GuildId
	end,
	List2 = lists:filter(Fun, List),
	List3 = lists:reverse(lists:keysort(#guild_damage.damage, List2)),
	case length(List3) > Len of
		true -> lists:sublist(List3, 1, 20);
		false -> List3
	end.


make_damage_rank_pt([], Acc, _Rank) -> lists:reverse(Acc);
make_damage_rank_pt([Rec | Rest], Acc, Rank) ->
	?debug("Rec:~p", [Rec]),
	[#usr{lev=Lev, prof=Prof, vip_lev=Vip_lev, name=Name}] = db:dirty_get(usr, Rec#guild_damage.uid),
	Ptm = #pt_public_guild_copy_damage_ranking{
		ranking    = Rank,
		uid        = Rec#guild_damage.uid,
		usr_name   = Name,
		prof       = Prof,
		lev        = Lev,
		vip_lev    = Vip_lev,
		damage_num = Rec#guild_damage.damage,
		position   = 0
	},
	make_damage_rank_pt(Rest, [Ptm | Acc], Rank + 1).


send_damage_reward_to_client(Uid, Sid, Id, Seq) -> 
	case fun_guild:get_guild_baseinfo(Uid) of
		{ok,_GuildId,_} ->
			Rec = get_data(Uid, Id),
			Pt = #pt_update_guild_boss_reward{
				my_damage          = Rec#guild_damage.damage,
				damage_reward_list = make_id_pt_list(Rec#guild_damage.damage_fetched),
				kill_reward_list   = make_id_pt_list(Rec#guild_damage.kill_fetched)
			},
			?send(Sid, proto:pack(Pt, Seq));
		_ -> skip
	end.

make_id_pt_list(List) ->
	Fun=fun(ID) ->
		#pt_public_id_list{id = ID}			
	end,	
	lists:map(Fun, List).

%%请求伤害奖励信息
req_get_guild_damage_reward(Uid, Sid, Seq, Id, Reward_id, Type) ->
	Rec = get_data(Uid, Id),
	case check_fetch(Rec, Reward_id, Type) of
		{error, Reason} -> ?error_report(Sid, Reason);
		{ok, Additem, FetchedIds} ->
			case Type of
				damage_reward ->
					SuccCallBack = fun() ->
						FetchedList = FetchedIds ++ Rec#guild_damage.damage_fetched,
						set_data(Rec#guild_damage{damage_fetched = FetchedList}),
						send_damage_reward_to_client(Uid, Sid, Id, Seq)
					end;
				kill_reward ->
					SuccCallBack = fun() ->
						FetchedList = FetchedIds ++ Rec#guild_damage.kill_fetched,
						set_data(Rec#guild_damage{kill_fetched = FetchedList}),
						send_damage_reward_to_client(Uid, Sid, Id, Seq)
					end
			end,
			fun_item_api:check_and_add_items(Uid, Sid, [], Additem, SuccCallBack, undefined)
	end.

check_fetch(Rec, Reward_id, damage_reward) -> 
	List = case Reward_id of
		0 -> data_cumulativedamage_config:get_all_id();
		_ -> [Reward_id]
	end,
	Damage = Rec#guild_damage.damage,
	Fun = fun(Id, {AccItem, AccId}) -> 
		case lists:member(Id, Rec#guild_damage.damage_fetched) of
			false -> 
				case data_cumulativedamage_config:get_data(Id) of
					#st_cumulativedamage_config{hurt = Hurt, reward = Reward} when Damage >= Hurt ->
						Additem = [{?ITEM_WAY_GUILD_BOSS_REWARD,Type,Num} || {Type,Num} <- Reward],
						{Additem ++ AccItem, [Id | AccId]};
					_ -> {AccItem, AccId}
				end;
			true -> {AccItem, AccId}
		end
	end,
	case lists:foldl(Fun, {[], []}, List) of
		{[], []} -> {error, "error_fetch_reward_not_reached"};
		{Additems, FetchedIds} -> {ok, Additems, FetchedIds}
	end;
check_fetch(Rec, Reward_id, kill_reward) -> 
	List = case Reward_id of
		0 -> data_eliminate_config:get_all_id();
		_ -> [Reward_id]
	end,
	{ok,GuildId,_} = fun_guild:get_guild_baseinfo(Rec#guild_damage.uid),
	Fun = fun(Id, {AccItem, AccId}) ->
		case lists:member(Id, Rec#guild_damage.kill_fetched) of
			false ->
				#st_eliminate_config{bossID=BossId, reward = Reward} = data_eliminate_config:get_data(Id),
				case fun_guild_boss:is_boss_killed(GuildId, BossId) of
					true ->
						Additem = [{?ITEM_WAY_GUILD_BOSS_REWARD,Type,Num} || {Type,Num} <- Reward],
						{Additem ++ AccItem, [Id | AccId]};
					_ -> {AccItem, AccId}
				end;
			true -> {AccItem, AccId}
		end
	end,
	case lists:foldl(Fun, {[], []}, List) of
		{[], []} -> {error, "error_fetch_reward_not_reached"};
		{Additems, FetchedIds} -> {ok, Additems, FetchedIds}
	end.

get_usr_damage(Uid, Id) ->
	Rec = get_data(Uid, Id),
	Rec#guild_damage.damage.

refresh_top_list(Id) ->
	List = db:dirty_get(guild_damage, Id, #guild_damage.copy_id),
	[db:dirty_del(guild_damage, Rec#guild_damage.id) || Rec <- List].
