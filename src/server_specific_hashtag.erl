-module(server_specific_hashtag).
-export([mapred1/2, mapred/2, merge/2, count/3, get_most_popular_tweets/4, start/1]).

start(Hashtag) ->
  {ok, Pid} = riakc_pb_socket:start("127.0.0.1", 10017),
  {ok, {index_results_v1,Results,undefined,undefined}} = riakc_pb_socket:get_index(Pid,<<"hashtags">>,{binary_index, "ht"},Hashtag),
  Bucket = get_all_from_sec_idx(Results, []),
  PopList = mapred1(Pid, Bucket),
  PopList.

get_all_from_sec_idx([], Bucket) -> Bucket;
get_all_from_sec_idx([H | T], L) -> get_all_from_sec_idx(T, [{<<"hashtags">>, H} | L]).

take_away_last([], CompleteList, _Hashtag) -> CompleteList;
take_away_last([H | T], CompleteList, Hashtag) when H =:= Hashtag -> take_away_last(T, CompleteList, Hashtag);
take_away_last([H | T], CompleteList, Hashtag) -> take_away_last(T, [H | CompleteList], Hashtag).

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
get_most_popular_tweets([], [Big], NotUsed, List) -> checklist(NotUsed, Big, List);
get_most_popular_tweets([{Hash1,V1}], [], P, Big) -> get_most_popular_tweets([], [{Hash1,V1}], P, Big);
get_most_popular_tweets([{Hash1,V1} , {Hash2,V2} | Startlist], [], [], Big)
when V1 >= V2 -> get_most_popular_tweets(Startlist,[{Hash1, V1}],[{Hash2, V2}], Big);
get_most_popular_tweets([{Hash1, V1},{Hash2, V2} | Startlist], [], [], Big)
when V1 < V2 -> get_most_popular_tweets(Startlist, [{Hash2, V2}], [{Hash1, V1}], Big);
get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [{HHash, HV}], NotBiggest, Big)
when (V1 >= V2)
and (V1 > HV) ->
  get_most_popular_tweets(Startlist, [{Hash1, V1}], [{Hash2, V2} , {HHash, HV} | NotBiggest], Big);

  get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [{HHash, HV}], NotBiggest, Big)
  when (V1 >= V2) and (V1 =< HV) -> get_most_popular_tweets(Startlist, [{HHash, HV}], [{Hash2, V2} , {Hash1, V1} | NotBiggest], Big);
  get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [{HHash, HV}], NotBiggest, Big)
  when (V1 < V2) and (V2 > HV) -> get_most_popular_tweets(Startlist, [{Hash2, V2}], [{Hash1, V1} , {HHash, HV} | NotBiggest], Big);
  get_most_popular_tweets([{Hash1, V1} , {Hash2, V2} | Startlist], [{HHash, HV}], NotBiggest, Big)
  when (V1 < V2) and (V2 =< HV) -> get_most_popular_tweets(Startlist, [{HHash, HV}], [{Hash1, V1} , {Hash2, V2} | NotBiggest], Big);
  get_most_popular_tweets([{Hash1, V1}], [{HHash, HV}], NotBiggest, Big)
  when (V1 =< HV) -> get_most_popular_tweets([], [{HHash, HV}], [{Hash1, V1} | NotBiggest], Big);
  get_most_popular_tweets([{Hash1, V1}], [{HHash, HV}], NotBiggest, Big)
  when (V1 > HV) -> get_most_popular_tweets([], [{Hash1, V1}], [{HHash, HV} | NotBiggest], Big).

checklist([], _Big, List) -> List;
checklist(NotUsed, Big, List) ->
    case check_length(List, 0) of
      5 -> List;
      4 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      3 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      2 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      1 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      0 -> get_most_popular_tweets(NotUsed, [], [], [Big | List])
    end.

check_length([], N) -> N;
    check_length([_ | Tail], N) -> check_length(Tail, N+1).
