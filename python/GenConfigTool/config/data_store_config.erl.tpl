-module(data_store_config).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[0]})-> #st_store_config{
	id              = ${data[0]},
	name            = "${data[1]}",
	cells           = [${data[3]}],
	refrushTimes    = [${data[4]}],
	refreshCostType = ${data[5]},
	refrshCost      = ${data[6]},
	offTime         = {${data[7]}},
	authorityType   = "${data[8]}",
	authorityLevel  = ${data[9]},
	discountLimit   = ${data[10]},
	showId          = [${data[11]}]
};
<?py #endfor ?>
get_data(_) -> {}.
