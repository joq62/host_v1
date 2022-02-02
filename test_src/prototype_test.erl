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
%-include("controller.hrl").
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

    io:format("~p~n",[{"Start start_script()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=start_script(),
    io:format("~p~n",[{"Stop  start_script()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start host_init()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=host_init(),
    io:format("~p~n",[{"Stop  host_init()",?MODULE,?FUNCTION_NAME,?LINE}]),

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
start_script()->
    % suppor debugging
    ok=application:start(sd),

    % Simulate host
    ok=test_nodes:start_nodes(),
    [Vm1|_]=test_nodes:get_nodes(),
    
    %simulate start script
    % rm -rf loader
    % git clone https://github.com/joq62/loader.git loader
    % erl -pa loader/ebin -sname loader -setcookie cookie_test -s boot_loader start worker -detached 
    
    LoaderDir="loader",
    LoaderGitPath="https://github.com/joq62/loader.git",
    Ebin="loader/ebin",
    
    os:cmd("rm -rf "++LoaderDir),
    os:cmd("git clone "++LoaderGitPath++" "++LoaderDir), 
    true=rpc:call(Vm1,code,add_path,[Ebin],5000),
    ok=rpc:call(Vm1,boot_loader,start,[[worker]],15000),
    
    pong=rpc:call(Vm1,loader,ping,[],2000),
    ok.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
host_init()->
    ok=application:start(host),
    
    [{"c100",_},
     {"c100",_},
     {"c100",_}]=host:filter([],[]),

    [{"c100","h201"}]=host:filter([{"c100","h201"}],[]),

    [{"c100","h202"}]=host:filter([],[{port,60000},{hw,glurk}]),
    []=host:filter([{"c100","h201"}],[{port,60000},{hw,glurk}]),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------



host_init_2()->
    ok=application:start(host),
    
    % Controller sim
    NeededAffinity={"c100","h201"},
    NeededCapability=[{port,60000},{hw,glurk}],

    Service0={"service_0","1.0.0",[],[]},
    Service1={"service_1","1.0.0",[{"c100","h201"}],[]},
    Service2={"service_2","1.0.0",[],[{port,60000},{hw,glurk}]},
    
    AllCapabilites=host:capabilites_all(),
    {"service_0","1.0.0",
     [{"c100",_},
      {"c100",_},
      {"c100",_}]}=filter({"service_0","1.0.0",[],[]},AllCapabilites),

    {"service_1","1.0.0",[{"c100","h201"}]}=filter({"service_1","1.0.0",[{"c100","h201"}],[]},AllCapabilites),

    {"service_2","1.0.0",[{"c100","h202"}]}=filter({"service_2","1.0.0",[],[{port,60000},{hw,glurk}]},AllCapabilites),
    {"service_3","1.0.0",[]}=filter({"service_3","1.0.0",[{"c100","h201"}],[{port,60000},{hw,glurk}]},AllCapabilites),

	    
    ok.

filter({ServiceId,Vsn,[],[]},AllCapabilites)->
  %  io:format("ServiceId ~p~n",[{ServiceId,?MODULE,?LINE}]),

    Candidates=[Id||{Id,_}<-AllCapabilites],
    {ServiceId,Vsn,Candidates};

filter({ServiceId,Vsn,Affinity,[]},AllCapabilites)->
   % io:format("ServiceId ~p~n",[{ServiceId,?MODULE,?LINE}]),
    Candidates=[Id||{Id,_}<-AllCapabilites,XId<-Affinity,
		    Id=:=XId],
    {ServiceId,Vsn,Candidates};

filter({ServiceId,Vsn,[],Constraints},AllCapabilites)->
   % io:format("ServiceId ~p~n",[{ServiceId,?MODULE,?LINE}]),
    {ServiceId,Vsn,filter1(AllCapabilites,Constraints)};

filter({ServiceId,Vsn,Affinity,Constraints},AllCapabilites)->
   % io:format("ServiceId ~p~n",[{ServiceId,?MODULE,?LINE}]),
    Stage1=[{Id,Capabilities}||{Id,Capabilities}<-AllCapabilites,XId<-Affinity,
		    Id=:=XId],
    {ServiceId,Vsn,filter1(Stage1,Constraints)}.


filter1(AllCapabilites,Constraints)->
    filter1(AllCapabilites,Constraints,[]).

filter1([],_,FilterStage1)->
    FilterStage1;

filter1([{Id,Capabilities}|T],Constraints,Acc)->

 %   Test=[{X,Z}||X<-Capabilities,Z<-Constraints],
   
    L1=lists:sort([X||X<-Capabilities,Z<-Constraints,
		      X=:=Z]),
%    io:format("L1,lists:sort(Constraints) ~p~n",[{L1,lists:sort(Constraints)}]),
%    io:format("L1=:=lists:sort(Constraints) ~p~n",[{L1=:=lists:sort(Constraints)}]),
  
    NewAcc=case L1=:=lists:sort(Constraints) of
	       true->
		   [Id|Acc];
	       false->
		   Acc
	   end,
    filter1(T,Constraints,NewAcc).

    



init(Name,Vsn,Template,LoaderVm)->
    {ok,ServiceVm}=rpc:call(LoaderVm,loader,create,[],10000),
    %Fix
    true=rpc:call(ServiceVm,code,add_patha,["ebin"],5000),
    ok=rpc:call(ServiceVm,application,set_env,[[{service,[{id,{Name,Vsn}},{template,Template},{loader_vm,LoaderVm}]}]],5000),
    ok=rpc:call(ServiceVm,application,start,[service],5000),
    {ok,{{Name,Vsn},ServiceVm}}.
  
    

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
dist_1()->
    [H1,H2,H3]=test_nodes:get_nodes(),
    io:format("sd:all ~p~n",[{rpc:call(H1,sd,all,[],2000),?FUNCTION_NAME,?MODULE,?LINE}]),

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
