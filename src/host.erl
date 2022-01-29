%% Author: uabjle
%% Created: 10 dec 2012
%% Description: TODO: Add description to application_org
-module(host). 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Definitions 
%% --------------------------------------------------------------------
-define(SERVER,host_server).
%% --------------------------------------------------------------------
-export([
	 availble_host_nodes/1,
	 availble_host_nodes/2,

	 started_nodes/0,
	 stopped/0,
	 started/0,
	 desired_state/0,
	 host_status/0,
	 host_status/1,
	 node_status/0,
	 node_status/1,
	 ping/0
        ]).

-export([
	 boot/0,
	 start/0,
	 stop/0
	]).



%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals
boot()->
    ok=application:start(?MODULE).
%% Gen server functions

start()-> gen_server:start_link({local, ?SERVER}, ?SERVER, [], []).
stop()-> gen_server:call(?SERVER, {stop},infinity).




%%---------------------------------------------------------------
-spec ping()-> {atom(),node(),module()}|{atom(),term()}.
%% 
%% @doc:check if service is running
%% @param: non
%% @returns:{pong,node,module}|{badrpc,Reason}
%%
ping()-> 
    gen_server:call(?SERVER, {ping},infinity).

availble_host_nodes(CallingNode)->
        gen_server:call(?SERVER, {availble_host_nodes,CallingNode},infinity).
availble_host_nodes(CallingNode,Constraints)->
        gen_server:call(?SERVER, {availble_host_nodes,CallingNode,Constraints},infinity).

started_nodes()-> 
    gen_server:call(?SERVER, {started_nodes},infinity).

started()-> 
    gen_server:call(?SERVER, {started},infinity).
stopped()-> 
    gen_server:call(?SERVER, {stopped},infinity).
host_status()->
     gen_server:call(?SERVER, {host_status},infinity).
host_status(Id)->
     gen_server:call(?SERVER, {host_status,Id},infinity).
node_status()->
     gen_server:call(?SERVER, {node_status},infinity).
node_status(Id)->
     gen_server:call(?SERVER, {node_status,Id},infinity).

desired_state()-> 
    gen_server:cast(?SERVER, {desired_state}).

%%----------------------------------------------------------------------
