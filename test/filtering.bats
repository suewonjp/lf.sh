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
  assert_basics $c
}

@test "filters with matched pattern" {
  control_test

  run lff empty
  assert_basics 3
  [ "${lines[0]}" = "files/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/folder 2/empty.txt" ]
}

@test "filters with non-matched pattern" {
  control_test

  run lff hello
  assert_basics 0
}

@test "copies filtered items to the system clipboard" {
  control_test

  if [[ "$( uname )" =~ Linux ]]; then
    ## Bats won't allow this test to run on Linux for some reason
    ## Looks like Bats is not supporting pipe properly
    return
  fi

  run lff ".db" +
  assert_basics 1
  [ "${lines[0]}" = "database/civilizer.h2.db" ]

  run _pbpaste
  [ $status -eq 0 ]
  [ "${lines[0]}" = "database/civilizer.h2.db" ]
}

@test "adds prefix and postfix to each of search result" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  test() {
    pre=${pr} post=${po} run lff
    assert_basics $c
    for ((i=0;i<c;++i)); do
      local tmp=$( printf "${pr}%s${po}\n" "${_LIST_FILE_OUTPUT_CACHE[i]}" )
      [ "${lines[i]}" = "$tmp" ]
    done
  }

  pr=\` po=\` test
  pr=\` po=\` test
  pr=\( po=\) test
  pr=\{ po=\} test
  pr=\[ po=\] test
  pr=\< po=\> test
}

@test "quotes each of search result" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  check() {
    assert_basics $c
    for ((i=0;i<c;++i)); do
      local tmp=$( printf "${quote}%s${quote}\n" "${_LIST_FILE_OUTPUT_CACHE[i]}" )
      [ "${lines[i]}" = "$tmp" ]
    done
  }

  q= run lff; quote=\' check
  qq= run lff; quote=\" check

  check() {
    assert_basics 3
    local tmp=$( printf "${quote}%s${quote}\n" "files/empty.txt" )
    [ "${lines[0]}" = "$tmp" ]
    tmp=$( printf "${quote}%s${quote}\n" "files/folder 0/empty.txt" )
    [ "${lines[1]}" = "$tmp" ]
    tmp=$( printf "${quote}%s${quote}\n" "files/folder 0/folder 2/empty.txt" )
    [ "${lines[2]}" = "$tmp" ]
  }

  q= run lff empty; quote=\' check
  qq= run lff empty; quote=\" check
}

@test "seprates each item with nul byte" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  test() {
    lff | while read f; do echo $f; done
  }
  run test
  assert_basics $c

  test() {
    nul= lff | while read f; do echo $f; done
  }
  run test
  assert_basics 0

  test() {
    nul= lff | while read -d $'\0' f; do echo $f; done
  }
  run test
  assert_basics $c
  for ((i=0;i<c;++i)); do
    [ "${lines[i]}" = "${_LIST_FILE_OUTPUT_CACHE[i]}" ]
  done

  test() {
    nul= lff empty | while read -d $'\0' f; do echo $f; done
  }
  run test
  assert_basics 3
  [ "${lines[0]}" = "files/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/folder 2/empty.txt" ]
}

@test "overrides behavior control variables" {
  control_test

  _LIST_FILE_BCV_NAME_PRE=__pre
  _LIST_FILE_BCV_NAME_POST=__post
  _LIST_FILE_BCV_NAME_Q=__q
  _LIST_FILE_BCV_NAME_QQ=__qq
  _LIST_FILE_BCV_NAME_NUL=__nul

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  __pre=\` __post=\` run lff
  assert_basics $c
  for ((i=0;i<c;++i)); do
    local tmp=$( printf "\`%s\`\n" "${_LIST_FILE_OUTPUT_CACHE[i]}" )
    [ "${lines[i]}" = "$tmp" ]
  done

  check() {
    assert_basics $c
    for ((i=0;i<c;++i)); do
      local tmp=$( printf "${quote}%s${quote}\n" "${_LIST_FILE_OUTPUT_CACHE[i]}" )
      [ "${lines[i]}" = "$tmp" ]
    done
  }

  __q= run lff; quote=\' check
  __qq= run lff; quote=\" check

  test() {
    __nul= lff empty | while read -d $'\0' f; do echo $f; done
  }
  run test
  assert_basics 3
}

