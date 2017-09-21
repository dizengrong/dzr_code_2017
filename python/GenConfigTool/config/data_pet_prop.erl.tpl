-module(data_pet_prop).
-include("common.hrl").
-compile(export_all).

<?py for data in all_data: ?>
get_data(${data[1]}) -> #st_pet_prop{id=${data[0]},petid=${data[1]},prop1=${data[3]},value1=${data[4]},maxvalue1=${data[5]},probability1=${data[6]},prop2=${data[7]},value2=${data[8]},maxvalue2=${data[9]},probability2=${data[10]},prop3=${data[11]},value3=${data[12]},maxvalue3=${data[13]},probability3=${data[14]},prop4=${data[15]},value4=${data[16]},maxvalue4=${data[17]},probability4=${data[18]},gs1=${data[19]},gs2=${data[20]},gs3=${data[21]},gs4=${data[22]}};
<?py #endfor ?>
get_data(_) -> {}.

<?py all_ids = [d[0] for d in all_data] ?>

get_all() -> ${all_ids}.
