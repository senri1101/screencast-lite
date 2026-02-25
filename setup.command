#!/bin/zsh

set -e

echo "========================================"
echo " Screen Recording Auto Compression Setup"
echo "========================================"
echo ""

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew was not found. Installing Homebrew..."
    echo "If prompted, enter your macOS login password and press Enter."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -d "/opt/homebrew/bin" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -d "/usr/local/bin" ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Homebrew is already installed."
fi

export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH

if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "ffmpeg was not found. Installing ffmpeg..."
    brew install ffmpeg
else
    echo "ffmpeg is already installed."
fi

if ! command -v osacompile >/dev/null 2>&1; then
    echo "Error: osacompile was not found on this macOS installation."
    exit 1
fi

SOURCE_DIR=$(cd "$(dirname "$0")" && pwd)
SCRIPT_SOURCE="$SOURCE_DIR/folder_action/screen_recording_auto_compress.js"
WORKER_SCRIPT_SOURCE="$SOURCE_DIR/folder_action/screen_recording_auto_compress.sh"
TARGET_DIR="$HOME/Library/Scripts/Folder Action Scripts"
TARGET_SCPT="$TARGET_DIR/screen_recording_auto_compress.scpt"
TARGET_WORKER="$TARGET_DIR/screen_recording_auto_compress.sh"

if [ ! -f "$SCRIPT_SOURCE" ] || [ ! -f "$WORKER_SCRIPT_SOURCE" ]; then
    echo "Error: folder action sources were not found."
    echo "Expected files:"
    echo "  - $SCRIPT_SOURCE"
    echo "  - $WORKER_SCRIPT_SOURCE"
    exit 1
fi

mkdir -p "$TARGET_DIR"
cp "$WORKER_SCRIPT_SOURCE" "$TARGET_WORKER"
chmod +x "$TARGET_WORKER"
osacompile -l JavaScript -o "$TARGET_SCPT" "$SCRIPT_SOURCE"

echo ""
echo "Installed folder action files:"
echo "  - $TARGET_SCPT"
echo "  - $TARGET_WORKER"
echo ""
echo "Opening Folder Actions Setup..."
open -a "Folder Actions Setup"

echo ""
echo "Next steps in Folder Actions Setup:"
echo "  1) Enable Folder Actions."
echo "  2) Add your Desktop folder in the left panel."
echo "  3) Click + on the right panel and choose screen_recording_auto_compress.scpt."
echo ""
echo "========================================"
echo "Setup finished. You can close this window."
echo "========================================"
