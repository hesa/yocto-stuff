#!/bin/bash

# SPDX-FileCopyrightText: 2021 Henrik Sandklef
#
# SPDX-License-Identifier: GPL-3.0-or-later

CURR_DIR=$(pwd)

exit_on_error()
{
    RET=$1
    if [ $RET -ne 0 ]
    then
        echo "ERROR: $2"
        exit $RET
    fi
}

install_req()
{
    sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 xterm python3-subunit mesa-common-dev
    exit_on_error $? "apt-get install"
}


get_poky()
{
    if [ -d poky ]
    then
        echo poky dir already exists
        return
    fi
    
    git clone git://git.yoctoproject.org/poky
    exit_on_error $? "git clone git://git.yoctoproject.org/poky"

    cd poky
    exit_on_error $? "cd poky"

    git fetch --tags
    exit_on_error $? "git fetch --tags"

    git checkout tags/yocto-3.2.2 -b my-yocto-3.2.2
    exit_on_error $? "git checkout tags/yocto-3.2.2 -b my-yocto-3.2.2"

    cd -

    cd $CURR_DIR
}

to_conf()
{
    echo "$*" >> conf/local.conf 
}

prepare_build()
{
    cd poky
    exit_on_error $? "cd poky"

    source oe-init-build-env
    exit_on_error $? "source oe-init-build-env"

    test -f conf/local.conf 
    exit_on_error $? "conf/local.conf present"


    EPIPHANY=$(grep -c epiphany conf/local.conf )
    if [ $EPIPHANY -eq 0 ]
    then
        to_conf "IMAGE_INSTALL_append = \" epiphany  \""
        to_conf "IMAGE_INSTALL_append = \" elfutils \""
        
        to_conf "INHERIT += \"archiver\""
        to_conf "ARCHIVER_MODE[src] = \"original\""
        
        to_conf "COPY_LIC_MANIFEST = \"1\""
        to_conf "COPY_LIC_DIRS = \"1\""
        to_conf "LICENSE_CREATE_PACKAGE = \"1\""
        
        to_conf "INHERIT += \"buildhistory\""
        to_conf "BUILDHISTORY_COMMIT = \"1\""
        to_conf "BUILDHISTORY_FEATURES = \"image\""
#INHERIT += "doubleopen"

    else
        echo "misc stuff already added to conf"
    fi
}

build()
{
    bitbake core-image-minimal
    exit_on_error $? "bitbake core-image-minimal"
}

install_req

get_poky

prepare_build

build

