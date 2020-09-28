-module(mod_off_line).
-include("common.hrl").

-export([agent_usr_login/0]).
% -export([get_off_line_award/4,send_msg/3]).

-define(WHITE_COLOR,1).
-define(GREEN_COLOR,2).
-define(BLUE_COLOR,3).

agent_usr_login() -> skip.