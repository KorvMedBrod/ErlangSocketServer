-module(shuffle).

-export([start/0]).

start() ->
  shuffle({"#sananaman", "#769idoneigdf", "#levelapp", "#g_bf", "#pjt2014", "#centralbabiro", "#dw_avengers", "#veloraindonesia", "#stalkers", "#ilhamitunc", "#kyuhyun4thwin", "#matilampu", "#lampumerah", "#khamoshiyan", "#ikede", "#5thcpccf", "#tvtokyo", "#midweekhappiness", "#wts", "#npask", "#lastfm"," #listas_zoo", "#swlille", "#abdullahabdulaziz", "#bambam", "#swlyon", "#jsb3", "#winitwednesday", "#sgkilometromv", "#swgiza", "#btsthanh", "#teog", "#xiumin", "#swamman", "#kumbadjid","#pymesunidas","#bbau", "#5sosarias", "#gsb2014", "#jackbam"}).

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
