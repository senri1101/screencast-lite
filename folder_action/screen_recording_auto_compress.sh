#!/bin/zsh

set -u

export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH

if ! command -v ffmpeg >/dev/null 2>&1; then
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
    continue
  fi

  if ! mdls -name kMDItemContentTypeTree -raw "$f" 2>/dev/null | /usr/bin/grep -q "public.movie"; then
    continue
  fi

  sleep 5
  output="$dir/${filename_noext}_small.mp4"

  if [ -e "$output" ]; then
    continue
  fi

  if ffmpeg -hide_banner -loglevel error -y -i "$f" -vcodec libx265 -crf 28 -preset slower "$output"; then
    osascript -e "tell application \"Finder\" to delete POSIX file \"$f\""
  else
    rm -f "$output"
  fi
done
