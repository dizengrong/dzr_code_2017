-module(data_chapter).
-compile(export_all).


%% get_chapter_id(关卡id) -> 所属的章节id
<?py for data in all_data: ?>
get_chapter_id(BarrierId) when BarrierId >= ${data[3]} -> ${data[0]};
<?py #endfor ?>
get_chapter_id(_) -> 0.

%% get_winned_chapter_id(关卡id) -> 所属的章节id
<?py for data in all_data: ?>
get_winned_chapter_id(BarrierId) when BarrierId >= ${data[4]} -> ${data[0]};
<?py #endfor ?>
get_winned_chapter_id(_) -> 0.

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

%% get_reward(章节id) -> [{物品id, 数量}]
<?py for data in all_data: ?>
get_reward(${data[0]}) -> ${split_items(data[2])};
<?py #endfor ?>
get_reward(_) -> [].
