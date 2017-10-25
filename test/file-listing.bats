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
  [ $status -eq 0 ] && [ "$output" = '*hello*world' ]

  #run _join '.*' hello world
  #[ $status -eq 0 ]
  #[ "$output" = '.*hello.*world' ]
}

@test "_trim works as expected" {
  control_test

  run _trim "   hello   "
  [ $status -eq 0 ] && [ "$output" = 'hello' ]

  run _trim "   hello  world   "
  [ $status -eq 0 ] && [ "$output" = 'hello  world' ]

  run _trim "   "
  [ $status -eq 0 ] && [ "$output" = '' ]

  run _trim
  [ $status -eq 0 ] && [ "$output" = '' ]
}

@test "_compile_dirs2ignore works as expected" {
  control_test

  run _compile_dirs2ignore " .git :.svn : .hg  "
  [ $status -eq 0 ]
  [ "$output" = "!:-path:*.git/*:!:-path:*.svn/*:!:-path:*.hg/*:" ]

  run _compile_dirs2ignore "database: .git :.svn : .hg  "
  [ $status -eq 0 ]
  [ "$output" = "!:-path:*database/*:!:-path:*.git/*:!:-path:*.svn/*:!:-path:*.hg/*:" ]

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
  [ $status -eq 0 ] && [ "$output" = '' ]
  
  run _compile_dirs2ignore "::"
  [ $status -eq 0 ] && [ "$output" = '' ]

  run _compile_dirs2ignore
  [ $status -eq 0 ] && [ "$output" = '' ]
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

  check() {
    assert_basics 8
    sort_array lines
    [ "${lines[0]}" = "${pwd}app-options.properties" ]
    [ "${lines[7]}" = "${pwd}files/folder 1/bar.txt" ]
  }

  run lf; show_output; check
  run lf --; check
  run lf . --; check
  run lf ./ --; check
  run lf + --; pwd=$PWD/ check
}

