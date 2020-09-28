-module (util_monster).
-include("common.hrl").
-export ([monster_name/1]).


monster_name(Type) ->
	#st_monster_config{name = Name} = data_monster:get_monster(Type),
	Name.

