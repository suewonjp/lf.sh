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
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]
}

@test "filters with matched pattern" {
  control_test

  run lff empty
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ "${lines[0]}" = "files/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/folder 2/empty.txt" ]
}

@test "filters with non-matched pattern" {
  control_test

  run lff hello
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 0 ]
}

@test "copies filtered items to the system clipboard" {
  control_test

  if [[ "$( uname )" =~ Linux ]]; then
    ## Bats won't allow this test to run on Linux for some reason
    ## Looks like Bats is not supporting pipe properly
    return
  fi

  run lff ".db" +
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 1 ]
  [ "${lines[0]}" = "database/civilizer.h2.db" ]

  run _pbpaste
  [ $status -eq 0 ]
  [ "${lines[0]}" = "database/civilizer.h2.db" ]
}

@test "adds prefix and postfix to each of search result" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]} pr= po= tmp=

  pr=\` po=\`
  pre=${pr} post=${po} run lff
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]
  for ((i=0;i<c;++i)); do
    tmp=$( printf "${pr}%s${po}\n" "${_LIST_FILE_OUTPUT_CACHE[i]}" )
    [ "${lines[i]}" = "$tmp" ]
  done

  pr=\` po=\`
  pre=${pr} post=${po} run lff
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]
  for ((i=0;i<c;++i)); do
    tmp=$( printf "${pr}%s${po}\n" "${_LIST_FILE_OUTPUT_CACHE[i]}" )
    [ "${lines[i]}" = "$tmp" ]
  done

  pr=\( po=\)
  pre=${pr} post=${po} run lff
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]
  for ((i=0;i<c;++i)); do
    tmp=$( printf "${pr}%s${po}\n" "${_LIST_FILE_OUTPUT_CACHE[i]}" )
    [ "${lines[i]}" = "$tmp" ]
  done

  pr=\{ po=\}
  pre=${pr} post=${po} run lff
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]
  for ((i=0;i<c;++i)); do
    tmp=$( printf "${pr}%s${po}\n" "${_LIST_FILE_OUTPUT_CACHE[i]}" )
    [ "${lines[i]}" = "$tmp" ]
  done

  pr=\[ po=\]
  pre=${pr} post=${po} run lff
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]
  for ((i=0;i<c;++i)); do
    tmp=$( printf "${pr}%s${po}\n" "${_LIST_FILE_OUTPUT_CACHE[i]}" )
    [ "${lines[i]}" = "$tmp" ]
  done

  pr=\< po=\>
  pre=${pr} post=${po} run lff
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]
  for ((i=0;i<c;++i)); do
    tmp=$( printf "${pr}%s${po}\n" "${_LIST_FILE_OUTPUT_CACHE[i]}" )
    [ "${lines[i]}" = "$tmp" ]
  done
}

@test "quotes each of search result" {
  control_test

  local tmp= c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  ## Single quotes
  q= run lff
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]
  for ((i=0;i<c;++i)); do
    tmp=$( printf "'%s'\n" "${_LIST_FILE_OUTPUT_CACHE[i]}" )
    [ "${lines[i]}" = "$tmp" ]
  done

  q= run lff empty
  [ $status -eq 0 ]
  echo "${lines[*]}"
  [ ${#lines[*]} -eq 3 ]
  tmp=$( printf "'%s'\n" "files/empty.txt" )
  [ "${lines[0]}" = "$tmp" ]
  tmp=$( printf "'%s'\n" "files/folder 0/folder 2/empty.txt" )
  [ "${lines[2]}" = "$tmp" ]

  ## Double quotes
  qq= run lff
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]
  for ((i=0;i<c;++i)); do
    tmp=$( printf "\"%s\"\n" "${_LIST_FILE_OUTPUT_CACHE[i]}" )
    [ "${lines[i]}" = "$tmp" ]
  done

  qq= run lff empty
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  tmp=$( printf "\"%s\"\n" "files/empty.txt" )
  [ "${lines[0]}" = "$tmp" ]
  tmp=$( printf "\"%s\"\n" "files/folder 0/empty.txt" )
  [ "${lines[1]}" = "$tmp" ]
}

@test "seprates each item with nul byte" {
  control_test

  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}

  test() {
    lff | while read f; do echo $f; done
  }
  run test
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]

  test() {
    nul= lff | while read f; do echo $f; done
  }
  run test
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 0 ]

  test() {
    nul= lff | while read -d $'\0' f; do echo $f; done
  }
  run test
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $c ]
  for ((i=0;i<c;++i)); do
    [ "${lines[i]}" = "${_LIST_FILE_OUTPUT_CACHE[i]}" ]
  done

  test() {
    nul= lff empty | while read -d $'\0' f; do echo $f; done
  }
  run test
  [ $status -eq 0 ]
  echo ${#lines[*]}
  echo "~~~~~"
  echo "${lines[*]}"
  [ ${#lines[*]} -eq 3 ]
  [ "${lines[0]}" = "files/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/folder 2/empty.txt" ]
}

