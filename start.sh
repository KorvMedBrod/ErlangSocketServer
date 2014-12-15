#! /bin/sh


case "$1" in
  start)
  exec erl -pa deps/*/ebin -pa ebin -s "server_socket" -sname server_socket -noshell -detached && echo "server started"
  ;;

  stop)
  echo "Nothing happens"
  ;;

  status)
  exec erl -pa deps/*/ebin -pa ebin -s "server_handler:status()" -sname server_handler && echo "status"
  ;;
  restart)
  stop
  start
  ;;
  *)
  echo $"Usage: $0 {start|stop|restart|status}"
  exit 1

esac
