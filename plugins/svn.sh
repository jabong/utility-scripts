# bash aliases to make svn branching less painful
# Gregor Dorfbauer, gd@usersnap.com
# http://usersnap.com
# 2013-06-12: Initial Version
# 2013-06-24: calling it from anywhere inside the working directory is possible

# Variables
bjSvnStatusSwitchPattern='    S   '
bjSvnStatusPatternModified='^M\s+'
bjSvnStatusPatternAdded='^A\s+'
bjSvnStatusPatternChanged='^(A|M)\s+'

function bjSvnInfo()
{
    svn info;
    printSeparator
}

function bjSvnLog()
{
    bjSvnUrl=$(bjDetectSvnUrl "$@")
    limit=$2
    svnLogOptions="" #--stop-on-copy
    svnLimitOptions="--limit ${limit}"
    if [ -z ${limit} ] ; then
        svnLimitOptions="--limit 5"
    else
        if [ "${limit}" = "copy" ] ; then
            svnLimitOptions="--stop-on-copy"
        fi
    fi
    printInfo "SVN Url: ${bjSvnUrl}"
    printDryRunCommand "svn log ${svnLogOptions} ${svnLimitOptions} ${bjSvnUrl}"
    svn log ${svnLogOptions} ${svnLimitOptions} ${bjSvnUrl}
}

function bjDetectSvnUrl()
{
    svnUrl="$1"
    if [ -z ${svnUrl} ]; then
        svnUrl=$(bjSvnGetUrl)
    fi
    echo ${svnUrl}
}

function bjSvnStatus()
{
    svnIgnorePattern="${bjSvnStatusSwitchPattern}"
    svnMatchPattern="${bjSvnStatusPatternChanged}"
    mode=$1
    listOnly=false
    case $mode in
        changed)
            svnMatchPattern="${bjSvnStatusPatternChanged}";;
        listOnly)
            listOnly=true
            svnMatchPattern="${bjSvnStatusPatternChanged}";;
        *)
            svnMatchPattern="";;
    esac
    bjSvnInfo
    printInfo '-- Checking Status of Working Copy against Repository --'
    if $listOnly ; then
        svn status | grep -v "${svnIgnorePattern}" | awk '{print $2}'
    else
        svn status | grep -v "${svnIgnorePattern}"
    fi
    printInfo '-- Done with Checking Status of Working Copy against Repository --'
    bjSvnInfo
}

function bjSvnRevert()
{
    pathToRevert=$1
    case $pathToRevert in
        changed)
                for path in $(svn status | grep -v "${svnIgnorePattern}" | awk '{print $2}')
                do
                    # printDryRunCommand "svn revert $path"
                    svn revert $path
                done
            ;;
        *)
            # printDryRunCommand "svn revert $1"
            svn revert -R $1
    esac
    printInfo "Reverted..."
}

function bjSvnGetRepo {
    REPO=`LANG=C svn info | grep "Repository Root"`
    echo ${REPO:17}
}

function bjSvnRepoBase {
   parent=""
   grandparent="."
   while [ -d "$grandparent/.svn" ]; do
      parent=$grandparent
      grandparent="$parent/.."
   done
   echo $parent
}

function bjSvnGetUrl {
    REPO=`LANG=C svn info | grep "URL"`
    echo ${REPO:5}
}

function bjSvnNoRepo {
    echo "You are not inside a svn working copy"
}

function bjSvnGetBranch {
    bjSvnUrl=$(bjSvnGetUrl)
    if [ -z "$bjSvnUrl" ]; then
        return;
    fi
    echo $(basename ${bjSvnUrl})
}

