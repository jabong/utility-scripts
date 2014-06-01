#!/bin/bash

if [ -d "${HOME}/lib/bash" ]; then
    bashLibDir="${HOME}/lib/bash"
elif [ -d ~/lib/bash ]; then
    bashLibDir=~/lib/bash
fi

pythonLibDir=${HOME}/lib/python
bjBashSessionStartDate=$(date +%Y-%m-%d)
bjClipboardLogFile="${bjHomeDir}/tmp/clipboard/${bjBashSessionStartDate}.log"

################################################################################
## Variable Declarations ##
################################################################################

strSeparator="####################################################################"
bjdh="${HOME}"
www="public_html"

bjdir=${bjHomeDir}
bjEditor='vim'

declare -a aAlphabetsSmall=(a b c d e f g h i j k l m n p q r s t u v w x y z)
declare -a aAlphabetsCaps=(A B C D E F G H I J K L M N P Q R S T U V W X Y Z)
aAkamaiPragmaHeaders=(
    "akamai-x-cache-on"
    "akamai-x-cache-remote-on"
    "akamai-x-ip-trace"
    "akamai-x-origin-response"
    "akamai-x-check-cacheable"
    "akamai-x-get-cache-key"
    "akamai-x-get-true-cache-key"
    "akamai-x-get-extracted-values"
    "akamai-x-get-ssl-client-session-id"
    "akamai-x-feo-trace"
    "akamai-x-serial-no"
    "akamai-x-get-request-id"
)

# Taxt Formating
txtRed=$(tput setaf 1) # Red
txtGreen=$(tput setaf 2) # Green
txtBlue=$(tput setaf 4) # Blue
txtWhite=$(tput setaf 7) # White
txtBold=$(tput bold) # Text Bold
txtReset=$(tput sgr0) # Text reset.

bjrsyncOptionsNonRecursive="--links --perms --times --group --owner --devices --specials --executability"
bjrsyncOptionsNonRecursive="$bjrsyncOptionsNonRecursive --verbose --human-readable --compress --itemize-changes --progress --stats --cvs-exclude"

if [ -d $bjdh/tmp/rsync ]; then
    bjrsyncOptionsNonRecursive="$bjrsyncOptionsNonRecursive --log-file=$bjdh/tmp/rsync"
fi

if [ -f $bjdh/settings/rsync/rsyncExcludePatterns.txt ]; then
    bjrsyncOptionsNonRecursive="$bjrsyncOptionsNonRecursive --cvs-exclude"
fi

bjrsyncOptionsNonRecursive="$bjrsyncOptionsNonRecursive --log-file=$bjdh/tmp/rsync"
bjrsyncOptions="--recursive $bjrsyncOptionsNonRecursive"
bjrsyncOptions="bijay"
scpOptions="-pqrC"

here="there"

################################################################################
## Simple Aliases ##
################################################################################

alias bjCopy='copyToClipboard'
alias bjPaste='pasteClipboardContent'

if $isMac; then
    alias bjPaste='pbpaste'
else
    alias bjPaste='xclip -o'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# enable color support of ls and also add handy aliases
## @TODO The Color Support adds binary characters
if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
    alias ls='ls -lah --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto --recursive --no-messages --ignore-case'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto --recursive --no-messages --ignore-case'
else
    alias ls='ls -lahpF'
    alias dir='ls --format=vertical'
    alias vdir='ls --format=long'
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -lahL'
alias l='ls -CF'

alias listDirs='find . -type d -maxdepth 1'
alias listDirsLs='/bin/ls -1d */'
alias listFiles='find . -type f -maxdepth 1'

alias home='cd ~/'
alias h='cd ~/'
alias cdp='cd $p'
alias f="find . |grep -i"
alias ggl='ping -c 5 google.com'
alias nwc="sudo cat /etc/network/interfaces"
alias p="cd ~/projects"
alias rmf='rm -fR'
alias rmfs='sudo rm -fR'

# Quick Open Files for editting or viewing.
alias als='$bjEditor ~/.bash_aliases'
alias lals='less ~/.bash_aliases'

alias du1='du --max-depth=1'
alias du2='du --max-deth=2'

# Auto Parameter
alias mkdir='mkdir -p'
alias kate='kate -u'
alias tarc='tar -cvvf'
# alias grep="grep --recursive --no-messages  --ignore-case"
alias bjgrep="grep --recursive --no-messages --include='*.(php|html)' "
alias cpr='cp -R'
alias scpr='scp -r'
alias ping='ping -c 5'

# Taken from http://ubuntuforums.org/showthread.php?t=679762
alias hs='history'
alias clr='clear'
alias hss='history | grep'

# System info
alias cpuu="ps -e -o pcpu,cpu,nice,state,cputime,args --sort pcpu | sed '/^ 0.0 /d'"
alias memu='ps -e -o rss=,args= | sort -b -k1,1n | pr -TW$COLUMNS'
alias pg='ps aux | grep'  #requires an argument

# chmod and permissions commands
alias mx='chmod a+x'
alias 000='chmod 000'
alias 644='chmod 644'
alias 755='chmod 755'
alias perm='stat --printf "%a %n \n "' # requires a file name e.g. perm file

# Exim Aliases
alias bjexiclean='echo "Removing all mails with no sender set"; exiqgrep -f "^<>$" -i | xargs exim -Mrm'
alias bjexifrozen='exiqgrep -z -i | xargs exim -Mrm'
alias bjexiqueue='exim -bp > $dumpdir/exim/queue_all; less $dumpdir/exim/queue_all'

# Databases
alias bjdbcheck="mysqlcheck --all-databases --all-in-1 --repair"

# Administration
alias userlist='cat /etc/passwd |grep "/bin/bash" |grep "[5-9][0-9][0-9]" |cut -d: -f1'

alias phpinfo='php -r "phpinfo();";'

