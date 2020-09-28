%% @doc 数据库版本控制
-module (db_version_script).
-export ([all_version/1, version_script/1]).


%% 所有的版本，按升序排序，版本号字符串排序必须和实际版本排序一致！
all_version(Agent) -> 
	all_version_help(util_server:is_cross_node(), Agent).

%% 游戏节点的版本
all_version_help(false, "fbird") ->
	[
		"master_01.01"
	];

%% 跨服节点的版本
all_version_help(true, "fbird") -> 
	[
		"master_01.01"
	].


version_script(Version) -> 
	version_script_help(util_server:is_cross_node(), Version).

%% 游戏节点
version_script_help(false, "master_01.01") -> update_mnesia_01_01;

%% 跨服节点
version_script_help(true, _) -> update_cross_mnesia_01_01.


