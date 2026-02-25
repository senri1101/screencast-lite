# screencast-lite

Automatically compress new macOS screen recordings (`.mov`) into smaller H.265 (`.mp4`) files.

This project is built for non-engineering users: run one setup script, install one Automator folder action, and your Desktop recordings are compressed automatically.

## What it does

- Watches your Desktop using an Automator Folder Action.
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
4. When Automator opens, click **Install**.
5. Set the watched folder to **Desktop**.

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
- Confirm Folder Action is installed and enabled.

### Original file was not deleted

This is expected when conversion fails. The original file is deleted only after a successful conversion.

## Uninstall

1. Remove or disable the Folder Action in macOS Folder Actions Setup.
2. Delete this repository folder.
3. (Optional) Keep or uninstall `ffmpeg` and Homebrew manually.

## Repository layout

- `setup.command`: one-click dependency + workflow installer
- `Screen Recording Auto Compress.workflow/Contents/document.wflow`: Automator workflow definition
- `docs/`: landing page (for GitHub Pages)

## License

No license is currently specified.
