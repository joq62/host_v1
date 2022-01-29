%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(boot_host).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("log.hrl").
-include("appl_mgr.hrl").
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
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start()->
    % get Lastest
    
    {ok,LatestHostRev}=latest_path("host"),
    LatestHostEbin=filename:join(LatestHostRev,"ebin"),
    code:add_patha(LatestHostEbin),
    application:start(host),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
latest_path(AppName)->
    Result = case file:list_dir(?RootDir) of
		 {error,Reason}->
		     {error,Reason};
		 {ok,Files}->
		     Dirs=[File||File<-Files,
				 filelib:is_dir(File)],
		     case lists:reverse(lists:sort(Files)) of
			 []->
			     {error,[eexist,Dirs]};
			 [Latest|_] ->
			     {ok,filename:join(AppName,Latest)}
		     end
	     end,
    Result.
