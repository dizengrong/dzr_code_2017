%% -*- coding: latin-1 -*-
-module(data_zhenfa).
-include("common.hrl").
-compile(export_all).

<?py import helper ?>
<?py all_type_set = set() ?>
<?py all_type_dict = {} ?>
<?py for data in all_data: ?>
<?py 	all_type_set.add(data['type']) ?>
<?py 	if data['type'] not in all_type_dict: ?>
<?py 		all_type_dict[data['type']] = [] ?>
<?py 	#endif ?>
<?py 	all_type_dict[data['type']].append((data['id'], helper.erl_split_items(data['activation']))) ?>
<?py #endfor ?>
%% ================================= 阵法加成 ==================================
all_type() -> ${list(all_type_set)}.

%% get_active_condition(阵法类型) -> [{阵法Id, 条件列表}]
<?py for key in all_type_dict: ?>
get_active_condition(${key}) -> [${','.join(['{' + str(d[0]) + ', ' + d[1] + '}' for d in all_type_dict[key]])}];
<?py #endfor ?>
get_active_condition(_) -> [].

<?py for data in all_data: ?>
get_zhenfa_attr(${data['id']}) -> ${helper.erl_split_items(data['attribute'])};
<?py #endfor ?>
get_zhenfa_attr(_) -> [].

%% ================================= 阵法克制 ==================================
%% race_restraint_damage(攻击方种族, 防守方种族) -> 伤害增加万分比
<?py for data in all_restraint_data: ?>
race_restraint_damage(${data['race']}, ${data['restraint']}) -> ${data['damage']};
<?py #endfor ?>
race_restraint_damage(_, _) -> undefined.

