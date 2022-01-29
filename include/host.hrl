-ifdef(unit_test).
-define(HostNodesFile,"./test_host_specs/host.nodes").
-else.
-define(GitCloneHost,boot_host:initial_clone_host()).
-define(GitPath,"https://github.com/joq62/host_specs.git").
-define(HostFilesDir,"../host_specs").
-endif.


-define(ScheduleInterval,20*1000).
