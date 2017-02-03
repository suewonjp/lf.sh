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

_pbcopy() {
  [ -n "${BASH_ALIASES[pbcopy]}" ] && $( echo ${BASH_ALIASES[pbcopy]} ) || pbcopy
}

_pbpaste() {
  [ -n "${BASH_ALIASES[pbpaste]}" ] && $( echo ${BASH_ALIASES[pbpaste]} ) || pbpaste
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
  local IFS=$'\n' basedir=. abspath= pattern='*' behavior="${1}" includedots=
  shift

  if [ "$#" -le 1 ]; then
    if [ "${1}" == '.+' ]; then
      ## '.+' denotes including dot files/directories
      includedots=true
    elif [ "${1}" == '+.+' ]; then
      ## '+.+' denotes the absolute path for the current working directory
      ## and including dot files/directories
      includedots=true
      abspath=true
    elif [ "${1}" != '--' ]; then
      ## Only a file pattern is given
      pattern="*${1}"
    fi
  elif [ "$#" -ge 2 ]; then
    ## The base directory and intermediate directory/file patterns are given
    if [ "${1}" == '+' ]; then
      ## '+' denotes the absolute path for the current working directory
      abspath=true
    elif [ "${1}" == '.+' ]; then
      ## '.+' denotes including dot files/directories
      includedots=true
    elif [ "${1}" == '+.+' ]; then
      ## '+.+' denotes the absolute path for the current working directory
      ## and including dot files/directories
      includedots=true
      abspath=true
    elif [ "${1:0:1}" == '+' ]; then
      ## '+' prefix denotes the absolute path for the given base directory
      ## e.g. "+src" will expand to $PWD/src
      basedir="${1:1}"
      abspath=true
    else
      ## Removing trailing '/'s if any
      basedir=$( echo ${1} | tr -s / )
      basedir="${basedir%/}"
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

  if [ "${includedots}" == "true" ]; then
    _LIST_FILE_OUTPUT_CACHE=( $( find "${basedir}" -type f -${behavior} "${pattern}" ) )
  else
    _LIST_FILE_OUTPUT_CACHE=( $( find "${basedir}" -type f -${behavior} "${pattern}" \! \( -path './.*' \) ) )
  fi

  local prefix=
  [ "${abspath}" = "true" ] && prefix="$PWD/"
  for (( i=0; i<${#_LIST_FILE_OUTPUT_CACHE[*]}; ++i)); do
    ## Remove leading "./" from each path and make it absolute if instructed so
    _LIST_FILE_OUTPUT_CACHE[i]="${prefix}${_LIST_FILE_OUTPUT_CACHE[i]#./}"
  done

  printf "%s\n" ${_LIST_FILE_OUTPUT_CACHE[@]} 
}

## List Files Select
_lfs() {
  if [ $# -eq 0 ]; then
    local IFS=$'\n'
    printf "%s\n" ${_LIST_FILE_OUTPUT_CACHE[@]}
    return
  fi

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
      if [ 1 -le "${index}" ] && [ "${index}" -le "${c}" ]; then
        index=$(( c - index ))
      else
        index=${c}
      fi
      ;;
  esac
  if [ "${index}" -eq "${c}" ]; then
    return 1
  elif [ "${2}" = "+" ]; then
    echo ${_LIST_FILE_OUTPUT_CACHE[index]}
    echo -n ${_LIST_FILE_OUTPUT_CACHE[index]} | _pbcopy
  else
    echo ${_LIST_FILE_OUTPUT_CACHE[index]}
  fi
}

_lff() {
  if [ $# -eq 0 ]; then
    _lfs
    return
  fi
  local IFS=$'\n' patt=${1} output=

  output=( $( _lfs | grep --color=never "${patt}" ) )

  if [ "${2}" = "+" ]; then
    if [ ${#output[*]} -eq 1 ]; then
      echo ${output[0]}
      echo -n ${output[0]} | _pbcopy
    else
      printf "%s\n" ${output[@]}
      printf "%s\n" ${output[@]} | _pbcopy
    fi
  else
    printf "%s\n" ${output[@]}
  fi
}

_g() {
  local IFS=$'\n' behavior=${1} patt=${2}
  if [ -z "${patt}" ]; then
    echo "${_LIST_FILE_GREP_CMD:-g} : please, provide pattern to search"
    return
  fi
  shift 2
  _lf ${behavior} $@ > /dev/null 2>&1
  local c=${#_LIST_FILE_OUTPUT_CACHE[*]}
  for (( i=0;i<c;++i )); do
    local match=$( grep ${GREP_OPTIONS--n} -- "${patt}" "${_LIST_FILE_OUTPUT_CACHE[i]}" )
    [ -n "${match}" ] && printf "%s:%s\n" "${_LIST_FILE_OUTPUT_CACHE[i]}" "${match}"
  done
}

alias ${_LIST_FILE_CMD:-lf}='_lf path'
alias ${_LIST_FILE_IGNORECASE_CMD:-lfi}='_lf ipath'
alias ${_LIST_FILE_SELECT_CMD:-lfs}='_lfs'
alias ${_LIST_FILE_FILTER_CMD:-lff}='_lff'
alias ${_LIST_FILE_GREP_CMD:-g}='_g path'
alias ${_LIST_FILE_GREP_IGNORECASE_CMD:-gi}='_g ipath'

