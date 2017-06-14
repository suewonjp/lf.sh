#!/usr/bin/env bats

load test_helper
fixtures
create_test_file_structure

@test "confirms aliases have been defined" {
  control_test

  run alias lf
  [ $status -eq 0 ]

  run alias lfi
  [ $status -eq 0 ]
}

@test "confirms the file structure for testing has been created" {
  control_test

  [ -d "${FIXTURE_ROOT}/${TEST_FS}" ]
}

@test "_join works as expected" {
  control_test

  run _join '*' hello world
  [ $status -eq 0 ]
  [ "$output" = '*hello*world' ]

  #run _join '.*' hello world
  #[ $status -eq 0 ]
  #[ "$output" = '.*hello.*world' ]
}

@test "_trim works as expected" {
  control_test

  run _trim "   hello   "
  [ $status -eq 0 ]
  [ "$output" = 'hello' ]

  run _trim "   hello  world   "
  [ $status -eq 0 ]
  [ "$output" = 'hello  world' ]

  run _trim "   "
  [ $status -eq 0 ]
  [ "$output" = '' ]

  run _trim
  [ $status -eq 0 ]
  [ "$output" = '' ]
}

@test "_compile_dirs2ignore works as expected" {
  control_test

  run _compile_dirs2ignore " .git :.svn : .hg  "
  [ $status -eq 0 ]
  [ "$output" = "!:-path:*.git/*:!:-path:*.svn/*:!:-path:*.hg/*:" ]

  run _compile_dirs2ignore ".git : some dirs to  ignore  :build  "
  [ $status -eq 0 ]
  [ "$output" = "!:-path:*.git/*:!:-path:*some dirs to  ignore/*:!:-path:*build/*:" ]

  run _compile_dirs2ignore ":.hidden"
  [ $status -eq 0 ]
  [ "$output" = '!:-path:*.hidden/*:' ]

  run _compile_dirs2ignore ".hidden:"
  [ $status -eq 0 ]
  [ "$output" = '!:-path:*.hidden/*:' ]

  run _compile_dirs2ignore ":.hidden:"
  [ $status -eq 0 ]
  [ "$output" = '!:-path:*.hidden/*:' ]

  run _compile_dirs2ignore ":"
  [ $status -eq 0 ]
  [ "$output" = '' ]
  
  run _compile_dirs2ignore "::"
  [ $status -eq 0 ]
  [ "$output" = '' ]

  run _compile_dirs2ignore
  [ $status -eq 0 ]
  [ "$output" = '' ]
}

@test "prints help messages" {
  control_test

  run lf -h
  [ $status -eq 0 ] && [ "$output" = "$( _help_lf )" ]

  run lf --h
  [ $status -eq 0 ] && [ "$output" = "$( _help_lf )" ]

  run lf -help
  [ $status -eq 0 ] && [ "$output" = "$( _help_lf )" ]

  run lf --help
  [ $status -eq 0 ] && [ "$output" = "$( _help_lf )" ]

  run lf -?
  [ $status -eq 0 ] && [ "$output" = "$( _help_lf )" ]

  run lf --?
  [ $status -eq 0 ] && [ "$output" = "$( _help_lf )" ]
}

@test "lists all files" {
  control_test

  run lf
  show_output
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 8 ]
  sort_array lines
  [ "${lines[0]}" = "app-options.properties" ]
  [ "${lines[7]}" = "files/folder 1/bar.txt" ]

  run lf --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 8 ]
  sort_array lines
  [ "${lines[0]}" = "app-options.properties" ]
  [ "${lines[7]}" = "files/folder 1/bar.txt" ]

  run lf . --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 8 ]
  sort_array lines
  [ "${lines[0]}" = "app-options.properties" ]
  [ "${lines[7]}" = "files/folder 1/bar.txt" ]

  run lf ./ --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 8 ]
  sort_array lines
  [ "${lines[0]}" = "app-options.properties" ]
  [ "${lines[7]}" = "files/folder 1/bar.txt" ]

  run lf + --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 8 ]
  sort_array lines
  [ "${lines[0]}" = "$PWD/app-options.properties" ]
  [ "${lines[7]}" = "$PWD/files/folder 1/bar.txt" ]
}

@test "removes trailing duplicate slashes if given" {
  control_test

  run lf .// --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 8 ]

  run lf ./// --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 8 ]

  run lf .//// --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 8 ]
}

@test "lists all files (including dot files)" {
  control_test

  run lf .+
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 11 ]
  sort_array lines
  [ "${lines[9]}" = ".hidden/baz.lst" ]
  [ "${lines[10]}" = ".hidden/log/error.log" ]

  run lf .+ --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 11 ]
  sort_array lines
  [ "${lines[9]}" = ".hidden/baz.lst" ]
  [ "${lines[10]}" = ".hidden/log/error.log" ]

  run lf .+${PWD} --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 11 ]
  sort_array lines
  [ "${lines[9]}" = "${PWD}/.hidden/baz.lst" ]
  [ "${lines[10]}" = "${PWD}/.hidden/log/error.log" ]

  cd ..
  run lf .+${TEST_FS} --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 11 ]
  sort_array lines
  [ "${lines[9]}" = "${TEST_FS}/.hidden/baz.lst" ]
  [ "${lines[10]}" = "${TEST_FS}/.hidden/log/error.log" ]
  cd -

  run lf +.+ --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 11 ]
  sort_array lines
  [ "${lines[9]}" = "${PWD}/.hidden/baz.lst" ]
  [ "${lines[10]}" = "${PWD}/.hidden/log/error.log" ]
}

