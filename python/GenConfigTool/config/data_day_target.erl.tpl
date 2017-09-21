-module(data_day_target).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_day_target{id=${data[0]},days=${data[1]},typeId=${data[2]},val1=${data[3]},val2=${data[4]},autoRefresh=1};
<?py #endfor ?>
get_data(_) -> {}.

<?py def select_one_field(datas, index_field, index_result):?>
<?py	ret_list = {} ?>
<?py	for data in datas: ?>
<?py		if ret_list.has_key(data[index_field]): ?>
<?py			ret_list[data[index_field]].append(data[index_result]) ?>
<?py		else: ?>
<?py			ret_list[data[index_field]] = [data[index_result]] ?>
<?py #endif ?>
<?py #endfor ?>
<?py	return ret_list ?>
<?py #enddef ?>

<?py typelist = select_one_field(all_data, 2, 0) ?>
<?py for data in typelist: ?>
select_typeId(${data}) -> ${typelist[data]};
<?py #endfor ?>
select_typeId(_) ->[].

<?py daylist = select_one_field(all_data, 1, 0) ?>
<?py for data in daylist: ?>
select_days(${data}) -> ${daylist[data]};
<?py #endfor ?>
select_days(_) ->[].
