-module(data_story).
-include("common.hrl").
-compile(export_all).

<?py def split_items(item_str):?>
<?py 	return "[{" + "}, {".join(item_str.split("|")) + "}]" ?>
<?py #enddef ?>

<?py all_ids = [] ?>
<?py for data in all_data: ?>
<?py start_step = int(data[1].split(',')[0]) ?>
<?py process_steps = [int(x.split(',')[0]) for x in data[2].split('|')] ?>
<?py finish_step = int(data[3].split(',')[0]) ?>
<?py all_ids.append(start_step) ?>
<?py all_ids += process_steps ?>
<?py all_ids.append(finish_step) ?>
get_data(${data[0]}) -> #st_stroy{finish_step = ${finish_step},reawrd = ${split_items(data[4])}};
<?py #endfor ?>
get_data(_) -> {}.

<?py for data in all_data: ?>
<?py start_step = int(data[1].split(',')[0]) ?>
<?py finish_step = int(data[3].split(',')[0]) ?>
get_chapter(BarrierId) when BarrierId >= ${start_step} andalso BarrierId =< ${finish_step} -> ${data[0]};
<?py #endfor ?>
get_chapter(_) -> 0.

get_all() -> ${all_ids}.
