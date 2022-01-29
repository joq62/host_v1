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
-include("configs.hrl").
%%---------------------------------------------------------------------
%% Records for test
%%


%% --------------------------------------------------------------------
%-compile(export_all).

-export([
	 start/1
	]).


%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start([controller])->
    io:format("controller ~p~n",[{?FUNCTION_NAME,?MODULE,?LINE}]),
    ok=do_clone(),
    ok=application:set_env([{host,[{type,controller}]}]),
    ok=application:start(host),
    ok;
start([worker])->
    io:format("worker ~p~n",[{?FUNCTION_NAME,?MODULE,?LINE}]),
    ok=do_clone(),
    ok=application:set_env([{host,[{type,worker}]}]),
    ok=application:start(host),
    ok.

do_clone()->
    git_clone_host_files(),
    git_clone_appl_files(),
    git_clone_host(),
    ok.

git_clone_host()->
    os:cmd("rm -rf "++?HostDir),
    os:cmd("git clone "++?HostGitPath),
    HostEbin=filename:join(?HostDir,"ebin"),
    true=code:add_patha(HostEbin),
    ok.

git_clone_host_files()->
    os:cmd("rm -rf "++?HostFilesDir),
    os:cmd("git clone "++?HostSpecsGitPath),
    true=code:add_patha(?HostFilesDir),
    ok.

git_clone_appl_files()->
    os:cmd("rm -rf "++?ApplSpecsDir),
    os:cmd("git clone "++?ApplSpecsGitPath),
    true=code:add_patha(?ApplSpecsDir),
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
