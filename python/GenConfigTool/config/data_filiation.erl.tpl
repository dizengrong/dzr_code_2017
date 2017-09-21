-module(data_filiation).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_filiation{id=${data[0]},entourageId=${data[2]},targetEntourageId=${data[3]},maxLevel=${data[4]}};
<?py #endfor ?>
get_data(_) -> {}.

<?py for data in all_data: ?>
select_targetId(${data[2]}, ${data[3]}) -> [${data[0]}];
<?py #endfor ?>
select_targetId(_,_) ->[].

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

<?py entourageIdList = select_one_field(all_data, 2, 0) ?>
<?py for data in entourageIdList: ?>
select_entourageId(${data}) -> ${entourageIdList[data]};
<?py #endfor ?>
select_entourageId(_) -> [].

