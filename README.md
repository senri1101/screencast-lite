# screencast-lite

Automatically compress new macOS screen recordings (`.mov`) into smaller H.265 (`.mp4`) files.

This project is built for non-engineering users: run one setup script, add one Folder Action script, and your Desktop recordings are compressed automatically.

## What it does

- Watches your Desktop through macOS Folder Actions.
- Detects screen recording files that start with:
  - `Screen Recording`
  - The Japanese default macOS prefix (handled internally via Unicode escape sequence).
- Waits 5 seconds to avoid converting an in-progress recording.
- Compresses with `ffmpeg` using:
  - codec: `libx265`
  - quality: `-crf 28`
  - preset: `-preset slower`
- Creates `<original_name>_small.mp4` in the same folder.
- Moves the original `.mov` file to Trash **only if conversion succeeds**.

## Requirements

- macOS (Intel or Apple Silicon)
- Internet connection for first-time dependency install
- Permission to install Homebrew packages

## Quick install

1. Download this repository.
2. Double-click `setup.command`.
3. Follow on-screen prompts.
4. Folder Actions Setup will open automatically.
5. Enable Folder Actions.
6. Add your Desktop folder in the left panel.
7. Add `screen_recording_auto_compress.scpt` in the right panel.

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
- Confirm Folder Actions are enabled.
- Confirm `screen_recording_auto_compress.scpt` is attached to Desktop in Folder Actions Setup.

### Original file was not deleted

This is expected when conversion fails. The original file is deleted only after a successful conversion.

## Uninstall

1. Open Folder Actions Setup.
2. Remove `screen_recording_auto_compress.scpt` from Desktop actions.
3. Delete `~/Library/Scripts/Folder Action Scripts/screen_recording_auto_compress.scpt`.
4. Delete `~/Library/Scripts/Folder Action Scripts/screen_recording_auto_compress.sh`.
5. Delete this repository folder.

## Repository layout

- `setup.command`: one-click dependency + folder action installer
- `folder_action/screen_recording_auto_compress.js`: folder action entry script source
- `folder_action/screen_recording_auto_compress.sh`: compression worker script
- `docs/`: landing page (for GitHub Pages)

## License

No license is currently specified.
