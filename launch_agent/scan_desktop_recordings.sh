#!/bin/bash

set -u
shopt -s nullglob

export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

WORKER_SCRIPT="$HOME/.screencast-lite/screen_recording_auto_compress.sh"
WATCH_DIRS=("$HOME/Desktop" "$HOME/Pictures/screenshots")
LOG_DIR="$HOME/.screencast-lite"
SCAN_LOG="$LOG_DIR/scanner.log"
LOCK_DIR="$LOG_DIR/scanner.lock"

mkdir -p "$LOG_DIR" >/dev/null 2>&1 || true

log() {
  printf '%s %s\n' "$(/bin/date '+%Y-%m-%d %H:%M:%S')" "$1" >>"$SCAN_LOG" 2>/dev/null || true
}

if ! mkdir "$LOCK_DIR" >/dev/null 2>&1; then
  log "skip: scan already running"
  exit 0
fi
trap 'rmdir "$LOCK_DIR" >/dev/null 2>&1 || true' EXIT

if [ ! -x "$WORKER_SCRIPT" ]; then
  log "skip: worker missing"
  exit 0
fi

jp_prefix=$'\xE7\x94\xBB\xE9\x9D\xA2\xE5\x8F\x8E\xE9\x8C\xB2'
mov_count=0
queued_count=0
scanned_dir_count=0

for watch_dir in "${WATCH_DIRS[@]}"; do
  if [ ! -d "$watch_dir" ]; then
    log "skip missing directory: $watch_dir"
    continue
  fi

  if [ ! -r "$watch_dir" ]; then
    log "skip unreadable directory: $watch_dir"
    continue
  fi

  scanned_dir_count=$((scanned_dir_count + 1))

  for f in "$watch_dir"/*.mov; do
    [ -f "$f" ] || continue
    mov_count=$((mov_count + 1))

    filename="${f##*/}"

    if [[ "$filename" != Screen\ Recording* && "$filename" != ${jp_prefix}* ]]; then
      continue
    fi

    queued_count=$((queued_count + 1))
    log "queue: $f"
    "$WORKER_SCRIPT" "$f"
  done
done

log "scan complete: dirs=$scanned_dir_count mov=$mov_count queued=$queued_count"
