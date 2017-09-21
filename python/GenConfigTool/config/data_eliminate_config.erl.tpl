-module(data_eliminate_config).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py	item_str2 = item_str.split("|") ?>
<?py	ret = "[" ?>
<?py	for index in range(len(item_str2)): ?>
<?py		data2 = item_str2[index].split(",") ?>
<?py		ret = ret + "{" + data2[0] + ", " + data2[1] +  "}, " ?>
<?py #endfor ?>
<?py	return ret[:-2] + "]" ?>
<?py #enddef ?>

<?py for data in all_data: ?>
get_data(${data[0]}) -> #st_eliminate_config{iD = ${data[0]}, bossID = ${data[1]}, reward = ${split_items(data[2])}};
<?py #endfor ?>
get_data(_) -> {}.

%% 所有id
<?py all_ids = [d[0] for d in all_data] ?>
get_all_id() -> ${all_ids}.


