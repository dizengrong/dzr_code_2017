-module(ptc_usr_info_property).
-export([get_id/0,get_name/0,get_des/0,get_note/0,write/1]).

get_id()-> 16#D124.

get_name() -> usr_info_property.

get_des() ->
	[
	 
		
		{prof,uint32,0}, 
		{military,uint32,0},
		{camp,uint32,0},
		{guild_name,string,""},
		{vip_lev,uint32,0},
		{headid,uint32,0},
		
		
		{cur_hp,uint32,0},
		{cur_mp,uint32,0},
		{exp,uint32,0},
		{limit_hp,uint32,0},
		{limit_mp,uint32,0},
		 
		{str,uint32,0},
		{agi,uint32,0},
		{sta,uint32,0},
		{wis,uint32,0},
		{spi,uint32,0},
		 
		{atk,uint32,0},
		{def,uint32,0},
		 
		{defIgnore,uint32,0},
		{cri,uint32,0},
		{criDmg,uint32,0},
		{tough,uint32,0},
		{hit,uint32,0},
		{dod,uint32,0},
		{cd,uint32,0},
		{dmgRate,uint32,0},
		{dmgDownRate,uint32,0},
		{blockRate,uint32,0},
		{blockDownRate,uint32,0},
		{realDmg,uint32,0},
		{stifle,uint32,0},
		{longSuffering,uint32,0},
		{moveSpd,uint32,0},
		{by_like,uint32,0},
		
		{lev,uint32,0},
		{peak_lev,uint32,0}
	].

get_note() ->"其他玩家属性". 
write(RdFile) ->
	write_ctrl:write(protocol,?MODULE,RdFile).