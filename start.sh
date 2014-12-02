#! /bin/sh
exec erl -pa deps/*/ebin -pa ebin -s "socket" -noshell -detached
