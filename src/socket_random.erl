-module(socket_random).

-author('L Bjork <gusbjorklu@student.gu.se>').

-export([start/0]).

start() ->
  {ok, Pid} = riakc_pb_socket:start("127.0.0.1", 10017),
  randomEntry(Pid,<<"hashtags">>).

randomEntry(Pid, Bucket) ->
  {ok, R} = riakc_pb_socket:list_keys(Pid, Bucket),
  List = dict:to_list(R),
  EntryNumber = randomize(List),
  {ok, Entry} = riakc_pb_socket:get(Pid, Bucket, EntryNumber).
  Entry.
randomize(List)->
  Index = random:uniform(length(List)),
  lists:nth(Index,List).
