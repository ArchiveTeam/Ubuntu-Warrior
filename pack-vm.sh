#!/bin/bash

VMNAME="archiveteam-warrior-3"
OVA_OUT="archiveteam-warrior-v3-$( date +%Y%m%d ).ova"

VBoxManage modifyhd --compact archiveteam-warrior-3-sys.vdi

VBoxManage export $VMNAME \
  --output $OVA_OUT \
  --vsys 0 \
  --product "ArchiveTeam Warrior" \
  --vendor "ArchiveTeam" \
  --vendorurl "http://www.archiveteam.org/" \
  --version "3"
