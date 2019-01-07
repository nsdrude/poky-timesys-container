# Copyright (C) 2015-2016 Intel Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

FROM crops/yocto:ubuntu-16.04-base

USER root

ADD https://raw.githubusercontent.com/crops/extsdk-container/master/restrict_useradd.sh  \
        https://raw.githubusercontent.com/crops/extsdk-container/master/restrict_groupadd.sh \
        https://raw.githubusercontent.com/crops/extsdk-container/master/usersetup.py \
        /usr/bin/
COPY poky-entry.py poky-launch.sh /usr/bin/
COPY sudoers.usersetup /etc/

# We remove the user because we add a new one of our own.
# The usersetup user is solely for adding a new user that has the same uid,
# as the workspace. 70 is an arbitrary *low* unused uid on debian.
RUN userdel -r yoctouser && \
    groupadd -g 70 usersetup && \
    useradd -N -m -u 70 -g 70 usersetup && \
    chmod 755 /usr/bin/usersetup.py \
        /usr/bin/poky-entry.py \
        /usr/bin/poky-launch.sh \
        /usr/bin/restrict_groupadd.sh \
        /usr/bin/restrict_useradd.sh && \
    echo "#include /etc/sudoers.usersetup" >> /etc/sudoers

#Timesys
RUN \
  apt-get update && apt-get install -y automake binutils-dev bison build-essential bzip2 ecj fastjar flex gawk gconf2 \
    gettext gperf groff gtk-doc-tools guile-1.8 icon-naming-utils indent libc6-dev libdbus-glib-1-dev \
    libexpat1-dev libglade2-dev libgmp3-dev libgtk2.0-bin libgtk2.0-dev libmpfr-dev libncurses5-dev \
    libperl-dev libsdl1.2-dev libtool libusb-dev libxml-parser-perl lzop python-dev python-libxml2 ruby \
    scons sharutils swig texinfo texlive-extra-utils texlive-latex3 unzip wget x11-xkb-utils xfonts-utils zip zlib1g \
    lib32ncurses5 lib32z1 lib32z1-dev libc6-dev-i386 && \
    echo "dash dash/sh boolean false" | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash && \
    apt-get install -y libarchive-zip-perl

#Poky IMX6 - Sumo
#Per: http://variwiki.com/index.php?title=Yocto_Build_Release&release=RELEASE_SUMO_V1.0_VAR-SOM-MX6
RUN \
  apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib \
    build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
    xz-utils debianutils iputils-ping libsdl1.2-dev xterm \
    autoconf libtool libglib2.0-dev libarchive-dev python-git \
    sed cvs subversion coreutils texi2html docbook-utils python-pysqlite2 \
    help2man make gcc g++ desktop-file-utils libgl1-mesa-dev libglu1-mesa-dev \
    mercurial automake groff curl lzop asciidoc u-boot-tools dos2unix mtd-utils pv \
    libncurses5 libncurses5-dev libncursesw5-dev libelf-dev zlib1g-dev

#RUN \
#  git config --global url."http://git.yoctoproject.org/git".insteadOf git://git.yoctoproject.org && \
#  git config --global url."https://github.com/".insteadOf git@github.com: && \
#  git config --global url."https://".insteadOf git://

RUN \
  apt-get install -y sshuttle

#RUN \
#  apt-get install -y icecc

#For xxd
RUN \
 apt-get install -y vim-common

#Atmel A5
apt-get install -y \
gcc-arm-linux-gnueabi

RUN \
sudo apt-get install -y \
kpartx u-boot-tools gcc-arm-linux-gnueabihf gcc-aarch64-linux-gnu \
device-tree-compiler android-tools-fsutils curl bc

USER usersetup
ENV LANG=en_US.UTF-8

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/usr/bin/poky-entry.py"]
