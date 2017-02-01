create_test_file_structure() {
  TEST_FS="test-fs"
  rm -rf "${FIXTURE_ROOT}"
  mkdir -p "${FIXTURE_ROOT}/${TEST_FS}"

  cd "${FIXTURE_ROOT}/${TEST_FS}"

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

  cd "${OLDPWD}"
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

lf() {
  $( echo ${BASH_ALIASES[lf]} $@ )
}

lfi() {
  $( echo ${BASH_ALIASES[lfi]} $@ )
}

lfs() {
  $( echo ${BASH_ALIASES[lfs]} $@ )
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