@test "removes trailing duplicate slashes if given" {
  control_test

  run lf .// --
  [ $status -eq 0 ] && [ ${#lines[*]} -eq 8 ]
  run lf ./// --
  [ $status -eq 0 ] && [ ${#lines[*]} -eq 8 ]
  run lf .//// --
  [ $status -eq 0 ] && [ ${#lines[*]} -eq 8 ]
}

@test "lists all files (including dot files)" {
  control_test

  check() {
    assert_basics 11
    sort_array lines
    [ "${lines[9]}" = "${pwd}.hidden/baz.lst" ]
    [ "${lines[10]}" = "${pwd}.hidden/log/error.log" ]
  }

  run lf .+; check
  run lf .+ --; check
  run lf .+${PWD} --; pwd=$PWD/ check
  cd ..; run lf .+${TEST_FS} --; pwd=${TEST_FS}/ check; cd -
  run lf +.+ --; pwd=$PWD/ check
}

@test "respects _LIST_FILE_DIRS_IGNORE variable" {
  control_test

  check() {
    assert_basics 9
    sort_array lines
    [ "${lines[0]}" = "${pwd}app-options.properties" ]
    [ "${lines[8]}" = "${pwd}files/folder 1/bar.txt" ]
  }

  _LIST_FILE_DIRS_IGNORE=".hidden"
  run lf .+; show_output; check
  run lf .+ --; check
  run lf +.+ --; pwd=$PWD/ check

  _LIST_FILE_DIRS_IGNORE=":"
  run lf .+ --
  assert_basics 11
}

@test "lists files with a file extention" {
  control_test

  local regex=".txt$"
  run lf .txt
  assert_basics 5
  [[ "${lines[0]}" =~ $regex ]]
  [[ "${lines[1]}" =~ $regex ]]
  [[ "${lines[2]}" =~ $regex ]]
  [[ "${lines[3]}" =~ $regex ]]
  [[ "${lines[4]}" =~ $regex ]]
}

@test "lists files with file pattern " {
  control_test

  check() {
    assert_basics 3
    [[ "${lines[0]}" =~ $regex ]]
    [[ "${lines[1]}" =~ $regex ]]
    [[ "${lines[2]}" =~ $regex ]]
  }

  local regex="empty.txt$"
  run lf empty*; check
  run lf + empty*; check
}

@test "lists files with an intermediate folder and file extention" {
  control_test

  check() {
    assert_basics 1
    [ "${lines[0]}" = "${pwd}database/civilizer.h2.db" ]
  }

  run lf database .db; check
  run lf + database .db; pwd=$PWD/ check
  run lf +database .db; pwd=$PWD/ check
}

@test "lists files with an intermediate folder and file extention (ignore cases)" {
  control_test

  check() {
    assert_basics 2
    [[ "${lines[0]}" =~ $regex ]]
    [[ "${lines[1]}" =~ $regex ]]
  }

  local regex=database.*.\(db\|DB\)$
  run lfi database .db; check

  regex=${PWD}/database.*.\(db\|DB\)$
  run lfi + database .db; check
  run lfi +database .db; check
}

@test "lists files with intermediate folders" {
  control_test

  check() {
    assert_basics 4
    sort_array lines
    [ "${lines[0]}" = "${pwd}files/folder 0/empty.txt" ]
    [ "${lines[1]}" = "${pwd}files/folder 0/folder 2/empty.txt" ]
    [ "${lines[2]}" = "${pwd}files/folder 0/foo.txt" ]
    [ "${lines[3]}" = "${pwd}files/folder 1/bar.txt" ]
  }

  run lf files folder --; check
  run lf + files folder --; pwd=$PWD/ check
}

@test "lists files with intermediate folders and file extention" {
  control_test

  check() {
    assert_basics 3
    sort_array lines
    [ "${lines[0]}" = "${pwd}files/folder 0/empty.txt" ]
    [ "${lines[1]}" = "${pwd}files/folder 0/folder 2/empty.txt" ]
    [ "${lines[2]}" = "${pwd}files/folder 0/foo.txt" ]
  }

  run lf files folder 0 .txt; check
  run lf + files folder 0 .txt; pwd=$PWD/ check
}

@test "lists only dot files" {
  control_test

  check() {
    assert_basics 3
    sort_array lines
    [ ${lines[0]} = "${pwd}.config" ]
    [ ${lines[1]} = "${pwd}.hidden/baz.lst" ]
    [ ${lines[2]} = "${pwd}.hidden/log/error.log" ]
  }

  run lf .+ /. --; check
  run lf +.+ /. --; pwd=$PWD/ check
}

@test "lists files under a dot directory" {
  control_test

  check() {
    assert_basics 2
    sort_array lines
    [ ${lines[0]} = "${pwd}.hidden/baz.lst" ]
    [ ${lines[1]} = "${pwd}.hidden/log/error.log" ]
  }

  run lf .+ .hidd --; check
  run lf +.+ .hidd --; pwd=$PWD/ check

  check() {
    assert_basics 1
    [ "${lines[0]}" = "${pwd}.hidden/log/error.log" ]
  }

  run lf .+ .log; check
  run lf +.+ .log; pwd=$PWD/ check
}

@test "lists files with an absolute base path" {
  control_test

  run lf "${PWD}" folder 0 .txt
  assert_basics 3
  sort_array lines
  [ "${lines[0]}" = "$PWD/files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "$PWD/files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "$PWD/files/folder 0/foo.txt" ]
}

@test "ignores files with 'ignore' variable" {
  control_test

  ignore=database run lf --
  assert_basics 6
  sort_array lines
  [ "${lines[0]}" = "app-options.properties" ]
  [ "${lines[5]}" = "files/folder 1/bar.txt" ]

  ignore=files/ run lf --
  assert_basics 3

  ignore='folder 0:' run lf --
  assert_basics 5

  ignore='folder 0:' run lf .+ --
  assert_basics 8
}

@test "appends or prepends new search result to the existing result" {
  control_test

  create_fake_file_list

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}
  run lfs
  assert_basics $(( $c + 0 ))

  prepend= run lf .properties
  assert_basics $(( $c + 1 ))
  [ "${lines[0]}" = "app-options.properties" ]

  append= run lf database --
  assert_basics $(( $c + 2 ))
  [ "${lines[$(( $c + 1 ))]}" = "database/civilizer.TRACE.DB" ]

  # When 'prepend' and 'append' are used simultaneously, respect only 'prepend'
  prepend= append= run lf .properties
  assert_basics $(( $c + 1 ))
  [ "${lines[0]}" = "app-options.properties" ]
}

@test "adds prefix and postfix to each of search result" {
  control_test

  test() {
    pre=${pr} post=${po} run lf .properties
    assert_basics 1
    [ "${lines[0]}" = "${pr}app-options.properties${po}" ]
  }

  pr=\` po=\` test
  pr=\( po=\) test
  pr=\{ po=\} test
  pr=\[ po=\] test
  pr=\< po=\> test
  pr=\\* po=\\* test
  pr=\+ po=\+ test
  pr=\~ po=\~ test
  pr=\| po=\| test
  pr=\# po=\# test
}

@test "quotes each of search result" {
  control_test

  check() {
    assert_basics 3
    sort_array lines
    local tmp=$( printf "${quote}%s${quote}\n" "files/folder 0/empty.txt" )
    [ "${lines[0]}" = "$tmp" ]
    tmp=$( printf "${quote}%s${quote}\n" "files/folder 0/folder 2/empty.txt" )
    [ "${lines[1]}" = "$tmp" ]
    tmp=$( printf "${quote}%s${quote}\n" "files/folder 0/foo.txt" )
    [ "${lines[2]}" = "$tmp" ]
  }

  q= run lf files folder 0 .txt
  quote=\' check

  qq= run lf files folder 0 .txt
  quote=\" check
}

@test "seprates each item with nul byte" {
  control_test

  test() {
    lf files folder 0 .txt | while read f; do echo $f; done
  }
  run test
  assert_basics 3

  test() {
    nul= lf files folder 0 .txt | while read f; do echo $f; done
  }
  run test
  assert_basics 0

  test() {
    nul= lf files folder 0 .txt | while read -d $'\0' f; do echo $f; done
  }
  run test
  assert_basics 3
  sort_array lines
  [ "${lines[0]}" = "files/folder 0/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/foo.txt" ]
}

