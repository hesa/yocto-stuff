#!/bin/bash

# SPDX-FileCopyrightText: 2021 Henrik Sandklef
#
# SPDX-License-Identifier: GPL-3.0-or-later

CURR_DIR=$(pwd)
POKY_GIT="https://git.yoctoproject.org/poky"
POKY_VERSION="poky-mickledore-4.2.1"
POKY_TAR_FILE="${POKY_VERSION}.tar.gz"
POKY_TAR="https://git.yoctoproject.org/poky/snapshot/${POKY_TAR_FILE}"



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
    echo "Installing required software"
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

    if [ "${POKY_GIT}" != "" ]
    then
        POKY_GIT="https://git.yoctoproject.org/cgit/cgit.cgi/poky/"
        git clone $POKY_GIT
        exit_on_error $? "git clone $POKY_GIT"
        
        cd poky
        exit_on_error $? "cd poky"
        
        git fetch --tags
        exit_on_error $? "git fetch --tags"

        git checkout tags/yocto-4.2.1 -b my-yocto-4.2.1
        exit_on_error $? "git checkout tags/yocto-4.2.1 -b my-yocto-4.2.1"

        cd -
    else
        if [ ! -f "${POKY_TAR_FILE}" ]
        then
            curl -LJO "${POKY_TAR}" 
            exit_on_error $? "curl -LJO ${POKY_TAR}" 
        fi
	
        tar zxvf "${POKY_TAR_FILE}"
        exit_on_error $? "tar xvf ${POKY_TAR_FILE}" 

	if [ ! -h poky ]
	then
            ln -s ${POKY_VERSION} poky
            exit_on_error $? "ln -s ${POKY_VERSION} poky"
	fi
    fi
    cd $CURR_DIR
}

to_conf()
{
    echo "$*" >> conf/local.conf 
}

prepare_build()
{
    pwd
    
    cd poky
    exit_on_error $? "cd poky"

    source oe-init-build-env
    exit_on_error $? "source oe-init-build-env"

    test -f conf/local.conf 
    exit_on_error $? "conf/local.conf present"

    EPIPHANY=$(grep -c epiphany conf/local.conf )
    if [ $EPIPHANY -eq 0 ]
    then
        to_conf "IMAGE_INSTALL:append = \" epiphany  \""
        to_conf "IMAGE_INSTALL:append = \" elfutils \""
        
        to_conf "INHERIT += \"archiver\""
        to_conf "ARCHIVER_MODE[src] = \"original\""
        
        to_conf "COPY_LIC_MANIFEST = \"1\""
        to_conf "COPY_LIC_DIRS = \"1\""
        to_conf "LICENSE_CREATE_PACKAGE = \"1\""
        
        to_conf "INHERIT += \"buildhistory\""
        to_conf "BUILDHISTORY_COMMIT = \"1\""
        to_conf "BUILDHISTORY_FEATURES = \"image\""
    else
        echo "misc stuff already added to conf"
    fi
}

build()
{
    bitbake core-image-minimal
    exit_on_error $? "bitbake core-image-minimal"
}

if [ "$1" == "--install-requirements" ]
then
    install_req
    shift
fi
if [ "$1" == "--no-git" ]
then
    POKY_GIT=""
    shift
fi

get_poky

prepare_build

build
