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
-include("configs.hrl").
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

    io:format("~p~n",[{"Start host_init()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok= host_init(),
    io:format("~p~n",[{"Stop  host_init()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start host_vm()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok= host_vm(),
    io:format("~p~n",[{"Stop  host_vm()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start appl_mgr()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok= appl_mgr(),
    io:format("~p~n",[{"Stop  appl_mgr()",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start host_appl()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok= host_appl(),
    io:format("~p~n",[{"Stop  host_appl()",?MODULE,?FUNCTION_NAME,?LINE}]),


    io:format("~p~n",[{"Start dist_1()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=dist_1(),
    io:format("~p~n",[{"Stop  sim_controller_1()",?MODULE,?FUNCTION_NAME,?LINE}]),

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
host_init()->
    %% Config files and ebin for host is already loaded and the vm is started
    [H1|_]=test_nodes:get_nodes(),
    ok=boot_host:do_clone(node()),
    
    %% Add path to configfiles

%    true=rpc:call(H1,code,add_patha,[?ApplSpecsDir],5000),
%    true=rpc:call(H1,code,add_patha,[?HostFilesDir],5000),

    ok=rpc:call(H1,application,set_env,[[{host,[{type,worker}]}]],5000),
    ok=rpc:call(H1,application,start,[host],5000),
    pong=rpc:call(H1,host,ping,[],2000),

   % HostEbin=filename:join(?HostDir,"ebin"),
   % true=rpc:call(H1,code,add_patha,[HostEbin],5000),
   % ok=boot_host:start([worker]),
    
    ok.
    

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
host_appl()->
   
    % Test host initiated in host_init
    [H1|_]=test_nodes:get_nodes(),
    % Start a Vm  

    
   
    {ok,N1}=rpc:call(H1,host,create,[],5000),
    false=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    false=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)), 
    % Load an application  
    ok=rpc:call(H1,host,load_appl,[myadd,N1],5000),
    true=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    false=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)),
    % Start an application   
    ok=rpc:call(H1,host,start_appl,[myadd,N1],5000),
    true=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    true=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)),
    % Test the application
    42=rpc:call(N1,myadd,add,[20,22],1000),
    {error,{already_started,myadd}}=rpc:call(H1,host,start_appl,[myadd,N1],5000),    
    
    [H1]=rpc:call(H1,sd,get,[host],5000),

    % stop an application 
    ok=rpc:call(H1,host,stop_appl,[myadd,N1],5000),
    true=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    false=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)),
    {badrpc,_}=rpc:call(N1,myadd,add,[20,22],1000),
    % Unload an application
    ok=rpc:call(H1,host,unload_appl,[myadd,N1],5000),
    false=lists:keymember(myadd,1,rpc:call(N1,application,loaded_applications,[],1000)),
    false=lists:keymember(myadd,1,rpc:call(N1,application,which_applications,[],1000)),
    {badrpc,_}=rpc:call(N1,myadd,add,[20,22],1000),
    
  
    ok.
    

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

host_vm()->
  % Test host initiated in host_init
    [H1|_]=test_nodes:get_nodes(),
  %  ok=application:start(host),
    {ok,N1}=rpc:call(H1,host,create,[],5000),
    pong=net_adm:ping(N1),
    Test1=test_1@c100,
    {ok,Test1}=rpc:call(H1,host,create,["test_1"],5000),
    pong=net_adm:ping(Test1),
    
    ok=rpc:call(H1,host,delete,[N1],5000),
    pang=net_adm:ping(N1),

    ok=rpc:call(H1,host,delete,[Test1]),
    pang=net_adm:ping(Test1),

    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
appl_mgr()->
    % Test host initiated in host_init
    [H1|_]=test_nodes:get_nodes(),
    
    {error,_}=rpc:call(H1,appl_mgr,get_appl_dir,[dbase,"1.0.0"],5000),
    ok=rpc:call(H1,appl_mgr,load_specs,[],5000),
%    io:format(" ~p~n",[{appl_mgr:all_app_info(),?FUNCTION_NAME,?MODULE,?LINE}]),
    {ok,"dbase/1.0.0"}=rpc:call(H1,appl_mgr,get_appl_dir,[dbase,"1.0.0"],5000),
    {ok,"dbase/1.0.0"}=rpc:call(H1,appl_mgr,get_appl_dir,[dbase,latest],5000),
    
   
    {ok,"myadd/1.0.0"}=rpc:call(H1,appl_mgr,get_appl_dir,[myadd,"1.0.0"],5000),
    {ok,"myadd/1.0.0"}=rpc:call(H1,appl_mgr,get_appl_dir,[myadd,latest],5000),
   
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
dist_1()->
    [H1,H2,H3]=test_nodes:get_nodes(),
    ok=rpc:call(H2,application,set_env,[[{host,[{type,worker}]}]],5000),
    ok=rpc:call(H2,application,start,[host],5000),
    pong=rpc:call(H2,host,ping,[],2000),

    ok=rpc:call(H3,application,set_env,[[{host,[{type,controller}]}]],5000),
    ok=rpc:call(H3,application,start,[host],5000),
    pong=rpc:call(H3,host,ping,[],2000),

    [H1,H2,H3]=lists:sort(rpc:call(H1,sd,get,[host],2000)),
    [H1,H2,H3]=lists:sort(rpc:call(H2,sd,get,[host],2000)),
    [H1,H2,H3]=lists:sort(rpc:call(H3,sd,get,[host],2000)),

    {state,worker}=rpc:call(H1,host,read_state,[],2000),
    {state,worker}=rpc:call(H2,host,read_state,[],2000),
    {state,controller}=rpc:call(H3,host,read_state,[],2000),
    

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
%% --------------------------------------------------------------------
setup()->
  
    ok=test_nodes:start_nodes(),
    
          
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
