# Ubuntu-Warrior (a.k.a. Warrior 3)

This project is for building a Warrior Virtual Machine Appliance for the year 2017. It also contains the necessary boot up scripts that this Warrior will update from.

For building the older version, see https://github.com/ArchiveTeam/warrior-preseed

If you wanted to download the warrior, see https://warriorhq.archiveteam.org/downloads/warrior3/. For support, see https://www.archiveteam.org/index.php?title=Warrior.


## Building a warrior

1. Install VirtualBox.
2. Download the ISO file for Alpine Linux `alpine-virt-3.6.2-x86_64.iso`
3. Run `./build-vm.sh` to create an empty Virtual Machine.
4. Boot up the virtual machine and wait for Aline's login prompt to appear.
5. Follow the instructions for installing to disk: https://wiki.alpinelinux.org/wiki/Install_to_disk using the options mentioned in `stage.sh`.
6. Power off the virtual machine using the `poweroff` command.
7. Eject the virtual disc by selecting Remove Disk from Virtual Drive.
8. Boot the machine and login with username `root` and password `warrior`.
9. Run `apk add openssl`
10. Run `wget https://raw.githubusercontent.com/ArchiveTeam/Ubuntu-Warrior/master/stage.sh`
11. Run `chmod +x stage.sh; ./stage.sh`
12. Wait and then reboot.
13. Wait for it to install the [Docker instance](https://github.com/ArchiveTeam/warrior-dockerfile) and [warrior-code2](https://github.com/ArchiveTeam/warrior-code2).
14. Export the appliance by running `./pack-vm.sh`.


## Updating boot scripts

*Note: Do not push to master without testing! The warrior pulls files from this repository on boot up.*

`boot.sh` is responsible for fetching a copy of `startup.sh`. This allows for easier maintenance but at the risk of breaking things. When testing, please edit `boot.sh` to point to a separate branch.
