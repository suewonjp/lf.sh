#!/usr/bin/env bats

load test_helper
fixtures
create_test_file_structure

unset _LIST_FILE_GREP_TOOL
unset _LIST_FILE_GREP_OPTIONS

@test "confirms aliases have been defined" {
  run alias g
  [ $status -eq 0 ]

  run alias gi
  [ $status -eq 0 ]
}

@test "prints help messages" {
  run g
  [ $status -eq 0 ] && [ "$output" = "$( _help_g )" ]
}

@test "searches for matching pattern" {
  run g foo .txt
  [ "$output" = "files/folder 0/foo.txt:1:foo" ]

  run g bar .txt
  [ "$output" = "files/folder 1/bar.txt:1:bar" ]

  run g baz .hidden --
  [ "$output" = ".hidden/baz.lst:1:baz" ]

  run g "civilizer"
  [ ${#lines[*]} -eq 6 ]
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
  _LIST_FILE_GREP_OPTIONS="-i -o"
  run gi "hello"
  [ ${#lines[*]} -eq 2 ]
  [ "${lines[0]}" = "app-options.properties:hello" ]
  [ "${lines[1]}" = "app-options.properties:HELLO" ]

  _LIST_FILE_GREP_OPTIONS="-oE"
  run gi 'https?://.+'
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = 'app-options.properties:https://github.com/suewonjp/civilizer' ]

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
  [ "${lines[0]}" = "app-options.properties:3:civilizer.message1=hello world!" ]
}

@test "respects _LIST_FILE_GREP_TOOL variable - egrep" {
  _LIST_FILE_GREP_TOOL=egrep
  _LIST_FILE_GREP_OPTIONS="-o"
  run g 'https?://.+'
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = 'app-options.properties:https://github.com/suewonjp/civilizer' ]
}

@test "respects _LIST_FILE_GREP_TOOL variable - fgrep" {
  _LIST_FILE_GREP_TOOL=fgrep
  _LIST_FILE_GREP_OPTIONS="-oi"
  run g 'hello'
  [ ${#lines[*]} -eq 2 ]
  [ "${lines[0]}" = 'app-options.properties:hello' ]
  [ "${lines[1]}" = 'app-options.properties:HELLO' ]
}

@test "respects _LIST_FILE_GREP_TOOL variable - ack" {
  _LIST_FILE_GREP_TOOL=ack
  run g 'hello'
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = 'app-options.properties:3:civilizer.message1=hello world!' ]
}

@test "respects _LIST_FILE_GREP_TOOL variable - ag" {
  _LIST_FILE_GREP_TOOL=ag
  run g 'hello'
  #echo "+++ ${output}"
  [ ${#lines[*]} -eq 3 ]
  [ "${lines[0]}" = 'app-options.properties' ]
  [ "${lines[1]}" = '3:civilizer.message1=hello world!' ]
  [ "${lines[2]}" = '4:civilizer.message2=HELLO WORLD!' ]

  _LIST_FILE_GREP_OPTIONS=--nonumbers
  run g 'hello'
  [ ${#lines[*]} -eq 2 ]
  [ "${lines[0]}" = 'app-options.properties:civilizer.message1=hello world!' ]
  [ "${lines[1]}" = 'app-options.properties:civilizer.message2=HELLO WORLD!' ]

  _LIST_FILE_GREP_OPTIONS="-s --nonumbers"
  run g 'hello'
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = 'app-options.properties:civilizer.message1=hello world!' ]
}

@test "ignores GREP_OPTIONS variable" {
  GREP_OPTIONS="-i"
  run gi "hello"
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "app-options.properties:3:civilizer.message1=hello world!" ]
}

