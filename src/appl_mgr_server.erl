%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(appl_mgr_server). 

-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("log.hrl").
-include("appl_mgr.hrl").
%% --------------------------------------------------------------------



%% External exports
-export([
	]).


-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {app_info
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
    
   % spawn(fun()->do_desired_state() end),
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
handle_call({all_app_info},_From, State) ->
    Reply=case State#state.app_info of
	      undefined->
		  {error,[app_spec_list_not_loaded,[]]};
	      AppInfoList->
		  {ok,AppInfoList}
	  end,
    {reply, Reply, State};

handle_call({git_load_configs},_From, State) ->
    Reply=lib_appl_mgr:git_load_configs(),
    {reply, Reply, State};

handle_call({load_app_specs},_From, State) ->
    Reply=case lib_appl_mgr:load_app_specs() of
	      {error,Reason}->
		  NewState=State,
		  {error,Reason};
	      {ok,AppInfo}->
		  NewState=State#state{app_info=AppInfo},
		  ok
	  end,
    {reply, Reply, NewState};

handle_call({update_app_specs},_From, State) ->
    Reply=case State#state.app_info of
	      undefined->
		  NewState=State,
		  {error,[app_spec_list_not_loaded,[]]};
	      AppInfoList->
		  case lib_appl_mgr:update_app_specs(AppInfoList) of
		      {error,Reason}->
			  NewState=State,
			  {error,Reason};
		      {ok,UpdatedAppInfoList}->
			  NewState=State#state{app_info=UpdatedAppInfoList},
			  ok
		  end
	  end,
    {reply, Reply, NewState};

handle_call({get_app_dir,App,Vsn},_From, State) ->
    Reply=case State#state.app_info of
	      undefined->
		  {error,[app_spec_list_not_loaded,[]]};
	      AppInfoList->
		  lib_appl_mgr:get_app_dir(App,Vsn,AppInfoList)
	  end,
    {reply, Reply, State};

handle_call({exists,App},_From, State) ->
    Reply=case State#state.app_info of
	      undefined->
		  {error,[app_spec_list_not_loaded,[]]};
	      AppInfoList->
		  lib_appl_mgr:exists(App,AppInfoList)
	  end,
    {reply, Reply, State};

handle_call({exists,App,Vsn},_From, State) ->
    Reply=case State#state.app_info of
	      undefined->
		  {error,[app_spec_list_not_loaded,[]]};
	      AppInfoList->
		  lib_appl_mgr:exists(App,Vsn,AppInfoList)
	  end,
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
  
    timer:sleep(?ScheduleInterval),
    rpc:cast(node(),appl_mgr,desired_state,[]).
		  
