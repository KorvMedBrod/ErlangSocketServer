-module(mapreduce).
-export([mapred1/2, mapred/2, merge/2, count/3, get_most_popular_tweets/4]).

mapred1(Pid, Bucket) ->
  {ok, [{1, [R]}]} = mapred(Pid, Bucket),
  L = dict:to_list(R),
  PopTweetList = get_most_popular_tweets(L, [], [], []),
  PopTweetList.

count(G, _, _) ->
    [dict:from_list([{I, 1} || I <- binary_to_term(riak_object:get_value(G))])].

merge(Gcounts, _) ->
    [lists:foldl(fun(G, Acc) ->
        dict:merge(fun(_, X, Y) -> X+Y end,
        G, Acc)
    end,
    dict:new(),
    Gcounts)].

mapred(Pid, Bucket) ->
      riakc_pb_socket:mapred(
        Pid,
        Bucket,
        [{map, {modfun, ?MODULE, count}, none, false},
        {reduce, {modfun, ?MODULE, merge}, none, true}]).

%sends back the checked list with the top 5 hashtag.
%get_most_popular_tweets([], [Big], NotUsed, List) -> checklist(NotUsed, Big, List);
%get_most_popular_tweets([{Hash1, V1}], [{HHash, HV}], List, Big) when (V1 >= HV) -> get_most_popular_tweets(Startlist, [{Hash1, V1}], [{HHash, HV} | List], Big);
%get_most_popular_tweets([{Hash1, V1}], [{HHash, HV}], List, Big) when (V1 < HV) -> get_most_popular_tweets(Startlist, [{HHash, HV}], [{Hash1, V1} | List], Big);
%get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [], [], Big) when (V1 >= V2) -> get_most_popular_tweets(Startlist, [{Hash1, V1}], [{Hash2, V2}], Big);
%get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [], [], Big) when (V1 < V2) -> get_most_popular_tweets(Startlist, [{Hash2, V2}], [{Hash1, V1}], Big);
%%get_most_popular_tweets([{Hash1, V1}, {Hash2, V2} | Startlist], [{HHash, HV}], NotBiggest, _) when V1 =:= V2 and V1 > HV -> get_most_popular_tweets(Startlist, [{Hash1, V1}], [{Hash2, V2} | {HHash, HV} | NotBiggest]);
%%get_most_popular_tweets([{Hash1, V1}, {Hash2, V2} | Startlist], [{HHash, HV}], NotBiggest, _) when V1 =:= V2 and V1 < HV -> get_most_popular_tweets(Startlist, [{HHash, HV}], [{Hash2, V2} | {Hash1, V1} | NotBiggest]);
%get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [{HHash, HV}], NotBiggest, Big) when (V1 > V2) and (V1 > HV) -> get_most_popular_tweets(Startlist, [{Hash1, V1}], [{Hash2, V2} | {HHash, HV} | NotBiggest], Big);
%get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [{HHash, HV}], NotBiggest, Big) when (V1 > V2) and (V1 < HV) -> get_most_popular_tweets(Startlist, [{HHash, HV}], [{Hash2, V2} | {Hash1, V1} | NotBiggest], Big);
%get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [{HHash, HV}], NotBiggest, Big) when (V1 < V2) and (V2 > HV) -> get_most_popular_tweets(Startlist, [{Hash2, V2}], [{Hash1, V1} | {HHash, HV} | NotBiggest], Big);
%get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [{HHash, HV}], NotBiggest, Big) when (V1 < V2) and (V2 < HV) -> get_most_popular_tweets(Startlist, [{HHash, HV}], [{Hash1, V1} | {Hash2, V2} | NotBiggest], Big).

get_most_popular_tweets([], [Big], NotUsed, List) -> checklist(NotUsed, Big, List);
get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [], [], Big)
  when V1 >= V2 -> get_most_popular_tweets(Startlist, [{Hash1, V1}], [{Hash2, V2}], Big);
get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [], [], Big)
  when V1 < V2 -> get_most_popular_tweets(Startlist, [{Hash2, V2}], [{Hash1, V1}], Big);
get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [{HHash, HV}], NotBiggest, Big)
  when (V1 > V2)
  and (V1 > HV) ->
  get_most_popular_tweets(Startlist, [{Hash1, V1}], [{Hash2, V2} , {HHash, HV} | NotBiggest], Big);

get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [{HHash, HV}], NotBiggest, Big)
  when (V1 > V2) and (V1 < HV) -> get_most_popular_tweets(Startlist, [{HHash, HV}], [{Hash2, V2} , {Hash1, V1} | NotBiggest], Big);
get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [{HHash, HV}], NotBiggest, Big)
  when (V1 < V2) and (V2 > HV) -> get_most_popular_tweets(Startlist, [{Hash2, V2}], [{Hash1, V1} , {HHash, HV} | NotBiggest], Big);
get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [{HHash, HV}], NotBiggest, Big)
  when (V1 < V2) and (V2 < HV) -> get_most_popular_tweets(Startlist, [{HHash, HV}], [{Hash1, V1} , {Hash2, V2} | NotBiggest], Big).

checklist(NotUsed, Big, List) ->
  case length(List) of
    5 -> List;
    true -> get_most_popular_tweets(NotUsed, [], [], [Big | List])
  end.
