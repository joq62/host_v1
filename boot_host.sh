#!/bin/bash
/lib/erlang/bin/erl -pa boot_ebin -sname host -s boot_host_controller start -setcookie cookie_test -detached
