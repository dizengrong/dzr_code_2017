%% @doc 这个是开发时使用的数据库升级脚本，方便开发阶段的数据库升级处理
%% 每一个当前版本都一个开发到下一个版本的升级语句，当下一个版本开发完成了
%% 这个升级语句就要成为下一个版本使用的正式升级脚本
%% 注意事项：
%% 		1.对于删除表记录里的字段的情况，如果该字段是索引字段或者
%% 		  删除字段后，索引字段原来所在的位置超出了现有范围了，则需要先执行删除索引的操作，有需要后面再加上
%% 		  mnesia:del_table_index(toplist_entoureage, rank),
%% 		  mnesia:add_table_index(toplist_entoureage, rank),
-module (update_mnesia_develop).
-include ("common.hrl").
-compile([export_all]).


% develop_update("master_01.01") ->
% 	Fun = fun(R) -> 
% 		case R of
% 			{RecordName, F1, F2, F3, F4, F5, F6, F7, F8, F9} -> 
% 				{RecordName, F1, F2, F3, F4, F5, 0, F6, F7, F8, F9};
% 			_ -> 
% 				R
% 		end
% 	end,
% 	{atomic, ok} = mnesia:transform_table(toplist_gem, Fun, record_info(fields, toplist_gem), toplist_gem),
% 	ok;

develop_update(Version) -> 
	Mod = db_version_script:version_script(Version),
	Mod:update_db(),
	ok.


