# Copyright (c) 2017 Suewon Bahng, suewonjp@gmail.com

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#    http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

unset _LIST_FILE_OUTPUT_CACHE

## Prepare clipboard utility functions
case "$( uname )" in
  Darwin*)
    _pbcopy() {
      pbcopy
    }
    _pbpaste() {
      pbpaste
    }
    ;;
  CYGWIN*)
    _pbcopy() {
      cat - >/dev/clipboard
    }
    _pbpaste() {
      cat /dev/clipboard
    }
    ;;
  *)
    ## If your system has xsel or xclip, we can define pbcopy/pbpaste
    ## In Linux, you can easily install either of these tools
    if type xsel > /dev/null 2>&1; then
      _pbcopy() {
        xsel --clipboard --input
      }
      _pbpaste() {
        xsel --clipboard --output
      }
    elif type xclip > /dev/null 2>&1; then
      _pbcopy() {
        xclip -selection clipboard
      }
      _pbpaste() {
        xclip -selection clipboard -o
      }
    else
      echo "${0##*/} [WARNNIG] pbcopy/pbpaste aliases can't be defined!" 2>&1
      echo "    - This means you can't use some extra features requiring system clipboard access via shell" 2>&1
      echo "    - Install tools such as xsel or xclip to enable the features" 2>&1
    fi
    ;;
esac

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

## Help Message
_help_lf() {
  cat <<'EOF'
lf  - Quickly type and search files
lfi - Same as `lf` except that case insensitive matching is performed

### General Usages
1) lf [ file pattern ]
  e.g) lf .txt
2) lf [ base dir ] [ (optional) intermediate patterns ... ] [ file pattern ]
  [base dir] should be a complete path name, not a partial matching pattern
  Thus, if [base dir] doesn't exist, the search will fail
  e.g) lf doc .pdf
  e.g) lf src web home*.js
  e.g) lf ~/bin .sh
  e.g) lf /usr/local share .txt

### Special Notations
1) -- Notation
  Denotes arbitrary files
  e.g) lf . src main -- 
2) + Notation
  Directs `lf` to list the output as absolute path 
  e.g) lf + doc .pdf
     - Will recursively search .pdf files through current working directory so that matching files should contain the pattern `*doc*.pdf`;
     - The output results will be absolute path
  e.g) lf +doc .pdf
     - Will recursively search .pdf files through *$PWD/doc* directory
     - The output results will be absolute path
3) .+ Notation
  Will also search dot folders right under the current working directory (such as .git, .svn, etc)
  By default, `lf` will exclude these dot folders from its search
4) +.+ Notation
  Same as `.+` except that the output results will be absolute path

For more information, see https://github.com/suewonjp/lf.sh/wiki/lf
EOF
}

## List Files
_lf() {
  local IFS=$'\n' basedir=. abspathcwd= pattern='*' behavior="${1}" includedots=
  shift

  case  "${1}" in
    -h|--h|-help|--help|-\?|--\?)
      _help_lf
      return
      ;;
  esac

  if [ "$#" -le 1 ]; then
    if [ "${1}" = '.+' ]; then
      ## '.+' denotes including dot files/directories
      includedots=true
    elif [ "${1}" = '+.+' ]; then
      ## '+.+' denotes the absolute path for the current working directory
      ## and including dot files/directories
      includedots=true
      abspathcwd=true
    elif [ "${1}" != '--' ]; then
      ## Only a file pattern is given
      pattern="*${1}"
    fi
  elif [ "$#" -ge 2 ]; then
    ## The base directory and intermediate directory/file patterns are given
    if [ "${1}" = '+' ]; then
      ## '+' denotes the absolute path for the current working directory
      abspathcwd=true
    elif [ "${1}" = '.+' ]; then
      ## '.+' denotes including dot files/directories
      includedots=true
    elif [ "${1}" = '+.+' ]; then
      ## '+.+' denotes the absolute path for the current working directory
      ## and including dot files/directories
      includedots=true
      abspathcwd=true
    elif [ "${1:0:1}" = '/' ]; then
      basedir=${1}
    elif [ "${1:0:1}" = '+' ]; then
      ## '+' prefix denotes the absolute path for the given base directory
      ## e.g. "+src" will expand to $PWD/src
      basedir="${1:1}"
      abspathcwd=true
    else
      ## Removing trailing '/'s if any
      basedir=$( echo ${1} | tr -s / )
      basedir="${basedir%/}"
    fi

    if [ "$#" -eq 2 ]; then
      ## Case of the base directory and a single file pattern
      pattern="*${2}"
      [ "${2}" = '--' ] && pattern='*'
    else
      ## Case of the base directory and multiple file patterns
      shift
      pattern="$( _join '*' $* )"
      [ "${pattern: -2}" = '--' ] && pattern="${pattern%--}"
    fi
  fi

  if [ "${includedots}" = "true" ]; then
    _LIST_FILE_OUTPUT_CACHE=( $( find "${basedir}" -type f -${behavior} "${pattern}" ) )
  else
    _LIST_FILE_OUTPUT_CACHE=( $( find "${basedir}" -type f -${behavior} "${pattern}" \! -path "${basedir}/.*" ) )
  fi

  local prefix=
  [ "${abspathcwd}" = "true" ] && prefix="$PWD/"
  for (( i=0; i<${#_LIST_FILE_OUTPUT_CACHE[*]}; ++i)); do
    ## Remove leading "./" from each path and make it absolute if instructed so
    _LIST_FILE_OUTPUT_CACHE[i]="${prefix}${_LIST_FILE_OUTPUT_CACHE[i]#./}"
  done

  printf "%s\n" ${_LIST_FILE_OUTPUT_CACHE[@]} 
}

_help_lfs() {
  cat <<'EOF'
lfs  - Select a path from results returned by lf or lfi

1) lfs  
  Will list all the paths returned by previous call of `lf` or `lfi` 
2) lfs [ index ]  
  Will select a path denoted by [index] from the paths found by previous call of `lf` or `lfi`
  [index] starts from 0 not 1; Thus `lfs 0` will select the first path from the list
  [index] can be a negative value
      e.g) `lfs -1` will select the last path from the list 
