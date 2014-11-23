%-author('Jesse E.I. Farmer <jesse@20bits.com>').

-module(socket).

-export([listen/0]).

-define(TCP_OPTIONS, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]).
-define(Port,8080).
-define(caseOne,"GetRandomTweet").
-define(casetwo,"GetTweet").

% Call echo:listen(Port) to start the service.
listen() ->
    {ok, LSocket} = gen_tcp:listen(?Port, ?TCP_OPTIONS),
    accept(LSocket).

% Wait for incoming connections and spawn the echo loop when we get one.
accept(LSocket) ->
    {ok, Socket} = gen_tcp:accept(LSocket),
    spawn(fun() -> loop(Socket) end),
    accept(LSocket).

% Echo back whatever data we receive on Socket.
loop(Socket) ->
    case gen_tcp:recv(Socket, 0) of
        {ok, Data} ->
          %io:format(Data),
            gen_tcp:send(Socket, gen_data(Data)),
            loop(Socket);
        {error, closed} ->
            ok
    end.



gen_data(<<"GetRandomTweet">>) ->
  io:format("found GetRandomTweet ~n"),
  "Here's a random tweet";
gen_data(<<"GetTweet">>) ->
  io:format("found GetTweet ~n"),
  "a tweet";
gen_data(_) ->
  io:format("found no match ~n"),
  "no match".
