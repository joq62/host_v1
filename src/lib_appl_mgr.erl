%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(lib_appl_mgr).   
   
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
	 load_specs/0,
	 update_specs/0,
	 get_appl_dir/3,
	 exists/2,
	 exists/3
	]).


%% ====================================================================
%% External functions
%% ====================================================================
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

load_specs()->
    Result=case get_appfiles() of
	       {error,Reason}->
		   {error,Reason};
	       {ok,AppFiles}->
		   AppInfo=git_load_app_specs(AppFiles),
		   {ok,AppInfo}
	   end,
    Result.

update_specs()->
    Result=case get_appfiles() of
	       {error,Reason}->
		   {error,Reason};
	       {ok,AppFiles}->
		   AppInfo=git_update_app_specs(AppFiles),
		   case git_update_app_specs(AppInfo) of
		       []->
			   {ok,AppInfo};
		       Updates->
			   %ToDo		
			   {ok,Updates}
		   end
	   end,
    Result.
		   
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
get_appl_dir(App,latest,AppInfo)->
    AppList=[{XApp,XVsn,AppDir}||{XApp,XVsn,AppDir}<-AppInfo,
			App=:=XApp],
    SortedAppList=lists:reverse(lists:keysort(2,AppList)),
    Result=case SortedAppList of
	       []->
		   {error,[eexists,App,latest]};
	       [{_App,_Vsn,LatestDir}|_]->
		   {ok,LatestDir}
	   end,
    Result;

get_appl_dir(App,Vsn,AppInfo)->
    AppDirList=[AppDir||{XApp,XVsn,AppDir}<-AppInfo,
			{App,Vsn}=:={XApp,XVsn}],
    Result=case AppDirList of
	       []->
		   {error,[eexists,App,Vsn]};
	       [Dir]->
		   {ok,Dir}
	   end,
    Result.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
exists(App,AppInfo)->
    lists:keymember(App,1,AppInfo).
 
exists(App,Vsn,AppInfo)->
    Result=case get_appl_dir(App,Vsn,AppInfo) of
	       {error,_}->
		   false;
	       _ -> 
		   true
	   end,
    Result.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
%% -------------------------------------------------------------------
get_appfiles()->
    Result=case filelib:is_dir(?ApplSpecsDir) of
	       false->
		   {error,[eexists,?ApplSpecsDir]};
	       true->
		   {ok,AllFiles}=file:list_dir(?ApplSpecsDir),
		   AppFiles=[{File,filename:join(?ApplSpecsDir,File)}||File<-AllFiles,
									  ".app"=:=filename:extension(File)],
		   {ok,AppFiles}
	   end,
    Result.
	       

    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
git_load_app_specs(AppInfo)->
    git_load_app_specs(AppInfo,[]).

git_load_app_specs([],LoadRes)->
    [{App,Vsn,AppDir}||{ok,App,Vsn,AppDir}<-LoadRes];
git_load_app_specs([{_File,FullPath}|T],Acc)->
    
    {ok,App}=appfile:read(FullPath,application),
    {ok,Vsn}=appfile:read(FullPath,vsn),
    {ok,GitPath}=appfile:read(FullPath,git_path),
    AppTopDir=atom_to_list(App),
    AppDir=filename:join(AppTopDir,Vsn),
    NewAcc=case filelib:is_dir(AppTopDir) of
	       false->
		   ok=file:make_dir(AppTopDir),
		   ok=file:make_dir(AppDir),
		   os:cmd("git clone "++GitPath++" "++AppDir),
		   [{ok,App,Vsn,AppDir}|Acc];
	      true ->
		  case filelib:is_dir(AppDir) of
		      false->
			  ok=file:make_dir(AppDir),
			  os:cmd("git clone "++GitPath++" "++AppDir),
			  [{ok,App,Vsn,AppDir}|Acc];
		      true ->
			  os:cmd("rm -rf "++AppDir),
			  os:cmd("git clone "++GitPath++" "++AppDir),
			  [{ok,App,Vsn,AppDir}|Acc]
		  end
	   end,
  
    %% Check if it worked ?
    git_load_app_specs(T,NewAcc).
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
git_update_app_specs(AppFiles)->
    git_update_app_specs(AppFiles,[]).

git_update_app_specs([],LoadRes)->
    [{App,Vsn,AppDir}||{ok,App,Vsn,AppDir}<-LoadRes];
git_update_app_specs([{_File,FullPath}|T],Acc)->
    {ok,App}=appfile:read(FullPath,application),
    {ok,Vsn}=appfile:read(FullPath,vsn),
    {ok,GitPath}=appfile:read(FullPath,git_path),
    AppTopDir=atom_to_list(App),
    AppDir=filename:join(AppTopDir,Vsn),
    NewAcc=case filelib:is_dir(AppTopDir) of
	       false->
		   ok=file:make_dir(AppTopDir),
		   ok=file:make_dir(AppDir),
		   os:cmd("git clone "++GitPath++" "++AppDir),
		   [{ok,App,Vsn,AppDir}|Acc];
	      true ->
		  case filelib:is_dir(AppDir) of
		      false->
			  ok=file:make_dir(AppDir),
			  os:cmd("git clone "++GitPath++" "++AppDir),
			  [{ok,App,Vsn,AppDir}|Acc];
		      true ->
			  Acc
		  end
	  end,
  
    %% Check if it worked ?
    git_update_app_specs(T,NewAcc).
