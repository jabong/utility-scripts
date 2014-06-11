#!/bin/bash

userName=""
userEmail=""

function usage()
{
    echo "You can run this script by running below command"
    echo "wget https://raw.githubusercontent.com/bijayrungta/utility-scripts/master/githubSetup.sh"
    echo "bash githubSetup.sh"
}

function doGenerateSshKeys()
{
    echo "Generating SSH Keys. Press Enter when prompted for Passphrase."
    ssh-keygen -t rsa -C "${userEmail}" -f id_rsa
    ssh-add ~/.ssh/id_rsa
    doPublishSshKeys
}

function doPublishSshKeys()
{
    echo "Install xclip if Ubuntu"
    sudo apt-get install xclip
    xclip -sel clip < ~/.ssh/id_rsa.pub

    echo ${separator}
    echo "## Please visit the link below to Add your SSH key to GitHub"
    echo "## https://github.com/settings/ssh"
    echo "## https://help.github.com/articles/generating-ssh-keys#step-3-add-your-ssh-key-to-github"
    echo ${separator}
}

function doCaptureUserInfo()
{
    echo "Set Global GIT Config for User name and Email if not set already"
    userName="$(git config --global user.name)"
    userEmail="$(git config --global user.email)"
    if [ "${userName}" = "" ]; then
        printf "Enter your Full Name: "
        read userName
        git config --global user.name "${userName}"
    fi
    if [ "${userEmail}" = "" ]; then
        printf "Enter your email: "
        read userEmail
        git config --global user.email "${userEmail}"
    fi
}

function runSetup()
{
    originalDir=$(pwd)
    echo ${separator}
    echo 'Welcometo Jabong!! This script will help you get started with Development for Jabong'.
    echo "Create the SSH Directory if it doesn't exist"
    mkdir -p ~/.ssh

    doCaptureUserInfo

    if [ ! "${userName}" -o ! "${userEmail}" ]; then
        echo 'Can not proceed without name or email'
        exit;
    fi

    if [ ! -f ~/.ssh/id_rsa ]; then
        doGenerateSshKeys
    else
        echo "You already have a SSH Key in your Home"
        doPublishSshKeys
    fi

    echo "Go back to Original Directory"
    cd ${originalDir}
}

separator="#########################################################################"

runSetup

