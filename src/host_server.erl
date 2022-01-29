%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(host_server). 

-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("log.hrl").
-include("host.hrl").
%% --------------------------------------------------------------------



%% External exports
-export([
	]).


-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
	       }).

%% ====================================================================
%% External functions
%% ====================================================================


%% ====================================================================
%% Server functions
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
    
    spawn(fun()->do_desired_state() end),
    rpc:cast(node(),log,log,[?Log_info("server started",[])]),
    {ok, #state{}
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

handle_call({availble_host_nodes,CallingNode},_From, State) ->
    Reply=lib_host:availble_host_nodes(CallingNode),
    {reply, Reply, State};

handle_call({availble_host_nodes,CallingNode,Constraints},_From, State) ->
    Reply=lib_host:availble_host_nodes(CallingNode,Constraints),
    {reply, Reply, State};

handle_call({started_nodes},_From, State) ->
    Reply=lib_host:node_started(),
    {reply, Reply, State};
handle_call({host_host},_From, State) ->
    Reply=db_host:status(),
    {reply, Reply, State};
handle_call({host_host,Id},_From, State) ->
    Reply=db_host:status(Id),
    {reply, Reply, State};
handle_call({node_host},_From, State) ->
    Reply={node_host},
    {reply, Reply, State};
handle_call({node_host,Id},_From, State) ->
    Reply={node_host,Id},
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
		   Result=rpc:call(node(),host_desired_state,start,[],2*60*1000)
		  % log:log(?Log_info("Result",[Result]))
	   end,
   
    timer:sleep(?ScheduleInterval),
    rpc:cast(node(),host,desired_state,[]).
		  