function _bjSvnCreateBranch {
    if [ $# != 2 ]; then
        echo "Usage: $0 branchname \"commit message\""
    else
        REPO=$(bjSvnGetRepo)
        if [ -z "$REPO" ]; then
            echo "You are not inside a svn working copy"
            return;
        fi
        svn copy $REPO/trunk $REPO/branches/$1 -m "$2"
        svn switch $REPO/branches/$1 $(bjSvnRepoBase)
    fi
}
alias bjSvnCreateBranch=_bjSvnCreateBranch

function _bjSvnDeleteBranch {
    if [ $# != 2 ]; then
        echo "Usage: $0 branchname \"commit message\""
    else
        REPO=$(bjSvnGetRepo)
        if [ -z "$REPO" ]; then
            echo "You are not inside a svn working copy"
            return;
        fi
        svn delete $REPO/branches/$1 -m "$2"
    fi
}
alias bjSvnDeleteBranch=_bjSvnDeleteBranch

function _bjSvnUpdateBranch {
    REPO=$(bjSvnGetRepo)
    if [ -z "$REPO" ]; then
        echo "You are not inside a svn working copy"
        return;
    fi
    svn merge $REPO/trunk $(bjSvnRepoBase)
}
alias bjSvnUpdateBranch=_bjSvnUpdateBranch

function _bjSvnSwitch {
    REPO=$(bjSvnGetRepo)
    if [ -z "$REPO" ]; then
        echo "You are not inside a svn working copy"
        return;
    fi
    svn switch $REPO/$1 $(bjSvnRepoBase)
}
alias bjSvnSwitch=_bjSvnSwitch

function _bjSvnReintegrate {
    if [ $# -lt 1 ]; then
        echo "Usage $0 branchname [\"commit message\"]"
        return
    fi
    REPO=$(bjSvnGetRepo)
    if [ -z "$REPO" ]; then
        echo "You are not inside a svn working copy"
        return;
    fi
    SVNST=`svn st`
    if [ "$SVNST" != "" ]; then
        echo "you have changes in your working copy."
        svn st
        return
    fi

    svn switch $REPO/trunk $(bjSvnRepoBase)
    svn merge --reintegrate $REPO/branches/$1 $(bjSvnRepoBase)
    if [ $# == 2 ]; then
        svn ci -m "$2" $(bjSvnRepoBase)
    else
        svn ci $(bjSvnRepoBase)
    fi
}
alias bjSvnReintegrate=_bjSvnReintegrate

function bjSvnCommit()
{
    svn commit -m "$1"
}

function bjSvnEditIgnore()
{
    bjSvnIgnoreOperation "$@" edit
}

function bjSvnShowIgnore()
{
    bjSvnIgnoreOperation "$@" show
}

function bjSvnIgnoreOperation()
{
    pathToCheck=.
    if [ "$1" ]; then
        pathToCheck="$1"
    fi
    operation="$2"
    operationCommand='propget'
    case $operation in
        edit) operationCommand='propedit';;
        get) operationCommand='propget';;
        show) operationCommand='propget';;
        *) operationCommand='propget';;
    esac
    svn ${operationCommand} svn:ignore "${pathToCheck}"
}

function bjIsSvnRepo()
{
    repoUrl=$(bjSvnGetRepo)
    if [ -z "${repoUrl}" ]; then
        return 1
    else
        return 0
    fi
}

function bjSvnViewFile()
{
    bjSvnUrl=$(bjDetectSvnUrl "$@")
    pathToCheck=.
    if [ "$2" ]; then
        pathToCheck="$2"
    fi
    revision=HEAD
    if [ "$3" ]; then
        revision="$3"
    fi
    printDryRunCommand "svn cat -r ${revision} ${bjSvnUrl}/${pathToCheck}"
    # svn cat -r ${revision} ${bjSvnUrl}/${pathToCheck}
}

function bjSvnRemoveVersionInfo()
{
    if ! $(bjIsSvnRepo); then
        bjSvnNoRepo
        return;
    fi
    # Will remove all Folders with the name .svn recursively.
    printDryRunCommand "find . -name .svn -exec rm -rf {} \;"
    find . -name .svn -exec rm -rf {} \;
}

function bjSvnExport()
{
    dirName="$(pfx noSeparator)"
    exportPath=${jbPatchesDir}/${dirName}
    if [ "$1" ]; then
        exportPath="$1"
    fi
    # Export Base from working directory.
    printDryRunCommand "svn export -q -r BASE . ${exportPath}"
    svn export -q -r BASE . ${exportPath}
}
