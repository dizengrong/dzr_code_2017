%% @doc 好友关系魔抗
-module (fun_relation_srv).
-include("common.hrl").
-export([init/0, handle_call/1, handle_msg/1, terminate/0, do_loop/1]).

init()->
	fun_relation_ex:init_data(),
	ok.

handle_call(Msg)->
	?log_error("~p unhandled message:~p", [?MODULE, Msg]),
	ok.

handle_msg({action,Action,Uid,Sid,Seq}) ->
	case Action of
		?ACTION_REQ_FRIEND_INFO -> fun_relation_ex:req_friend_info(Uid, Sid, Seq);
		?ACTION_REQ_ONE_DELETE_FRIEND_APPLY -> fun_relation_ex:req_one_delete_friend_apply(Uid, Sid, Seq);
		?ACTION_REQ_RECOMMEND_LIST -> fun_relation_ex:req_recommend_list(Uid, Sid, Seq);
		_ ->
			?log_error("receive unknown action:~p", [Action])
	end;

handle_msg({action_int,Action,Uid,Sid,Seq,Data}) ->
	case Action of				
		?ACTION_REQ_FRIEND_APPLY -> fun_relation_ex:req_friend_apply(Uid, Sid, Seq, Data);
		?ACTION_REQ_PASS_FRIEND_APPLY -> fun_relation_ex:req_pass_friend_apply(Uid, Sid, Seq, Data);
		?ACTION_REQ_DELETE_FRIEND_APPLY -> fun_relation_ex:req_delete_friend_apply(Uid, Sid, Seq, Data);
		?ACTION_REQ_DELETE_FRIEND -> fun_relation_ex:req_delete_friend(Uid, Sid, Seq, Data);
		?ACTION_REQ_FRIEND_TOP -> fun_relation_ex:req_friend_top(Uid, Sid, Seq, Data);
		_ -> 
			?log_error("receive unknown action:~p", [Action])
	end;

handle_msg({action_string,Action,Uid,Sid,Seq,Data})->
	case Action of
		?ACTION_REQ_SEARCH_FRIEND -> fun_relation_ex:req_search_friend(Uid, Sid, Seq, Data);
		_ ->
			?log_error("receive unknown action:~p", [Action])
	end;

handle_msg(Msg) -> 
	?log_error("~p unhandled message:~p", [?MODULE, Msg]).

terminate() -> 
	ok.

do_loop(_Now) -> 
	ok.