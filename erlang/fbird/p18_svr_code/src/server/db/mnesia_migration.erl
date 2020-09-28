%% @doc mnesia数据库迁移，如把位于机器A的mnesia数据库直接迁移到机器B去，不同节点的迁移也是一样的
%% 迁移数据库时需要先备份mnesia数据库，等迁移完了后再恢复
-module (mnesia_migration).
-include ("common.hrl").
-export ([migration/4]).


%% 将数据库备份文件Source的节点名从From迁移为To，并保存到备份文件Target
%% migration(node(), node(), "/path/to/mnesia.backup", "/path/to/new.mnesia.backup")
migration(From, To, Source, Target) ->
	change_node_name(mnesia_backup, From, To, Source, Target).


change_node_name(Mod, From, To, Source, Target) ->
    Switch =
        fun(Node) when Node == From -> To;
           (Node) when Node == To -> throw({error, already_exists});
           (Node) -> Node
        end,
    Convert =
        fun({schema, db_nodes, Nodes}, Acc) ->
                {[{schema, db_nodes, lists:map(Switch,Nodes)}], Acc};
           ({schema, version, Version}, Acc) ->
                {[{schema, version, Version}], Acc};
           ({schema, cookie, Cookie}, Acc) ->
                {[{schema, cookie, Cookie}], Acc};
           ({schema, Tab, CreateList}, Acc) ->
                Keys = [ram_copies, disc_copies, disc_only_copies],
                OptSwitch =
                    fun({Key, Val}) ->
                            case lists:member(Key, Keys) of
                                true -> {Key, lists:map(Switch, Val)};
                                false-> {Key, Val}
                            end
                    end,
                {[{schema, Tab, lists:map(OptSwitch, CreateList)}], Acc};
           (Other, Acc) ->
                {[Other], Acc}
        end,
    mnesia:traverse_backup(Source, Mod, Target, Mod, Convert, switched).

