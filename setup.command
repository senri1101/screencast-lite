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

SOURCE_DIR=$(cd "$(dirname "$0")" && pwd)
WORKER_SOURCE="$SOURCE_DIR/folder_action/screen_recording_auto_compress.sh"
FOLDER_ACTION_TEMPLATE="$SOURCE_DIR/folder_action/screen_recording_auto_compress_folder_action.applescript.tpl"
SCAN_SOURCE="$SOURCE_DIR/launch_agent/scan_desktop_recordings.sh"
PLIST_TEMPLATE="$SOURCE_DIR/launch_agent/io.github.senri1101.screencast-lite.plist"

APP_DIR="$HOME/.screencast-lite"
WORKER_TARGET="$APP_DIR/screen_recording_auto_compress.sh"
FOLDER_ACTION_SOURCE="$APP_DIR/screen_recording_auto_compress_folder_action.applescript"
SCAN_TARGET="$APP_DIR/scan_desktop_recordings.sh"
LOG_PATH="$APP_DIR/launchd.log"
ERR_LOG_PATH="$APP_DIR/launchd.err.log"

LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_TARGET="$LAUNCH_AGENTS_DIR/io.github.senri1101.screencast-lite.plist"
FOLDER_ACTIONS_DIR="$HOME/Library/Scripts/Folder Action Scripts"
FOLDER_ACTION_SCPT="$FOLDER_ACTIONS_DIR/screen_recording_auto_compress.scpt"

if [ ! -f "$WORKER_SOURCE" ] || [ ! -f "$FOLDER_ACTION_TEMPLATE" ] || [ ! -f "$SCAN_SOURCE" ] || [ ! -f "$PLIST_TEMPLATE" ]; then
    echo "Error: launch agent source files were not found."
    echo "Expected files:"
    echo "  - $WORKER_SOURCE"
    echo "  - $FOLDER_ACTION_TEMPLATE"
    echo "  - $SCAN_SOURCE"
    echo "  - $PLIST_TEMPLATE"
    exit 1
fi

mkdir -p "$APP_DIR" "$LAUNCH_AGENTS_DIR" "$FOLDER_ACTIONS_DIR"
cp "$WORKER_SOURCE" "$WORKER_TARGET"
cp "$SCAN_SOURCE" "$SCAN_TARGET"
chmod +x "$WORKER_TARGET" "$SCAN_TARGET"

python - "$FOLDER_ACTION_TEMPLATE" "$FOLDER_ACTION_SOURCE" "$WORKER_TARGET" <<'PY'
import pathlib
import sys

src = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])
worker = sys.argv[3]

content = src.read_text(encoding="utf-8")
content = content.replace("__WORKER_SCRIPT__", worker)
out.write_text(content, encoding="utf-8")
PY

osacompile -o "$FOLDER_ACTION_SCPT" "$FOLDER_ACTION_SOURCE"

python - "$PLIST_TEMPLATE" "$PLIST_TARGET" "$SCAN_TARGET" "$HOME" "$HOME/Desktop" "$LOG_PATH" "$ERR_LOG_PATH" <<'PY'
import pathlib
import sys

src = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])
scan = sys.argv[3]
home = sys.argv[4]
desktop = sys.argv[5]
log = sys.argv[6]
err = sys.argv[7]

content = src.read_text(encoding="utf-8")
content = content.replace("__SCAN_SCRIPT_PATH__", scan)
content = content.replace("__HOME_PATH__", home)
content = content.replace("__DESKTOP_PATH__", desktop)
content = content.replace("__LOG_PATH__", log)
content = content.replace("__ERR_LOG_PATH__", err)
out.write_text(content, encoding="utf-8")
PY

if launchctl print "gui/$UID/io.github.senri1101.screencast-lite" >/dev/null 2>&1; then
    launchctl bootout "gui/$UID/io.github.senri1101.screencast-lite" >/dev/null 2>&1 || true
fi

launchctl bootstrap "gui/$UID" "$PLIST_TARGET"
launchctl kickstart -k "gui/$UID/io.github.senri1101.screencast-lite"

echo ""
echo "LaunchAgent installed:"
echo "  - $PLIST_TARGET"
echo ""
echo "Worker scripts installed:"
echo "  - $WORKER_TARGET"
echo "  - $SCAN_TARGET"
echo "  - $FOLDER_ACTION_SCPT"
echo ""
echo "Log files:"
echo "  - $APP_DIR/worker.log"
echo "  - $APP_DIR/scanner.log"
echo "  - $LOG_PATH"
echo "  - $ERR_LOG_PATH"
echo ""
echo "LaunchAgent auto-compression is active for your Desktop."
echo ""
echo "Opening Folder Actions Setup for compatibility mode..."
open -a "Folder Actions Setup"
echo ""
echo "If LaunchAgent does not auto-compress on your macOS setup:"
echo "  1) Enable Folder Actions."
echo "  2) Add Desktop in the left panel."
echo "  3) Attach screen_recording_auto_compress.scpt in the right panel."
echo ""
echo "========================================"
echo "Setup finished. You can close this window."
echo "========================================"
