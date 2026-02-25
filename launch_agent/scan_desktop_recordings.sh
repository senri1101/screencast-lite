#!/bin/zsh

set -u
setopt null_glob

WORKER_SCRIPT="$HOME/.screencast-lite/screen_recording_auto_compress.sh"
DESKTOP_DIR="$HOME/Desktop"

if [ ! -x "$WORKER_SCRIPT" ] || [ ! -d "$DESKTOP_DIR" ]; then
  exit 0
fi

jp_prefix=$'\xE7\x94\xBB\xE9\x9D\xA2\xE5\x8F\x8E\xE9\x8C\xB2'

for f in "$DESKTOP_DIR"/*.mov(N); do
  [ -f "$f" ] || continue

  filename=$(basename "$f")

  if [[ "$filename" != Screen\ Recording* && "$filename" != ${jp_prefix}* ]]; then
    continue
  fi

  "$WORKER_SCRIPT" "$f"
done
