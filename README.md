### DESCRIPTION
***lf.sh*** is a Bash utility to help you quickly search arbitrary files or search text from files.

It's more convenient and intuitive to use than _ls_ or _find_ command.

### HOW TO USE ( BY EXAMPLES )
Assume we have file structure as follows:

    .
    ├── .config
    ├── .hidden
    │   ├── baz.lst
    │   └── log
    │       └── error.log
    ├── app-options.properties
    ├── database
    │   ├── civilizer.TRACE.DB
    │   └── civilizer.h2.db
    └── files
        ├── empty.txt
        ├── folder 0
        │   ├── empty.txt
        │   ├── folder 2
        │   │   └── empty.txt
        │   └── foo.txt
        └── folder 1
            └── bar.txt

    7 directories, 11 files

List every file **with an extension .txt**, recursively:

        $ lf .txt
    
        files/empty.txt
        files/folder 0/empty.txt
        files/folder 0/folder 2/empty.txt
        files/folder 0/foo.txt
        files/folder 1/bar.txt

List files with pattern _empty*_ under _files_ folder (or its descendant folders):

        $ lf files/ empty*
    
        files/empty.txt
        files/folder 0/empty.txt
        files/folder 0/folder 2/empty.txt

Find a file with more patterns:  
**( [ NOTE ] As you see, _lf.sh_ uses a more casual style of space separated patterns which is more convenient and easy to type )**

        $ lf . file folder 0 foo.*
    
        files/folder 0/foo.txt

To print **absolute path** for the output result, use **+** notation:  
**( [ NOTE ] The search will be executed under the current working directory )**

        $ lf + folder 2 txt
    
        /Users/bsw/lf.sh/test/fixtures/test-fs/files/folder 0/folder 2/empty.txt

You can specify an arbitrary absolute path as base directory to begin search with like so:  
**( [ NOTE ] The major purpose of _lf_ is to search files through the current working directory; Searching files through your entire file system (or your entire home directory) with _lf_ is inefficient and not recommended; [locate](http://www.linfo.org/locate.html "") is recommended for that purpose. )**

        $ lf /usr/local man .git1

        /usr/local/git/share/man/man1/git-remote-testgit.1
        /usr/local/git/share/man/man1/git.1

_lf.sh_ excludes dot folders (such as .git, .svn, etc) from its search by default.  
To search dot folders right under the current working directory, use **.+** notation:  
*( [ Tips ] To print absolute path for that, use +.+ notation )*

        $ lf .+ error .log
    
        .hidden/log/error.log

`lf` requires a file pattern to be specified as its last parameter, but sometimes you have no clue about patterns of target files or you may want to list all files involved with certain directory patterns;  
In these cases, you can use `--` to denote any arbitrary file;


        $ lf . data --
        
        database/civilizer.h2.db
        database/civilizer.TRACE.DB

lf command has two usage patterns;

1. lf [ file pattern ]
    - e.g) lf .txt
1. lf [ base dir ] [ (optional) intermediate patterns ... ] [ file pattern ]
    - [base dir] should be a complete path name, not a partial matching pattern
    - Thus, if [base dir] doesn't exist, the search will fail

To print help message, type `lf --help`

###### [ CAVEAT ] Don't use asterisk (\*) alone as a whole word like the following:

        $ lf . file folder 0 *
This won't work and may produce unexpected output;  
Most shells including Bash will perform [pathname expansion](http://wiki.bash-hackers.org/syntax/expansion/globs "") when they see wildcards such as \* and if \* is used alone (which is most greedy), it will be expanded every path name under the current working directory.  
This behavior is based on POXIS specification and there is little _lf.sh_ can do about it;  
Though, **concatenating \* with other patterns will be OK** like so:

        $ lf . file folder 0 *oo*.txt
    
        files/folder 0/foo.txt
However, even in this case, a space is preferable to \* like so:

        $ lf . file folder 0 oo .txt
If you don't have any clue about patterns for target files, use **--**:

        $ lf . file folder 0 --
        
        files/folder 0/empty.txt
        files/folder 0/folder 2/empty.txt
        files/folder 0/foo.txt

Read [this](https://github.com/suewonjp/lf.sh/wiki/lf#quirks) for other quirks

### DETAILED MANUALS FOR ALL COMMANDS
[ lf command  : Quickly type and search files ](https://github.com/suewonjp/lf.sh/wiki/lf)

_lf.sh_ will come with other useful commands besides _lf_ demonstrated above;

[ lfs command : Select a path from results returned by lf or lfi ](https://github.com/suewonjp/lf.sh/wiki/lfs)

[ lff command : Filter results returned by lf or lfi ](https://github.com/suewonjp/lf.sh/wiki/lff)

[ g command   : Quickly search text from files ](https://github.com/suewonjp/lf.sh/wiki/g)

### HOW TO INSTALL
Download [lf.sh script](https://github.com/suewonjp/lf.sh/blob/master/lf.sh "") and copy it to your favorite place.  
Then, insert the following code snippet inside your _.bashrc_ or _.bash_profile_.  

        ### Assume you have copied it to ~/bin
        [ -f $HOME/bin/lf.sh ] && source $HOME/bin/lf.sh

Man pages are not ready yet...

### CREDITS
- _lf.sh_ has been inspired by [z script](https://github.com/rupa/z "")
- _lf.sh_ uses [Bats: Bash Automated Testing System](https://github.com/sstephenson/bats "") for its unit testing

### COPYRIGHT/LICENSE/DISCLAIMER

    Copyright (c) 2017 Suewon Bahng, suewonjp@gmail.com
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
        http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

* * *
Written by Suewon Bahng   ( Last Updated January, 2017 )

### CONTRIBUTORS
Suewon Bahng  

Other contributors are welcome!
