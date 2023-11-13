#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash

cat <<EOM
setup.sh
==================================================================
This script partitions and encrypts your disk and installs NixOS
with Opt-in persistence through impermanence & blank snapshotting
==================================================================
EOM

# Script default variables
DEFAULT_DISK_PATH="/dev/vda"
DEFAULT_SWAP_SIZE=$(free -h | awk '/^Mem:/ {print $2}' | sed 's/i//')
DEFAULT_HYBERNATE="true"
DEFAULT_PASSWORD="password"
DEFAULT_HOSTNAME="nixos-dev"

# Bash colors
RED="\e[31m"
YELLOW="\e[33m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

# Display available disks
echo -e "${YELLOW}Checking for available disks${ENDCOLOR}"
lsblk -p
echo ""

# Get user input
echo -e "${YELLOW}Gathering user input${ENDCOLOR}"
read -p "Enter device path for the disk you want to use (default: ${DEFAULT_DISK_PATH}): " DISK_PATH
DISK_PATH=${DISK_PATH:-$DEFAULT_DISK_PATH}
PARTITION_BOOT=${DISK_PATH}1
PARTITION_SYSTEM=${DISK_PATH}2
read -p "Enter size for swap partition (default: ${DEFAULT_SWAP_SIZE}): " SWAP_SIZE
SWAP_SIZE=${SWAP_SIZE:-$DEFAULT_SWAP_SIZE}
read -p "Enter desired hostname (default: ${DEFAULT_HOSTNAME}): " HOSTNAME
HOSTNAME=${HOSTNAME:-$DEFAULT_HOSTNAME}
read -s -p "Enter password for disk encryption (default: ${DEFAULT_PASSWORD}): " PASSWORD
PASSWORD=${PASSWORD:-$DEFAULT_PASSWORD}
echo ""
echo ""

# Erase disk
echo -e "${YELLOW}Erasing disk ${DISK_PATH}${ENDCOLOR}"
sgdisk -og ${DISK_PATH}
echo ""

# Create partitions
echo -e "${YELLOW}Creating partitions on disk ${DISK_PATH}${ENDCOLOR}"
sgdisk -n 1::+1G  -c 1:boot -t 1:ef00 ${DISK_PATH}    # boot partition
sgdisk -n 2::0  -c 2:system -t 2:8309 ${DISK_PATH}    # system partition
echo ""

# Encrypt system partition
echo -e "${YELLOW}Encrypting system partition ${PARTITION_SYSTEM}${ENDCOLOR}"
echo -n ${PASSWORD} | cryptsetup --batch-mode luksFormat --label luks ${PARTITION_SYSTEM} -
echo -n ${PASSWORD} | cryptsetup open ${PARTITION_SYSTEM} enc -
echo ""

# Format boot partition
echo -e "${YELLOW}Formating boot partition ${PARTITION_BOOT}${ENDCOLOR}"
mkfs.fat -F 32 -n boot ${PARTITION_BOOT}
echo ""

# Create LVM volume
echo -e "${YELLOW}Creating LVM volume on system partition ${PARTITION_SYSTEM}${ENDCOLOR}"
pvcreate /dev/mapper/enc
vgcreate lvm /dev/mapper/enc
lvcreate --size "${SWAP_SIZE}" --name swap lvm
lvcreate --extents 100%FREE --name nixos lvm
echo ""

# Format LVM volumes
echo -e "${YELLOW}Formating LVM volumes${ENDCOLOR}"
mkswap /dev/mapper/lvm-swap
mkfs.btrfs /dev/mapper/lvm-nixos

# Creating sub-volumes
echo -e "${YELLOW}Creating sub-volumes${ENDCOLOR}"
mount -t btrfs /dev/mapper/lvm-nixos /mnt
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/log
echo -e "${YELLOW}Creating 'read-only? snapshot for root sub-volume${ENDCOLOR}"
btrfs subvolume snapshot -r /mnt/root /mnt/root-blank
umount /mnt
echo ""

# Mount subvolumes
echo -e "${YELLOW}Mounting sub-volumes and boot partition${ENDCOLOR}"
mount -o subvol=root,compress=zstd,noatime /dev/mapper/lvm-nixos /mnt
mkdir -p /mnt/{boot,home,nix,persist,var} && mkdir /mnt/var/log
mount -o subvol=home,compress=zstd,noatime /dev/mapper/lvm-nixos /mnt/home
mount -o subvol=nix,compress=zstd,noatime /dev/mapper/lvm-nixos /mnt/nix
mount -o subvol=persist,compress=zstd,noatime /dev/mapper/lvm-nixos /mnt/persist
mount -o subvol=log,compress=zstd,noatime /dev/mapper/lvm-nixos /mnt/var/log
mount ${PARTITION_BOOT} /mnt/boot
echo ""

# Create NixOS configuration
echo -e "${YELLOW}Creating NixOS configuration${ENDCOLOR}"
nixos-generate-config --root /mnt
echo ""

# Fixing generated Hardware configuration
echo -e "${YELLOW}Fixing generated hardware-configuration.nix...${ENDCOLOR}"
UUID_DISK_BOOT=$(blkid | grep ${PARTITION_BOOT} | awk -F' ' '{gsub(/"/, "", $2); print $2}' | cut -d '=' -f 2 -s)
UUID_DISK_SYSTEM=$(blkid | grep ${PARTITION_SYSTEM} | awk -F' ' '{gsub(/"/, "", $2); print $2}' | cut -d '=' -f 2 -s)
NIXOS_HW_CONFIG="/mnt/etc/nixos/hardware-configuration.nix"
## Set btrfs parameters
sed -i '/^ *options = \[/ s/];/"compress=zstd" "noatime" ];/ ' ${NIXOS_HW_CONFIG}
## Make sure /var/log is available at boot
sed -i '/options = \[ "subvol=log" "compress=zstd" "noatime" \];/ s/];/&\n      neededForBoot = true;/' ${NIXOS_HW_CONFIG}
## Load LUKS encrypted volume
sed -i "/^ *boot.initrd.kernelModules/ a \  boot.initrd.luks.devices.\"system\".device = \"/dev/disk/by-uuid/$UUID_DISK_SYSTEM\";" ${NIXOS_HW_CONFIG}
## Add swap device
sed -i "s/^  swapDevices = \[\];/  swapDevices = [ { device = \"\/dev\/disk\/by-uuid\/$UUID_DISK_BOOT\"; } ];/" ${NIXOS_HW_CONFIG}
echo ""

# Replacing OS configuration
echo -e "${YELLOW}Replacing generated configuration.nix...${ENDCOLOR}"
NIXOS_CONFIG="/mnt/etc/nixos/configuration.nix"
cp -f ./hosts/init_configuration.nix ${NIXOS_CONFIG}
sed -i "s/networking.hostName = .*/networking.hostName = \"$HOSTNAME\";/" ${NIXOS_CONFIG}
echo ""

# Install NixOS
echo -e "${YELLOW}Installing NixOS${ENDCOLOR}"
nixos-install
echo ""

# Finish
echo -e "${GREEN}DONE${ENDCOLOR}"
