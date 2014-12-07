#! /bin/sh
exec erl -pa deps/*/ebin -pa ebin -s "server_socket" -noshell -detached
