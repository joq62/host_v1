%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(controller).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("log.hrl").
%-include("appl_mgr.hrl").
-include("configs.hrl").
%%---------------------------------------------------------------------
%% Records for test
%%


%% --------------------------------------------------------------------
%-compile(export_all).

-export([
	 init/0
	]).


%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
init()->
    Res=[create_load_start(Appl)||Appl<-?ControllerAppls],
    io:format("Res ~p~n",[{Res,?FUNCTION_NAME,?MODULE,?LINE}]).
   
    
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
create_load_start(Appl)->
    
    {ok,Vm}=rpc:call(node(),host,create,[],5000),
    % Load Start sd that always needs to be part of a Vm
    ok=rpc:call(node(),host,load_appl,[sd,Vm],5000),
    ok=rpc:call(node(),host,start_appl,[sd,Vm],5000),

    % Load Start Appl that always needs to be part of a Vm
    ok=rpc:call(node(),host,load_appl,[Appl,Vm],5000),
    ok=rpc:call(node(),host,start_appl,[Appl,Vm],5000),
    {ok,Appl}.
    
