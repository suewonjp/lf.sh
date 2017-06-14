#!/usr/bin/env bats

load test_helper
fixtures
create_fake_file_list

@test "confirms aliases have been defined" {
  control_test

  run alias lff
  [ $status -eq 0 ]
}

@test "confirms the fake file list for testing has been created" {
  control_test

  [ ${#_LIST_FILE_OUTPUT_CACHE[*]} -gt 0 ]
}

@test "prints help messages" {
  control_test

  run lff -h
  [ $status -eq 0 ] && [ "$output" = "$( _help_lff )" ]

  run lff --h
  [ $status -eq 0 ] && [ "$output" = "$( _help_lff )" ]

  run lff -help
  [ $status -eq 0 ] && [ "$output" = "$( _help_lff )" ]

  run lff --help
  [ $status -eq 0 ] && [ "$output" = "$( _help_lff )" ]

  run lff -?
  [ $status -eq 0 ] && [ "$output" = "$( _help_lff )" ]

  run lff --?
  [ $status -eq 0 ] && [ "$output" = "$( _help_lff )" ]
}

@test "lists all when no parameter given" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}
  run lff
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]
}

@test "filters with matched pattern" {
  control_test

  run lff empty
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ "${lines[0]}" = "files/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/folder 2/empty.txt" ]
}

@test "filters with non-matched pattern" {
  control_test

  run lff hello
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 0 ]
}

@test "copies filtered items to the system clipboard" {
  control_test

  if [[ "$( uname )" =~ Linux ]]; then
    ## Bats won't allow this test to run on Linux for some reason
    ## Looks like Bats is not supporting pipe properly
    return
  fi

  run lff ".db" +
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "database/civilizer.h2.db" ]

  run _pbpaste
  [ $status -eq 0 ]
  [ "${lines[0]}" = "database/civilizer.h2.db" ]
}
