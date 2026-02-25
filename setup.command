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

WORKFLOW_NAME="Screen Recording Auto Compress.workflow"
DIR=$(cd "$(dirname "$0")" && pwd)

if [ -d "$DIR/$WORKFLOW_NAME" ]; then
    echo "Opening the workflow installer..."
    open "$DIR/$WORKFLOW_NAME"
    echo ""
    echo "When macOS asks, click Install to enable the folder action."
    echo "Set the watched folder to your Desktop."
else
    echo "Error: $WORKFLOW_NAME was not found."
    echo "Place setup.command and the workflow bundle in the same folder, then try again."
    exit 1
fi

echo ""
echo "========================================"
echo "Setup finished. You can close this window."
echo "========================================"
