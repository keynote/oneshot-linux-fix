#!/bin/bash

script_dir="$(dirname "$(realpath $0)")"
save_dir="$HOME/.local/share/Oneshot"
documents_dir="$HOME/Documents"
cd "$script_dir"

# file is expected to be there
if [ ! -e ./_______.png ]; then
  cp ./images/icon.png ./_______.png
fi

if [ -n "$FLATPAK_ID" ]; then
  pipe_dir="$HOME/.var/app/$FLATPAK_ID"
  XDG_CURRENT_DESKTOP="DISABLED"
elif [ -n "$SNAP_REAL_HOME" ]; then
  pipe_dir="$SNAP_REAL_HOME"
  XDG_CURRENT_DESKTOP="DISABLED"
else
  pipe_dir="$HOME"
fi

if [[ "$XDG_CURRENT_DESKTOP" =~ (Cinnamon|KDE|MATE|XFCE) ]]; then
  journal_path="$save_dir/_______"
else
  journal_path="$documents_dir/Oneshot/_______"
fi

# copied journal is missing libraries, so replace it with a script that calls the original
while true; do
  if [ -e "$journal_path" ] && [ "$(du -b "$journal_path" | cut -f1)" -gt "100000" ]; then
    printf '#!/bin/bash\n%s\n%s' "HOME=$pipe_dir" "$script_dir/_______" > "$journal_path"
    chmod +x "$journal_path"
  fi
  sleep 5
done &

# background fixes
if [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]]; then
  if [ -f ./qdbus ] && [ ! -x ./qdbus ]; then
    chmod +x ./qdbus
  fi
  PATH="$(pwd):$PATH:/usr/bin/"
elif [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  gsettings monitor org.gnome.desktop.background picture-uri | awk -f ./bg_gnome.awk &
elif [[ "$XDG_CURRENT_DESKTOP" == *"XFCE"* ]]; then
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0 -R -r
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0 -m | awk -f ./bg_xfce.awk &
fi

trap 'kill -s SIGTERM $(jobs -p)' EXIT SIGINT SIGTERM

if ( [ -n "$FLATPAK_ID" ] || [ -n "$SNAP" ] ) && [ $# -gt 0 ]; then
  $@
else
  ./steamshim
fi
