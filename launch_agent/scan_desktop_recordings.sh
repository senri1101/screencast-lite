#!/bin/bash

set -u
shopt -s nullglob

export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

WORKER_SCRIPT="$HOME/.screencast-lite/screen_recording_auto_compress.sh"
DESKTOP_DIR="$HOME/Desktop"
LOG_DIR="$HOME/.screencast-lite"
SCAN_LOG="$LOG_DIR/scanner.log"

mkdir -p "$LOG_DIR" >/dev/null 2>&1 || true

log() {
  printf '%s %s\n' "$(/bin/date '+%Y-%m-%d %H:%M:%S')" "$1" >>"$SCAN_LOG" 2>/dev/null || true
}

if [ ! -x "$WORKER_SCRIPT" ] || [ ! -d "$DESKTOP_DIR" ]; then
  log "skip: worker or desktop missing"
  exit 0
fi

if [ ! -r "$DESKTOP_DIR" ]; then
  log "skip: desktop not readable"
  exit 0
fi

jp_prefix=$'\xE7\x94\xBB\xE9\x9D\xA2\xE5\x8F\x8E\xE9\x8C\xB2'
mov_count=0
queued_count=0

for f in "$DESKTOP_DIR"/*.mov; do
  [ -f "$f" ] || continue
  mov_count=$((mov_count + 1))

  filename="${f##*/}"

  if [[ "$filename" != Screen\ Recording* && "$filename" != ${jp_prefix}* ]]; then
    continue
  fi

  queued_count=$((queued_count + 1))
  log "queue: $filename"
  "$WORKER_SCRIPT" "$f"
done

log "scan complete: mov=$mov_count queued=$queued_count"
