-module(write_ctrl).

-export([write/3,write/2]).

write(Module,CtrlModule,RdFile) ->
	Module:set_file(CtrlModule),
	Module:write(RdFile).

write(Module,CtrlModule) ->
	Module:set_file(CtrlModule),
	Module:write().