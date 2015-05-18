#!/bin/bash

userName=""
userEmail=""

function usage()
{
    echo "You can run this script by running below command"
    echo "bash <(curl -s --location https://raw.githubusercontent.com/bijayrungta/utility-scripts/master/githubSetup.sh)"
    echo "bash githubSetup.sh"
}

function doValidateName()
{
    IFS=" "
    set -- $userName
    lastname="$2"
    if  [[ $userName = *[[:space:]]* &&  ${userName:0:1} =~ ^[A-Z] &&  ${lastname:0:1} =~ ^[A-Z] ]] ; then
        echo "username is ok"
    else
        printf "ERROR !! NOTE :\n a. Name should be your firstname and lastname with space \n b. First character of firstname and lastname should be capital\n"
        exit
    fi
}

function doValidateEmail()
{
    emailEntered="$1"
    IFS="@"
    set -- $userEmail
    if [ "${#@}" -ne 2 ]; then
        printf "ERROR !! NOTE : \n please enter your jabong.com email id"
        exit
    fi
    domain="$2"
    if [ "$domain" = "jabong.com" ] ; then
        ok="email-id is ok"
    else
        printf "ERROR !! NOTE : \n please enter your jabong.com email id"
        exit
    fi
}

function doGenerateSshKeys()
{
    cd ~/.ssh
    echo "Generating SSH Keys for User '${userEmail}'. !!!Press Enter when prompted for Passphrase!!!"
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
        doValidateName
        git config --global user.name "${userName}"
    fi
    if [ "${userEmail}" = "" ]; then
        printf "Enter your email: "
        read userEmail
        doValidateEmail
        git config --global user.email "${userEmail}"
    fi
    echo ${separator}
    echo "User Information: Name: ${userName}; Email: ${userEmail}"
}

function initSetup()
{
    originalDir=$(pwd)
    echo ${separator}
    echo 'Welcome!! This script will help you get started with Development with GitHub'.
    echo "Create the SSH Directory if it doesn't exist"
    mkdir -p ~/.ssh

    doCaptureUserInfo

    if [ ! "${userName}" -o ! "${userEmail}" ]; then
        echo 'Can not proceed without name or email'
        exit;
    fi
}

function runSetup()
{
    initSetup "$@"

    if [ ! -f ~/.ssh/id_rsa ]; then
        doGenerateSshKeys
    else
        echo "You already have a SSH Key in your Home"
        doPublishSshKeys
    fi

    doDownloadRepository

    echo "Go back to Original Directory"
    cd ${originalDir}
}


function doDownloadRepository()
{
    echo ${separator}
    echo "Please contact the Repository maintainer to provide you access to Project Repository that you need to work on!"
}
separator="#########################################################################"
# operation="$1"

runSetup "$@"
