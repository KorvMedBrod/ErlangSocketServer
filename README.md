# ErlangSocketServer

1.  Get dependencies

        $ rebar get-deps
        $ rebar compile


2.  In order to run it in the background

        $ erl -pa deps/*/ebin -pa ebin -s "socket" -noshell -detached
