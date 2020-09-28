%% -*- coding: latin-1 -*-
%% @doc 多语言处理
-module (util_lang).
-include("common.hrl").
-export([get_text_str/1, get_rank_str/1, get_title_name/1, get_mail/1]).
-export([get_item_name/1, get_scene_name/1]).
-export([get_robot_name/1, cant_words/0, get_entourage_name/1]).
% -export([get_item_rank_lv/1, get_mastery_name/1]).


get_rank_str(?T_RANK_ARENA)         -> get_text_str(242);
get_rank_str(_)                     -> "".


get_title_name(TitleId) ->
	#titles_set{titleName = Name} = data_titles_set:get_titles_set(TitleId),
	get_translation(Name).


get_text_str(Id) -> 
	Text = data_text:get_data(Id),
	get_translation(Text).


get_mail(MailId) ->
	#mail_content{mailName=Title,text=Content} = data_mail:data_mail(MailId),
	{get_translation(Title), get_translation(Content)}.


get_item_name(ItemType) ->
	#st_item_type{name=ItemName} = data_item:get_data(ItemType),
	get_translation(ItemName).

get_scene_name(Scene) ->
	#st_scene_config{name = Name} = data_scene_config:get_scene(Scene),
	get_translation(Name).


get_entourage_name(EType) ->
	#st_entourage_config{name=EntouraName} = data_entourage:get_data(EType),
	get_translation(EntouraName).


% get_mastery_name(ID) -> 
% 	#get_mastery{name=MasaterName} = data_mastery:get_mastery(ID),
% 	get_translation(MasaterName).


get_robot_name(Id) ->
	#st_robot{name=Name} = data_robot:get_data(Id),
	get_translation(Name).


cant_words() -> 
	unicode:characters_to_list(iolist_to_binary("~@#$&_`■")).


get_translation(Str) ->
	case server_config:get_conf(language) of
		zh_cn -> Str;
		zh_tw -> data_text_tw:get_data(Str);
		en    -> data_text_en:get_data(Str);
		ko    -> data_text_ko:get_data(Str)
	end.

