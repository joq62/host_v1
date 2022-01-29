-ifdef(unit_test).
-define(GitPath,"https://github.com/joq62/test_appl_specs.git").
-define(ApplSpecsDir,"../test_appl_specs").
-else.
-define(GitPath,"https://github.com/joq62/appl_specs.git").
-define(ApplSpecsDir,"../appl_specs").
-endif.

-define(RootDir,".").
-define(ScheduleInterval,20*1000).
