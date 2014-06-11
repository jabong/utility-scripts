#!/bin/bash

################################
# To fix execute this command: #
# source tools/jbUtilities.sh  #
# jbPhpFixAll                  #
################################
function jbPhpFixAll()
{
    startTime="$(date +%H-%M-%S)"

    jbPhpCsFixers=(
        linefeed
        indentation
        trailing_spaces
        visibility
        braces
        extra_empty_lines
        function_declaration
        controls_spaces
        include
        eof_ending
    )
    jbPathsToFix=(
        "alice/alice"
        "bob/public/js"
        "bob/application"
        "bob/cli"
        "bob/public"
        "bob/tests"
        "bob/library/Bob"
        "bob/library/BobTest"
        "bob/library/functions"
        "library/Rocket"
        "payment_jabong"
        "shared"
    )

    for pathToFix in "${jbPathsToFix[@]}"
    do
        :
        echo "Will Fix for Path ${pathToFix}"

        for fixer in "${jbPhpCsFixers[@]}"
        do
            :
            echo "Will Fix for directory '${pathToFix}' with Fixer '${fixer}'"
            jbRunPhpFixer ${pathToFix} ${fixer}
            # do whatever on $i
        done
        echo "Fixed for Path ${pathToFix}"
    done
}

function jbRunPhpFixer()
{
    fixOptions=""
    pathToFix='.'
    if [ "$1" ]; then
        pathToFix="$1"
    fi
    fixer=linefeed
    if [ ! -z "$2" ]; then
        fixer="$2"
    fi
    if [ ! -z "$3" ]; then
        fixOptions="${fixOptions} --diff"
    fi
    if [ ! -z "$4" ]; then
        fixOptions="${fixOptions} --dry-run"
    fi
    echo "Will fix the operation for directory: ${pathToFix} using fixer ${fixer} with opetions as ""${fixOptions}"""

    if [ -e "${pathToFix}" ]; then
        echo "Will fix the directory ${pathToFix}, Patch would be saved at ${fixDiffPath}"
        # Print the Command to be run;
        cat << HEREDOC
php-cs-fixer fix \
    --fixers=${fixer} \
    ${pathToFix}
HEREDOC

php-cs-fixer fix \
    --fixers=${fixer} \
    ${pathToFix}
        echo "Done with Fix for directory '${pathToFix}' with opetions as '${fixOptions}'"
    else
        echo "Not a File or Directory."
    fi
}
