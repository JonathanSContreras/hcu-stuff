# HCU Lab Assistant Knowledge Base

This repo is a living brain dump and handoff guide for lab assistants at **Houston Christian University**. It captures the setup processes, scripts, and student-facing docs used to run the CS labs — so the next person doesn't have to figure everything out from scratch.

If you're taking over as a lab assistant, start here.

---

## Repository Structure

```
hcu_stuff/
└── raspberry_pi_stuff/
    ├── imaging/          # Scripts and docs for flashing student Pi SD cards
    └── COSC Docs/        # Student-facing documentation for the Pi image
```

---

## raspberry_pi_stuff

Everything related to the Raspberry Pi 4 setup used in **COSC 1351 (Intro to Programming)**.

### imaging/

Scripts and reference material for preparing student SD cards. The custom image includes a preconfigured desktop, HCU network settings, starter project folders, and a Python virtual environment with common libraries pre-installed.

> **Image files are not in this repo** — they're too large for GitHub. Download from the shared drive:
> **[HCU Images on OneDrive](https://1drv.ms/f/c/c4556d4a89ead8b0/IgBZfWznSoY5S5nOYKABLC5nAZliolEe56E34YAV023t80M?e=cghPRV)**
>
> Filenames follow the format `HCU_COSC1351_MMDDYY.img.xz`
> (e.g. `HCU_COSC1351_071325.img.xz` = July 13, 2025)

| File | Purpose |
|---|---|
| `burn_pi_multi.sh` | **Primary script.** Detects all plugged-in SD cards, flashes in parallel, and expands the filesystem to fill 32 GB cards |
| `flash_sd.sh` | Flash-only — does **not** resize. Don't use for student prep |
| `flasd_sd_cards.txt` | Manual step-by-step reference (no automation) |
| `Raspberry Pi SD Card Burn Process.md` | Full walkthrough: burn, expand, troubleshoot |
| `Static IP Setup.pdf` / `.docx` | How to configure static IPs on the Pi and Windows PC for VNC access |

**Quick start (Ubuntu Linux, with `sudo`):**
```bash
sudo ./burn_pi_multi.sh /path/to/HCU_COSC1351_MMDDYY.img.xz
```

See [`imaging/README.md`](./raspberry_pi_stuff/imaging/README.md) for the full TA guide.

---

### COSC Docs/

Student-facing documentation that ships with the Pi image.

| File | Purpose |
|---|---|
| `Raspberry Pi Starter Kit - Student Image.md` | Welcome doc for students: login info, preinstalled tools, Python venv setup, GPIO safety, and tips |

This doc is written to be beginner-friendly — assume students have zero prior Linux or hardware experience.

---

## Key Things to Know as a Lab Assistant

- **Always run `lsblk` before flashing** SD cards. Writing to the wrong device destroys data on that drive.
- Use `burn_pi_multi.sh`, not `flash_sd.sh`. The simpler script skips partition resizing and leaves cards with only ~16 GB usable.
- The image was created on a 16 GB card and needs to be expanded after flashing to fill a 32 GB card — the script handles this automatically.
- Each Pi auto-connects to **HCU Engineering** (5 GHz WiFi) on first boot.
- For VNC access over Ethernet, both the Pi and the Windows PC need static IPs assigned manually after flashing (see `Static IP Setup.pdf`).
- Default Pi credentials: `pi` / `raspberry`
- The Python virtual environment is at `~/projects/raspi-env/venv/`. Students activate it with the `activate_pi` alias.

---

## Contributing / Keeping This Up to Date

This repo is meant to grow over time. If you figure something out that took you longer than it should have — write it down here. Future lab assistants will thank you.

Suggested additions as the lab expands:
- Networking/VPN setup guides
- Lab machine software configs
- Common student errors and fixes
- Course-specific setup notes (beyond COSC 1351)
