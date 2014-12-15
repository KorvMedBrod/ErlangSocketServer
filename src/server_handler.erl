-module(server_handler).

-author('L Bjork <gusbjorklu@student.gu.se>').

-export([stop/0,status/0]).

stop() ->
  {ok,ServerName}=inet:gethostname(),
  Conector = "server_socket@",
  Connection = Conector ++ ServerName,
  rpc:call(list_to_atom(Connection), init, stop, []).


status() ->
  {ok,ServerName}=inet:gethostname(),
  Conector = "server_socket@",
  Connection = Conector ++ ServerName,
  net_kernel:connect_node(Connection).
