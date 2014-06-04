#!/bin/bash

# Exim Aliases
alias bjexiclean='echo "Removing all mails with no sender set"; exiqgrep -f "^<>$" -i | xargs exim -Mrm'
alias bjexifrozen='exiqgrep -z -i | xargs exim -Mrm'
alias bjexiqueue='exim -bp > $dumpdir/exim/queue_all; less $dumpdir/exim/queue_all'
