%% @doc Handle changed files


-module(filewatcher_handler).
-include("common.hrl").
-author("Arjan Scherpenisse <arjan@miraclethings.nl>").

-export([
    file_changed/2,
    file_blacklisted/1
    ]).

-type verb() :: create|modify|delete.

%% @doc Called when a file is changed on disk. Decides what to do.
%% @spec file_changed(modify | create, string()) -> ok
file_changed(Verb, F) when is_binary(F) ->
    file_changed(Verb, util:to_list(F));
file_changed(Verb, F) ->
    handle_file(check_deleted(F, Verb), filename:basename(F), filename:extension(F), F),
    ok.

-spec handle_file(verb(), string(), string(), string()) -> string() | undefined.
handle_file(Verb, _Basename, _Ext, Filename) ->
    ?INFO("~p: Verb ~p of ~p", [calendar:local_time(), Verb, Filename]),
    case get_upload_dest_dir(filename:join([Filename]), setting:watch_dirs()) of
        false -> ignore;
        WatchDir -> 
            rsync_handler:rsync_to_server(WatchDir)
    end. 


get_upload_dest_dir(_Filename, []) -> false;
get_upload_dest_dir(Filename, [WatchDir | Rest]) ->
    case lists:prefix(WatchDir, Filename) of
        true  -> WatchDir;
        false -> get_upload_dest_dir(Filename, Rest)
    end.

file_blacklisted(F) when is_list(F) ->
    file_blacklisted(unicode:characters_to_binary(F));
file_blacklisted(<<".", _/binary>>) ->
    true;
file_blacklisted(F) when is_binary(F) ->
    case binary:last(F) of
        $# -> true;
        _ ->
            case re:run(F, rsync_handler:get_exclude_pattern_re()) of
                {match, _} ->
                     true;
                nomatch ->
                    false
            end
    end.

check_deleted(F, delete) ->
    case filelib:is_file(F) of
        true -> create;
        false -> delete
    end;
check_deleted(F, Verb) ->
    case filelib:is_file(F) of
        true -> Verb;
        false -> delete
    end.


