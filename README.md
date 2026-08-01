# OneShot linux fix
This is a small collection of scripts that are made to fix some issues with the native linux version on Steam.

## Steam Flatpak
This is known to not work when using the Flatpak package of Steam.
You may consider installing a native package from your distribution.

If you don't mind not getting achievements, you can use [Goldberg Emulator](https://mr_goldberg.gitlab.io/goldberg_emulator/) to run OneShot without Steam.

## Usage
1. Open the OneShot game directory: `Right click the game -> Manage -> Browse local files`

2. Download the scripts via `Code -> Download ZIP` and extract them into the game directory.

3. Make `fix_libs.sh` and `launch.sh` executable if they are not:
```sh
chmod +x fix_libs.sh launch.sh
```

4. Move the problematic libraries:
```sh
mkdir removed_libs
mv libcrypt.so.1 libdrm.so.2 libGLdispatch.so.0 librt.so.1 libstdc++.so.6 libgdk-3.so.0 libwayland-client.so.0 libgio-2.0.so.0 libglib-2.0.so.0 libgmodule-2.0.so.0 libmount.so.1 libsystemd.so.0 removed_libs/
```
Alternatively run the `./fix_libs.sh` script to move all libraries that the system already has.

5. Change the launch option in Steam to:
```sh
./launch.sh; exit; %command%
```

6. Start the game via Steam or the launch script.

## What and how it fixes some issues (Spoilers might be ahead)
### Crashes and library related things
The following gets fixed by removing certain libraries:

Crash on startup: `libcrypt.so.1 libdrm.so.2 libGLdispatch.so.0 librt.so.1 libstdc++.so.6`

Crash on startup under Wayland: `libgdk-3.so.0 libwayland-client.so.0`

Background not changing on GNOME, Cinnamon, Deepin, Mate: `libgio-2.0.so.0 libglib-2.0.so.0 libgmodule-2.0.so.0 libmount.so.1`

Crash with Goldberg Emulator: `libsystemd.so.0`

The script doesn't move the libSDL libraries as removing them broke the puzzle in the refuge when using GNOME.

### Journal
The `_______.png` file is missing, which results in a error at some point, so it copies the correct image to the expected path on launch.

The game also later copies the journal to the save directory and creates a desktop entry in the Documents on supported DEs, which doesn't work correctly, as the executable will be missing libraries.
I have decided to run a loop in the `launch.sh` script that will wait for the file, and replace it with a bash script that calls the journal in the game directory.

### Wallpaper
#### KDE/Plasma
qdbus no longer exists on newer version of KDE/Plasma, so it now uses a dummy file to call dbus-send instead.

It also modifies the scripts to correctly set the background color, and default back to "Scaled and Cropped" when no other mode was set.

#### XFCE
It now uses a separate path for each monitor, so it monitors the changes to the old path with xfconf-query and pipe the output to an awk script, which will then apply the changes to each monitor.

#### GNOME
On GNOME the darkmode background doesn't get changed, so it monitors the changes to the normal background, and change the darkmode background accordingly with an awk script.