# Force to ask for Password in SSH
alias sshp='ssh -o "PubkeyAuthentication no"'
alias scpp='scp -o "PubkeyAuthentication no"'

if $isMac; then
    alias bjPrettyPrintJson='json_pp'
else
    alias bjPrettyPrintJson='json_pp'
fi

###############
## Functions ##
###############
function rmMatching()
{
    printHeader "Will remove following Files matching pattern *$1*"
    ls *$1*
    rm *$1*
    printInfo "### Done ###"
}

function grepf()
{
    grep $1 *
}

function grepphp()
{
    grep --include=*.php $1 *
}

function ispeed()
{
    wget --output-document=/dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip
}

###############################
# Clipboard related functions #
###############################
function copyToClipboard()
{
    if $isMac; then
        echo "$@" | pbcopy
    else
        printInfo "Not implemented for Linux yet."
    fi
    printInfo "Content copied to Clipboard"
    bjPaste
}

function pasteClipboardContent()
{
    printInfo "Dumping the Clipboard Content"
    printSeparator

    if $isMac; then
        pbpaste;
    else
        xclip -o;
    fi
    echo "" # Move Cursor to new line.
}

function logClipboardContent()
{
    clipboardLogFile=
    # printInfo "Clipboard Content "
}

function myip()
{
    ipDetected=false
    if [ $(which curl) ]; then
        echo 'Try with curl:'
        curl -s checkip.dyndns.org | /bin/grep -o '\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}'
        ipDetected=true
    fi

    if [ ! ${ipDetected} -a $(which wget) ]; then
        echo 'Try with wget:'
        wget -q -O - checkip.dyndns.org | /bin/grep -o '\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}'
    fi

    if [ ! ${ipDetected} -a $(which wget) ]; then
        echo "Try with lynx: "
        lynx --dump "http://checkip.dyndns.org"
    fi
}

function bjFormatSql()
{
    inputFile=$1
    outputFile=$2
    if [ -z $inputFile ]; then
        echo 'Please provide the Input file for formatting'
        exit
    fi
    if [ -z $outputFile ]; then
        dirName=$(dirname ${inputFile})
        fileName=$(bjFileName ${inputFile})
        fileExtension=$(bjFileExtension ${inputFile})
        outputFile=${dirName}/${fileName}.formatted.${fileExtension}
        # outputFile=${inputFile}.formatted.sql
    fi

    sqlformat --keywords=upper --reindent --indent_width=4 --outfile=${outputFile} ${inputFile}
    echo "Formatted SQL saved at ${outputFile}"
    if $isMac; then
        sed -i "" '/^$/d' ${outputFile}
        # echo "Backup file at ${outputFile}.bkp"
        # rm ${outputFile}.bkp
    else
        sed -i '/^$/d' ${outputFile}
    fi
    bjConfirmAndOpenIde ${outputFile}
}

function bjChangeExtension()
{
    if [ ! -f "$1" ] ; then
        printInfo "File doesn't exist at $1"
        return;
    fi
    if [ -z $2 ]; then
        printInfo "Please provide the Target Extension"
        return;
    fi
    targetExtension="$2"
    originalFile=$1
    dirName=$(dirname ${originalFile})
    fileName=$(bjFileName ${originalFile})
    fileExtension=$(bjFileExtension ${originalFile})
    destinationFile=${dirName}/${fileName}.${targetExtension}
    echo "${destinationFile}"
}

