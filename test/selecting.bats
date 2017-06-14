#!/usr/bin/env bats

load test_helper
fixtures
create_fake_file_list

@test "confirms aliases have been defined" {
  control_test

  run alias lfs
  [ $status -eq 0 ]
}

@test "confirms the fake file list for testing has been created" {
  control_test

  [ ${#_LIST_FILE_OUTPUT_CACHE[*]} -gt 0 ]
}

@test "prints help messages" {
  control_test

  run lfs -h
  [ $status -eq 0 ] && [ "$output" = "$( _help_lfs )" ]

  run lfs --h
  [ $status -eq 0 ] && [ "$output" = "$( _help_lfs )" ]

  run lfs -help
  [ $status -eq 0 ] && [ "$output" = "$( _help_lfs )" ]

  run lfs --help
  [ $status -eq 0 ] && [ "$output" = "$( _help_lfs )" ]

  run lfs -?
  [ $status -eq 0 ] && [ "$output" = "$( _help_lfs )" ]

  run lfs --?
  [ $status -eq 0 ] && [ "$output" = "$( _help_lfs )" ]
}

@test "lists all when no parameter given" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}
  run lfs
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]
}

@test "selecting works for valid positive index range" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  for ((i=0;i<c;++i)); do
    run lfs $i
    [ $status -eq 0 ]
    [ ${#lines[*]} -eq 1 ]
    [ "$output" = "${_LIST_FILE_OUTPUT_CACHE[i]}" ]
  done
}

@test "selecting works for valid negative index range" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  for ((i=-c;i<0;++i)); do
    run lfs $i
    [ $status -eq 0 ]
    [ ${#lines[*]} -eq 1 ]
    local realIndex=$(( c + i ))
    [ "$output" = "${_LIST_FILE_OUTPUT_CACHE[realIndex]}" ]
  done
}

@test "selecting with invalid index returns nothing" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  run lfs $c
  [ $status -eq 1 ]
  [ ${#lines[*]} -eq 0 ]

  run lfs $(( c + $RANDOM ))
  [ $status -eq 1 ]
  [ ${#lines[*]} -eq 0 ]

  run lfs -0
  [ $status -eq 1 ]
  [ ${#lines[*]} -eq 0 ]

  run lfs $(( -c -1 - $RANDOM ))
  [ $status -eq 1 ]
  [ ${#lines[*]} -eq 0 ]
}

@test "copies selected items to the system clipboard" {
  control_test

  if [[ "$( uname )" =~ Linux ]]; then
    ## Bats won't allow this test to run on Linux for some reason
    ## Looks like Bats is not supporting pipe properly
    return
  fi

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  for ((i=0;i<c;++i)); do
    run lfs $i +
    [ $status -eq 0 ]

    run _pbpaste
    [ $status -eq 0 ]
    [ "$output" = "${_LIST_FILE_OUTPUT_CACHE[i]}" ]
  done
}

