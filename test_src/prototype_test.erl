%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description :  1
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(prototype_test).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("log.hrl").
-include("appl_mgr.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]). 


%% ====================================================================
%% External functions
%% ====================================================================


%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
  %  io:format("~p~n",[{"Start setup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=setup(),
    io:format("~p~n",[{"Stop setup",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start boot()",?MODULE,?FUNCTION_NAME,?LINE}]),
%    ok= boot(),
%    io:format("~p~n",[{"Stop  boot()",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start host_init()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok= host_init(),
    io:format("~p~n",[{"Stop  host_init()",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start host_vm()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok= host_vm(),
    io:format("~p~n",[{"Stop  host_vm()",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start appl_mgr()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok= appl_mgr(),
    io:format("~p~n",[{"Stop  appl_mgr()",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start host_appl()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok= host_appl(),
    io:format("~p~n",[{"Stop  host_appl()",?MODULE,?FUNCTION_NAME,?LINE}]),


  %  io:format("~p~n",[{"Start sim_controller_1()",?MODULE,?FUNCTION_NAME,?LINE}]),
%    ok= sim_controller_1(),
 %   io:format("~p~n",[{"Stop  sim_controller_1()",?MODULE,?FUNCTION_NAME,?LINE}]),

 %   
      %% End application tests
  %  io:format("~p~n",[{"Start cleanup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=cleanup(),
  %  io:format("~p~n",[{"Stop cleaup",?MODULE,?FUNCTION_NAME,?LINE}]),
   
    io:format("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.
 %  io:format("application:which ~p~n",[{application:which_applications(),?FUNCTION_NAME,?MODULE,?LINE}]),



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
host_appl()->
    % Start a Vm  
    {ok,N1}=host:create(),
    false=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    false=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)), 
    % Load an application  
    ok=host:load_appl(myadd,N1),
    true=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    false=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)),
    % Start an application   
    ok=host:start_appl(myadd,N1),
    true=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    true=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)),
    % Test the application
    42=rpc:call(N1,myadd,add,[20,22],1000),
    {error,{already_started,myadd}}=host:start_appl(myadd,N1),    
    
    % stop an application 
    ok=host:stop_appl(myadd,N1),
    true=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    false=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)),
    {badrpc,_}=rpc:call(N1,myadd,add,[20,22],1000),
    % Unload an application
    ok=host:unload_appl(myadd,N1),
    false=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    false=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)),
    {badrpc,_}=rpc:call(N1,myadd,add,[20,22],1000),

    ok.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
host_init()->
  %  ok=boot_host:start(),

    ok.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

host_vm()->
    ok=application:start(host),
    {ok,N1}=host:create(),
    pong=net_adm:ping(N1),
    Test1=test_1@c100,
    {ok,Test1}=host:create("test_1"),
    pong=net_adm:ping(Test1),
    
    ok=host:delete(N1),
    pang=net_adm:ping(N1),

    ok=host:delete(Test1),
    pang=net_adm:ping(Test1),

    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
appl_mgr()->

    {error,_}=appl_mgr:get_appl_dir(dbase,"1.0.0"),
    ok=appl_mgr:load_specs(),
%    io:format(" ~p~n",[{appl_mgr:all_app_info(),?FUNCTION_NAME,?MODULE,?LINE}]),
    {ok,"dbase/1.0.0"}=appl_mgr:get_appl_dir(dbase,"1.0.0"),
    {ok,"dbase/1.0.0"}=appl_mgr:get_appl_dir(dbase,latest),
    
   
    {ok,"myadd/1.0.0"}=appl_mgr:get_appl_dir(myadd,"1.0.0"),
    {ok,"myadd/1.0.0"}=appl_mgr:get_appl_dir(myadd,latest),
 
   
    
  
    
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
   
        
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
   
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