function phpf()
{
    if $isMac; then
        printInfo "*** Not implemented for Mac OSX ***"
    fi
    if [ -f $1 ] ; then
        dirName=`dirname $1`
        baseName=`basename $1`
        case $1 in
            *.php)  phpformat "$1" $2;;
             *)     echo "'$1' cannot be formatted as it doesn't seem like a php file" ;;
        esac
    elif [ -d $1 ]; then
        for file in $1/*;
        do
            echo "Process for $file"
            phpf $file $2;
        done;
    fi
}

function phpff()
{
    if [ -f $1 ] ; then
        dirName=`dirname $1`
        baseName=`basename $1`
        case $1 in
            *.php)  phpformat "$1" FINAL;;
             *)     echo "'$1' cannot be formatted as it doesn't seem like a php file" ;;
        esac
    elif [ -d $1 ]; then
        echo "$1 is a Directory, enter into it."
        for file in $1/*;
        do
            echo "Process for $file"
            phpff $file;
        done;
    fi
}

function phpformat()
{
    mode=$2
    if [ -z $mode ] ; then
        isFinal=0;
    else
        isFinal=1;
    fi
    originalFile=$1
    dirName=$(dirname ${originalFile})
    fileName=$(bjFileName ${originalFile})
    fileExtension=$(bjFileExtension ${originalFile})
    destinationFile=${dirName}/${fileName}.formatted.${fileExtension}

    if [ -f $1 ] ; then
        echo "-- Formatting the File ${originalFile} --"
        ${HOME}/codebase/www/tools/phpformatter/release/phpf ${originalFile} ${destinationFile}
        echo "-- Remove Trailing Spaces/Tabs from file. --"
        sed -i 's/[ \t]*$//' $destinationFile
        if (( $isFinal )) ; then
            mv $destinationFile $originalFile
            destinationFile=$originalFile
        fi
        echo "Saved in ${destinationFile}"
    fi
}

function tidyf()
{
    if [ -f $1 ] ; then
        dirName=`dirname $1`
        baseName=`basename $1`
        tidy -config ${HOME}/settings/format/tidy.conf "$1" -output "$1.formatted.html"
    fi
}

function rmCtrlM()
{
    echo 'Not implemented yet.'
}

function rthumbs()
{
    originalDir=`pwd`
    dirName=$1
    if [ -z $dirName ] ; then
        dummy=0;
    else
        cd $dirName
    fi

    echo "Will Remove all Files named Thumbs.db typically created by Windows File System"
    find . -name 'Thumbs.db' -type f -exec rm -rf {} \;
    cd $originalDir
}

alias rmthumbs="rthumbs"

function rcvs()
{
    originalDir=`pwd`
    dirName=$1
    if [ -z $dirName ] ; then
        dummy=0;
    else
        cd $dirName
    fi

    echo "Will Remove all Directories named CVS typically created by CVS"
    find . -name 'CVS' -type d -exec rm -rf {} \;
    cd $originalDir
}

function rmExecutables()
{
    originalDir=`pwd`
    dirName=$1
    if [ -z $dirName ] ; then
        dummy=0;
    else
        cd $dirName
    fi

    echo "Will Remove all Files named Thumbs.db typically created by Windows File System"
    find . -name '.exe' -type f -exec rm -rf {} \;
    cd $originalDir
}

function genPassword()
{
    passwordLength=$1
    if [ -z $passwordLength ] ; then
        passwordLength=8;
    fi
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $passwordLength | sed 1q
}

#######################
# Url Related Methods #
#######################
function bjHostName()
{
    url=$1
    hostAddress="${url%%[?#]*}"
    hostAddress=${hostAddress:7}
    hostAddress="${hostAddress%%[/]*}"
    echo ${hostAddress}
}

function urlencode()
{
    ENCODED=$(echo -n "$1" | \
    perl -pe's/([^-_.~A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg');
    echo $ENCODED
}

function google2()
{
    perl -e '$i=0;while($i<10){open(WGET,qq/|xargs lynx -dump/);printf WGET qq{http://www.google.com/search?q=site:g33kinfo.com&hl=en&start=$i&sa=N},$i+=10}'|grep '\/\/g33kinfo.com\/'
}

function extractLinksGoogleSearch()
{
    # extract links from a google results page saved as a file
    # http://www.commandlinefu.com/commands/view/266/extract-links-from-a-google-results-page-saved-as-a-file
    gsed -e :a -e 's/\(<\/[^>]*>\)/\1\n/g;s/\(<br>\)/\1\n/g' page2.txt | sed -n '/<cite>/p;s/<cite>\(.*\)<\/cite>/\1/g' >> output
}

function monitorSite()
{
    watch -n 15 curl -s --connect-timeout 10 $1
}

## File Backup, Move and Copy
function bkpt()
{
    echo "Function call to Backup/Tar Directory $1"
    currentDirectory=`pwd`
    dirName=""
    baseName=""
    tarOptions=""

    if [ -f ${HOME}/settings/patterns/exclude/lamp.txt ] ; then
        # tarOptions="--exclude-from ${HOME}/settings/patterns/exclude/lamp.txt"
        tarOptions=""
    fi

    if [ -f $1 ] ; then
        dirName=`dirname $1`
        baseName=`basename $1`
    elif [ -d $1 ] ; then
        dirName=`dirname $1`
        baseName=`basename $1`
    else
        echo "'$1' is not a valid file or Directory"
        exit
    fi

    pfx=`date +%Y-%m-%d_%H-%M-%S_`
    oldFileName="$baseName"
    newFileName="$pfx$baseName.tar.bz2"

    echo "Change Directory to $dirName"
    cd $dirName
    echo "Backing up $oldFileName to $newFileName"
    echo "Command to be run: tar $tarOptions cjf $newFileName $oldFileName"
    # Remove the $tarOptions Thing for the Time being..
    tar $tarOptions cjf $newFileName $oldFileName
    echo 'Archive done'
    echo 'Back to previous Directory'
    cd $currentDirectory
    echo "Done.."
}

function bkpmv()
{
    echo "Function call to take a Backup of Directory $1 and Delete"
    currentDirectory=`pwd`
    dirName=""
    baseName=""
    if [ -f $1 ] ; then
        dirName=`dirname $1`
        baseName=`basename $1`
    elif [ -d $1 ] ; then
        dirName=`dirname $1`
        baseName=`basename $1`
    else
        echo "'$1' is not a valid file or Directory"
        exit
    fi

    pfx=`date +%Y-%m-%d_%H-%M-%S_`
    oldFileName="$dirName/$baseName"
    newFileName="$dirName/$pfx$baseName"

    echo "Moving $oldFileName to $newFileName"
    echo "Command to be run: mv $oldFileName $newFileName"
    mv $oldFileName $newFileName
    echo 'Archive done'
    echo 'Back to previous Directory'
    cd $currentDirectory
    echo "Done.."
}

function bkpcp()
{
    currentDirectory=`pwd`
    dirName=""
    baseName=""
    if [ -f $1 ] ; then
        dirName=`dirname $1`
        baseName=`basename $1`
    elif [ -d $1 ] ; then
        dirName=`dirname $1`
        baseName=`basename $1`
    else
        echo "'$1' is not a valid file or Directory"
        exit
    fi

    pfx=`date +%Y-%m-%d_%H-%M-%S_`
    oldFileName="$dirName/$baseName"
    newFileName="$dirName/$pfx$baseName"

    echo "Backing up $oldFileName to $newFileName"
    echo "Command to be run: cp -R $oldFileName $newFileName"
    cp -R $oldFileName $newFileName
    echo 'Archive done'
    echo 'Back to previous Directory'
    cd $currentDirectory
    echo "Done.."
}

function bkp()
{
    bkpcp $1
}

function dumpt()
{
    pfx=`date +%Y-%m-%d_%H-%M-%S_`
    oldFilePath=$1
    dirName=`dirname $1`
    baseName=`basename $1`
    newFilePath=$dumpdir/$pfx$baseName.tar
    echo "Backing up $oldFilePath to $newFilePath"
    echo "Command to be run: tar -cvvf $newFilePath $oldFilePath"
    sudo tar -cvvf $newFilePath $oldFilePath
    sudo chmod 644 $newFilePath
    echo "Done Dumping the tar at.."
    echo $newFilePath
    ls $newFilePath
}

function dumpf()
{
    pfx=`date +%Y-%m-%d_%H-%M-%S_`
    oldFilePath=$1
    dirName=`dirname $1`
    baseName=`basename $1`
    newFilePath=$dumpdir/$pfx$baseName
    echo "Backing up $oldFilePath to $newFilePath"
    cp "$oldFilePath" -R "$newFilePath"
    sudo chmod 644 -R $newFilePath
    echo "Done Dumping the file at.."
    echo $newFilePath
    ls $newFilePath
}

function convertEOL()
{
    perl -pi -e 's/\r\n?/\n/g' $1
}

function emailq()
{
    php ~/www/index.php \
        --moduleName=emailqueue \
        --managerName=emailqueue \
        --action=process \
        --deliveryDate=all --limit=1
}

##################################################################
## http://ubuntuforums.org/showthread.php?t=679762  ##############
##################################################################
function extract()
{
    if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xjf $1        ;;
             *.tar.gz)    tar xzf $1     ;;
             *.bz2)       bunzip2 $1       ;;
             *.rar)       rar x $1     ;;
             *.gz)        gunzip $1     ;;
             *.tar)       tar xf $1        ;;
             *.taz)       tar -xvf $1        ;;
             *.tbz2)      tar xjf $1      ;;
             *.tgz)       tar xzf $1       ;;
             *.zip)       unzip $1     ;;
             *.Z)         uncompress $1  ;;
             *.7z)        7z x $1    ;;
             *)           echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

function extractSmart()
{
    if [ ! -f $1 ] ; then
        printStatus "'$1' is not a valid file"
        return
    fi
    filePath=$1
    previousDir=$(pwd)
    fileDir=$(dirname "${filePath}")
    fileBaseName=$(basename "${filePath}")
    fileName=$(bjFileName "${filePath}")
    fileExtension=$(bjFileExtension "${filePath}")

    cd ${fileDir}
    mkdir "${fileName}"
    cp "${fileBaseName}" ${fileName}/
    cd "${fileName}"
    extract "${fileBaseName}"
    rm "${fileBaseName}"
    numFiles=$(/bin/ls -A1 | wc -l)
    printStatus "Number of Files: ${numFiles}"
    if [ ${numFiles} = 1 ]; then
        extractedFileName=$(/bin/ls)
        tempraryFilemName=$(pfx)${extractedFileName}
        printStatus "Extracted File Name: ${extractedFileName}, Temporary File Name: ${tempraryFilemName}"
        printDryRunCommand "mv /${extractedFileName} /tmp/${tempraryFilemName}"
        mv "${extractedFileName}" "/tmp/${tempraryFilemName}"
        cd ..
        rmdir "${fileName}"
        printDryRunCommand "mv /tmp/${tempraryFilemName} ./${extractedFileName}"
        mv "/tmp/${tempraryFilemName}" ./${extractedFileName}
    fi
    printStatus "Extracted file at ${fileDir}/${fileName} Back to Previous Directory"
    cd ${previousDir}
}

function compress()
{
    dirPriorToExe=`pwd`
    fullPath=$1
    dirName=`dirname $1`
    baseName=`basename $1`
    echo "Compressing ${fullPath}"

    if [ -f $1 ] ; then
        echo "It was a file change directory to $dirName"
        cd $dirName
        case $2 in
          tar.bz2)
                    tar cjf $baseName.tar.bz2 $baseName
                    ;;
          tar.gz)
                    tar czf $baseName.tar.gz $baseName
                    ;;
          gz)
                    gzip $baseName
                    ;;
          tar)
                    tar -cvvf $baseName.tar $baseName
                    ;;
          zip)
                    zip -r $baseName.zip $baseName
                    ;;
            *)
                    echo "Method not passed, compressing using tar.bz2"
                    tar cjf $baseName.tar.bz2 $baseName
                    ;;
        esac
        echo "Back to Directory $dirPriorToExe"
        cd $dirPriorToExe
    else
        if [ -d $1 ] ; then
            echo "It was a Directory change directory to $dirName"
            cd $dirName
            case $2 in
                tar.bz2)
                        tar cjf $baseName.tar.bz2 $baseName
                        ;;
                tar.gz)
                        tar czf $baseName.tar.gz $baseName
                        ;;
                gz)
                        gzip -r $baseName
                        ;;
                tar)
                        tar -cvvf $baseName.tar $baseName
                        ;;
                zip)
                        zip -r $baseName.zip $baseName
                        ;;
                *)
                    echo "Method not passed, compressing using tar.bz2"
                tar cjf $baseName.tar.bz2 $baseName
                        ;;
            esac
            echo "Back to Directory $dirPriorToExe"
            cd $dirPriorToExe
        else
            echo "'$1' is not a valid file/folder"
        fi
    fi
    echo "Done"
    echo "###########################################"
}

#netinfo - shows network information for your system
function netinfo()
{
    echo "--------------- Network Information ---------------"
    /sbin/ifconfig | awk /'inet addr/ {print $2}'
    /sbin/ifconfig | awk /'Bcast/ {print $3}'
    /sbin/ifconfig | awk /'inet addr/ {print $4}'
    /sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'
    # myip=`lynx -dump -hiddenlinks=ignore -nolist http://checkip.dyndns.org:8245/ | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g' `
    # echo "${myip}"
    echo "---------------------------------------------------"
}

#dirsize - finds directory sizes and lists them for the current directory
function dirsize()
{
    du -shx * .[a-zA-Z0-9_]* 2> /dev/null | \
    egrep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
    egrep '^ *[0-9.]*M' /tmp/list
    egrep '^ *[0-9.]*G' /tmp/list
    rm -rf /tmp/list
}

#copy and go to dir
function cpg()
{
  if [ -d "$2" ];then
    cp $1 $2 && cd $2
  else
    cp $1 $2
  fi
}

#move and go to dir
function mvg()
{
  if [ -d "$2" ];then
    mv $1 $2 && cd $2
  else
    mv $1 $2
  fi
}

# mkdir and go to dir
function mkdirg()
{
    mkdir -p $1
    cd $1
}

function pfx()
{
    separator="_"
    if [ ! -z $1 ]; then
        separator=""
    fi
    pfx=`date +%Y-%m-%d_%H-%M-%S`
    pfx="${pfx}${separator}"
    echo $pfx
}

function dateh()
{
    box "`date -R`"
}

#Copy Files. Make Directories where necessery.
function cpm()
{
    sourceFile=$1
    sourceDirName=`dirname $1`
    destinationRootDir=$2
    if [ -z $destinationRootDir ] ; then
        destinationRootDir=.
    else
        dummy=1;
    fi

    if [ -d $destinationRootDir ] ; then
        if [ -d "$destinationRootDir/$sourceDirName" ];then
            echo "Direcoty Exists, Continue Downloading"
        else
            echo "Direcoty $destinationRootDir/$sourceDirName doesn't exist, Create it.."
            mkdir -p "$destinationRootDir/$sourceDirName";
        fi
        echo "Copy all file $sourceFile to $destinationRootDir/$sourceFile Recursively."
        cp -R $sourceFile $destinationRootDir/$sourceFile
    fi
}

# Find and Replace in PHP Files.
function bjphpfr()
{
    findPattern=$1
    replacePattern=$2
    path=$3

    if [ -z $path ] ; then
        path=./
    else
        isFinal=1;
    fi

    grep --recursive --no-messages --files-with-matches --extended-regexp --include=*.php -e '$findPattern' $path | xargs sed -i 's/$findPattern/$replacePattern/g'
}

function detectAndClean()
{
    # The Argument is for the User
    pfx=`date +%Y-%m-%d_%H-%M-%S_`
    suffix=detectAndClean
    filePath=$pfx$suffix
    dumpPath=$dumpdir/$filePath
    echo "Change Directory to /home/$1/public_html"
    echo "Dump File is $dumpPath"
    cd /home/$1/public_html
    echo "Run Command:touch $dumpPath"
    sudo touch $dumpPath
    sudo echo 'Search in PHP Files ' >> $dumpPath
    sudo grep -r -B 2 -A 2  --include=*.php '<!-- o65 -->' * >> $dumpPath
    sudo echo 'Search in HTML Files ' >> $dumpPath
    sudo grep -r -B 2 -A 2  --include=*.html '<!-- o65 -->' * >> $dumpPath
    sudo chmod 644 $dumpPath
}

# Pass like detectAndCleanAll ${HOME}/public_html
function detectAndCleanAll()
{
    path=$1
    pattern=$2
    grepOptions=" --recursive --before-context=1 --after-context=1 --no-messages --extended-regexp"

    if [ -z $path ] ; then
        path=./
    else
        isFinal=1;
    fi

    if [ -z $pattern ] ; then
        # pattern="(eval|base64_encode|base64_decode|create_function|exec|shell_exec|system|passthru|ob_get_contents|file|curl_init|readfile|fopen|fsockopen|pfsockopen|fclose|fread|include|require|file_put_contents)";
        pattern="(eval|base64_encode|base64_decode|create_function|exec|shell_exec|system|passthru|ob_get_contents|curl_init|readfile|fopen|fsockopen|pfsockopen|fclose|fread|file_put_contents)"
    else
        isFinal=1;
    fi

    # The Argument is for the User
    pfx=`date +%Y-%m-%d_%H-%M-%S_`
    suffix=detectAndClean
    filePath=$pfx$suffix
    dumpPath=$dumpdir/$filePath

    echo "Dump File is $dumpPath"

    echo "Run Command:touch $dumpPath"
    sudo touch $dumpPath
    sudo chmod 777 $dumpPath

    echo 'Search in PHP Files '
    sudo echo 'Search in PHP Files ' >> $dumpPath
    echo "sudo grep $grepOptions --include=*.php -e $pattern $path >> $dumpPath"
    sudo grep $grepOptions --include=*.php -e "$pattern" $path >> $dumpPath

    echo 'Search in HTML Files '
    sudo echo 'Search in HTML Files ' >> $dumpPath
    echo "sudo grep $grepOptions --include=*.html -e $pattern $path >> $dumpPath"
    sudo grep $grepOptions --include=*.html -e "$pattern" $path >> $dumpPath

    less $dumpPath
}

function bjexilog()
{
    pattern=$1
    localDumpDir=$dumpdir/exim
    ensureDirExists localDumpDir
    dumpPath=$localDumpDir/grep

    if [ -f $dumpPath ]; then
      . rm $dumpPath
    fi
    echo "Dump Path is $dumpPath"

    echo "Searching in exim_mainlog for $pattern"
    grep "$pattern" /var/log/exim_mainlog >> $dumpPath
    echo "Searching in exim_rejectlog for $pattern"
    grep "$pattern" /var/log/exim_rejectlog >> $dumpPath
    echo "Searching in exim_paniclog for $pattern"
    grep "$pattern" /var/log/exim_paniclog >> $dumpPath
    echo 'Done...'
    less $dumpPath
}

function detectPossibleAttack()
{
    datePart=`date +%Y-%m-%d_%H-%M-%S`
    filePart=detectPossibleAttack
    filePath=$pfx$filePart

    dumpPath=$dumpdir/$filePart/$datePart
    grepOptions="--line-number -C 2"

    logMessage "Detecting for Attacks started at `date --rfc-2822`" $dumpPath
    echo "Dump Path is $dumpPath"
    echo "grep Options are $grepOptions"
    echo $strSeparator >> $dumpPath

    logMessage "Search for public_html/index.php uploaded" $dumpPath
    grep $grepOptions 'public_html/index\.php uploaded' /var/log/messages >> $dumpPath

    logMessage "Search for public_html/login.php uploaded" $dumpPath
    grep $grepOptions 'public_html/login\.php uploaded' /var/log/messages >> $dumpPath

    logMessage "Search for public_html/index.html uploaded" $dumpPath
    grep $grepOptions 'public_html/index\.html uploaded' /var/log/messages >> $dumpPath

    logMessage "Search for public_html/index.htm uploaded" $dumpPath
    grep $grepOptions 'public_html/index\.htm uploaded' /var/log/messages >> $dumpPath

    logMessage "Search for index.php uploaded" $dumpPath
    echo "Command to be Run: # grep $grepOptions '/index\\.php uploaded' /var/log/messages >> $dumpPath"
    grep $grepOptions '/index\.php uploaded' /var/log/messages >> $dumpPath

    logMessage "Search for login.php uploaded" $dumpPath
    echo "Command to be Run: # grep $grepOptions '/login\\.php uploaded' /var/log/messages >> $dumpPath"
    grep $grepOptions '/login\.php uploaded' /var/log/messages >> $dumpPath

    logMessage "Search for index.html uploaded" $dumpPath
    echo "Command to be Run: # grep $grepOptions '/index\\.html uploaded' /var/log/messages >> $dumpPath"
    grep $grepOptions '/index\.html uploaded' /var/log/messages >> $dumpPath

    # logMessage "Search for public_html/index.htm uploaded" $dumpPath
    # grep $grepOptions 'public_html/index\.htm uploaded' /var/log/messages >> $dumpPath

    less $dumpPath
}

function bjlogftp()
{
    pfx=`date +%Y-%m-%d_%H-%M-%S_`
    suffix=ftp_logins
    filePath=$pfx$suffix
    dumpPath=$dumpdir/$filePath
    sudo grep -A 2 " is now logged in" /var/log/messages > $dumpPath
    sudo chmod 644 $dumpPath
    echo "Done dumping the ftp log"
    echo $dumpPath
    ls $dumpPath
}

function generateImageBrowser()
{
    prefix=`date +%Y-%m-%d_%H-%M-%S_`
    suffix=imageBrowser.html
    fileName=$prefix$suffix
    outputPath="${HOME}/tmp/${prefix}${suffix}"
    echo "File Path is $outputPath"

    if [ -d "$1" ];then
        initDir=`pwd`
        dir=$1
        cd $dir
        dirPath=`pwd`
        outputPath="$dirPath/$fileName"

        echo "<h3>Images in $dirPath</h3>" > $outputPath
        echo "<ul>" >> $outputPath

        find . -maxdepth 1 -type f -printf '<li>%f<img src="%f" /></li>' >> $outputPath
        echo "</ul>" >> $outputPath

        echo "Change Directory back to initial"
        cd $initDir
        echo "Done with wrting the file at $outputPath"
        ls $outputPath
        less $outputPath
    else
        echo "Invalid Path provided no such Directory exists.."
        echo "terminating now"
    fi
}

function ensureDirExists()
{
    echo 'Function Call to ensure that the Directory exists $1'
    $path=$1
    mkdir -p $path
    printMessage "Created Path $path"
}

function ftpGetRecursive()
{
    ftpUser=$1
    server=$2
    localTargetDirectory=$3
    remoteSourceRelativeDirectory=$4
    ncftpget –R –v –u $ftpUser $server $localTargetDirectory $remoteSourceRelativeDirectory
}

function discoverUserName()
{
    path=$1
    fileName=`basename $path`
    dirName=`dirname $path`
    case $dirName in
        "/home")
            echo $fileName
            exit 0;
            ;;
        "/")
            echo $fileName
            exit 0;
            ;;
        *)
            echo `discoverUserName $dirName`
            ;;
    esac
}

function box()
{
    copyToClipboard "$(printBox "$1")"
}

function boxf()
{
    copyToClipboard "$(printBox "$1" 80)"
}

function printBox()
{
    # Parameters.
    stringToPrint="$1"
    lineLength=$2
    charToUse=${3:-\#};

    stringLength=${#1}
    if [ -z $lineLength ]; then
        lineLength=$(expr ${#1} + 4)
    fi
    #printRaw "Length of Word is ${stringLength}"
    #printRaw "Length of Line would be ${lineLength}"
    paddingLength=$(expr ${lineLength} - 2 - ${stringLength})
    #printRaw "Total Padding would be ${paddingLength}"
    paddingLeft=$(expr ${paddingLength} / 2);
    paddingEnd=${paddingLeft}
    #printRaw "Paddding at Left ${paddingLeft}"
    #printRaw "Paddding at End ${paddingEnd}"
    isOdd=$(expr ${stringLength} % 2)
    if [ ${lineLength} -ge 80 ] && [ $isOdd -eq 1 ]; then
        paddingEnd=$(expr $paddingLeft + 1)
    fi
    #printRaw "Paddding at Left ${paddingLeft}"
    #printRaw "Paddding at End ${paddingEnd}"
    printChars ${lineLength} ${charToUse} nl;
    printChars ${paddingLeft} ${charToUse};
    printf " ${stringToPrint} "
    printChars ${paddingEnd} ${charToUse} nl;
    printChars ${lineLength} ${charToUse} nl;
}

function boxd()
{
    box "`date -R`"
}

function printChars()
{
    newLine=$3
    for (( i=0; $i<$1; i=$i+1));
        do printf $2;
    done;
    if [ ! -z $newLine ] ; then
        printf "\n";
    fi
}

# CHange File Permission of all Folders to 0755 and all Files to 0644
function chFilePermission()
{
    path=$1
    if [ -z $path ] ; then
        path=./
    else
        isFinal=1;
    fi
    echo "Changing Permissions under the Directory $path Folders to 0755 and Files into 0644"
    find $path -type d -print0 | xargs -0 chmod 0755 && find . -type f -print0 | xargs -0 chmod 0644
}

# Install my ssh key on a remote system.
function sshInstallkey()
{
    [ -n "$1" ] || {
        echo "usage: ssh-installkey username@host" >&2
        return 1
    }
    ssh $1 "mkdir -p -m 700 .ssh"
    ssh $1 "cat >> ~/.ssh/authorized_keys2" < ~/.ssh/id_dsa.pub
}

# Install some basic settings on the remote system for things like zsh, vim,
# and screen.  Then, try to change shells.
function sshInstallsettings()
{
    [ -n "$1" ] || {
        echo "usage: ssh-installsettings username@host" >&2
        return 1
    }

    scp -r \
        .zlogin .zshenv .zshrc \
        .vim .vimrc \
        .screenrc \
        $1:

    echo "Attempting to set login shell." >&2
    ssh $1 "chsh -s /usr/bin/zsh"
}

# Administration

function ulist()
{
    awk -F":" '{ print "username: " $1 "\t\tuid:" $3 "\t\tFull_Name: " $5 }' /etc/passwd
}

function bjCheckRootOwner()
{
    userToCheck=$1
    pathToCorrect=$2
    if [ -z $pathToCheck ] ; then
        pathToCheck=/home/$userToCheck/public_html;
    else
        isFinal=1;
    fi
    # Find Files/Folders whose owner is root.
    sudo find $pathToCheck -user 0
}

function bjCorrectOwner()
{
    userToCorrect=$1
    pathToCorrect=$2
    if [ -z $pathToCorrect ] ; then
        pathToCorrect=/home/$userToCorrect/public_html;
    else
        isFinal=1;
    fi
    # This should correct all root owned file
    sudo find $pathToCorrect -user 0 | xargs sudo chown $userToCorrect:$userToCorrect
}

function bjCorrectSelfOwner()
{
    userToCorrect=$1
    pathToCorrect=$2
    if [ -z $pathToCorrect ] ; then
        pathToCorrect=.;
    else
        isFinal=1;
    fi
    # This should correct all root owned file
    sudo find $pathToCorrect -user 0 | xargs sudo chown $userToCorrect:$userToCorrect
}

function dirCount()
{
    dirCount=0;
    for fileName in $1/*;
    do
        if [ -d "$fileName" ]; then
            dirCount=$(($dirCount+1));
        fi
    done
    echo "Number of Directories: $dirCount";
}

function slowQueries()
{
    mysqldumpslow -s t /var/lib/mysql/slow.log
}

function rmTrailingSpaces()
{
    echo "Not implemented yet"
}

function checkHeaders()
{
    requestUrl=$1
    host=$2
    commandOptionsWithDumpHeaders="--include --insecure -silent --verbose --compressed --output /dev/null --dump-header /dev/stdout"
    commandOptions="--include --insecure -silent --verbose --compressed --output /dev/null"

    if [ -z $host ] ; then
        curl ${commandOptions} ${requestUrl}
    else
        curl ${commandOptions} -H "Host: ${host}" ${requestUrl}
    fi
}

function bjHumanFilesize() 
{
	awk -v sum="$1" ' BEGIN {hum[1024^3]="Gb"; hum[1024^2]="Mb"; hum[1024]="Kb"; for (x=1024^3; x>=1024; x/=1024) { if (sum>=x) { printf "%.2f %s\n",sum/x,hum[x]; break; } } if (sum<1024) print "1kb"; } '
}

function findAliasDefinition()
{
    grep --color=always -n -C 1 -R -E "function $1" ${bashLibDir}
}

function bjFindUtilityScripts()
{
    printHeader "Find Alias or Function named $1 in Utility Scripts"
    grep --color=always -n -C 1 -R -E "(function|alias) $1" ${bashLibDir}
    printInfo "Done"
}

function bjFindUtilityScriptsOccurances()
{
    printHeader "Find Occuarances of $1 in Utility Scripts"
    grep --color=always -n -C 1 -R -E "$1" ${bashLibDir}
    printInfo "Done"
}

function txtRed()
{
    printf "${txtRed}$*${txtReset}"
}

function txtGreen()
{
    printf "${txtGreen}$*${txtReset}"
}

function txtBlue()
{
    printf "${txtBlue}$*${txtReset}"
}

function txtWhite()
{
    printf "${txtWhite}$*${txtReset}"
}

function txtBold()
{
    printf "${txtBold}$*${txtReset}"
}

function currentDirInfo()
{
    echo "-- Current Directory is `pwd` --"
}

function bjFilePath()
{
    filePath="$1"
    # printHeader "Detect Absolute path for File ${filePath}"
    firstCharacter="${filePath:0:1}"
    # printHeader "First Character is ${firstCharacter}"
    if [ "${firstCharacter}" != "/" ]; then
        filePath=$(pwd)/$1
    fi
    echo "${filePath}"

    if [ ! -z ${2} ]; then
        copyToClipboard "${filePath}"
    fi
}

function bjFileName()
{
    fileBaseName=$(basename "$1")
    fileName="${fileBaseName%.*}"
    echo ${fileName}
}

function bjFileExtension()
{
    fileBaseName=$(basename "$1")
    fileExtension="${fileBaseName##*.}"
    echo ${fileExtension}
}

function toLowerBash()
{
    string=$1
    echo ${string,,}
}

function toUpperBash()
{
    string=$1
    echo ${string^^}
}

function toLower()
{
    # Using TR
    echo $1 | tr '[:upper:]' '[:lower:]'
}

function toUpper()
{
    # Using TR
    echo $1 | tr '[:lower:]' '[:upper:]'
}

function toLowerAwk()
{
    echo $1 | awk '{print tolower($0)}'
}

function toUpperAwk()
{
    echo $1 | awk '{print toupper($0)}'
}

function gitInfo()
{
    projectRoot=$1
    if [ -z $projectRoot ]; then
        projectRoot=`pwd`
    fi

    currentDirInfo
    echo "Git Info:"
    if [ -d ${projectRoot}/.git ]; then
        cat ${projectRoot}/.git/config
        printSeparator
        printInfo "Git Branches..."
        git branch -a
        printSeparator
    else
        echo "Not a Git Repository"
    fi
}

function gitCommit()
{
    git commit -a -m "$1"
}

function bjMysqlCreateUser()
{
    echo "CREATE USER \"$1\"@localhost IDENTIFIED BY \"$2\";"
    # SET PASSWORD FOR "$1"@localhost = PASSWORD("$2");
    echo "GRANT ALL PRIVILEGES ON *.* TO \"$1\"@localhost WITH GRANT OPTION;"
    echo "CREATE USER \"$1\"@localhost IDENTIFIED BY \"$2\";"
    echo "GRANT ALL PRIVILEGES ON *.* TO \"$1\"@\"10.211.55\" WITH GRANT OPTION;"
}

function printMysqlChars()
{
    for i in `seq 1 128`;
    do
        echo "UNION SELECT \"$i\", CONCAT('\"', CHAR($i), '\"') AS result" >> chars.sql;
    done;
    echo "SQL Saved in chars.sql"
}

function bjSvnGetBranch()
{
    # http://www.commandlinefu.com/commands/view/1877/get-the-current-svn-branchtag-good-for-ps1prompt_command-cases
    svn info | grep '^URL:' | egrep -o '(tags|branches)/[^/]+|trunk' | egrep -o '[^/]+$'

    # Alternative 1
    # svn info | sed -n "/URL:/s/.*\///p"

    # Alternative 2
    # svn info | grep ^URL | awk -F\/ '{print $NF}'
}

function bjApacheOperations()
{
    return;
    # enable site
    sudo a2ensite

    # disable site
    sudo a2dissite

    # enable an apache2 module
    sudo a2enmod

    # e.g. a2enmod php4 will create the correct symlinks in mods-enabled to
    # allow the module to be used. In this example it will link both php4.conf
    # and php4.load for the user

    # disable an apache2 module
    sudo a2dismod

    # force reload the server:
    sudo /etc/init.d/apache2 force-reload

    # Restart Apache Service
    sudo service apache restart

    # Reload Apache Service
    sudo service apache reload
}

function bjServiceStatus()
{
    sudo service $1 status
}

function bjReloadService()
{
    sudo service $1 reload
}

function bjReloadApache()
{
    bjReloadService apache2
}

function bjRestartService()
{
    printInfo "sudo service $1 restart"
    sudo service $1 restart
}

function bjRestartApache()
{
    bjRestartService apache2
}

function bjPreview()
{
    if [ -d "$1" ]; then
        ls "$1"
    else
        less "$1"
    fi
}

function bjCompareFiles()
{
    compareProgram='vimdiff'
    compareProgram='meld'
    if $isMac; then
        compareProgram=opendiff
    fi
    mineDir="$1"
    theirsDir="$2"
    comparePath="$3"
    ${compareProgram} ${mineDir}/${comparePath} ${theirsDir}/${comparePath}
}

function bjConvertToMarkdown()
{
    inputFile="$1"
    dirName=$(dirname ${inputFile})
    fileName=$(bjFileName ${inputFile})
    fileExtension=$(bjFileExtension ${inputFile})
    markDownFile="${dirName}/${fileName}_${fileExtension}.md"
    textutil -convert html "${inputFile}" -stdout | pandoc -f html -t markdown -o "${markDownFile}"
}

function bjGetAkamaiPragmaHeaders()
{
    separator=", "
    pragmaHeaders="$(printf "${separator}%s" "${aAkamaiPragmaHeaders[@]}")"
    pragmaHeaders="${pragmaHeaders:${#separator}}" # remove leading separator
    echo "${pragmaHeaders}"
}

#########################
# Most Common Functions #
#########################

function showOutput()
{
    fileName=$1
    printStatus "Content of File: ${fileName}"
    if $isMac; then
        pygmentize "${fileName}"
    else
        cat "${fileName}"
    fi
    printSeparator
}

function logMessage()
{
    message="$1"
    logName=$2
    echo $strSeparator
    echo "${message}" >> ${logName}
    echo "${message}"
}

function logSeparator()
{
    echo $strSeparator
}

function printMessage()
{
   echo $1
}

function printRaw()
{
    echo "# $1"
}

function printStatus()
{
    if [ -z $2 ]; then
        printSeparator
    fi
    printRaw "## $1"
    printSeparator
}

function printHeader()
{
    if [ -z $2 ]; then
        printSeparator
    fi
    printRaw "# $1"
}

function printInfo()
{
    printRaw "# $1"
    if [ -z $2 ]; then
        printSeparator
    fi
}

function printDryRunCommand()
{
    printInfo "Command to be run: $1"
}

function printSeparator()
{
    echo $strSeparator
}

function md5()
{
    php -r "echo 'md5 of $1 is: ';echo md5('$1');";
    echo '';
    printSeparator
}

function testScript()
{
    inputFile="$1"
    echo "Input File: ${inputFile}"
    dirName=`dirname $inputFile`;
    baseName=`basename $inputFile`;
    outputFile=${dirName}/${baseName%.*}.clean.diff
    printInfo "dirName: ${dirName}"
    printInfo "baseName: ${baseName}"
    printInfo "outputFile: ${outputFile}"
}
