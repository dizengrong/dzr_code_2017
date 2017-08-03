compile:
erl -pa ebin -make
clean:
del  .\ebin\*.beam
run:
erl -pa ebin/ -s use_port start -s reloader

erl -pa ebin/ rsync_service/deps/cowboy/ebin/ rsync_service/deps/cowlib/ebin/ rsync_service/deps/erlydtl/ebin/ rsync_service/deps/ranch/ebin/ -s main start -s reloader

erl +pc unicode -pa ebin/ work_helper/deps/cowboy/ebin/ work_helper/deps/cowlib/ebin/ work_helper/deps/erlydtl/ebin/ work_helper/deps/merl/ebin/  work_helper/deps/ranch/ebin/ -s work_helper_main start -s reloader

release:
erl -pa ebin/ -s gen_release make_win_release


https://github.com/rustyio/sync
