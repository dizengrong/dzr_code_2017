-module(data_skillleveldata).
-include("common.hrl").
-compile(export_all).

<?py def parse_tuple(item_str):?>
<?py 	buff = item_str.replace('{', '') ?>
<?py 	buff = buff.replace('}', '') ?>
<?py 	if buff == '': ?>
<?py 		return '' ?>
<?py 	else: ?>
<?py 		buff = eval(buff) ?>
<?py 		b = '' ?>
<?py 		for s in xrange(len(buff)/5): ?>
<?py 			b = b + '{' + str(buff[(s-1)*5 + 0]) + ',{' + str(buff[(s-1)*5 + 1]) + ',' + str(buff[(s-1)*5 + 2]) + '},{' + str(buff[(s-1)*5 + 3]) + ',' + str(buff[(s-1)*5 + 4]) + '}},' ?>
<?py 		#endfor ?>
<?py 		return b[:-1] ?>
<?py 	#endif ?>
<?py #enddef ?>


<?py for data in all_data: ?>
get_skillleveldata(${data[1]}) -> #st_skillleveldata_config{skillId=${data[1]},skillLevel=${data[2]},power1=${data[3]},power1_add=${data[4]},power2=${data[5]},power2_add=${data[6]},long_suffering=${data[7]},threaten=${data[8]},targetBuff=[${parse_tuple(data[9])}],selfBuff=[${parse_tuple(data[10])}],mp=${data[11]},cd=${data[12]},dmgScript="${data[13]}",mainProperty=${data[14]}}; 
<?py #endfor ?>
get_skillleveldata(_) -> {}.

