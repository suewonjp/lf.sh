create_test_file_structure() {
  TEST_FS="test-fs"
  rm -rf "${FIXTURE_ROOT}"
  mkdir -p "${FIXTURE_ROOT}/${TEST_FS}"

  pushd "${FIXTURE_ROOT}/${TEST_FS}" > /dev/null 2>&1

  mkdir -p "files/folder 0/folder 2" "files/folder 1" "database" ".hidden/log"
  touch "app-options.properties" \
      "files/empty.txt" \
      "files/folder 0/empty.txt" \
      "files/folder 0/foo.txt" \
      "files/folder 0/folder 2/empty.txt" \
      "files/folder 1/bar.txt"  \
      "database/civilizer.h2.db"  \
      "database/civilizer.TRACE.DB" \
      ".hidden/baz.lst" \
      ".hidden/log/error.log" \
      ".config"
  echo "civilizer.dev=true
civilizer.url=https://github.com/suewonjp/civilizer
civilizer.message1=hello world!
civilizer.message2=HELLO WORLD!" > "app-options.properties"
  echo "foo" > "files/folder 0/foo.txt"
  echo "bar" > "files/folder 1/bar.txt"
  echo "baz" > ".hidden/baz.lst"
  echo "civilizer" > "database/civilizer.h2.db"
  echo "civilizer" > "database/civilizer.TRACE.DB"
  echo "Something wrong..." > ".hidden/log/error.log"

  pushd ".hidden" > /dev/null 2>&1
  ln -s "../database" database
  popd > /dev/null 2>&1

  popd > /dev/null 2>&1
}

create_fake_file_list() {
  _LIST_FILE_OUTPUT_CACHE=( ".config" \
    ".hidden/baz.lst" \
    ".hidden/log/error.log" \
    "app-options.properties" \
    "database/civilizer.h2.db" \
    "database/civilizer.TRACE.DB" \
    "files/empty.txt" \
    "files/folder 0/empty.txt" \
    "files/folder 0/folder 2/empty.txt" \
    "files/folder 0/foo.txt" \
    "files/folder 1/bar.txt" )
}

sort_array() {
  if [ -n "$1" ]; then
    local IFS=$'\n'
    eval "local arr=( \${$1[*]} )"
    arr=( $( sort -d <<<"${arr[*]}" ) )
    eval "$1=( \${arr[*]} )"
  fi
}

lf() {
  $( echo ${BASH_ALIASES[lf]} $@ )
}

lfi() {
  $( echo ${BASH_ALIASES[lfi]} $@ )
}

lfs() {
  $( echo ${BASH_ALIASES[lfs]} $@ )
}

lff() {
  $( echo ${BASH_ALIASES[lff]} $@ )
}

g() {
  $( echo ${BASH_ALIASES[g]} $@ )
}

gi() {
  $( echo ${BASH_ALIASES[gi]} $@ )
}

fixtures() {
  FIXTURE_NAME="fixtures"
  FIXTURE_ROOT="${BATS_TEST_DIRNAME}/${FIXTURE_NAME}"
  RELATIVE_FIXTURE_ROOT="$( bats_trim_filename "${FIXTURE_ROOT}" )"
  cd "${BATS_TEST_DIRNAME}"
  shopt -s expand_aliases
  source "../lf.sh"
}

setup() {
  [ -d "${FIXTURE_ROOT}/${TEST_FS}" ] && cd "${FIXTURE_ROOT}/${TEST_FS}"
  :
}

teardown() {
  :
}

show_output() {
  echo "actual output => $output"
}

show_lines() {
  echo "actual lines =>"
  printf "%s\n" "${lines[@]}"
}

_LIST_FILE_TEST_SKIP_ALL=n

control_test() {
  [[ "${_LIST_FILE_TEST_SKIP_ALL}" = "y" || "${1}" = "skip" ]] && skip
  :
}

assert_basics() {
  [ $status -eq 0 ]
  [ ${#lines[*]} -eq $1 ]
}

expect_failure() {
  [ $status -eq 1 ]
  [ ${#lines[*]} -eq 0 ]
}