@test "respects _LIST_FILE_DIRS_IGNORE variable" {
  control_test

  _LIST_FILE_DIRS_IGNORE=".hidden"
  run lf .+
  show_output
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 9 ]
  sort_array lines
  [ "${lines[0]}" = "app-options.properties" ]
  [ "${lines[8]}" = "files/folder 1/bar.txt" ]

  run lf .+ --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 9 ]

  run lf +.+ --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 9 ]
  sort_array lines
  [ "${lines[0]}" = "${PWD}/app-options.properties" ]
  [ "${lines[8]}" = "${PWD}/files/folder 1/bar.txt" ]

  _LIST_FILE_DIRS_IGNORE=":"
  run lf .+ --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 11 ]
}

@test "lists files with a file extention" {
  control_test

  local regex=".txt$"
  run lf .txt
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 5 ]
  [[ "${lines[0]}" =~ $regex ]]
  [[ "${lines[1]}" =~ $regex ]]
  [[ "${lines[2]}" =~ $regex ]]
  [[ "${lines[3]}" =~ $regex ]]
  [[ "${lines[4]}" =~ $regex ]]
}

@test "lists files with file pattern " {
  control_test

  local regex="empty.txt$"
  run lf empty*
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [[ "${lines[0]}" =~ $regex ]]
  [[ "${lines[1]}" =~ $regex ]]
  [[ "${lines[2]}" =~ $regex ]]

  run lf + empty*
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [[ "${lines[0]}" =~ $regex ]]
  [[ "${lines[1]}" =~ $regex ]]
  [[ "${lines[2]}" =~ $regex ]]
  sort_array
}

@test "lists files with an intermediate folder and file extention" {
  control_test

  run lf database .db
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "database/civilizer.h2.db" ]

  run lf + database .db
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "$PWD/database/civilizer.h2.db" ]

  run lf +database .db
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "$PWD/database/civilizer.h2.db" ]
}

@test "lists files with an intermediate folder and file extention (ignore cases)" {
  control_test

  local regex=database.*.\(db\|DB\)$
  run lfi database .db
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 2 ]
  [[ "${lines[0]}" =~ $regex ]]
  [[ "${lines[1]}" =~ $regex ]]

  regex=${PWD}/database.*.\(db\|DB\)$
  run lfi + database .db
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 2 ]
  [[ "${lines[0]}" =~ $regex ]]
  [[ "${lines[1]}" =~ $regex ]]

  run lfi +database .db
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 2 ]
  [[ "${lines[0]}" =~ $regex ]]
  [[ "${lines[1]}" =~ $regex ]]
}

@test "lists files with intermediate folders" {
  control_test

  run lf files folder --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 4 ]
  sort_array lines
  [ "${lines[0]}" = "files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/foo.txt" ]
  [ "${lines[3]}" = "files/folder 1/bar.txt" ]

  run lf + files folder --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 4 ]
  sort_array lines
  [ "${lines[0]}" = "$PWD/files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "$PWD/files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "$PWD/files/folder 0/foo.txt" ]
  [ "${lines[3]}" = "$PWD/files/folder 1/bar.txt" ]
}

@test "lists files with intermediate folders and file extention" {
  control_test

  run lf files folder 0 .txt
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  sort_array lines
  [ "${lines[0]}" = "files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/foo.txt" ]

  run lf + files folder 0 .txt
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  sort_array lines
  [ "${lines[0]}" = "$PWD/files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "$PWD/files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "$PWD/files/folder 0/foo.txt" ]
}

@test "lists only dot files" {
  control_test

  run lf .+ /. --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  sort_array lines
  [ ${lines[0]} = ".config" ]
  [ ${lines[1]} = ".hidden/baz.lst" ]
  [ ${lines[2]} = ".hidden/log/error.log" ]

  run lf +.+ /. --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  sort_array lines
  [ ${lines[0]} = "$PWD/.config" ]
  [ ${lines[1]} = "$PWD/.hidden/baz.lst" ]
  [ ${lines[2]} = "$PWD/.hidden/log/error.log" ]
}

@test "lists files under a dot directory" {
  control_test

  run lf .+ .hidd --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 2 ]
  sort_array lines
  [ ${lines[0]} = ".hidden/baz.lst" ]
  [ ${lines[1]} = ".hidden/log/error.log" ]

  run lf +.+ .hidd --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 2 ]
  sort_array lines
  [ ${lines[0]} = "$PWD/.hidden/baz.lst" ]
  [ ${lines[1]} = "$PWD/.hidden/log/error.log" ]

  run lf .+ .log
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = ".hidden/log/error.log" ]

  run lf +.+ .log
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "$PWD/.hidden/log/error.log" ]
}

@test "lists files with an absolute base path" {
  control_test

  run lf "${PWD}" folder 0 .txt
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  sort_array lines
  [ "${lines[0]}" = "$PWD/files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "$PWD/files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "$PWD/files/folder 0/foo.txt" ]
}

