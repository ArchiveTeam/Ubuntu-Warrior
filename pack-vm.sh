#!/bin/bash

VMNAME="archiveteam-warrior-3.2"
OVA_OUT="archiveteam-warrior-v3.2-$( date +%Y%m%d ).ova"

VBoxManage modifyhd --compact archiveteam-warrior-3-sys.vdi

VBoxManage modifyvm $VMNAME --bioslogodisplaytime 0 --bioslogofadein off --bioslogofadeout off --boot1 disk --boot2 none --boot3 none --boot4 none --biosbootmenu disabled

VBoxManage storagectl $VMNAME --name "IDE Controller" --remove

VBoxManage export $VMNAME \
  --output $OVA_OUT \
  --vsys 0 \
  --product "ArchiveTeam Warrior" \
  --vendor "ArchiveTeam" \
  --vendorurl "http://www.archiveteam.org/" \
  --version "3.2"
