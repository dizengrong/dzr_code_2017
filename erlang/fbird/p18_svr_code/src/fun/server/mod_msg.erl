-module(mod_msg).

-export([send_to_agnetmng/1,send_to_scenemng/1]).
-export([handle_to_agnetmng/2,handle_to_scenemng/2]).

-export([send_to_scenesvr/2,send_to_agent/2,send_to_scene/2]).
-export([handle_to_scenesvr/3,handle_to_agent/3,handle_to_scene/3]).
-export([handle_to_http_client/2]).
-export([handle_to_toplist_mng/1]).
-export([handle_to_chat_server/1]).
-export([send_to_familymng/1,handle_to_familymng/2]).

send_to_agnetmng(Msg) -> gen_server:cast(agent_mng, Msg).
handle_to_agnetmng(Module,Msg) -> send_to_agnetmng({handle_msg,Module,Msg}).
handle_to_http_client(Module,Msg) -> gen_server:cast(http_client, {handle_msg,Module,Msg}).

send_to_scenemng(Msg) -> gen_server:cast(scene_mng, Msg).
handle_to_scenemng(Module,Msg) -> send_to_scenemng({handle_msg,Module,Msg}).

send_to_scenesvr(Hid,Msg) -> gen_server:cast(Hid, Msg).
handle_to_scenesvr(Hid,Module,Msg) -> send_to_scenesvr(Hid, {handle_msg,Module,Msg}).

send_to_agent(Hid,Msg) -> gen_server:cast(Hid, Msg).
handle_to_agent(Hid,Module,Msg) -> send_to_agent(Hid, {handle_msg,Module,Msg}).

send_to_scene(Hid,Msg) -> gen_server:cast(Hid, Msg).
handle_to_scene(Hid,Module,Msg) -> send_to_scene(Hid, {handle_msg,Module,Msg}).


handle_to_toplist_mng(Msg) ->
	gen_server:cast(toplist_mng, Msg).

handle_to_chat_server(Msg) ->
	gen_server:cast(chat_server, Msg).

send_to_familymng(Msg) -> gen_server:cast(family_mng, Msg).
handle_to_familymng(Module,Msg) -> send_to_familymng({handle_msg,Module,Msg}).