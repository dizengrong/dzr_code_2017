-module(ptc_ret_guide_tag_point).


-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#E129.

get_name() ->ret_guide_tag_point.

get_des() ->
	[
      {wave,uint32,0},
      {x,uint32,0},
      {y,uint32,0},
      {z,uint32,0},
      {mx,uint32,0},
      {my,uint32,0},
      {mz,uint32,0}
	].

get_note() ->"二货
	二货2". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).