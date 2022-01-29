%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description :  1
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(cluster_start_test).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("log.hrl").
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

%    io:format("~p~n",[{"Start init()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=init(),
    io:format("~p~n",[{"Stop init()",?MODULE,?FUNCTION_NAME,?LINE}]),

  %  io:format("~p~n",[{"Start stop_restart()",?MODULE,?FUNCTION_NAME,?LINE}]),
  %  ok= stop_restart(),
  %  io:format("~p~n",[{"Stop  stop_restart()",?MODULE,?FUNCTION_NAME,?LINE}]),

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
init()->
    
    [N0,N1,N2]=test_nodes:get_nodes(),

   %% Start N0  node  
    ok=rpc:call(N0,application,start,[kubelet],10*1000),
    pong=rpc:call(N0,kubelet,ping,[],2000),
    pong=rpc:call(N0,sd,ping,[],2000),
    pong=rpc:call(N0,bully,ping,[],2000),
    pong=rpc:call(N0,dbase,ping,[],2000),
   

    N0=rpc:call(N0,bully,who_is_leader,[],5000),

 %% Start N1  node  
    ok=rpc:call(N1,application,start,[kubelet],10*1000),
    pong=rpc:call(N1,kubelet,ping,[],2000),
    pong=rpc:call(N1,sd,ping,[],2000),
    pong=rpc:call(N1,bully,ping,[],2000),
    pong=rpc:call(N1,dbase,ping,[],2000),
    N0=rpc:call(N1,bully,who_is_leader,[],5000),

 %% Start N2  node  
    ok=rpc:call(N2,application,start,[kubelet],10*1000),
    pong=rpc:call(N2,kubelet,ping,[],2000),
    pong=rpc:call(N2,sd,ping,[],2000),
    pong=rpc:call(N2,bully,ping,[],2000),
    pong=rpc:call(N2,dbase,ping,[],2000),
    N0=rpc:call(N2,bully,who_is_leader,[],5000),
    
%   io:format("nodes() ~p~n",[{nodes(),?FUNCTION_NAME,?MODULE,?LINE}]),
    rpc:call(N0,log,read_all,[],5000),
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
