#!/bin/bash

# SPDX-FileCopyrightText: 2021 Henrik Sandklef
#
# SPDX-License-Identifier: GPL-3.0-or-later

exit_on_error()
{
    RET=$1
    if [ $RET -ne 0 ]
    then
        echo "ERROR: $2"
        exit $RET
    fi
}

#
# find settings
#
yoga -i core-image-minimal -cc
exit_on_error $? "yoga -i core-image-minial -cc"

#
# run yoga
#
yoga -ncc
exit_on_error $? "yoga -ncc"


