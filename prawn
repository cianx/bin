#!/usr/bin/env bash

mounted=`sudo dmsetup ls | grep prawn | cut -f1`
if [[ "$mounted" == "prawn" ]] ; then
  sudo umount /mnt/prawn
  sudo cryptsetup luksClose prawn
  echo "unmounted"
else
  sudo cryptsetup luksOpen /mnt/library/prawn.iso prawn
  sudo mount --source /dev/mapper/prawn --target /mnt/prawn
  echo "mounted"
fi

