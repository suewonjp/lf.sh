#!/usr/bin/env bats

load test_helper
fixtures
create_fake_file_list

@test "confirms aliases have been defined" {
  run alias lfs
  [ $status -eq 0 ]

  if [ "Darwin" != "$( uname )" ]; then
    run alias pbcopy
    [ $status -eq 0 ]

    run alias pbpaste
    [ $status -eq 0 ]
  fi
}

@test "confirms the fake file list for testing has been created" {
  [ ${#_LIST_FILE_OUTPUT_CACHE[*]} -gt 0 ]
}

@test "prints help messages" {
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
  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}
  run lfs
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]
}

@test "selecting works for valid positive index range" {
  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  for ((i=0;i<c;++i)); do
    run lfs $i
    [ $status -eq 0 ]
    [ ${#lines[*]} -eq 1 ]
    [ "$output" = "${_LIST_FILE_OUTPUT_CACHE[i]}" ]
  done
}

@test "selecting works for valid negative index range" {
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
  if [ "$( uname )" != "Darwin" ]; then
    ## For some reason, this test only works on OS X for now...
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

