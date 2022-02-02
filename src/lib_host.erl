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

%% --------------------------------------------------------------------
%-compile(export_all).

-export([
	 filter/3,
	 read_specs/0,
	 get_node/2,
	 capabilites_all/1
	
	
	]).


%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
filter(Affinity,Constraints,HostInfo)->
    AllCapabilites=capabilites_all(HostInfo),
    do_filter(Affinity,Constraints,AllCapabilites).
    
    
do_filter([],[],AllCapabilites)->
  %  io:format("ServiceId ~p~n",[{ServiceId,?MODULE,?LINE}]),
    Candidates=[Id||{Id,_}<-AllCapabilites],
    Candidates;

do_filter(Affinity,[],AllCapabilites)->
   % io:format("ServiceId ~p~n",[{ServiceId,?MODULE,?LINE}]),
    Candidates=[Id||{Id,_}<-AllCapabilites,XId<-Affinity,
		    Id=:=XId],
    Candidates;

do_filter([],Constraints,AllCapabilites)->
   % io:format("ServiceId ~p~n",[{ServiceId,?MODULE,?LINE}]),
    do_filter(AllCapabilites,Constraints);

do_filter(Affinity,Constraints,AllCapabilites)->
   % io:format("ServiceId ~p~n",[{ServiceId,?MODULE,?LINE}]),
    Stage1=[{Id,Capabilities}||{Id,Capabilities}<-AllCapabilites,XId<-Affinity,
		    Id=:=XId],
    do_filter(Stage1,Constraints).


do_filter(AllCapabilites,Constraints)->
    do_filter_2(AllCapabilites,Constraints,[]).

do_filter_2([],_,FilterStage1)->
    FilterStage1;

do_filter_2([{Id,Capabilities}|T],Constraints,Acc)->

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
    do_filter_2(T,Constraints,NewAcc).



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
get_node(Id,HostInfo)->
    NodeList=[{proplists:get_value(node,I)}||I<-HostInfo,
					     Id=:=proplists:get_value(id,I)],
    case NodeList of
	[]->
	    {error,[eexists,Id]};
	[Vm] ->
	    Vm
    end.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
capabilites_all(HostInfo)->
    [{proplists:get_value(id,I),proplists:get_value(capabilities,I)}||I<-HostInfo].

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
read_specs()->
    {ok,Files}=file:list_dir(?HostFilesDir),
    ServiceSepcFiles=[filename:join(?HostFilesDir,File)||File<-Files,
							    ".host"=:=filename:extension(File)],
    read_specs(ServiceSepcFiles,[]).

read_specs([],List)->
    List;
read_specs([File|T],Acc) ->
    {ok,Info}=file:consult(File),
    read_specs(T,[Info|Acc]).
