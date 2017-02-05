#!/usr/bin/env bats

load test_helper
fixtures
create_test_file_structure

@test "confirms aliases have been defined" {
  run alias g
  [ $status -eq 0 ]

  run alias gi
  [ $status -eq 0 ]
}

@test "searches for matching pattern" {
  run g foo .txt
  [ "$output" = "files/folder 0/foo.txt:1:foo" ]

  run g bar .txt
  [ "$output" = "files/folder 1/bar.txt:1:bar" ]

  run g baz .hidden --
  [ "$output" = ".hidden/baz.lst:1:baz" ]

  run g "civilizer"
  [ ${#lines[*]} -eq 5 ]
}

@test "searches for matching pattern (ignore cases of file names)" {
  run gi "civilizer" .db
  [ ${#lines[*]} -eq 2 ]
}

@test "searches for non-matching pattern" {
  run g FOO file .txt
  [ "$output" = "" ]

  run gi CIVILIZER database .db
  [ "$output" = "" ]
}

@test "respects _LIST_FILE_GREP_OPTIONS variable" {
  _LIST_FILE_GREP_OPTIONS="-i"
  run gi "hello"
  [ ${#lines[*]} -eq 2 ]
  [ "${lines[0]}" = "app-options.properties:civilizer.message1=hello world!" ]
  [ "${lines[1]}" = "civilizer.message2=HELLO WORLD!" ]

  _LIST_FILE_GREP_OPTIONS=""
  run gi "hello"
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "app-options.properties:civilizer.message1=hello world!" ]

  _LIST_FILE_GREP_OPTIONS=''
  run gi "hello"
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "app-options.properties:civilizer.message1=hello world!" ]

  _LIST_FILE_GREP_OPTIONS=
  run gi "hello"
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "app-options.properties:civilizer.message1=hello world!" ]

  unset _LIST_FILE_GREP_OPTIONS
  run gi "hello"
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "app-options.properties:2:civilizer.message1=hello world!" ]
}

@test "ignores GREP_OPTIONS variable" {
  GREP_OPTIONS="-i"
  run gi "hello"
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "app-options.properties:2:civilizer.message1=hello world!" ]
}

