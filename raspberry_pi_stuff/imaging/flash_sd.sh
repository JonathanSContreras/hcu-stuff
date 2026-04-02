#!/usr/bin/env bash
set -euo pipefail

IMAGE="$1"

if [[ -z "$IMAGE" ]]; then
  echo "Usage: sudo $0 /path/to/image.img.xz"
  exit 1
fi

if [[ ! -f "$IMAGE" ]]; then
  echo "Image file not found: $IMAGE"
  exit 1
fi

# Detect removable drives
mapfile -t DEVICES < <(lsblk -ndo PATH,RM,TYPE | awk '$2==1 && $3=="disk"{print $1}')

if [[ ${#DEVICES[@]} -eq 0 ]]; then
  echo "No removable drives detected."
  exit 1
fi

echo "Detected drives to flash:"
for d in "${DEVICES[@]}"; do
  lsblk -p "$d"
done

read -rp "Type YES to confirm erasing these devices: " CONFIRM
[[ "$CONFIRM" == "YES" ]] || { echo "Aborted."; exit 1; }

# Flash in parallel
for d in "${DEVICES[@]}"; do
  echo "Flashing $IMAGE -> $d"
  xzcat "$IMAGE" | sudo dd of="$d" bs=4M status=progress conv=fsync &
done

wait
echo "Flashing complete!"
