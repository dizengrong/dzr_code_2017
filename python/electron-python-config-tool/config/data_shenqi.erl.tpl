-module(data_shenqi).
-include("common.hrl").
-compile(export_all).

<?py import helper ?>
<?py for data in all_base_data: ?>
get_base(${data['itemId']}) -> #st_shenqi{type=${data['type']},max_star=${data['star_max']},god_power={${data['god_power']}}, attr1={${data['attribute_power1']}}, attr2={${data['attribute_power2']}}, attr3={${data['attribute_power3']}}, attr4={${data['attribute_power4']}}};
<?py #endfor ?>
get_base(Id) -> {error_config_not_find, Id}.

<?py max_lv_dict = {} ?>
<?py for data in all_lv_data: ?>
<?py 	max_lv_dict[data['need_star']] = data['lv'] ?>
<?py #endfor ?>

<?py for star in max_lv_dict: ?>
get_max_lv(${star}) -> ${max_lv_dict[star]};
<?py #endfor ?>
get_max_lv(_) -> 0.

<?py for data in all_lv_data: ?>
get_lv_up_cost(${data['lv']}) -> ${helper.erl_split_items(data['need_item'])};
<?py #endfor ?>
get_lv_up_cost(_) -> [].

%% 加对应的基础属性的万分比
<?py for data in all_lv_data: ?>
get_lv_attr_rate(${data['lv']}) -> {${data['god_power']}, ${data['attribute_power1']}, ${data['attribute_power2']}, ${data['attribute_power3']}, ${data['attribute_power4']}};
<?py #endfor ?>
get_lv_attr_rate(_) -> {0, 0, 0, 0, 0}.

%% ================================= 升星配置 ==================================
<?py for data in all_star_data: ?>
<?py 	if data['need_level'] != 0: ?>
get_up_star_cnf(${data['godWeaponId']}, ${data['starLv']}) -> {${data['need_level']}, ${helper.erl_split_items(data['need_item'])}, ${helper.erl_split_items(data['god_weapon_need'])}};
<?py 	#endif ?>
<?py #endfor ?>
get_up_star_cnf(_, _) -> undefined.

<?py for data in all_star_data: ?>
get_star_skill(${data['godWeaponId']}, ${data['starLv']}) -> [${data['skill']}];
<?py #endfor ?>
get_star_skill(_, _) -> [].



