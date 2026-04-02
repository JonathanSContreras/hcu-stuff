# Raspberry Pi SD Card Burn Process  
For Ubuntu Linux  

This document explains how to burn the HCU_COSC1351_071325 image to multiple SD cards and expand the filesystem to use the full 32 GB.  
The instructions apply to Ubuntu Linux.

## Requirements

### Hardware
- USB 3 SD card readers  
- 32 GB SD cards  
- Powered USB 3 hub for more than two readers  

### Software
- lsblk  
- xz  
- dd  
- partprobe  
- parted  
- e2fsck  
- resize2fs  
- wipefs  
- udevadm  

Install any missing tools with:

```bash
sudo apt install util-linux xz-utils coreutils parted e2fsprogs udev
```

## Important Facts

1. The source image was created on a 16 GB SD card.  
2. Writing the image to a 32 GB card leaves unused space.  
3. The root filesystem must be expanded after writing.  
4. Burn speed depends on the slowest SD card or reader.  
5. Use USB 3 ports for maximum performance.

## Identify SD Cards

Run:

```

lsblk -p

```

Look for devices with:
- RM = 1  
- TYPE = disk  
- SIZE about 29.7G  

Example detected devices:

```

/dev/sdb  
/dev/sdc

```

Never write to partitions such as `/dev/sdb1`.

## Unmount and Wipe SD Cards

Unmount:

```

sudo umount /dev/sdb* /dev/sdc*

```

Wipe old signatures:

```

sudo wipefs -a /dev/sdb  
sudo wipefs -a /dev/sdc

```

This prevents conflicts from previous data.

## Burn the Image to Multiple Cards

Run each burn in parallel for maximum speed:

```

sudo xzcat HCU_COSC1351_071325.img.xz | sudo dd of=/dev/sdb bs=4M oflag=direct conv=fsync status=progress &  
sudo xzcat HCU_COSC1351_071325.img.xz | sudo dd of=/dev/sdc bs=4M oflag=direct conv=fsync status=progress &

```

Use:

```

wait

```

This pauses until all background write jobs finish.

## Verify the Burn Completed

Check for active processes:

```

pgrep dd  
pgrep xzcat

```

If nothing is returned, the burns are complete.

## Expand the Filesystem

Each 32 GB card will show a 16 GB root partition.  
Expand it to fill the full card.

### Step 1. Reload the partition table

```

sudo partprobe /dev/sdb  
sudo partprobe /dev/sdc

```

### Step 2. Identify the root partition

Usually this is partition 2:

```

/dev/sdb2  
/dev/sdc2

```

### Step 3. Resize the partition to 100 percent

```

sudo parted -s /dev/sdb resizepart 2 100%  
sudo parted -s /dev/sdc resizepart 2 100%

```

### Step 4. Run filesystem checks

```

sudo e2fsck -f -y /dev/sdb2  
sudo e2fsck -f -y /dev/sdc2

```

### Step 5. Expand the filesystem

```

sudo resize2fs /dev/sdb2  
sudo resize2fs /dev/sdc2

```

This expands the root filesystem to fill the card.

## Confirm Expansion

Run:

```

lsblk -p

```

The root partition should now show about 29 GB.

## Common Problems

### “No space left on device”
- Normal when burning images created on smaller cards  
- Should not happen on 32 GB cards unless the card is failing  

### Slow burn speed
- USB 2 port  
- Low quality card reader  
- Faulty SD card  

### Device not detected
- Try another port  
- Try another reader  
- Check device logs with `dmesg`

## Hardware Recommendations

For fast and stable burns:
- USB 3 SD card readers  
- One SD card per reader  
- Powered USB 3 hub  

## Automation Script

A full automation script is available.  
It detects devices, burns the image, and expands each card.

Usage:

```

sudo ./burn_pi_multi.sh HCU_COSC1351_071325.img.xz

```

Review the script before running.

## After Flashing: VNC & Static IP Setup

Once cards are flashed, each Pi will auto-connect to **HCU Engineering** (5 GHz WiFi) on first boot.

For VNC access over a direct Ethernet connection, you need to assign static IPs to both the Pi and the Windows PC:

| Device | Static IP |
|---|---|
| Raspberry Pi (wired) | `192.168.2.151` / `255.255.255.0` |
| Windows PC (Ethernet) | `192.168.2.152` / `255.255.255.0` |

See **`Static IP Setup.pdf`** in this folder for the full step-by-step walkthrough.

---

## Final Notes

- Always check device names before writing. Accidental writes to internal drives will destroy data. Use `lsblk` every time before burning.
- Do not unplug SD cards while flashing. This will corrupt the card.
- This script must be run with `sudo`. It will exit if not run as root.