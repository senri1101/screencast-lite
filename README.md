# screencast-lite

Automatically compress new macOS screen recordings (`.mov`) into smaller H.265 (`.mp4`) files.

This project is built for non-engineering users: run one setup script, and a LaunchAgent will monitor your Desktop and compress matching recordings.

## What it does

- Watches your Desktop via `launchd` (`LaunchAgent` with `WatchPaths`).
- Detects screen recording files by:
  - extension: `.mov`
  - filename prefix: `Screen Recording` or Japanese default prefix (handled internally via Unicode escape sequence)
- Waits 5 seconds to avoid converting an in-progress recording.
- Compresses with `ffmpeg` using:
  - codec: `libx265`
  - quality: `-crf 28`
  - preset: `-preset slower`
- Creates `<original_name>_small.mp4` in the same folder.
- Moves the original `.mov` file to Trash **only if conversion succeeds**.
- Writes logs to `~/.screencast-lite/worker.log`.

## Requirements

- macOS (Intel or Apple Silicon)
- Internet connection for first-time dependency install
- Permission to install Homebrew packages

## Quick install

1. Download this repository.
2. Double-click `setup.command`.
3. Follow on-screen prompts.
4. Setup installs and starts the LaunchAgent automatically.

If you updated this repository after a previous install, run `setup.command` again to refresh the installed agent and scripts.

## Daily usage

1. Record your screen using macOS built-in recording.
2. Save the file to Desktop.
3. Wait for automatic compression.
4. Use the generated `_small.mp4` file.

## Troubleshooting

### `ffmpeg not found`

Run `setup.command` again. It installs Homebrew and ffmpeg if missing.

### No output file is created

- Confirm the file extension is `.mov`.
- Confirm the filename starts with `Screen Recording` (or Japanese default prefix).
- Confirm the file was saved to Desktop.
- Confirm the LaunchAgent is loaded:

```bash
launchctl print "gui/$UID/io.github.senri1101.screencast-lite"
```

- Check logs:

```bash
tail -n 100 "$HOME/.screencast-lite/worker.log"
```

### Original file was not deleted

This is expected when conversion fails. The original file is deleted only after a successful conversion.

## Uninstall

```bash
launchctl bootout "gui/$UID/io.github.senri1101.screencast-lite" || true
rm -f "$HOME/Library/LaunchAgents/io.github.senri1101.screencast-lite.plist"
rm -rf "$HOME/.screencast-lite"
```

## Repository layout

- `setup.command`: one-click dependency + launch agent installer
- `folder_action/screen_recording_auto_compress.sh`: compression worker script
- `launch_agent/scan_desktop_recordings.sh`: desktop scan entrypoint
- `launch_agent/io.github.senri1101.screencast-lite.plist`: launch agent template
- `docs/`: landing page (for GitHub Pages)

## License

No license is currently specified.
