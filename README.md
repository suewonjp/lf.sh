### :coffee: DESCRIPTION
***lf.sh*** is a Bash utility to help you quickly search arbitrary files or search text from files.

It's more convenient and intuitive to use than `ls` or `find` command.

### :coffee: HOW TO USE ( BY EXAMPLES )
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

List files with pattern `*empty*` under `files` folder (or its descendant folders):

        $ lf files/ empty --
    
        files/empty.txt
        files/folder 0/empty.txt
        files/folder 0/folder 2/empty.txt

List files with pattern `foo.*` under the current working directory:  
(See **General Formula** section below for more detail):  

        $ lf . file folder 0 foo. --
    
        files/folder 0/foo.txt

To print **absolute path** for the output result, use `+` notation:  
**( [ NOTE ] The search will be executed under the current working directory )**

        $ lf + folder 2 txt
    
        /Users/bsw/lf.sh/test/fixtures/test-fs/files/folder 0/folder 2/empty.txt

You can specify an absolute path for the base directory to begin search with like so:  
**( [ NOTE ] The major purpose of `lf` is to search files through the current working directory; Searching files through your entire file system (or your entire home directory) with `lf` is inefficient and not recommended; [locate](http://www.linfo.org/locate.html "") is recommended for that purpose. )**

        $ lf /usr/local man .git1

        /usr/local/git/share/man/man1/git-remote-testgit.1
        /usr/local/git/share/man/man1/git.1

By default, `lf` **excludes** dot folders (such as .git, .svn, etc) or dot files (.bashrc, .gitignore, etc) from its search.  
To search dot files or files inside dot folders, use `.+` notation:  
**( [ TIPS ] To print absolute path for that result, use +.+ notation )**

        $ lf .+ error .log
    
        .hidden/log/error.log

`lf` requires a file pattern to be specified as its last parameter, but sometimes you have no clue about patterns of target files or you may want to list all files involved with certain directory patterns;  
In these cases, you can use `--` to denote any arbitrary file;

        $ lf . data --
        
        database/civilizer.h2.db
        database/civilizer.TRACE.DB

**[ Since version 0.7 ]** Use `ignore` variable to specify folders to ignore like so:

        $ ignore=node_module lf .js

Use colon (:) to specify multiple folders to ignore.

        $ ignore=node_module:www lf .js

Quote them if they contain space characters.

        $ ignore='node_module:temp memo' lf .js

**[ Since Version 0.8 ]** Use `del` variable to delete files/folders found like so:

        $ del= lf .js

        lf.sh : Are you sure if you want to delete the following path? (y or n)
            foo.js
            bar.js
        y
        lf.sh : "foo.js" (file) deleted...
        lf.sh : "bar.js" (file) deleted...

> Type `y` to delete those files/folders or type `n` to abort.

**[ Since Version 0.8 ]** Use `q` or `qq` to quote each item in the search result like so:

            $ q= lf .js

            'foo.js'
            'bar.js'

            $ qq= lf .js

            "foo.js"
            "bar.js"

**[ Since Version 0.9 ]** Use `sym` to search files through **symlinks**  
( `lf` doesn't follow symlinks by default. )

            $ tree -a test

            test
            ├── baz.lst
            ├── database -> ../database
            └── log
                └── error.log

            ### 'database' is not a folder. It's a symlink

            $ lf test --      ### Don't follow symlinks by default.

            test/fixtures/test-fs/.hidden/baz.lst
            test/fixtures/test-fs/.hidden/log/error.log

            $ sym= lf test -- ### Follow symlinks.

            test/fixtures/test-fs/.hidden/baz.lst
            test/fixtures/test-fs/.hidden/database/civilizer.h2.db
            test/fixtures/test-fs/.hidden/log/error.log

Also, there are other variables like `ignore` for quickly controlling behaviors of `lf`. See [Quick Behavioral Control Variables](https://github.com/suewonjp/lf.sh/wiki/lf#heavy_check_mark-quick-behavioral-control-variables)

### :coffee: GENERAL FORMULA
`lf` command has two usage patterns;

1. lf [ target file pattern ]
    - e.g) lf .txt
1. lf [ base dir ] [ (optional) intermediate patterns ... ] [ target file pattern ]
    - [base dir] should be a complete path (relative or absolute), not a partial matching pattern
        - `.`(current path) or `..`(parent path) is also accepted
    - If [base dir] doesn't exist on the file system, the search will fail

Notice that [ target file pattern ] is required in any case.

To print help message, type `lf --help`

### :coffee: [ CAVEATS ]
Don't use a separate asterisk (`*`) to denote arbitrary filenames like the following:

        $ lf . file folder 0 *
This won't work and may produce unexpected output;  
Most shells including Bash will perform [pathname expansion](http://wiki.bash-hackers.org/syntax/expansion/globs "") when they see wildcards such as `*` and if `*` is used alone (which is most greedy), it will be expanded every path name under the current working directory.  
This behavior is based on POXIS specification and there is little `lf.sh` can do about it;  
Though, concatenating `*` with other patterns will be OK like so:

        $ lf . file folder 0 *oo*.txt
    
        files/folder 0/foo.txt
However, even in this case, a space is preferable to `*`:

        $ lf . file folder 0 oo .txt

        files/folder 0/foo.txt
If you don't have any clue about target filename pattern, use `--` instead of `*`:  
( `lf` uses `--` as a notation for every unspecific filename)

        $ lf . file folder 0 --
        
        files/folder 0/empty.txt
        files/folder 0/folder 2/empty.txt
        files/folder 0/foo.txt

Read [this](https://github.com/suewonjp/lf.sh/wiki/Quirks-Troubleshootings) for other quirks

### :coffee: MANUALS & DOCUMENTATIONS
[ lf command  : Quickly type and search files ](https://github.com/suewonjp/lf.sh/wiki/lf)

> Notice that `lf.sh` comes with other useful commands besides `lf` demonstrated above;

[ lfs command : Select a path from results returned by lf or lfi ](https://github.com/suewonjp/lf.sh/wiki/lfs)

[ lff command : Filter results returned by lf or lfi ](https://github.com/suewonjp/lf.sh/wiki/lff)

[ g command   : Quickly search text from files returned by lf or lfi ](https://github.com/suewonjp/lf.sh/wiki/g)

* * *

[Behavior Control Variables](https://github.com/suewonjp/lf.sh/wiki/lf#heavy_check_mark-quick-behavioral-control-variables)

[ Tips ](https://github.com/suewonjp/lf.sh/wiki/Tips)

[ How to Configure lf.sh ](https://github.com/suewonjp/lf.sh/wiki/How-To-Configure)

[ Quirks & Troubleshootings ](https://github.com/suewonjp/lf.sh/wiki/Quirks-Troubleshootings)

### :coffee: HOW TO INSTALL
Download [lf.sh script](https://github.com/suewonjp/lf.sh/blob/master/lf.sh "") and copy it to your favorite place.  
Then, insert the following code snippet inside your `.bashrc` or `.bash_profile`.  

        ### Assume you have copied it to ~/bin
        [ -f $HOME/bin/lf.sh ] && source $HOME/bin/lf.sh

Man pages are not ready yet...

### :coffee: CREDITS
- `lf.sh` has been inspired by [z script](https://github.com/rupa/z "")
- `lf.sh` uses [Bats: Bash Automated Testing System](https://github.com/sstephenson/bats "") for its unit testing

### :copyright: COPYRIGHT/LICENSE/DISCLAIMER

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

### :busts_in_silhouette: CONTRIBUTORS
Suewon Bahng  

Other contributors are welcome!

* * *
Updated by Suewon Bahng ( Nov 2017 )

