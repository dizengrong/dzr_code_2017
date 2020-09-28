-module (fun_guild_copy_progress).
-include("common.hrl").
-export([handle/1]).
-export([get_guildcopy_progress/2]).
-export([set_kill_info/3]).

handle({set_guild_copy_progress, Wave, Progress, GuildId, Scene}) ->
	List = db:dirty_get(guild_boss_progress, GuildId, #guild_boss_progress.guild_id),
	case lists:keyfind(Scene, #guild_boss_progress.scene_id, List) of
		Rec = #guild_boss_progress{} ->
			Rec2 = Rec#guild_boss_progress{wave = Wave, progress = util:term_to_string(Progress)},
			db:dirty_put(Rec2);
		_ ->
			case data_guild_copy:select(Scene) of
				[] -> ?log_warning("Scene is not a guild copy scene : ~p", [Scene]);
				CopyList ->
					CopyId = hd(CopyList),
					NewRec = #guild_boss_progress{guild_id = GuildId, copy_id = CopyId, scene_id = Scene, wave = Wave, progress = util:term_to_string(Progress)},
					db:insert(NewRec)
			end
	end.

get_guildcopy_progress(GuildId,Scene) ->
	List = db:dirty_get(guild_boss_progress, GuildId, #guild_boss_progress.guild_id),
	case lists:keyfind(Scene, #guild_boss_progress.scene_id, List) of
		#guild_boss_progress{wave = Wave, progress = Progress} ->
			{Wave, util:string_to_term(util:to_list(Progress))};
		_ -> {0,{}}
	end.

set_kill_info(Wave, GuildId, Scene) ->
	Now = util_time:unixtime(),
	List = db:dirty_get(guild_boss_progress, GuildId, #guild_boss_progress.guild_id),
	case lists:keyfind(Scene, #guild_boss_progress.scene_id, List) of
		Rec = #guild_boss_progress{} ->
			Rec2 = Rec#guild_boss_progress{wave = Wave, kill_time = Now},
			db:dirty_put(Rec2);
		_ ->
			case data_guild_copy:select(Scene) of
				[] -> ?log_warning("Scene is not a guild copy scene : ~p", [Scene]);
				CopyList ->
					CopyId = hd(CopyList),
					NewRec = #guild_boss_progress{guild_id = GuildId, copy_id = CopyId, scene_id = Scene, wave = Wave, kill_time = Now},
					db:insert(NewRec)
			end
	end.