-module(socket).

-author('L Bjork <gusbjorklu@student.gu.se>').

-export([start/0,loop/1,match_data/1]).

-define(TCP_OPTIONS, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]).
-define(Port,8080).

% Call echo:listen(Port) to start the service.
start() ->
  {ok, LSocket} = gen_tcp:listen(?Port, ?TCP_OPTIONS),
  spawn(fun() -> accept(LSocket) end).

% Wait for incoming connections and spawn the echo loop when we get one.
accept(LSocket) ->
  {ok, Socket} = gen_tcp:accept(LSocket),
  Pid = spawn(fun() ->
    io:format("Connection accepted ~n", []),
    loop(Socket)
  end),
  gen_tcp:controlling_process(Socket, Pid),
  accept(LSocket).

% Takes the recived data as "Data" and sends it to the pattern macher
loop(Socket) ->
    case gen_tcp:recv(Socket, 0) of
        {ok, Data} ->
          io:format("In data ~p~n", [Data]),
          gen_tcp:send(Socket, match_data(Data)),
            loop(Socket);
        {error, closed} ->
            ok
    end.

-define(caseOne, <<"GetRandomTweet">>).
-define(caseTwo, <<"GetTweet">>).
%The pattern macting is towards "Bit Strings"
match_data(?caseOne) ->
  io:format("found GetRandomTweet ~n"),
  "Here's a random tweet";
match_data(?caseTwo) ->
  io:format("found GetTweet ~n"),
  "a tweet";
match_data(_) ->
  io:format("found no match ~n"),
  "no match".
