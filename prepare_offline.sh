#!/usr/bin/env bash
# INSTRUCTOR ONLY. Builds a USB/shared-folder bundle so lab machines download almost nothing.
# Run on ONE Ubuntu machine of the SAME version as the lab machines, AFTER setup.sh has completed on it.
# Usage:  bash prepare_offline.sh /media/$USER/USBDRIVE/cisf-lab
set -e
DEST="${1:?Give a destination folder, e.g. /media/$USER/USBDRIVE/cisf-lab}"
SRC="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$DEST/offline/wheels"
cp "$SRC/setup.sh" "$SRC/verify.sh" "$DEST/"
echo "1/3 Downloading Ollama package (about 1.4 GB)..."
wget -c -O "$DEST/offline/ollama-linux-amd64.tar.zst" https://ollama.com/download/ollama-linux-amd64.tar.zst
echo "2/3 Copying AI models from this machine..."
sudo cp -r /usr/share/ollama/.ollama/models "$DEST/offline/ollama-models"
sudo chown -R "$USER" "$DEST/offline/ollama-models"
echo "3/3 Downloading Orange packages for this Python version ($(python3 -V))..."
python3 -m venv /tmp/cisf_dl && /tmp/cisf_dl/bin/pip download -q -d "$DEST/offline/wheels" orange3 PyQt5 pip setuptools wheel
du -sh "$DEST"
echo "BUNDLE READY. On each lab machine run:  bash /media/\$USER/<USB name>/cisf-lab/setup.sh"
