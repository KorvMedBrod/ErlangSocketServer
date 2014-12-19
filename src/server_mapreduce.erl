-module(server_mapreduce).
-export([mapred1/2, mapred/2, merge/2, count/3, get_most_popular_tweets/4, start/0]).

start() ->
  {ok, Pid} = riakc_pb_socket:start("127.0.0.1", 10017),
  mapred1(Pid,<<"hashtags">>).

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

  checklist(NotUsed, Big, List) ->
    case check_length(List, 0) of
      50 -> List;
      49 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      48 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      47 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      46 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      45 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      44 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      43 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      42 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      41 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      40 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      39 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      38 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      37 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      36 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      35 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      34 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      33 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      32 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      31 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      30 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      29 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      28 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      27 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      26 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      25 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      24 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      23 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      22 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      21 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      20 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      19 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      18 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      17 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      16 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      15 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      14 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      13 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      12 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      11 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      10 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      9 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      8 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      7 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      6 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      5 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      4 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      3 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      2 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      1 -> get_most_popular_tweets(NotUsed, [], [], [Big | List]);
      0 -> get_most_popular_tweets(NotUsed, [], [], [Big | List])
    end.

    check_length([], N) -> N;
    check_length([_ | Tail], N) -> check_length(Tail, N+1).
