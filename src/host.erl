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
	 load_appl/2,
	 load_appl/3,
	 unload_appl/2,
	 start_appl/2,
	 stop_appl/2,

	 create/0,
	 create/1,
	 delete/1,
	 read_state/0,
	 ping/0
	]).


-export([
	 start/0,
	 stop/0
	]).


-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
		type
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
%% Function:load_appl(App)
%% @doc: loads latest version of App to vm Vm      
%% @param: Application and erlang vm to load 
%% @returns:ok|{error,Reason}
%%
%%---------------------------------------------------------------
-spec load_appl(atom(),node())-> atom()|{atom(),term()}.
load_appl(Appl,Vm)->
    gen_server:call(?SERVER, {load_appl,Appl,Vm},infinity).
%%---------------------------------------------------------------
%% Function:load_appl(App,Vsn,Vm)
%% @doc: loads Vsn version of App to vm Vm      
%% @param: Application and erlang vm to load 
%% @returns:ok|{error,Reason}
%%
%%---------------------------------------------------------------
-spec load_appl(atom(),string(),node())-> atom()|{atom(),term()}.
load_appl(Appl,Vsn,Vm)->
    gen_server:call(?SERVER, {load_appl,Appl,Vsn,Vm},infinity).

%%---------------------------------------------------------------
%% Function:start_appl(App,Vm)
%% @doc: Start loaded application App on on vm Vm      
%% @param: Application and erlang vm to start
%% @returns:ok|{error,Reason}
%%
%%---------------------------------------------------------------
-spec start_appl(atom(),string())-> atom()|{atom(),term()}.
start_appl(Appl,Vm)->
    gen_server:call(?SERVER, {start_appl,Appl,Vm},infinity).

%%---------------------------------------------------------------
%% Function:stop_appl(App,Vm)
%% @doc: Stop loaded application App on on vm Vm      
%% @param: Application and erlang vm to stop
%% @returns:stopped|{error,Reason}
%%
%%---------------------------------------------------------------
-spec stop_appl(atom(),string())-> atom()|{atom(),term()}.
stop_appl(Appl,Vm)->
    gen_server:call(?SERVER, {stop_appl,Appl,Vm},infinity).

%%---------------------------------------------------------------
%% Function:unload_appl(App,Vm)
%% @doc: Unload loaded application App on on vm Vm      
%% @param: Application and erlang vm to unload
%% @returns:ok|{error,Reason}
%%
%%---------------------------------------------------------------
-spec unload_appl(atom(),string())-> atom()|{atom(),term()}.
unload_appl(Appl,Vm)->
    gen_server:call(?SERVER, {unload_appl,Appl,Vm},infinity).

%% ====================================================================
%% Vm machine functions
%% ====================================================================

%%---------------------------------------------------------------
%% Function:create()
%% @doc: creates a erlang slave node with a unique name and same cookie
%%       as the host      
%% @param: non
%% @returns:{ok,NodeName}|{error,Reason}
%%
%%---------------------------------------------------------------
-spec create()-> {atom(),node()}|{atom(),term()}.
create()->
    gen_server:call(?SERVER, {create},infinity).
%%---------------------------------------------------------------
%% @doc: creates a erlang slave node with a unique nodename 
%%       Unique_NodeName and same cookie as the host      
%% @param: NodeName
%% @returns:{ok,NodeName}|{error,Reason}
%%
%%---------------------------------------------------------------
-spec create(string())-> {atom(),node()}|{atom(),term()}.
create(NodeName)->
    gen_server:call(?SERVER, {create,NodeName},infinity).

%%---------------------------------------------------------------
%% @doc: delete an erlang slave node       
%% @param: Node
%% @returns:ok
%%
%%---------------------------------------------------------------
-spec delete(node())-> atom().
delete(Vm)->
    gen_server:call(?SERVER, {delete,Vm},infinity).


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
    {ok,Type}=application:get_env(host,type),
    io:format("Type ~p~n",[{Type,?FUNCTION_NAME,?MODULE,?LINE}]),
    
%    spawn(fun()->do_desired_state() end),
%    rpc:cast(node(),log,log,[?Log_info("server started",[])]),
    {ok, #state{type=Type}
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

handle_call({load_appl,Appl,Vm},_From, State) ->
    Reply=rpc:call(node(),lib_host,load_appl,[Appl,Vm],5000),
    {reply, Reply, State};

handle_call({load_appl,Appl,Vsn,Vm},_From, State) ->
    Reply=rpc:call(node(),lib_host,load_appl,[Appl,Vsn,Vm],5000),
    {reply, Reply, State};

handle_call({unload_appl,Appl,Vm},_From, State) ->
    Reply=rpc:call(node(),lib_host,unload_appl,[Appl,Vm],5000),
    {reply, Reply, State};

handle_call({start_appl,Appl,Vm},_From, State) ->
    Reply=rpc:call(node(),lib_host,start_appl,[Appl,Vm],5000),
    {reply, Reply, State};

handle_call({stop_appl,Appl,Vm},_From, State) ->
    Reply=rpc:call(node(),lib_host,stop_appl,[Appl,Vm],5000),
    {reply, Reply, State};

handle_call({create},_From, State) ->
    Reply=rpc:call(node(),lib_vm,create,[],5000),
    {reply, Reply, State};

handle_call({create,NodeName},_From, State) ->
    Reply=rpc:call(node(),lib_vm,create,[NodeName],5000),
    {reply, Reply, State};

handle_call({delete,Vm},_From, State) ->
    Reply=rpc:call(node(),lib_vm,delete,[Vm],5000),
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
		  
