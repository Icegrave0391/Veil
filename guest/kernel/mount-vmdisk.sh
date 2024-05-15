#!/bin/bash -e

pushd ../ && source .env && popd 
./unmount-vmdisk.sh

# install the nbd module
sudo modprobe nbd max_part=8

# create a folder to load the vm image
if [ ! -d $VMDISKMOUNT ]
then
  mkdir -p $VMDISKMOUNT
fi

# connect the qcow2 image
sudo qemu-nbd --connect=/dev/nbd0 $VMDISK

# sync
sync

# install the root directory (it is partition 2 usually)
sudo fdisk /dev/nbd0 -l

# mount the simple drives
sudo mount /dev/nbd0p1 $VMDISKMOUNT
sudo mount /dev/nbd0p15 $VMDISKMOUNT/boot/efi

# sync
sync

# mount the /dev and /sys folders too. This is needed for update-grub command.
sudo mount -o bind /dev $VMDISKMOUNT/dev
sudo mount -o bind /dev/pts $VMDISKMOUNT/dev/pts
sudo mount -o bind /proc $VMDISKMOUNT/proc
sudo mount -o bind /run $VMDISKMOUNT/run
sudo mount -o bind /sys $VMDISKMOUNT/sys
