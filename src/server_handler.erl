-module(server_handler).

-author('L Bjork <gusbjorklu@student.gu.se>').

-export([stop/0,stopping/0,start/0]).

stop() ->
  spawn(?MODULE, stopping, []).

stopping() ->
  {ok,ServerName}=inet:gethostname(),
  Conector = "server_socket@",
  Connection = Conector ++ ServerName,
  %net_kernel:connect_node(Connection).
  rpc:call(list_to_atom(Connection), init, stop, []).

start() ->
  io:format("testing").
