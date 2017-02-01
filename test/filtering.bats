#!/usr/bin/env bats

load test_helper
fixtures
create_fake_file_list

@test "aliases are recognizable" {
  run alias lff
  [ $status -eq 0 ]
}

@test "confirm fake file list for testing has been created" {
  [ ${#_LIST_FILE_OUTPUT_CACHE[*]} -gt 0 ]
}

@test "list all when no parameter given" {
  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}
  run lff
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]
}

@test "filtering with matched pattern" {
  run lff empty
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ "${lines[0]}" = "files/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/folder 2/empty.txt" ]
}

@test "filtering with non-matched pattern" {
  run lff hello
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 0 ]
}

@test "can copy filtered item to system clipboard" {
  run lff ".db" +
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "database/civilizer.h2.db" ]

  run _pbpaste
  [ $status -eq 0 ]
  [ "${lines[0]}" = "database/civilizer.h2.db" ]
}
