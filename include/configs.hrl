-ifdef(unit_test).
% host
-define(GitCloneHost,nop).
-define(HostDir,"host").
-define(HostGitPath,"https://github.com/joq62/host.git").
-define(HostSpecsGitPath,"https://github.com/joq62/test_host_specs.git").
-define(HostFilesDir,"test_host_specs").
-define(ApplSpecsGitPath,"https://github.com/joq62/test_appl_specs.git").
-define(ApplSpecsDir,"test_appl_specs").
% appl_mgr
-else.
-define(GitCloneHost,boot_host:initial_clone_host()).
-define(HostDir,"host").
-define(HostGitPath,"https://github.com/joq62/host.git").
-define(HostSpecsGitPath,"https://github.com/joq62/host_specs.git").
-define(HostFilesDir,"host_specs").
-define(ApplSpecsGitPath,"https://github.com/joq62/appl_specs.git").
-define(ApplSpecsDir,"appl_specs").
-endif.
%----------------------------------------------------------------
-define(RootDir,".").

%----------------------------------------------------------------
-define(WorkerAppls,[myadd]).
-define(ControllerAppls,[myadd,mydivi]).



