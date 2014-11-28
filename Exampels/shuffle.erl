-module(shuffle).

-export([start/0]).
-define(tweets,{"#sananaman", "#769idoneigdf", "#levelapp", "#g_bf", "#pjt2014", "#centralbabiro", "#dw_avengers", "#veloraindonesia", "#stalkers", "#ilhamitunc", "#kyuhyun4thwin", "#matilampu", "#lampumerah", "#khamoshiyan", "#ikede", "#5thcpccf", "#tvtokyo", "#midweekhappiness", "#wts", "#npask", "#lastfm"," #listas_zoo", "#swlille", "#abdullahabdulaziz", "#bambam", "#swlyon", "#jsb3", "#winitwednesday", "#sgkilometromv", "#swgiza", "#btsthanh", "#teog", "#xiumin", "#swamman", "#kumbadjid","#pymesunidas","#bbau", "#5sosarias", "#gsb2014", "#jackbam"}).

start() ->
  shuffle(?tweets).

shuffle(Tuple) ->
  shuffle(Tuple, size(Tuple)).

shuffle(Tuple, 1) ->
  convertToString(tuple_to_list(Tuple),"");
shuffle(Tuple, N)->
  Random = erlang:phash2(os:timestamp(), N) + 1,
  A = element(N, Tuple),
  B = element(Random, Tuple),
  Tuple2 = setelement(N, Tuple, B),
  Tuple3 = setelement(Random, Tuple2, A),
  shuffle(Tuple3, N - 1).

convertToString([],S) ->
  S;
convertToString([Tuple|A],S) ->
  lists:flatten(io_lib:format("~p", [Tuple])).
  %  convertToString(A,S+Tuple).
