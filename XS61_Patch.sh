## Xenserver 6.1 Patch Script
## By Julian Valbuena
## Ninefold.com
## Installs XenServer Patches for you
## 
## 
## Usage:  xs61_patch.sh  [HOSTNAME] [PWD] [PATCH] [UUID] [NAMELABEL] [NFS] [ACTION]
## Must specify an action, available options: [ install, mountnfs, delete ]
## Find out what the secondary storage is for your server and use it in the NFS entry, i.e. ic1z1prjnss001.easyhost.local
## patches will only be looked for on directory /volumes/pool0/XS61_Patches
## chmod o+x /usr/local/sbin/xs61_patch.sh

#!/bin/bash

HOSTNAME=$1
PWD=$2
PATCH=$3
UUID=$4
NAMELABEL=$5
NFS=$6
ACTION=$7
PATCH_DIR='/volumes/pool0/XS61_Patches'

print_help() {
    echo "Usage: xs61_patch.sh [HOSTNAME] [PWD] [PATCH] [UUID] [NAMELABEL] [NFS] [ACTION]"
	echo "NFS - FQDN or IP of the NFS server in which patches are stored"
	echo "ACTION - possible actions: install | mountnfs | cleanup | install_hpsa | replace_NFSSR "
    echo "eg  xs61_patchx.sh install"
    exit 0
}

install_patch() {
	if [ -f /mnt/$PATCH ]
		then
		# Patching like a boss
		xe patch-upload -s $HOSTNAME -u root -pw $PWD file-name=/mnt/$PATCH
		xe patch-pool-apply uuid=$UUID
		AFTERAPPLY=`xe patch-list -s $HOSTNAME -u root -pw $PWD name-label=$NAMELABEL |grep after-apply-guidance | awk -F ':' '{print $2}'`
		if [ "$AFTERAPPLY" == 'restartXAPI' ]
			then
				xe-toolstack-restart
				exit 0;
			else
				echo no XAPI restart needed
			fi	
		else
			mount_dir
		fi
}

mount_dir() {
	echo Need to mount patching directory... please be patient...
	mount -t nfs $NFS:$PATCH_DIR /mnt
	echo you will need to run xs61_patch.sh again or make sure your patch is on the NFS server and that the arguments are correct.
	exit 4;
}

install_hpsa() {
    mkdir -p /mnt/tmp
    mount /mnt/hpsa.iso /mnt/tmp/ -o loop,ro
    cd /mnt/tmp/
    ./install.sh
}

# This one only applies to Cloudstack 3.6.x, patching replaces NFSSR.py, CloudStack needs this replaced by it's own script.
replace_NFSSR() {
    echo  'fixing issue with NFSSR.py copying the correct version from /usr/lib64/cloud/agent/scripts/vm/hypervisor/xenserver/xenserver60/NFSSR.py'
    cp -uf /mnt/NFSSR.py /opt/xensource/sm/NFSSR.py
}

cleanup() {
	echo Not quite there yet
	exit 0;
}

while test -n "$7"; do
    case "$7" in
        --help|-h)
            print_help
            exit 0
            ;;
        install)
           mode=install
           shift
           ;;
        mountnfs)
            mode=mountnfs
            shift
            ;;
        install_hpsa)
            mode=install_hpsa
            shift
            ;;
        replace_NFSSR)
            mode=replace_NFSSR
            shift
            ;;
        cleanup)
            mode=cleanup
            shift
            ;;
        *)
            echo "Unknown Argument: $7"
            print_help
            exit 3
            ;;
    esac
    shift
done

case $mode in
     install)
	install_patch
     ;;
    
     mountnfs)
	mount_dir
     ;;

     replace_NFSSR)
    replace_NFSSR
     ;;

     install_hpsa)
    install_hpsa
     ;;

     cleanup)
        cleanup
     ;;
     *)
	echo "Error: Unknown operations mode"
         print_help
        exit 3;
esac