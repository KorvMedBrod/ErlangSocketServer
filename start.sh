#! /bin/sh

PIDFILE=SocketServer.pid

case "$1" in
  start)
  echo "staring\n"
  exec erl -pa deps/*/ebin -pa ebin -s "server_socket" -noshell -detached & pid=$!
  echo "started with pid $pid"
  echo $pid > PIDFILE
  ;;

  stop)
  for line in $ (cat $PIDFILE) do kill -9 "$ line" done
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
