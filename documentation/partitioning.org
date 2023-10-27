#+title: =Partitioning and Mounting=

My configuration has extra helper scripts for partitioning and mounting the system.

These scripts live in [hosts/HOSTNAME/disks.nix] (which must customized to fit your specific configuration).
* Preflight Checks
** Variables to Check
Make sure you check the *capitalized variables* located within the =let= block in your device's =hosts/HOSTNAME/hardware-configuration.nix= and =hosts/HOSTNAME/disks.nix= files! These values are crucial to the scripts you'll run in the next steps as well as for how NixOS configures itself to read your partitions.
NOTES:
- When editing any of the path variables, always include =/= in the beginning and where else is necessary!
- In order to get the get the correct value for the =DISK= variable located in =disks.nix= for your drive, check the =/dev/disk/by-id= and locate the name of your drive (without anything at the end like =-part1=)
    - The path should look something like =/dev/by/disk/by-id/InterfaceType-OEMINFO= with =InterfaceType= being how its connected to your machine (like usb or nvme) and =OEMINFO= being the extremely long string that has the OEM of the device aswell as serial number (in some cases).
- Make sure the =SWAP_PATH= and =SWAP_SIZE= variables in =hardware-configuration.nix= and =disks.nix= match each other! The =SWAP_SIZE= variable in =disks.nix= is *string* while the one in =hardware-configuration.nix= is an *integer*.
- For the =SWAP_FILE= variable in the =disks.nix= file, the path is relative to =/mnt= on the iso (since that's where it will be mounted to when running the =disks-mount= command).
* Partitioning Steps
** 1. Creating the Partitions
Execute =nix run .#nixosConfigurations.$HOSTNAME.config.disks-create= to create the disks. Please be warned that this command will destroy everything on the disk so make sure you correctly defined the device in the configs and backed up everything!!! If necessary, unplug important devices you don't want to get wiped!
** 2. Formatting the Partitions
Execute =nix run .#nixosConfigurations.$HOSTNAME.config.disks-format= to format the filesystems on the newly created partitions
** 3. Mounting the Partitions
Execute =nix run .#nixosConfigurations.$HOSTNAME.config.disks-mount= to mount all of the newly created partitions to the live installer
** 4. Retrieving Partition IDs
Execute =nix run .#nixosConfigurations.$HOSTNAME.config.disks-retrieve= to obtain the necessary values for the variables =MAIN_PART= and =BOOT_PART=, needed for the =hardware-configuration.nix= file. The output is preformatted with the variable names and their respect partition IDs, so one just simply needs to copy over the output into the file. The output should follow the following format in the console:
#+begin_src shell
MAIN_PART = "/dev/disk/by-uuid/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX";
BOOT_PART = "/dev/disk/by-uuid/XXXX-XXXX";
#+end_src
If the output isn't correct, then instead run =nixos-generate-config --show-hardware-config --root /mnt=, it will output a base configuration file that the installer provides; containing the partition ids and see what are the ids for the newly created partitions (as well as other additional settings that are needed for your system).
* Optional Steps
Only do these if you're using a setup that includes what my setup uses (like swapfiles)
** Creating Swapfiles and Obtaining Resume Offset for Hibernation
Execute =nix run .#nixosConfigurations.$HOSTNAME.config.create-swapfile= to create the swapfile aswell as calculate what the =resume-offset= value should be for the current system. This is required since I'm using swapfiles and want to enable hibernation. Since there is no swap partition, the system needs to know where the swap header is on the system's disk (aka, it needs to know on which disk block sector the swapfile is located). Once it's ran, the resume offset value is echoed into the console; then you must take this value and put it in the =hosts/HOSTNAME/hardware-configuration.nix= file under the =RESUME_OFFSET= variable.
* Final Notes
- Once you finish all of these steps, move on to the next steps of the [[file:installation.org][Installation]] guide file!
