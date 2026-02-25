# screencast-lite

Automatically compress new macOS screen recordings (`.mov`) into smaller H.265 (`.mp4`) files.

This project is built for non-engineering users: run one setup script, then use either LaunchAgent mode or Folder Action mode for Desktop auto-compression.

## What it does

- Watches your Desktop via `launchd` (`LaunchAgent` with `WatchPaths` plus a 20-second fallback interval).
- Installs a Folder Action compatibility script (`screen_recording_auto_compress.scpt`) for macOS setups where LaunchAgent cannot read Desktop files.
- Detects screen recording files by:
  - extension: `.mov`
  - filename prefix: `Screen Recording` or Japanese default prefix (handled internally via Unicode escape sequence)
- Waits 5 seconds to avoid converting an in-progress recording.
- Compresses with `ffmpeg` using:
  - codec: `libx265`
  - compatibility: `-pix_fmt yuv420p` + `-tag:v hvc1`
  - quality: `-crf 28`
  - preset: `-preset slower`
- Creates snake_case output names in the same folder, for example:
  - `screen_recording_20260225_164553_small.mp4`
- Moves the original `.mov` file to Trash **only if conversion succeeds**.
- Writes logs to `~/.screencast-lite/worker.log`.
- Writes scanner logs to `~/.screencast-lite/scanner.log`.

## Requirements

- macOS (Intel or Apple Silicon)
- Internet connection for first-time dependency install
- Permission to install Homebrew packages

## Quick install

1. Download this repository.
2. Double-click `setup.command`.
3. Follow on-screen prompts.
4. Setup installs and starts the LaunchAgent automatically.
5. Setup also opens Folder Actions Setup.
6. If LaunchAgent mode does not process Desktop recordings, attach `screen_recording_auto_compress.scpt` to Desktop in Folder Actions Setup.

If you updated this repository after a previous install, run `setup.command` again to refresh the installed agent and scripts.

## Daily usage

1. Record your screen using macOS built-in recording.
2. Save the file to Desktop.
3. Wait for automatic compression.
4. Use the generated snake_case `_small.mp4` file.

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
tail -n 100 "$HOME/.screencast-lite/scanner.log"
tail -n 100 "$HOME/.screencast-lite/launchd.err.log"
```

- If scanner logs keep showing `mov=0` while `.mov` files exist on Desktop, switch to Folder Action mode:
  - Open Folder Actions Setup.
  - Enable Folder Actions.
  - Add Desktop in the left panel.
  - Attach `screen_recording_auto_compress.scpt` in the right panel.

### Original file was not deleted

This is expected when conversion fails. The original file is deleted only after a successful conversion.

### QuickTime cannot open an existing output

- Re-run `setup.command` to install the latest worker script.
- Re-convert from the original `.mov` file.
- New outputs are encoded with `yuv420p` + `hvc1` for better QuickTime compatibility.

## Uninstall

```bash
launchctl bootout "gui/$UID/io.github.senri1101.screencast-lite" || true
rm -f "$HOME/Library/LaunchAgents/io.github.senri1101.screencast-lite.plist"
rm -f "$HOME/Library/Scripts/Folder Action Scripts/screen_recording_auto_compress.scpt"
rm -rf "$HOME/.screencast-lite"
```

## Repository layout

- `setup.command`: one-click dependency + launch agent + folder action compatibility installer
- `folder_action/screen_recording_auto_compress.sh`: compression worker script
- `folder_action/screen_recording_auto_compress_folder_action.applescript.tpl`: folder action script template
- `launch_agent/scan_desktop_recordings.sh`: desktop scan entrypoint
- `launch_agent/io.github.senri1101.screencast-lite.plist`: launch agent template
- `docs/`: landing page (for GitHub Pages)

## License

No license is currently specified.
