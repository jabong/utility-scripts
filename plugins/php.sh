#!/bin/bash

# Binary Paths
PHPF=${HOME}/codebase/www/tools/phpformatter/release/phpf
bjBinaryPhpStorm=/usr/local/bin/pstorm

alias phpi='php -i'
alias phpis='phpi | grep -E '

# alias php-cs-fixer="${bjHomeDir}/.composer/vendor/fabpot/php-cs-fixer/php-cs-fixer"

function grepphp()
{
    grep --include=*.php $1 *
}

function bjInitEditPhpSettings()
{
    if ${isMac}; then
        mkdir ${bashLibDir}/settings/${bjUserSettingsDir}/etc
        cp /private/etc/php.ini ${bashLibDir}/settings/${bjUserSettingsDir}/etc/php.ini
    else
        mkdir ${bashLibDir}/settings/${bjUserSettingsDir}/etc/php5/cli
        mkdir ${bashLibDir}/settings/${bjUserSettingsDir}/etc/php5/apache2
        cp /etc/php5/cli/php.ini ${bashLibDir}/settings/${bjUserSettingsDir}/etc/php5/cli/php.ini
        cp /etc/php5/apache2/php.ini ${bashLibDir}/settings/${bjUserSettingsDir}/etc/php5/apache2/php.ini
    fi
    printInfo "PHP Config Files copied for editing."
}

function bjUpdatePhpSettings()
{
    printHeader "Updating PHP Settings.."
    if ${isMac}; then
        sudo cp ${bashLibDir}/settings/${bjUserSettingsDir}/etc/php.ini /private/etc/php.ini
    else
        sudo cp ${bashLibDir}/settings/${bjUserSettingsDir}/etc/php5/cli/php.ini /etc/php5/cli/php.ini
        sudo cp ${bashLibDir}/settings/${bjUserSettingsDir}/etc/php5/apache2/php.ini /etc/php5/apache2/php.ini
        bjRestartApache
    fi
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


#####################
# Framework related #
#####################

# Seagull PHP Framework.
function emailq()
{
    php ~/www/index.php \
        --moduleName=emailqueue \
        --managerName=emailqueue \
        --action=process \
        --deliveryDate=all --limit=1
}

