%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 20121
%%% -------------------------------------------------------------------
-module(host_desired_state).  
    
%% -------------------------------------------------------2 -------------
%% Include files
%% --------------------------------------------------------------------
-include("log.hrl").
%%---------------------------------------------------------------------
%% Records for test
%%

%% --------------------------------------------------------------------
%-compile(export_all).
-export([
	 start/0

	 ]).

%% ====================================================================
%% External functions
%% ====================================================================
start()->
    MissingHosts=[HostId||HostId<-db_host:ids(),
			  pang=:=net_adm:ping(db_host:node(HostId))],
    case MissingHosts of
	[]->
	    ok;
	HostsToStart->
	    log:log(?Log_ticket("Missinghosts to start ",[MissingHosts])),
	    ok	    
    end.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
