#!/bin/bash

##
# Bash Aliases to make git operations less painful
##

function bjGitInfo()
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

function bjGitCommit()
{
    git commit -a -m "$1"
}

function bjGitStatus()
{
    git status
}

function bjGitPush()
{
    git push
}

function bjGitRemoveObsoleteBranches()
{
    # Prune References to removed Remote Branches.
    git remote prune origin
}

function bjGitDiff()
{
    git diff "$@" > /tmp/gitDiff.diff
    previewSyntax /tmp/gitDiff.diff
}

function bjGitApplyPatch()
{
    # @see https://ariejan.net/2009/10/26/how-to-create-and-apply-a-patch-with-git/
    patchFile=$1;
    echo "Applying patch ${patchFile} to Current Dir";
    if [ ! -f "${patchFile}" ]; then
        printInfo "Patch does not exist."
        return;
    fi
    printDryRunCommand "git apply patch -p0 ${patchFile}"
    git apply --stat ${patchFile}
}

function bjGitAddEmptyFolder()
{
    filePath=$(bjFilePath "$@")
    mkdir -p "${filePath}"
    cp ${bashLibDir}/settings/templates/git/.gitignore-emptyFolder "${filePath}/.gitignore"
}

function bjGitSyncUpstream()
{
    # @see https://help.github.com/articles/syncing-a-fork
    # git remote -v
    # git remote add upstream https://github.com/octocat/repo.git
    # git remote -v
    git fetch upstream
    git branch -va
    git checkout master
    git merge upstream/master
    git push origin
}
