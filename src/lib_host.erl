%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(lib_host).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("log.hrl").
-include("configs.hrl").
%%---------------------------------------------------------------------
%% Records for test
%%
%-define(ScheduleInterval,20*1000).
%-define(ConfigsGitPath,"https://github.com/joq62/configs.git").
%-define(ConfigsDir,filename:join(?ApplMgrConfigDir,"configs")).
%-define(ApplicationsDir,filename:join(?ConfigsDir,"applications")).
%-define(ApplMgrConfigDir,"appl_mgr.dir").

%% --------------------------------------------------------------------
%-compile(export_all).

-export([
	 git_load_host_files/0,
	 git_update_host_files/0,

	 connect_nodes/0,
	 
	 load_appl/2,
	 load_appl/3,
	 unload_appl/2,
	 start_appl/2,
	 stop_appl/2
	
	]).


%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
connect_nodes()->
 
    io:format("HostNodesFile ~p~n",[{?HostNodesFile,?FUNCTION_NAME,?MODULE,?LINE}]),
    
    {ok,ContactNodes}=file:consult(?HostNodesFile),
    Res=[{N,net_adm:ping(N)}||N<-ContactNodes],
    Res.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
git_load_host_files()->
    os:cmd("rm -rf "++?HostFilesDir),
    os:cmd("git clone "++?HostSpecsGitPath),
    ok.

    
git_update_host_files()->
    {error,[not_implmented]}.
		   
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------




%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
load_appl(Appl,Vm)->
    Result=case appl_mgr:get_appl_dir(Appl) of
	       {error,Reason}->
		   {error,Reason};
	       {ok,ApplDirPath}->
		   do_load(Appl,ApplDirPath,Vm)
	   end,
    Result.

load_appl(Appl,Vsn,Vm)->
    Result=case appl_mgr:get_appl_dir(Appl,Vsn) of
	       {error,Reason}->
		   {error,Reason};
	       {ok,ApplDirPath}->
		   do_load(Appl,ApplDirPath,Vm)
	   end,
    Result.    





do_load(Appl,ApplDirPath,Vm)->
    EbinPath=filename:join(ApplDirPath,"ebin"),
    Result=case rpc:call(Vm,code,add_patha,[EbinPath],5000) of
	       {Error,Reason}->
		   {Error,Reason};
	       true->
		   case rpc:call(Vm,application,load,[Appl],5000) of
		       {Error,Reason}->
			   {Error,Reason};
		       ok->
			   ok
		   end
	   end,
    Result.
    
    %% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
unload_appl(Appl,Vm)->
    rpc:call(Vm,application,unload,[Appl],10*1000).


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start_appl(Appl,Vm)->
    rpc:call(Vm,application,start,[Appl],10*1000).


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
stop_appl(Appl,Vm)->
    rpc:call(Vm,application,stop,[Appl],10*1000).

