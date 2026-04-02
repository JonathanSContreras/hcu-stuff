#!/usr/bin/env bash

set -euo pipefail

IMAGE="${1:-}"
CONFIRM="${2:-}"

if [[ -z "${IMAGE}" ]]; then
  echo "Usage: sudo $0 /path/to/image.img.xz [--yes]"
  exit 1
fi
if [[ ! -f "${IMAGE}" ]]; then
  echo "Image not found: ${IMAGE}"
  exit 1
fi
if [[ $EUID -ne 0 ]]; then
  echo "Run as root with sudo."
  exit 1
fi

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing tool: $1"; exit 1; }; }
need lsblk
need xzcat
need dd
need partprobe
need parted
need e2fsck
need resize2fs
need wipefs
need udevadm

echo "Detecting removable disks..."
mapfile -t DEVICES < <(lsblk -ndo PATH,RM,TYPE | awk '$2==1 && $3=="disk"{print $1}')
if [[ ${#DEVICES[@]} -eq 0 ]]; then
  echo "No removable disks found."
  exit 1
fi

echo "Will flash to these devices:"
for d in "${DEVICES[@]}"; do
  lsblk -p "$d"
done

if [[ "${CONFIRM:-}" != "--yes" ]]; then
  read -r -p "Type YES to continue and ERASE these devices: " ans
  [[ "${ans}" == "YES" ]] || { echo "Aborted."; exit 1; }
fi

echo "Unmounting any mounted partitions..."
for d in "${DEVICES[@]}"; do
  while read -r pnt; do
    [[ -n "$pnt" ]] && umount -f "$pnt" || true
  done < <(lsblk -prno MOUNTPOINT "$d" | sed '/^$/d')
done

echo "Wiping old signatures..."
for d in "${DEVICES[@]}"; do
  wipefs -a "$d" || true
done

echo "Flashing in parallel..."
pids=()
for d in "${DEVICES[@]}"; do
  (
    echo "Writing ${IMAGE} to ${d}..."
    xzcat "${IMAGE}" | dd of="${d}" bs=4M oflag=direct conv=fsync status=progress
    sync
    partprobe "${d}" || true
    udevadm settle || true
  ) &
  pids+=("$!")
done

fail=0
for pid in "${pids[@]}"; do
  if ! wait "$pid"; then
    fail=1
  fi
done
[[ $fail -ne 0 ]] && { echo "One or more writes failed."; exit 1; }

echo "Expanding root partitions to fill each card..."
for d in "${DEVICES[@]}"; do
  udevadm settle || true
  partprobe "$d" || true
  sleep 1

  ROOT_PART=""
  ROOT_PART=$(lsblk -prno PATH,FSTYPE "$d" | awk '/ext4|btrfs/{print $1}' | tail -n1)
  if [[ -z "${ROOT_PART}" ]]; then
    ROOT_PART=$(lsblk -prno PATH "$d" | tail -n1)
  fi

  if [[ "$ROOT_PART" == "$d" || -z "$ROOT_PART" ]]; then
    echo "Could not find a partition on $d to expand."
    continue
  fi

  PARTNUM=$(lsblk -prno NAME "$ROOT_PART" | sed -E 's#.*/##' | sed -E 's/[^0-9]*([0-9]+)$/\1/')
  if [[ -z "${PARTNUM}" ]]; then
    echo "Could not determine partition number for $ROOT_PART"
    continue
  fi

  echo "Resizing partition $ROOT_PART on $d to 100%..."
  parted -s "$d" ---pretend-input-tty \
    unit % print \
    resizepart "${PARTNUM}" 100% || true

  udevadm settle || true
  partprobe "$d" || true
  sleep 1

  FSTYPE=$(lsblk -prno FSTYPE "$ROOT_PART")
  if [[ "$FSTYPE" == "ext4" || -z "$FSTYPE" ]]; then
    echo "Running fsck and resize2fs on ${ROOT_PART}..."
    e2fsck -f -y "$ROOT_PART" || true
    resize2fs "$ROOT_PART"
  elif [[ "$FSTYPE" == "btrfs" ]]; then
    echo "Btrfs found. Expand with 'btrfs filesystem resize max' after boot."
  else
    echo "Unknown filesystem ${FSTYPE}. Skipping."
  fi
done

echo "Done. All cards flashed and expanded."
