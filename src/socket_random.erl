-module(socket_random).

-author('L Bjork <gusbjorklu@student.gu.se>').

-export([start/0]).

start() ->
  {ok, Pid} = riakc_pb_socket:start("127.0.0.1", 10017),
  randomEntry(Pid,<<"hashtags">>).

randomEntry(Pid, Bucket) ->
  {ok, List} = riakc_pb_socket:list_keys(Pid, Bucket),
  EntryNumber = randomize(List),
  {ok, Entry} = riakc_pb_socket:get(Pid, Bucket, EntryNumber),
  {ReturnValue} = binary_to_term(riakc_obj:get_value(Entry)),
  ReturnValue.
randomize(List)->
  Index = random:uniform(length(List)),
  lists:nth(Index,List).
