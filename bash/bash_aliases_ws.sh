#!/bin/bash

# Load Desktop specific aliases if available.
if ${isMac}; then
    # It's a Mac

    if [ -f "${bjHomeDir}/lib/bash/desktop_aliases.sh" ]; then
        source ${bjHomeDir}/lib/bash/desktop_aliases.sh
    fi
fi

# Determine if I am on Mac or Linux.
homeDirContainer=`dirname ${HOME}`
macHomeDirContainer='/Users'
bjUserSettingsDir=ubuntu-13
if [ "${homeDirContainer}" = "${macHomeDirContainer}" ]; then
    isMac=true
fi

###########################
## Variable Declarations ##
###########################
bjEditor=vim

bjUASamsungNote="Mozilla/5.0 (Linux; U; Android 2.3; en-us; SAMSUNG-SGH-I717 Build/GINGERBREAD) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"
bjUAFirefoxDesktop="Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.64 Safari/537.31"

####################
## Simple Aliases ##
####################
alias bjDiff="diff -Naur"
alias bjCheat='less ~/cheat'
alias bjchki='ping google.com -c 3'

function bjImportLibraries()
{
    if [ -f ${bashLibDir}/load.list ]; then
        for fileName in $(cat ${bashLibDir}/load.list)
        do
            filePath=${bashLibDir}/${fileName}.sh
            if [ -f ${filePath} ]; then
                source ${filePath}
            fi
        done
    fi

    for projectDir in ${bjHomeDir}/lib/bash/projects/*;
        do
            # echo "Checking and loading ${projectDir}/bash_aliases_ws.sh"
            if [ -f "${projectDir}/bash_aliases_ws.sh" ]; then
                . "${projectDir}/bash_aliases_ws.sh"
            fi

            if [ -f "${projectDir}/bash_aliases_common.sh" ]; then
                . "${projectDir}/bash_aliases_common.sh"
            fi
        done
}

function bjSendCurlRequests()
{
    folderName=`pfx noSeparator`
    responseFolderPath=${bjHomeDir}/tmp/curl/response/${folderName}
    url=$1
    hostAddress=$2
    numIterations=$3
    includeAkamaiHeaders=$4
    sendMobileUA=$5
    akamaiHeaders=''
    akamaiHeadersRaw="$(bjGetAkamaiPragmaHeaders)"
    userAgentHeadersRaw="${bjUAFirefoxDesktop}"
    if [ -z ${url} ] ; then
        url="http://www.jabong.com/whetever/men/";
    fi
    if [ -z ${hostAddress} ] ; then
        hostAddress=$(bjHostName ${url})
    fi
    if [ -z ${numIterations} ] ; then
        numIterations=3;
    fi
    if [ ! -z ${includeAkamaiHeaders} ] ; then
        akamaiHeaders="-H \"Pragma: ${akamaiHeadersRaw}\""
    fi
    if [ ! -z ${sendMobileUA} ] ; then
        userAgentHeadersRaw="${bjUASamsungNote}"
    fi
    userAgentHeaders="-H \"User-Agent: ${userAgentHeadersRaw}\""

    mkdir -p ${responseFolderPath};
    printHeader "Send Curl Requests. Response will be stored in ${responseFolderPath}"
    printRaw "Url to fetch: ${url}"
    printRaw "Host Name: ${hostAddress}"

    for ((i=1; i<=${numIterations}; i++))
    do
        outputFile=${responseFolderPath}/response-${i}.html
        printHeader "Iteration $i for Url: ${url}"
        printRaw "Output to be stored at: ${outputFile}"
        printInfo "Command to be run"
        cat << HEREDOC
            curl --include --insecure --silent --show-error \\
            --output ${outputFile} \\
            --dump-header /dev/stdout \\
            --compressed \\
            -H "Pragma: ${akamaiHeadersRaw}" \\
            -H "User-Agent: ${userAgentHeadersRaw}" \\
            -H "Host: ${hostAddress}" \\
            -H "Accept-Encoding: gzip,deflate,sdch" \\
            -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \\
            -H "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3" \\
            -H "Accept-Language: en-US,en;q=0.8" \\
            -H "Cache-Control: no-cache" \\
            -H "Connection: keep-alive" \\
            "${url}"
HEREDOC
        printSeparator

        # Run the Command
        curl --include --insecure --show-error \
            --output ${outputFile} \
            --dump-header /dev/stdout \
            --compressed --verbose \
            -H "Pragma: ${akamaiHeadersRaw}" \
            -H "Host: ${hostAddress}" \
            -H "User-Agent: ${userAgentHeadersRaw}" \
            -H "Accept-Encoding: gzip,deflate,sdch" \
            -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
            -H "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3" \
            -H "Accept-Language: en-US,en;q=0.8" \
            -H "Cache-Control: no-cache" \
            -H "Connection: keep-alive" \
            "${url}"
        echo "$(wc -c ${outputFile}) Bytes received"
    done
    printInfo "Done with sending ${numIterations} Curl Requests. Response stored in ${responseFolderPath}"
    ls ${responseFolderPath}
    printSeparator
}

function bjSendAkamaiRequests()
{
    folderName=`pfx -e`
    url=$1
    if [ -z ${url} ] ; then
        url="http://www.google.com/";
    fi
    numIterations=$2
    if [ -z ${numIterations} ] ; then
        numIterations=3;
    fi
    mkdir -p ~/tmp/jabong/response/${folderName};
    for ((i=1; i<=${numIterations}; i++))
    do
        echo ${strSeparator}
        echo "Iteration $i for Url: ${url}"
        echo ${strSeparator}
        outputFile=~/tmp/jabong/response/${folderName}/response-${i}.html
        curl -m 10 -D - -o /dev/null -s \
            -H "Accept-Encoding: gzip,deflate,sdch" \
            -H "Pragma: akamai-x-get-cache-key" \
            -H "Pragma: akamai-x-cache-on" \
            -H "Pragma: akamai-x-cache-remote-on" \
            -H "Pragma: akamai-x-get-true-cache-key" \
            ${url};
        echo "`wc -c ${outputFile}` Bytes received"
    done
    echo "Response stored in ~/tmp/curl/response/${folderName}"
}

################################################################################
############################### System Settings ################################
################################################################################
function showHostsFile()
{
    less /etc/hosts
}

function updateHostsFile()
{
    hostsFilesDir=${bashLibDir}/settings/hosts
    if ${isMac}; then
        nativeHostsFile=hosts-mac.txt
    else
        nativeHostsFile=hosts-${guestHostName}.txt
    fi

    if [ ! -f ${hostsFilesDir}/${nativeHostsFile} ]; then
        printInfo "Hosts File doesn't exist at ${hostsFilesDir}/${nativeHostsFile}"
    fi

    printInfo "Prepare Hosts File Native Settings; cat ${hostsFilesDir}/${nativeHostsFile} > ${hostsFilesDir}/hosts-tmp.txt"
    cat ${hostsFilesDir}/${nativeHostsFile} > ${hostsFilesDir}/hosts-tmp.txt
    printInfo "Prepare Hosts File Common Settings; cat ${hostsFilesDir}/hosts-common.txt >> ${hostsFilesDir}/hosts-tmp.txt"
    cat ${hostsFilesDir}/hosts-common.txt >> ${hostsFilesDir}/hosts-tmp.txt

    printInfo "Take Backup of Active Hosts File"
    cp /etc/hosts ${hostsFilesDir}/$(pfx)${nativeHostsFile}

    printInfo "Copy prepared file to /etc/hosts; sudo cp ${bashLibDir}/settings/hosts-tmp.txt /etc/hosts"
    sudo cp ${hostsFilesDir}/hosts-tmp.txt /etc/hosts
    printInfo "Done"
    showHostsFile
}

function bjLoadMigrationTools()
{
    source ${bashLibDir}/migrateSystem.sh
}

function bjUpdateUserSettings()
{
    alias diffProgram="diff -Naur"
    isDryRun=true
    if [ ! -z "$1" ]; then
        isDryRun=false
    fi
    diffPath=/tmp/$(pfx)settings.diff
    printStatus "Update User Settings for other OS: ${bjUserSettingsDir}"
    for fileName in ${bashLibDir}/settings/home/${bjUserSettingsDir}/_*.sh
    do
        destinationFileName=$(bjFileName ${fileName})
        destinationFileName=${destinationFileName#*_}
        logMessage "$(diffProgram ${bjHomeDir}/.${destinationFileName} ${fileName})" ${diffPath}
        printDryRunCommand "cp ${fileName} ${bjHomeDir}/.${destinationFileName}"
        if ! ${isDryRun} ; then
            printDryRunCommand "cp ${fileName} ${bjHomeDir}/.${destinationFileName}"
            cp ${fileName} ${bjHomeDir}/.${destinationFileName}
        fi
    done
    printInfo "Done. Diff created at ${diffPath}"
    previewSyntax ${diffPath}
}

function bjUpdateApache24Settings()
{
    ${bashLibDir}/settings/apache2.4/conf-available
    sudo cp ${bashLibDir}/settings/php5/cli/php.ini /etc/php5/cli/php.ini
    sudo cp ${bashLibDir}/settings/php5/apache2/php.ini /etc/php5/apache2/php.ini
    bjRestartApache
}

function runTutorial()
{
    echo "OPTIND starts at ${OPTIND}"
    while getopts "pq:" optname
    do
        case "${optname}" in
        "p")
            echo "Option ${optname} is specified"
            ;;
        "q")
            echo "Option ${optname} has value ${OPTARG}"
            ;;
        "?")
            echo "Unknown option ${OPTARG}"
            ;;
        ":")
            echo "No argument value for option ${OPTARG}"
            ;;
        *)
        # Should not occur
            echo "Unknown error while processing options"
            ;;
        esac
        echo "optname is ${optname}"
        echo "OPTIND is now ${OPTIND}"
    done
}


##
# MUST BE AT THE END OF FILE AS last STATEMENT.
# Import Accounts based Aliases and Functions Library.
bjImportPlugins

