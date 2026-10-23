# Cultivaria mod updater

Keeps your Cultivaria modpack up to date with one double-click.

## Step by step (do this once)

1. Open the **Releases** page: https://github.com/oxbi/cultivariamodupdater/releases/latest
2. Under **Assets**, click **`Cultivaria-Updater.zip`** to download it.
   - Ignore the two other entries there, **"Source code (zip)"** and **"Source code (tar.gz)"**. GitHub adds those on its own; you don't need them.
3. Open your Downloads folder, right-click `Cultivaria-Updater.zip` and choose **Extract All...**, then **Extract**.
4. Open the new `Cultivaria-Updater` folder. It holds 3 files; keep them together.
5. **Close Minecraft / TLauncher.**
6. Double-click **`Update-Cultivaria.bat`**.
   - If Windows says "Windows protected your PC", click **More info**, then **Run anyway**.
7. A black window shows what it downloads. When it says **"Updated to pack ..."** or **"Already up to date"**, press any key. Done: start the game as usual.

## Every update after that

When you're told there is an update: close Minecraft, double-click `Update-Cultivaria.bat` again (the same file from step 4, no new download). It updates itself too.

## What it does and doesn't touch

- Changes: the pack's mods, our Cultivaria mod file and the pack's config files, in `%APPDATA%\.minecraft`. Replaced files are backed up first to `.minecraft\cultivaria-update-backup`.
- Never touches: your settings and keybinds, saves, screenshots, resource packs, and mods you added yourself. Your shader and minimap settings are kept as well.
- If a download or check fails it stops with a red "UPDATE FAILED" message and changes nothing. Send that message to the host.

## Different Minecraft folder?

It expects the normal TLauncher folder (`%APPDATA%\.minecraft`). If yours is elsewhere, open a terminal in the folder and run:
`Update-Cultivaria.bat -GameDir "D:\path\to\.minecraft"`

---
*For the host:* the repo root holds `manifest.json` + `files/` (the current pack) once a release is published.
