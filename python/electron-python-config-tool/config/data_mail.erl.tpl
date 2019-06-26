%% -*- coding: latin-1 -*-
-module(data_mail).
-include("common.hrl").
-compile(export_all).


<?py for data in all_data: ?>
data_mail(${data['id']}) -> #mail_content{id=${data['id']},mailName= "${data['title']}",text= "${data['content']}"};
<?py #endfor ?>
data_mail(_) -> {}.

