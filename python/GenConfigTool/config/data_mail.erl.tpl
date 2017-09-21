-module(data_mail).
-include("common.hrl").
-compile(export_all).


<?py for data in all_data: ?>
data_mail(${data[0]}) -> #mail_content{id=${data[0]},mailName= "${data[1]}",text= "${data[3]}"};
<?py #endfor ?>
data_mail(_) -> {}.