3) lfs [ index ] +  
  Same as `lfs [index]` except that the selected path will be copied to the system clipboard
  This is useful when you want to use that selected path for another application such as a text editor or file explorer, etc.

For more information, see https://github.com/suewonjp/lf.sh/wiki/lfs
EOF
}

## List Files Select
_lfs() {
  case  "${1}" in
    -h|--h|-help|--help|-\?|--\?)
      _help_lfs
      return
      ;;
  esac

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

_help_lff() {
  cat <<'EOF'
lff  - Filter results returned by lf or lfi

1) lff  
  Will list all the paths returned by previous call of `lf` or `lfi` 
2) lff [ pattern ]  
  Will select one or more paths matching [pattern] from the paths found by previous call of `lf` or `lfi`
  [pattern] is `basic regular expression` used by `grep` command by default.
3) lff [ pattern ] +  
  Same as `lff [pattern]` except that the filtered paths will be copied to the system clipboard
  This is useful when you want to use that selected path for another application such as a text editor or file explorer, etc.

For more information, see https://github.com/suewonjp/lf.sh/wiki/lff
EOF
}

_lff() {
  case  "${1}" in
    -h|--h|-help|--help|-\?|--\?)
      _help_lff
      return
      ;;
  esac

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

_help_g() {
  cat <<'EOF'
g  - Quickly search text from file
gi - Same as `g` except that case insensitive matching is performed for filenames (not for text patterns)

1) g [ text pattern ] [ params for lf ... ]
  All parameters except the 1st parameter obey the rule of lf command (lf -h for details)
  The 1st parameter [text pattern] is `Basic Regular Expression` (which is used by the regular `grep` command by default) pattern.

For more information, see https://github.com/suewonjp/lf.sh/wiki/g
EOF
}

_g() {
  local behavior=${1} patt=${2}
  local grepTool=${_LIST_FILE_GREP_TOOL:-grep} grepOptions=()

  case "${grepTool}" in
    grep|egrep|fgrep) grepOptions=( ${_LIST_FILE_GREP_OPTIONS--n} ) ;;
    ack|ag) grepOptions=( ${_LIST_FILE_GREP_OPTIONS--H} ) ;;
    *) echo "${0##*/} [WARNNIG] ${_LIST_FILE_GREP_TOOL} is unknown tool! Using grep instead..." 2>&1
       grepTool=grep
       grepOptions=( ${_LIST_FILE_GREP_OPTIONS--n} ) ;;
  esac

  if [ -z "${patt}" ]; then
    _help_g
    return
  fi
  shift 2
  _lf ${behavior} $@ > /dev/null 2>&1
  local c=${#_LIST_FILE_OUTPUT_CACHE[*]} GREP_OPTIONS= LFS=$'\n'
  [ "${c}" -ne 0 ] && "${grepTool}" ${grepOptions[*]} -- "${patt}" "${_LIST_FILE_OUTPUT_CACHE[@]}"
}

alias ${_LIST_FILE_CMD:-lf}='_lf path'
alias ${_LIST_FILE_IGNORECASE_CMD:-lfi}='_lf ipath'
alias ${_LIST_FILE_SELECT_CMD:-lfs}='_lfs'
alias ${_LIST_FILE_FILTER_CMD:-lff}='_lff'
alias ${_LIST_FILE_GREP_CMD:-g}='_g path'
alias ${_LIST_FILE_GREP_IGNORECASE_CMD:-gi}='_g ipath'

