-module(data_shenqi).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

%% 初始拥有的神器id列表
<?py init_list = [] ?>
<?py for data in all_data: ?>
<?py if data[7].split(',')[1] == '0': ?>
<?py 	init_list.append(data[0]) ?>
<?py #endif ?>
<?py #endfor ?>
get_init_shenqi_list() -> ${init_list}.

%% 激活神器:get_active_data(神器id) -> {激活消耗, 激活展示id};
<?py for data in all_data: ?>
get_active_data(${data[0]}) -> {${split_items(data[7])}, ${data[8]}};
<?py #endfor ?>
get_active_data(Id) -> throw({error_config, ?MODULE, get_active_data, Id}).

<?py for data in all_data: ?>
get_shenqi_skill(${data[0]}) -> ${data[2]};
<?py #endfor ?>
get_shenqi_skill(Id) -> throw({error_config, ?MODULE, get_shenqi_skill, Id}).

<?py skill_list = [] ?>
%% is_shenqi_skill(技能id) -> true|false;
<?py for data in all_data: ?>
<?py 	if data[2] not in skill_list: ?>
<?py 		skill_list.append(data[2]) ?>
is_shenqi_skill(${data[2]}) -> true;
<?py 	#endif ?>
<?py #endfor ?>
is_shenqi_skill(_Id) -> false.

<?py skill_list = [] ?>
%% get_skill_cd(技能id) -> 技能cd;
<?py for data in all_data: ?>
<?py 	if data[2] not in skill_list: ?>
<?py 		skill_list.append(data[2]) ?>
get_skill_cd(${data[2]}) -> ${data[9].split(',')[0]};
<?py 	#endif ?>
<?py #endfor ?>
get_skill_cd(Id) -> throw({error_config, ?MODULE, get_skill_cd, Id}).

%% 神器升级消耗:get_up_cost(神器等级) -> [{ItemType, Num}];
<?py for data in lv_data: ?>
get_up_cost(${data[0]}) -> ${split_items(data[1])};
<?py #endfor ?>
get_up_cost(Id) -> throw({error_config, ?MODULE, get_up_cost, Id}).

%% 神器伤害:get_skill_hurt(神器等级) -> 伤害;
<?py for data in lv_data: ?>
get_skill_hurt(${data[0]}) -> ${data[2]};
<?py #endfor ?>
get_skill_hurt(Id) -> throw({error_config, ?MODULE, get_skill_hurt, Id}).
