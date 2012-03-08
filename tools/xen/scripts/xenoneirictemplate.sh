#!/bin/bash
## makeubuntu.sh, this creates Ubuntu server 11.10 32 and 64 bit templates
## on Xenserver 6.0.2 Net install only
## Original Author: David Markey <david.markey@citrix.com>
## Author: Renuka Apte <renuka.apte@citrix.com>
## This is not an officially supported guest OS on XenServer 6.02

LENNY=$(xe template-list name-label=Debian\ Lenny\ 5.0\ \(32-bit\) --minimal)

if [[ -z $LENNY ]] ; then
    echo "Cant find lenny 32bit template, is this on 6.0.2?"
    exit 1
fi

distro="Ubuntu 11.10"
arches=("32-bit" "64-bit")


for arch in ${arches[@]} ; do
    echo "Attempting $distro ($arch)"
    if [[ -n $(xe template-list name-label="$distro ($arch)" params=uuid --minimal) ]] ; then
        echo "$distro ($arch)" already exists, Skipping
    else

        NEWUUID=$(xe vm-clone uuid=$LENNY new-name-label="$distro ($arch)")
        xe template-param-set uuid=$NEWUUID other-config:install-methods=http,ftp \
         other-config:install-repository=http://archive.ubuntu.net/ubuntu \
         PV-args="-- quiet console=hvc0 partman/default_filesystem=ext3 locale=en_US console-setup/ask_detect=false keyboard-configuration/layoutcode=us netcfg/choose_interface=eth3 netcfg/get_hostname=unassigned-hostname netcfg/get_domain=unassigned-domain auto url=http://images.ansolabs.com/devstackubuntupreseed.cfg" \
         other-config:debian-release=oneiric \
         other-config:default_template=true

        if [[ "$arch" == "32-bit" ]] ; then
            xe template-param-set uuid=$NEWUUID other-config:install-arch="i386"
        else
            xe template-param-set uuid=$NEWUUID other-config:install-arch="amd64"
        fi
        echo "Success"
    fi
done

echo "Done"
