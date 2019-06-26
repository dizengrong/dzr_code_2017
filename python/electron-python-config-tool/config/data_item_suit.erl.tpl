%% -*- coding: latin-1 -*-
-module(data_item_suit).
-include("common.hrl").
-compile(export_all).
<?py import helper ?>

<?py for data in all_data: ?>
get_data(${data['id']}) -> #st_item_suit{id=${data['id']},suit_list=[${data['suit']}]};
<?py #endfor ?>
get_data(_) -> {}.

<?py for data in all_data: ?>
<?py 	for attr in data['suit'].split(','): ?>
get_suit(${attr}) -> ${data['id']};
<?py 	#endfor ?>
<?py #endfor ?>
get_suit(_) -> 0.


%% 套装穿戴几件的总属性, return:{属性id, 总属性}
<?py for data in all_data: ?>
<?py 	attrs_list = [] ?>
<?py 	pre = [] ?>
<?py 	for attr in data['attribute'].split('|'): ?>
<?py 		attr = attr.replace('{', '(') ?>
<?py 		attr = attr.replace('}', ')') ?>
<?py 		temp = eval('[' + attr + ']') ?>
<?py 		pre = helper.attr_add(pre, temp[1]) ?>
<?py 		attrs_list.append((data['id'] * 100 + temp[0], temp[0], pre)) ?>
<?py 	#endfor ?>
<?py 	attrs_list.reverse() ?>
<?py 	for attr in attrs_list: ?>
get_attr(${data['id']}, N) when N >= ${attr[1]} -> {${attr[0]}, ${str(attr[2]).replace('(', '{').replace(')', '}')}};
<?py 	#endfor ?>

<?py #endfor ?>
get_attr(_, _) -> [].
