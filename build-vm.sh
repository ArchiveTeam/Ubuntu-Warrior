#!/bin/bash

VMNAME="archiveteam-warrior-3.1"
INSTALL_ISO="alpine-virt-3.6.2-x86_64.iso"

VBoxManage createvm --name $VMNAME --ostype Linux_64 --register
VBoxManage modifyvm $VMNAME \
  --memory 400 \
  --vram 1 \
  --acpi on \
  --ioapic on \
  --cpus 1 \
  --rtcuseutc on \
  --cpuhotplug off \
  --pae on \
  --hwvirtex on \
  --nestedpaging on \
  --largepages off \
  --accelerate3d off \
  --nic1 nat \
  --nictype1 82540EM \
  --natpf1 "Web interface,tcp,127.0.0.1,8001,,8001" \
  --audio none \
  --clipboard disabled \
  --usb off \
  --usbehci off \
  --mouse ps2 \
  --keyboard ps2 \
  --biosbootmenu menuonly

VBoxManage storagectl $VMNAME --name "SATA Controller" --add sata
VBoxManage createhd --filename archiveteam-warrior-3-sys.vdi --size 61440
VBoxManage storageattach $VMNAME \
  --storagectl "SATA Controller" \
  --port 0 --device 0 --type hdd \
  --medium archiveteam-warrior-3-sys.vdi

VBoxManage storagectl $VMNAME --name "IDE Controller" --add ide
VBoxManage storageattach $VMNAME --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $INSTALL_ISO
