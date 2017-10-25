#!/usr/bin/env bats

load test_helper
fixtures
create_test_file_structure

unset _LIST_FILE_GREP_TOOL
unset _LIST_FILE_GREP_OPTIONS

@test "confirms aliases have been defined" {
  control_test

  run alias g
  [ $status -eq 0 ]

  run alias gi
  [ $status -eq 0 ]
}

@test "prints help messages" {
  control_test

  run g
  [ $status -eq 0 ] && [ "$output" = "$( _help_g )" ]
}

@test "searches for matching pattern" {
  control_test

  run g foo .txt
  [ "$output" = "files/folder 0/foo.txt:1:foo" ]

  run g bar .txt
  [ "$output" = "files/folder 1/bar.txt:1:bar" ]

  run g baz .hidden --
  [ "$output" = ".hidden/baz.lst:1:baz" ]

  run g "civilizer"
  assert_basics 6
}

@test "searches for matching pattern (ignore cases of file names)" {
  control_test

  run gi "civilizer" .db
  assert_basics 2
}

@test "searches for non-matching pattern" {
  control_test

  run g FOO file .txt
  [ "$output" = "" ]

  run gi CIVILIZER database .db
  [ "$output" = "" ]
}

@test "respects _LIST_FILE_GREP_OPTIONS variable" {
  control_test

  _LIST_FILE_GREP_OPTIONS="-i -o"
  run gi "hello"
  assert_basics 2
  [ "${lines[0]}" = "app-options.properties:hello" ]
  [ "${lines[1]}" = "app-options.properties:HELLO" ]

  _LIST_FILE_GREP_OPTIONS="-oE"
  run gi 'https?://.+'
  assert_basics 1
  [ "${lines[0]}" = 'app-options.properties:https://github.com/suewonjp/civilizer' ]

  _LIST_FILE_GREP_OPTIONS=""
  run gi "hello"
  assert_basics 1
  [ "${lines[0]}" = "app-options.properties:civilizer.message1=hello world!" ]

  _LIST_FILE_GREP_OPTIONS=''
  run gi "hello"
  assert_basics 1
  [ "${lines[0]}" = "app-options.properties:civilizer.message1=hello world!" ]

  _LIST_FILE_GREP_OPTIONS=
  run gi "hello"
  assert_basics 1
  [ "${lines[0]}" = "app-options.properties:civilizer.message1=hello world!" ]

  unset _LIST_FILE_GREP_OPTIONS
  run gi "hello"
  assert_basics 1
  [ "${lines[0]}" = "app-options.properties:3:civilizer.message1=hello world!" ]
}

@test "respects _LIST_FILE_GREP_TOOL variable - egrep" {
  control_test

  _LIST_FILE_GREP_TOOL=egrep
  _LIST_FILE_GREP_OPTIONS="-o"
  run g 'https?://.+'
  assert_basics 1
  [ "${lines[0]}" = 'app-options.properties:https://github.com/suewonjp/civilizer' ]
}

@test "respects _LIST_FILE_GREP_TOOL variable - fgrep" {
  control_test

  _LIST_FILE_GREP_TOOL=fgrep
  _LIST_FILE_GREP_OPTIONS="-oi"
  run g 'hello'
  assert_basics 2
  [ "${lines[0]}" = 'app-options.properties:hello' ]
  [ "${lines[1]}" = 'app-options.properties:HELLO' ]
}

@test "respects _LIST_FILE_GREP_TOOL variable - ack" {
  control_test

  if ! type ack > /dev/null 2>&1; then
    skip "Ack is not installed..."
  fi

  _LIST_FILE_GREP_TOOL=ack
  run g 'hello'
  assert_basics 1
  [ "${lines[0]}" = 'app-options.properties:3:civilizer.message1=hello world!' ]
}

@test "respects _LIST_FILE_GREP_TOOL variable - ag" {
  control_test

  if ! type ag > /dev/null 2>&1; then
    skip "The Silver Searcher is not installed..."
  fi

  _LIST_FILE_GREP_TOOL=ag
  run g 'hello'
  assert_basics 3
  [ "${lines[0]}" = 'app-options.properties' ]
  [ "${lines[1]}" = '3:civilizer.message1=hello world!' ]
  [ "${lines[2]}" = '4:civilizer.message2=HELLO WORLD!' ]

  _LIST_FILE_GREP_OPTIONS=--nonumbers
  run g 'hello'
  assert_basics 2
  [ "${lines[0]}" = 'app-options.properties:civilizer.message1=hello world!' ]
  [ "${lines[1]}" = 'app-options.properties:civilizer.message2=HELLO WORLD!' ]

  _LIST_FILE_GREP_OPTIONS="-s --nonumbers"
  run g 'hello'
  assert_basics 1
  [ "${lines[0]}" = 'app-options.properties:civilizer.message1=hello world!' ]
}

@test "ignores GREP_OPTIONS variable" {
  control_test

  GREP_OPTIONS="-i"
  run gi "hello"
  assert_basics 1
  [ "${lines[0]}" = "app-options.properties:3:civilizer.message1=hello world!" ]
}

