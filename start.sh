#! /bin/sh


case "$1" in
  start)
  exec erl -pa deps/*/ebin -pa ebin -s "server_socket" -sname server_socket -noshell -detached
  echo "server started"
  ;;

  stop)
  exec erl -pa deps/*/ebin -pa ebin -s "server_handler:stop" -sname server_handler -noshell -detached
  echo "server stoped"
  ;;

  status)
  echo "another time"
  ;;
  restart)
  stop
  start
  ;;
  *)
  echo $"Usage: $0 {start|stop|restart|status}"
  exit 1

esac
