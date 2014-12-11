-module(server_handler).

-author('L Bjork <gusbjorklu@student.gu.se>').

-export([stop/0]).

stop() ->
  {ok,ServerName}=inet:gethostname(),
  Conector = "server_socket@",
  Connection = Conector ++ ServerName,
  %net_kernel:connect_node(Connection).
  rpc:call(list_to_atom(Connection), init, stop, []).
