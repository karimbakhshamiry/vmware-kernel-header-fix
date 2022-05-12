#!/usr/bin/env bash
#This script solves the problem of missing linux headers while starting VMWare
#In some kali machines, VMWare does not start after updating it to it new version
#This script helps solve the problem easily, and starts the vmware services normally

set -e
echo ""
echo ""
echo "__________________________________________________________________"
echo "    	             	SWITCHING TO SUPERUSER                  "
echo "__________________________________________________________________"
sudo su

echo ""
echo ""
echo "__________________________________________________________________"
echo "			UPDATING AND INSTALLING HEADERS			"
echo "__________________________________________________________________"

sleep 2
#update & install kernel headers if not installed
apt update
apt install linux-headers-`uname -r`



echo ""
echo ""
echo "__________________________________________________________________"
echo "				CHANGING DIRECTORY			"
echo "__________________________________________________________________"

sleep 2
#changes the directory to source module of vmware
cd /usr/lib/vmware/modules/source



echo ""
echo ""
echo "__________________________________________________________________"
echo "				REMOVING OLD FILES			"
echo "__________________________________________________________________"

sleep 2
#removing old files if exist
if test -e vmnet-only; then rm -r vmnet-only; fi
if test -e vmmon-only; then rm -r vmmon-only; fi
if test -e vmmon.o; then rm vmmon.o; fi
if test -e vmnet.o; then rm vmnet.o; fi



echo ""
echo ""
echo "__________________________________________________________________"
echo "	     EXTRACTING AND WORKING WITH VMNET AND VMMON TAR FILES      "
echo "__________________________________________________________________"

sleep 2
#extracting the vmnet tarball and processing make file
tar xvf vmnet.tar

#copying missing files from gcc include directory 
cp /lib/gcc/x86_64-linux-gnu/11/include/stdarg.h /usr/lib/vmware/modules/source/vmnet-only/
cp /lib/gcc/x86_64-linux-gnu/11/include/stddef.h /usr/lib/vmware/modules/source/vmnet-only/

cd vmnet-only
make
cd ..

#extracting the evmmon tarball and process make file
tar xvf vmmon.tar

#copying missing files from gcc include directory 
cp /lib/gcc/x86_64-linux-gnu/11/include/stdarg.h /usr/lib/vmware/modules/source/vmmon-only/./include/
cp /lib/gcc/x86_64-linux-gnu/11/include/stddef.h /usr/lib/vmware/modules/source/vmmon-only/./include/

cd vmmon-only
make
cd ..



echo ""
echo ""
echo "_____________________________________________________________________"
echo "MOVING VMMON AND VMNET MAKE-PRODUCED FILES TO KERNEL MODULE DIRECTORY"
echo "_____________________________________________________________________"

if test -e /lib/modules/`uname -r`/misc; then rm -r /lib/modules/`uname -r`/misc; fi
sleep 2
#making a directory to copy transfer vmmon and vmnet make files to kernel module
mkdir /lib/modules/`uname -r`/misc
cp vmmon.o /lib/modules/`uname -r`/misc/vmmon.ko
cp vmnet.o /lib/modules/`uname -r`/misc/vmnet.ko



echo ""
echo ""
echo "__________________________________________________________________"
echo "  GENERATING A DEPENDENCAY MAP AND RESTARTING THE VMWARE SERVICE  "
echo "__________________________________________________________________"

sleep 2
#dependency issue solving and restarting the vmware services
depmod -a
/etc/init.d/vmware restart



echo ""
echo ""
echo "__________________________________________________________________"
echo "	     EXPORTING A LIBRARY PATH VARIABLE TO VMWARE BIN FILE	"
echo "__________________________________________________________________"

sleep 2
#adding the library path to vmware bin file
sed -i "11iexport LD_LIBRARY_PATH=/usr/lib/vmware/lib/libglibmm-2.4.so.1/:\$LD_LIBRARY_PATH" /usr/bin/vmware



echo ""
echo ""
echo "__________________________________________________________________"
echo "          REMOVING GARBAGES AND UNNECESSARY FILES                 "
echo "__________________________________________________________________"

sleep 2
#removing the garbage/extra files
rm -r /usr/lib/vmware/modules/source/vmnet-only
rm -r /usr/lib/vmware/modules/source/vmmon-only

echo ""
echo ""
echo "__________________________________________________________________"
echo "          EVERYTHING HAS BEEN SET UP SUCCESSFULLY                 "
echo "__________________________________________________________________"
