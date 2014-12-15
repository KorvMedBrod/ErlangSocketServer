# ErlangSocketServer

1.  Get dependencies

        $ rebar get-deps
        $ rebar compile


2.1  In order to run it in the background

        $ erl -pa deps/*/ebin -pa ebin -s "server_socket" -noshell -detached
        alt
        $ sh start.sh start

2.2  Or if you want to start or test mapreduce

        $ erl -pa deps/*/ebin -pa ebin
        $ server_mapreduce:start().
