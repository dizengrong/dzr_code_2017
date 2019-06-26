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
<?py 		for s in range(0, int(len(buff)/5)): ?>
<?py 			b = b + '{' + str(buff[(s-1)*5 + 0]) + ',{' + str(buff[(s-1)*5 + 1]) + ',' + str(buff[(s-1)*5 + 2]) + '},{' + str(buff[(s-1)*5 + 3]) + ',' + str(buff[(s-1)*5 + 4]) + '}},' ?>
<?py 		#endfor ?>
<?py 		return b[:-1] ?>
<?py 	#endif ?>
<?py #enddef ?>


<?py for data in all_data: ?>
get_skillleveldata(${data['skillid']}) -> #st_skillleveldata_config{skillId=${data['skillid']},power1=${data['power1']},power1_add=${data['power1_add']},power2=${data['power2']},power2_add=${data['power2_add']},long_suffering=${data['long_suffering']},threaten=${data['threaten']},targetBuff=[${parse_tuple(data['targetBuff'])}],selfBuff=[${parse_tuple(data['selfBuff'])}],mp=${data['mp']},cd=${data['cd']},dmgScript="${data['dmgScript']}"}; 
<?py #endfor ?>
get_skillleveldata(_) -> {}.