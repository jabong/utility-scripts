#!/bin/bash

##
# Shell Script for Bash Aliases loaded on Shell startup through ~/.bash_profile
#
# LICENSE
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# @copyright    Copyright (c) 2005-2014 Bijay Rungta http://bijayrungta.com
# @license      http://www.gnu.org/licenses/gpl-2.0.html GNU GENERAL PUBLIC LICENSE
##

##
# This file should be copied to Home folder for your Mac/Linux Machine as ~/.bash_aliases
# Alternatively, you can keep this in a different path and load this on demand as
# source /path/to/this/file
##

bjHomeDir=$HOME
bjProjectCode=ws
isNative=true
isMac=true      # Set this to false if it's not a Mac.
isGuestOS=false

# If it's a Guest OS on Virtual Machine, give the name.
# guestHostName="ubuntu-13"

function bjp()
{
    if [ -f ${bjHomeDir}/lib/bash/bash_aliases_common.sh ]; then
        . ${bjHomeDir}/lib/bash/bash_aliases_common.sh
    elif [ -f ~/lib/bash/bash_aliases_common.sh ]; then
        . ~/lib/bash/bash_aliases_common.sh
    fi

    if [ -f ${bjHomeDir}/lib/bash/bash_aliases_${bjProjectCode}.sh ]; then
        . ${bjHomeDir}/lib/bash/bash_aliases_${bjProjectCode}.sh
    elif [ -f ~/lib/bash/bash_aliases_${bjProjectCode}.sh ]; then
        . ~/lib/bash/bash_aliases_${bjProjectCode}.sh
    fi
}

# Comment it if you don't want to load the Scripts automatically
bjp
