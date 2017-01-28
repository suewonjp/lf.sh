unset _LIST_FILE_OUTPUT_CACHE

## Prepare pbcopy/pbpaste command pair
## These are native commands in OS X and we define them as aliases in other systems
type pbcopy > /dev/null 2>&1 && pbpaste > /dev/null 2>&1 || {
case "$( uname )" in
  CYGWIN*)
    alias pbcopy='cat - > /dev/clipboard'
    alias pbpaste='cat /dev/clipboard'
    ;;
  *)
    ## If your system has xsel or xclip, we can define pbcopy/pbpaste
    ## In Linux, you can easily install either of these tools
    if type xsel > /dev/null 2>&1; then
      alias pbcopy='xsel --clipboard --input'
      alias pbpaste='xsel --clipboard --output'
    elif type xclip > /dev/null 2>&1; then
      alias pbcopy='xclip -selection clipboard'
      alias pbpaste='xclip -selection clipboard -o'
    else
      echo "${0##*/} [WARNNIG] pbcopy/pbpaste aliases can't be defined!" 2>&1
      echo "    - This means you can't use some extra features requiring system clipboard access via shell" 2>&1
      echo "    - Install tools such as xsel or xclip to enable the features" 2>&1
    fi
    ;;
esac
}

## Join the words with the given delimiter
## e.g. _join '*' hello world ==> *hello*world 
_join() {
  local IFS="$1"
  shift
  echo "${IFS}$*"
  #local sep="$1" result=
  #shift
  #for i in "$@"; do
    #result+="${sep}${i}"
  #done
  #echo ${result}
}

## List Files
_lf() {
  local IFS=$'\n' basedir= pattern= behavior="${1}"
  shift

  if [ "$#" -eq 1 ]; then
    ## Only a file pattern is given
    ## The base directory is assumed "."
    basedir=.
    pattern="*${1}"
    [ "${1}" == '--' ] && pattern='*'
  elif [ "$#" -ge 2 ]; then
    ## The base directory and file patterns are given
    basedir="${1}"
    if [ "${1}" == "+" ]; then
      ## "+" denotes the absolute path for the current working directory
      basedir="$PWD"
    elif [ "${1:0:1}" == "+" ]; then
      ## "+" prefix denotes the absolute path for the given base directory
      ## e.g. "+src" will expand to $PWD/src
      basedir="$PWD/${1:1}"
    fi

    if [ "$#" -eq 2 ]; then
      ## Case of the base directory and a single file pattern
      pattern="*${2}"
      [ "${2}" == '--' ] && pattern='*'
    else
      ## Case of the base directory and multiple file patterns
      shift
      pattern="$( _join '*' $* )"
      [ "${pattern: -2}" == '--' ] && pattern="${pattern%--}"
    fi
  fi

  [ "${_LIST_FILE_DEBUG}" = "yes" ] && echo "find ${basedir} -type f -${behavior} ${pattern}"

  _LIST_FILE_OUTPUT_CACHE=( $( find "${basedir}" -type f -${behavior} "${pattern}" ) )

  ## Remove leading "./" or ".//" from each path
  for (( i=0; i<${#_LIST_FILE_OUTPUT_CACHE[*]}; ++i)); do
    _LIST_FILE_OUTPUT_CACHE[i]=${_LIST_FILE_OUTPUT_CACHE[i]#.//}
    _LIST_FILE_OUTPUT_CACHE[i]=${_LIST_FILE_OUTPUT_CACHE[i]#./}
  done

  printf "%s\n" ${_LIST_FILE_OUTPUT_CACHE[@]} 
}

## List Files Select
_lfs() {
  local c=${#_LIST_FILE_OUTPUT_CACHE[@]}
  local index=${c}
  case "${1}" in
    [0-9]*) ## We need to confirm the variable is an integer number
      if [ 0 -le "${1}" ] && [ "${1}" -lt "${c}" ]; then
        index=${1}
      fi
      ;;
    -[0-9]*)
      index=${1:1} ## Strip off the negative sign
      if [ 0 -lt "${index}" ] && [ "${index}" -lt "${c}" ]; then
        index=$(( c - index ))
      fi
      ;;
  esac
  if [ "${2}" = "+" ]; then
    printf "%s" ${_LIST_FILE_OUTPUT_CACHE[index]} | pbcopy
  else
    echo ${_LIST_FILE_OUTPUT_CACHE[index]}
  fi
}

alias ${_LIST_FILE_CMD:-lf}='_lf path '
alias ${_LIST_FILE_IGNORE_CASE_CMD:-lfi}='_lf ipath '
alias ${_LIST_FILE_SELECT_CMD:-lfs}='_lfs'

