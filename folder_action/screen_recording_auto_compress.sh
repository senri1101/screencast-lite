#!/bin/bash

set -u

export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH
LOG_DIR="$HOME/.screencast-lite"
if ! mkdir -p "$LOG_DIR" >/dev/null 2>&1; then
  LOG_DIR="${TMPDIR:-/tmp}/screencast-lite"
  mkdir -p "$LOG_DIR" >/dev/null 2>&1 || true
fi
LOG_FILE="$LOG_DIR/worker.log"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >>"$LOG_FILE" 2>/dev/null || true
}

if ! command -v ffmpeg >/dev/null 2>&1; then
  log "ffmpeg was not found in PATH"
  osascript -e 'display alert "Error: ffmpeg not found" message "Install ffmpeg with Homebrew and run setup.command again."'
  exit 1
fi

jp_prefix=$'\xE7\x94\xBB\xE9\x9D\xA2\xE5\x8F\x8E\xE9\x8C\xB2'

for f in "$@"; do
  [ -f "$f" ] || continue

  filename=$(basename "$f")
  dir=$(dirname "$f")
  filename_noext="${filename%.*}"

  case "$filename" in
    *.mov) ;;
    *) continue ;;
  esac

  if [[ "$filename" != Screen\ Recording* && "$filename" != ${jp_prefix}* ]]; then
    log "skip non-target filename: $filename"
    continue
  fi

  sleep 5
  output="$dir/${filename_noext}_small.mp4"

  if [ -e "$output" ]; then
    log "skip existing output: $output"
    continue
  fi

  log "start compress: $f -> $output"
  if ffmpeg -hide_banner -loglevel error -y -i "$f" -vcodec libx265 -x265-params log-level=error -crf 28 -preset slower "$output"; then
    log "success compress: $output"
    trash_dir="$HOME/.Trash"
    mkdir -p "$trash_dir" >/dev/null 2>&1 || true
    trash_target="$trash_dir/$filename"
    if [ -e "$trash_target" ]; then
      stamp=$(date '+%Y%m%d_%H%M%S')
      trash_target="$trash_dir/${filename_noext}_${stamp}.mov"
    fi

    if mv "$f" "$trash_target" >/dev/null 2>&1; then
      log "moved original to Trash: $trash_target"
    else
      log "failed to move original to Trash: $f"
    fi
  else
    rm -f "$output"
    log "failed compress: $f"
  fi
done
