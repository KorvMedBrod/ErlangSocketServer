-module(socket).

-author('L Bjork <gusbjorklu@student.gu.se>').

-export([start/0, loop0/1, worker/2]).

-define(PORT,8080).


start() ->
  start(?PORT).
start(P) ->
  spawn(?MODULE, loop0, [P]).

loop0(Port) ->
  case gen_tcp:listen(Port, [binary, {reuseaddr, true},{packet, 0}, {active, false}]) of
  {ok, LSock} ->
    spawn(?MODULE, worker, [self(), LSock]),
    loop(LSock);
  Other ->
    io:format("Can't listen to socket ~p~n", [Other])
  end.

loop(S) ->
  receive
  next_worker ->
    spawn_link(?MODULE, worker, [self(), S])
  end,
  loop(S).

worker(Server, LS) ->
  case gen_tcp:accept(LS) of
    {ok, Socket} ->
      Server ! next_worker,
      %%call for reciver with Socket
    reciver(Socket);
    {error, Reason} ->
      Server ! next_worker,
      io:format("Can't accept socket ~p~n", [Reason])
    end.

% Takes the recived data as "Data" and sends it to the pattern macher
reciver(Socket) ->
    case gen_tcp:recv(Socket, 0) of
        {ok, Data} ->
          io:format("In data ~p~n", [Data]),
          gen_tcp:send(Socket, match_data(Data)),
            loop(Socket);
        {error, closed} ->
            ok
    end.

-define(tweets,{"#sananaman", "#769idoneigdf", "#levelapp", "#g_bf", "#pjt2014", "#centralbabiro", "#dw_avengers", "#veloraindonesia", "#stalkers", "#ilhamitunc", "#kyuhyun4thwin", "#matilampu", "#lampumerah", "#khamoshiyan", "#ikede", "#5thcpccf", "#tvtokyo", "#midweekhappiness", "#wts", "#npask", "#lastfm"," #listas_zoo", "#swlille", "#abdullahabdulaziz", "#bambam", "#swlyon", "#jsb3", "#winitwednesday", "#sgkilometromv", "#swgiza", "#btsthanh", "#teog", "#xiumin", "#swamman", "#kumbadjid","#pymesunidas","#bbau", "#5sosarias", "#gsb2014", "#jackbam"}).
-define(caseOne, <<"GetRandomTweet">>).
-define(caseTwo, <<"GetTweet">>).
-define(caseThree, <<"Test">>).

%The pattern macting is towards "Bit Strings"
match_data(?caseOne) ->
  "Here's a random tweet";
match_data(?caseTwo) ->
  "a tweet";
match_data(?caseThree ) ->
  RetunValue = shuffle(?tweets),
  lists:flatten(io_lib:format("~p", [RetunValue]));
  %random:seed(5991,29821,991);
  %random:seed("#sananaman", "#769idoneigdf", "#levelapp", "#g_bf", "#pjt2014", "#centralbabiro", "#dw_avengers", "#veloraindonesia", "#stalkers", "#ilhamitunc", "#kyuhyun4thwin", "#matilampu", "#lampumerah", "#khamoshiyan", "#ikede", "#5thcpccf", "#tvtokyo", "#midweekhappiness", "#wts", "#npask", "#lastfm"," #listas_zoo", "#swlille", "#abdullahabdulaziz", "#bambam", "#swlyon", "#jsb3", "#winitwednesday", "#sgkilometromv", "#swgiza", "#btsthanh", "#teog", "#xiumin", "#swamman", "#kumbadjid","#pymesunidas","#bbau", "#5sosarias", "#gsb2014", "#jackbam");
  %"{#sananaman, #769idoneigdf, #levelapp, #g_bf, #pjt2014, #centralbabiro, #dw_avengers, #veloraindonesia, #stalkers, #ilhamitunc, #kyuhyun4thwin, #matilampu, #lampumerah, #khamoshiyan, #ikede, #5thcpccf, #tvtokyo, #midweekhappiness, #wts, #npask, #lastfm, #listas_zoo, #swlille, #abdullahabdulaziz, #bambam, #swlyon, #jsb3, #winitwednesday, #sgkilometromv, #swgiza, #btsthanh, #teog, #xiumin, #swamman, #kumbadjid, #pymesunidas, #bbau, #5sosarias, #gsb2014, #jackbam}";
match_data(_) ->
  "no match".



shuffle(Tuple) ->
  shuffle(Tuple, size(Tuple)).

shuffle(Tuple, 1) ->
  Tuple;
shuffle(Tuple, N)->
  Random = erlang:phash2(os:timestamp(), N) + 1,
  A = element(N, Tuple),
  B = element(Random, Tuple),
  Tuple2 = setelement(N, Tuple, B),
  Tuple3 = setelement(Random, Tuple2, A),
  shuffle(Tuple3, N - 1).
