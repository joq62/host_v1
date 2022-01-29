%% Author: uabjle
%% Created: 10 dec 2012
%% Description: TODO: Add description to application_org
%% 
-module(appl_mgr). 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Definitions 
%% --------------------------------------------------------------------
-define(SERVER,appl_mgr_server).
%% --------------------------------------------------------------------
-export([
	 all_app_info/0,
	 git_load_configs/0,
	 load_app_specs/0,
	 update_app_specs/0,
	 get_app_dir/2,
	 exists/1,
	 exists/2,
	 ping/0
        ]).

-export([
	 boot/0,
	 start/0,
	 stop/0
	]).



%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals
boot()->
    ok=application:start(?MODULE).
%% Gen server functions

start()-> gen_server:start_link({local, ?SERVER}, ?SERVER, [], []).
stop()-> gen_server:call(?SERVER, {stop},infinity).




%%---------------------------------------------------------------
-spec ping()-> {atom(),node(),module()}|{atom(),term()}.
%% 
%% @doc:check if service is running
%% @param: non
%% @returns:{pong,node,module}|{badrpc,Reason}
%%
ping()-> 
    gen_server:call(?SERVER, {ping},infinity).
all_app_info()-> 
    gen_server:call(?SERVER, {all_app_info},infinity).
git_load_configs()->
    gen_server:call(?SERVER, { git_load_configs},infinity).
load_app_specs()->
    gen_server:call(?SERVER, {load_app_specs},infinity).
update_app_specs()->
    gen_server:call(?SERVER, {update_app_specs},infinity).
get_app_dir(App,latest)->
    gen_server:call(?SERVER, {get_app_dir,App,latest},infinity);
get_app_dir(App,Vsn)->
    gen_server:call(?SERVER, {get_app_dir,App,Vsn},infinity).

exists(App)->
     gen_server:call(?SERVER, {exists,App},infinity).
exists(App,Vsn)->
     gen_server:call(?SERVER, {exists,App,Vsn},infinity).
    

%%----------------------------------------------------------------------
