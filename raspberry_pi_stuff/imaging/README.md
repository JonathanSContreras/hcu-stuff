# Raspberry Pi Imaging

Scripts and reference material for flashing Raspberry Pi 4 SD cards used in **COSC 1351 (Intro to Programming)** at Houston Christian University.

The custom image includes a preconfigured desktop background, starter files for students, HCU network settings, and a static IP configuration for VNC access.

---

## Folder Contents

| File | Description |
|---|---|
| `burn_pi_multi.sh` | **Use this one.** Detects all plugged-in SD cards, flashes them in parallel, and expands the root filesystem to fill each card |
| `flash_sd.sh` | Flash-only script — does **not** resize the partition (leaves cards with ~16 GB usable). Do not use for student card prep |
| `flasd_sd_cards.txt` | Step-by-step reference guide for manually flashing cards (no automation) |
| `Raspberry Pi SD Card Burn Process.md` | Full walkthrough: burn process, filesystem expansion, troubleshooting, and hardware recommendations |
| `Static IP Setup.pdf` | How to set static IPs on the Pi (wired) and Windows PC for reliable VNC access |

> **Image files are not stored in this repo** (too large for GitHub). Download the latest image from the shared drive:
> **[HCU Images](https://1drv.ms/f/c/c4556d4a89ead8b0/IgBZfWznSoY5S5nOYKABLC5nAZliolEe56E34YAV023t80M?e=cghPRV)** — filenames follow the format `HCU_COSC1351_MMDDYY.img.xz` (e.g. `HCU_COSC1351_071325.img.xz` = July 13, 2025).

---

## Quick Start

Use `burn_pi_multi.sh` for the full process. It handles everything: flashing, syncing, and resizing.

**Requirements:** Ubuntu Linux, `sudo`, SD cards inserted via USB readers.

```bash
sudo ./burn_pi_multi.sh /path/to/HCU_COSC1351_MMDDYY.img.xz
```

The script will:
1. Detect all removable disks and display them
2. Prompt for confirmation before erasing anything — **type `YES` exactly**
3. Flash the image to all cards in parallel
4. Expand the root partition to fill each card (the source image is 16 GB; cards are 32 GB)

Add `--yes` to skip the confirmation prompt (useful when re-flashing a known batch):

```bash
sudo ./burn_pi_multi.sh /path/to/image.img.xz --yes
```

> **Do not unplug SD cards while flashing.** Doing so will corrupt the card and it will need to be reformatted.

---

## Network Configuration

Each Pi is preconfigured to auto-connect to **HCU Engineering** (5 GHz WiFi) on first boot.

For VNC access over a direct Ethernet connection, both the Pi and the Windows PC need static IPs assigned manually after flashing. See [`Static IP Setup.pdf`](./Static%20IP%20Setup.pdf) for the full walkthrough.

| Device | IP | Subnet |
|---|---|---|
| Raspberry Pi (wired/eth0) | `192.168.2.151` | `255.255.255.0` |
| Windows PC (Ethernet) | `192.168.2.152` | `255.255.255.0` |

Connect via VNC Viewer to: `192.168.2.151`

---

## Required Tools

These are standard packages on Ubuntu. Install any missing ones with:

```bash
sudo apt install util-linux xz-utils coreutils parted e2fsprogs udev
```

---

## Hardware Setup

- One USB 3 SD card reader per card
- Use USB 3 ports for best speed
- For more than two cards at once, use a **powered USB 3 hub**

---

## Notes for TAs

- **Always run `lsblk` before flashing** to confirm device names. Writing to the wrong device will destroy data on that drive.
- Always use `burn_pi_multi.sh`, not `flash_sd.sh`. The simpler script skips partition resizing and leaves cards with only ~16 GB usable.
- The script must be run with `sudo` — it will exit immediately if not.
- The image was originally created on a 16 GB card. The script automatically expands the filesystem to fill 32 GB cards.
- If a card is not detected, try a different port or reader, and check `dmesg` for errors.
- For VNC troubleshooting, verify VNC is enabled on the Pi: **Menu → Preferences → Raspberry Pi Configuration → Interfaces → VNC: Enable**.
- For full burn process details, see [`Raspberry Pi SD Card Burn Process.md`](./Raspberry%20Pi%20SD%20Card%20Burn%20Process.md).
