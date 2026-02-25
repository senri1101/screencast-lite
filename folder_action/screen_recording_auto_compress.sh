#!/bin/bash

set -u

export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
LOG_DIR="$HOME/.screencast-lite"
if ! mkdir -p "$LOG_DIR" >/dev/null 2>&1; then
  LOG_DIR="${TMPDIR:-/tmp}/screencast-lite"
  mkdir -p "$LOG_DIR" >/dev/null 2>&1 || true
fi
LOG_FILE="$LOG_DIR/worker.log"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >>"$LOG_FILE" 2>/dev/null || true
}

to_snake_case_ascii() {
  local raw="$1"
  local ascii
  ascii="$(printf '%s' "$raw" | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null || printf '%s' "$raw")"
  printf '%s' "$ascii" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/_/g; s/^_+//; s/_+$//; s/_+/_/g'
}

build_output_stem() {
  local name_noext="$1"
  local year month day hour minute second
  local stem

  if [[ "$name_noext" =~ ([0-9]{4})[-./]([0-9]{2})[-./]([0-9]{2})[^0-9]*([0-9]{1,2})[.:]([0-9]{2})[.:]([0-9]{2}) ]]; then
    year="${BASH_REMATCH[1]}"
    month="${BASH_REMATCH[2]}"
    day="${BASH_REMATCH[3]}"
    hour="$(printf '%02d' "${BASH_REMATCH[4]}")"
    minute="${BASH_REMATCH[5]}"
    second="${BASH_REMATCH[6]}"
    printf 'screen_recording_%s%s%s_%s%s%s' "$year" "$month" "$day" "$hour" "$minute" "$second"
    return
  fi

  stem="$(to_snake_case_ascii "$name_noext")"
  if [ -z "$stem" ]; then
    stem="screen_recording_$(date '+%Y%m%d_%H%M%S')"
  fi
  case "$stem" in
    screen_recording_*) ;;
    *) stem="screen_recording_${stem}" ;;
  esac
  printf '%s' "$stem"
}

if ! command -v ffmpeg >/dev/null 2>&1; then
  log "ffmpeg was not found in PATH"
  osascript -e 'display alert "Error: ffmpeg not found" message "Install ffmpeg with Homebrew and run setup.command again."'
  exit 1
fi

jp_prefix=$'\xE7\x94\xBB\xE9\x9D\xA2\xE5\x8F\x8E\xE9\x8C\xB2'

for f in "$@"; do
  [ -f "$f" ] || continue

  filename="${f##*/}"
  dir="${f%/*}"
  filename_noext="${filename%.*}"

  case "$filename" in
    *.mov) ;;
    *) continue ;;
  esac

  if [[ "$filename" != Screen\ Recording* && "$filename" != ${jp_prefix}* ]]; then
    log "skip non-target filename: $filename"
    continue
  fi

  /bin/sleep 5
  output_stem="$(build_output_stem "$filename_noext")"
  output="$dir/${output_stem}_small.mp4"

  if [ -e "$output" ]; then
    log "skip existing output: $output"
    continue
  fi

  log "start compress: $f -> $output"
  if ffmpeg -hide_banner -loglevel error -y -i "$f" \
    -c:v libx265 -x265-params log-level=error -pix_fmt yuv420p -tag:v hvc1 -crf 28 -preset slower \
    -c:a aac -b:a 128k -movflags +faststart \
    "$output"; then
    log "success compress: $output"
    trash_dir="$HOME/.Trash"
    mkdir -p "$trash_dir" >/dev/null 2>&1 || true
    trash_target="$trash_dir/$filename"
    if [ -e "$trash_target" ]; then
      stamp=$(/bin/date '+%Y%m%d_%H%M%S')
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
