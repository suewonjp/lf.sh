#!/usr/bin/env bats

load test_helper
fixtures
create_test_file_structure

@test "confirms aliases have been defined" {
  run alias lf
  [ $status -eq 0 ]

  run alias lfi
  [ $status -eq 0 ]
}

@test "confirms the file structure for testing has been created" {
  [ -d "${FIXTURE_ROOT}/${TEST_FS}" ]
}

@test "_join works as expected" {
  run _join '*' hello world
  [ $status -eq 0 ]
  [ "$output" = '*hello*world' ]

  #run _join '.*' hello world
  #[ $status -eq 0 ]
  #[ "$output" = '.*hello.*world' ]
}

@test "prints help messages" {
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
  run lf
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 8 ]
  [ "${lines[0]}" = "app-options.properties" ]
  [ "${lines[7]}" = "files/folder 1/bar.txt" ]

  run lf --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 8 ]
  [ "${lines[0]}" = "app-options.properties" ]
  [ "${lines[7]}" = "files/folder 1/bar.txt" ]

  run lf . --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 8 ]
  [ "${lines[0]}" = "app-options.properties" ]
  [ "${lines[7]}" = "files/folder 1/bar.txt" ]

  run lf ./ --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 8 ]
  [ "${lines[0]}" = "app-options.properties" ]
  [ "${lines[7]}" = "files/folder 1/bar.txt" ]

  run lf + --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 8 ]
  [ "${lines[0]}" = "$PWD/app-options.properties" ]
  [ "${lines[7]}" = "$PWD/files/folder 1/bar.txt" ]
}

@test "removes trailing duplicate slashes if given" {
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
  run lf .+
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 11 ]
  [ "${lines[0]}" = ".config" ]
  [ "${lines[10]}" = "files/folder 1/bar.txt" ]

  run lf .+ --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 11 ]
  [ "${lines[0]}" = ".config" ]
  [ "${lines[10]}" = "files/folder 1/bar.txt" ]

  run lf +.+ --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 11 ]
  [ "${lines[0]}" = "$PWD/.config" ]
  [ "${lines[10]}" = "$PWD/files/folder 1/bar.txt" ]
}

@test "lists files with a file extention" {
  run lf .txt
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 5 ]
  [ "${lines[0]}" = "files/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/folder 2/empty.txt" ]
  [ "${lines[3]}" = "files/folder 0/foo.txt" ]
  [ "${lines[4]}" = "files/folder 1/bar.txt" ]
}

@test "lists files with file pattern " {
  run lf empty*
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ "${lines[0]}" = "files/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/folder 2/empty.txt" ]

  run lf + empty*
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ "${lines[0]}" = "$PWD/files/empty.txt" ]
  [ "${lines[1]}" = "$PWD/files/folder 0/empty.txt" ]
  [ "${lines[2]}" = "$PWD/files/folder 0/folder 2/empty.txt" ]
}

@test "lists files with an intermediate folder and file extention" {
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
  run lfi database .db
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 2 ]
  [ "${lines[0]}" = "database/civilizer.h2.db" ]
  [ "${lines[1]}" = "database/civilizer.TRACE.DB" ]

  run lfi + database .db
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 2 ]
  [ "${lines[0]}" = "$PWD/database/civilizer.h2.db" ]
  [ "${lines[1]}" = "$PWD/database/civilizer.TRACE.DB" ]

  run lfi +database .db
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 2 ]
  [ "${lines[0]}" = "$PWD/database/civilizer.h2.db" ]
  [ "${lines[1]}" = "$PWD/database/civilizer.TRACE.DB" ]
}

@test "lists files with intermediate folders" {
  run lf files folder --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 4 ]
  [ "${lines[0]}" = "files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/foo.txt" ]
  [ "${lines[3]}" = "files/folder 1/bar.txt" ]

  run lf + files folder --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 4 ]
  [ "${lines[0]}" = "$PWD/files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "$PWD/files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "$PWD/files/folder 0/foo.txt" ]
  [ "${lines[3]}" = "$PWD/files/folder 1/bar.txt" ]
}

@test "lists files with intermediate folders and file extention" {
  run lf files folder 0 .txt
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ "${lines[0]}" = "files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "files/folder 0/foo.txt" ]

  run lf + files folder 0 .txt
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ "${lines[0]}" = "$PWD/files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "$PWD/files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "$PWD/files/folder 0/foo.txt" ]
}

@test "lists only dot files" {
  run lf .+ /. --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ ${lines[0]} = ".config" ]
  [ ${lines[1]} = ".hidden/baz.lst" ]
  [ ${lines[2]} = ".hidden/log/error.log" ]

  run lf +.+ /. --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ ${lines[0]} = "$PWD/.config" ]
  [ ${lines[1]} = "$PWD/.hidden/baz.lst" ]
  [ ${lines[2]} = "$PWD/.hidden/log/error.log" ]
}

@test "lists files under a dot directory" {
  run lf .+ .hidd --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 2 ]
  [ ${lines[0]} = ".hidden/baz.lst" ]
  [ ${lines[1]} = ".hidden/log/error.log" ]

  run lf +.+ .hidd --
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 2 ]
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
  run lf "${PWD}" folder 0 .txt
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq 3 ]
  [ "${lines[0]}" = "$PWD/files/folder 0/empty.txt" ]
  [ "${lines[1]}" = "$PWD/files/folder 0/folder 2/empty.txt" ]
  [ "${lines[2]}" = "$PWD/files/folder 0/foo.txt" ]
}

