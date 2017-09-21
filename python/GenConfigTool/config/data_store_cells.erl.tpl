-module(data_store_cells).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]})->#st_store_cell{id=${data[0]},cellID=${data[1]},itemId=${data[2]},celltype=${data[3]},costType=${data[5]},costNum=${data[6]},groupNum=${data[7]},limitType="${data[8]}",buyLimits=${data[9]},discountRate=${data[10]},authorityType="${data[11]}",authorityLevel=${data[12]}};
<?py #endfor ?>
get_data(_) -> {}.

<?py pre = 0 ?>
<?py acc_rate = 0 ?>
<?py max_weight = {} ?>
<?py for data in all_data: ?>
<?py	if pre != data[1]: ?>
<?py 		max_weight[pre] = acc_rate ?>
<?py 		acc_rate = 0 ?>
<?py #endif ?>
rand(${data[1]}, Rand) when Rand >= ${acc_rate} andalso Rand < ${acc_rate + data[4]} -> ${data[0]};
<?py 	acc_rate = acc_rate + data[4] ?>
<?py 	pre = data[1] ?>
<?py #endfor ?>
<?py max_weight[pre] = acc_rate ?>
rand(_, _) -> 0.

<?py for data in max_weight: ?>
<?py	if data != 0: ?>
max_weight(${data}) -> ${max_weight[data]};
<?py 	#endif ?>
<?py #endfor ?>
max_weight(_CellId) -> throw({config_error, max_weight, _CellId}).

