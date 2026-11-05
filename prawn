#!/usr/bin/env bash

ISO_PATH=/home/cian/Dropbox/Backups/kane/prawn.iso
ls ${ISO_PATH}

mounted=`sudo dmsetup ls | grep prawn | cut -f1`
if [[ "$mounted" == "prawn" ]] ; then
  sudo umount /mnt/prawn
  sudo cryptsetup luksClose prawn
  echo "unmounted"
else
  sudo cryptsetup luksOpen ${ISO_PATH} prawn
  sudo mount --source /dev/mapper/prawn --target /mnt/prawn
  echo "mounted"
fi

