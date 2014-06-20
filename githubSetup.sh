#!/bin/bash
sudo apt-get install git
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
    cd ~/.ssh
    echo "Generating SSH Keys for User '${userEmail}'. !!!Press Enter when prompted for Passphrase!!!"
    ssh-keygen -t rsa -C "${userEmail}" -f id_rsa
    ssh-add ~/.ssh/id_rsa
    doPublishSshKeys
}

function First_and_lastNameValidation()
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

function emailValidation()
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
        echo "email-id is ok"
    else
        printf "ERROR !! NOTE : \n please enter your jabong.com email id"
        exit
    fi
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
	First_and_lastNameValidation
        git config --global user.name "${userName}"
    fi
    if [ "${userEmail}" = "" ]; then
        printf "Enter your email: "
        read userEmail
	emailValidation
        git config --global user.email "${userEmail}"
    fi
    echo ${separator}
    echo "User Information: Name: ${userName}; Email: ${userEmail}"
}

function initSetup()
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
    echo "Downloading Repository from LAN. This will work only if you are on LAN"
    tempPath="/home/`whoami`/projects/$(date +%Y-%m-%d_%H-%M-%S)"
    mkdir -p ${tempPath}
    curl -o ${tempPath}/INDFAS.tar.bz2 "http://172.18.0.43/download/git-repository/INDFAS.tar.bz2"
    cd ${tempPath}
    tar pxjf INDFAS.tar.bz2
    cd INDFAS
    git fetch origin
    git reset --hard FETCH_HEAD
    git pull origin master
    echo "Fix permissions for directories."
    bash tools/initRepo.sh

    if [ -d ~/projects/INDFAS ]; then
        echo "You seem to already have a setup at ~/projects/INDFAS. Please move this Directory if you want to start afresh"
        echo "Latest Repository has been downloaded into a folder ${tempPath} and can be used for an additional setup."
    else
        mkdir -p ~/projects
        mv ${tempPath}/INDFAS ~/projects/
        rm -fR ${tempPath}
        echo "Your repository is all set at location ~/projects/INDFAS"
    fi
    echo "!!!!!!!!!!!!! CONGRATULATIONS, you are all set. !!!!!!!!!!!!!!!"
    echo ${separator}
}

separator="#########################################################################"
# operation="$1"

runSetup "$@"
