%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(host). 

-behaviour(gen_server). 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("log.hrl").
-include("host.hrl").
%% --------------------------------------------------------------------
-define(SERVER,host).


%% External exports
-export([
	 filter/2,

	 capabilites_all/0,
	 get_node/1,
	 
	 read_state/0,
	 ping/0
	]).


-export([
	 start/0,
	 stop/0
	]).


-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
		host_specs
	       }).

%% ====================================================================
%% External functions
%% ====================================================================


%% ====================================================================
%% Server functions
%% ====================================================================
%% Gen server functions

start()-> gen_server:start_link({local, ?SERVER}, ?SERVER, [], []).
stop()-> gen_server:call(?SERVER, {stop},infinity).

%% ====================================================================
%% Application handling
%% ====================================================================

%%---------------------------------------------------------------
%% Function: filter(Affinity,Constraints)
%% @doc: creates a list of hosts that fulfills Affinity and Constraints      
%% @param: Affinity and Constraints
%% @returns:[{Id,LoaderVm}]
%%
%%---------------------------------------------------------------
-spec filter([term()],[term()])-> [{term(),node()}].
filter(Affinity,Constraints)->
    gen_server:call(?SERVER, {filter,Affinity,Constraints},infinity).

%%---------------------------------------------------------------
%% Function: capabilites_all()
%% @doc: all nodes capabilites      
%% @param: non 
%% @returns:[{Id,Capabilities}]
%%
%%---------------------------------------------------------------
-spec capabilites_all()-> [{term(),[term()]}].
capabilites_all()->
    gen_server:call(?SERVER, {capabilites_all},infinity).
%%---------------------------------------------------------------
%% Function:get_node(Id)
%% @doc: get loader node for host with Id       
%% @param: node Id 
%% @returns:Vm|{error,Reason}
%%
%%---------------------------------------------------------------
-spec get_node(term())-> node()|{atom(),term()}.
get_node(Id)->
    gen_server:call(?SERVER, {get_node,Id},infinity).

%% ====================================================================
%% Vm machine functions
%% ====================================================================


%% ====================================================================
%% Support functions
%% ====================================================================
%%---------------------------------------------------------------
%% Function:read_state()
%% @doc: read theServer State variable      
%% @param: non 
%% @returns:State
%%
%%---------------------------------------------------------------
-spec read_state()-> term().
read_state()->
    gen_server:call(?SERVER, {read_state},infinity).
%% 
%% @doc:check if service is running
%% @param: non
%% @returns:{pong,node,module}|{badrpc,Reason}
%%
-spec ping()-> {atom(),node(),module()}|{atom(),term()}.
ping()-> 
    gen_server:call(?SERVER, {ping},infinity).

%% ====================================================================
%% Gen Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
    HostSpecsInfo=lib_host:read_specs(),
  %  io:format("Type ~p~n",[{Type,?FUNCTION_NAME,?MODULE,?LINE}]),
    
%    spawn(fun()->do_desired_state() end),
%    rpc:cast(node(),log,log,[?Log_info("server started",[])]),
    {ok, #state{host_specs=HostSpecsInfo}
    }.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_call({filter,Affinity,Constraints},_From, State) ->
    Reply=lib_host:filter(Affinity,Constraints,State#state.host_specs),
    {reply, Reply, State};


handle_call({get_node,Id},_From, State) ->
    Reply=lib_host:get_node(Id,State#state.host_specs),
    {reply, Reply, State};

handle_call({capabilites_all},_From, State) ->
    Reply=lib_host:capabilites_all(State#state.host_specs),
    {reply, Reply, State};



handle_call({read_state},_From, State) ->
    Reply=State,
    {reply, Reply, State};
handle_call({ping},_From, State) ->
    Reply=pong,
    {reply, Reply, State};

handle_call({stopped},_From, State) ->
    Reply=ok,
    {reply, Reply, State};




handle_call({not_implemented},_From, State) ->
    Reply=not_implemented,
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    rpc:cast(node(),log,log,[?Log_ticket("unmatched call",[Request, From])]),
    Reply = {ticket,"unmatched call",Request, From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_cast({desired_state}, State) ->
    spawn(fun()->do_desired_state() end),
    {noreply, State};

handle_cast(Msg, State) ->
    rpc:cast(node(),log,log,[?Log_ticket("unmatched cast",[Msg])]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(Info, State) ->
    rpc:cast(node(),log,log,[?Log_ticket("unmatched info",[Info])]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
do_desired_state()->
    % io:format("~p~n",[{time(),node(),?MODULE,?FUNCTION_NAME,?LINE,CallerPid}]),
    case bully:am_i_leader(node()) of
	false->
	    ok;
	true->
	    Result=rpc:call(node(),host_desired_state,start,[],2*60*1000),
	    glurk=Result
						% log:log(?Log_info("Result",[Result]))
    end,
    
    timer:sleep(?ScheduleInterval),
    rpc:cast(node(),host,desired_state,[]).
		  
