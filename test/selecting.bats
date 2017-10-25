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
  assert_basics $c
  #[ $status -eq 0 ]
  #[ ${#lines[*]} -eq $c ]
}

@test "selecting works for valid positive index range" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  for ((i=0;i<c;++i)); do
    run lfs $i
    assert_basics 1
    [ "$output" = "${_LIST_FILE_OUTPUT_CACHE[i]}" ]
  done
}

@test "selecting works for valid negative index range" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  for ((i=-c;i<0;++i)); do
    run lfs $i
    assert_basics 1
    local realIndex=$(( c + i ))
    [ "$output" = "${_LIST_FILE_OUTPUT_CACHE[realIndex]}" ]
  done
}

@test "selecting with invalid index returns nothing" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  run lfs $c; expect_failure
  run lfs $(( c + $RANDOM )); expect_failure
  run lfs -0; expect_failure
  run lfs $(( -c -1 - $RANDOM )); expect_failure
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

@test "adds prefix and postfix to each of search result" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  test() {
    pre=${pr} post=${po} run lfs
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

  q= run lfs; quote=\' check
  qq= run lfs; quote=\" check

  check() {
    assert_basics 1
    local tmp=$( printf "${quote}%s${quote}\n" "${_LIST_FILE_OUTPUT_CACHE[i]}" )
    [ "$output" = "$tmp" ]
  }

  for ((i=0;i<c;++i)); do
    q= run lfs $i; quote=\' check
  done

  for ((i=0;i<c;++i)); do
    qq= run lfs $i; quote=\" check
  done
}

@test "seprates each item with nul byte" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  test() {
    lfs | while read f; do echo $f; done
  }
  run test
  assert_basics $c

  test() {
    nul= lfs | while read f; do echo $f; done
  }
  run test
  assert_basics 0

  test() {
    nul= lfs | while read -d $'\0' f; do echo $f; done
  }
  run test
  assert_basics $c
  for ((i=0;i<c;++i)); do
    [ "${lines[i]}" = "${_LIST_FILE_OUTPUT_CACHE[i]}" ]
  done

  test() {
    nul= lfs 0 | while read -d $'\0' f; do echo $f; done
  }
  run test
  assert_basics 1
}

