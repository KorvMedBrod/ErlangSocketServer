OS
  Ubuntu 12.04.5 LTS (GNU/Linux 3.2.0-73-virtual x86_64)

Software installed
  1. Erlang "R16B02-basho5"
     Installed from source, see link
     http://docs.basho.com/riak/latest/ops/building/installing/erlang/#Installing-on-GNU-Linux

  2. Riak riak_kv_version : <<"2.0.0-12-g20c5237">>
     Running five databases, see link
     http://docs.basho.com/riak/latest/quickstart/
     In order to get mapreduce to work you also need a file in each node that points to the compiled erlang code.
     Under "Loading code into Riak"
     http://www.galdiuz.com/mapred.html
     Direct link to file.
     http://www.galdiuz.com/advanced.config
     The path sould look something like this.
     "/__PATH__/ErlangSocketServer/ebin"

  3. The socket server it self needs rebar, in order to get and compile the riak.
     Prefebly from source since one of the frameworks has an issue with the older version in the Ubuntu package handler.
     https://github.com/basho/rebar
