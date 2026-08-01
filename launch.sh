#!/bin/bash

# was annoying me in the logs
LD_PRELOAD_BAK="$LD_PRELOAD"
export LD_PRELOAD=""

script_dir="$(dirname "$(realpath $0)")"
save_dir="$HOME/.local/share/Oneshot"
cd "$script_dir"

# file is expected to be there
if [ ! -e ./_______.png ]; then
  cp ./images/icon.png ./_______.png
fi

# copied journal is missing libraries, so replace it with a script that calls the original
while true; do
  if [ -e "$save_dir/_______" ] && [ "$(du -b "$save_dir/_______" | cut -f1)" -gt "100000" ]; then
    printf '#!/bin/bash\n%s' "$script_dir/_______" > "$save_dir/_______"
    chmod +x "$save_dir/_______"
  fi
  sleep 5
done &

# background fixes
if [ "$XDG_SESSION_DESKTOP" = "KDE" ]; then
  if [ -f ./qdbus ] && [ ! -x ./qdbus ]; then
    chmod +x ./qdbus
  fi
  PATH="$(pwd):$PATH:/usr/bin/"
elif [ "$XDG_SESSION_DESKTOP" = "GNOME" ]; then
  gsettings monitor org.gnome.desktop.background picture-uri | awk -f ./bg_gnome.awk &
elif [ "$XDG_SESSION_DESKTOP" = "XFCE" ]; then
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0 -R -r
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0 -m | awk -f ./bg_xfce.awk &
elif [ "$XDG_SESSION_DESKTOP" = "COSMIC" ]; then
  if [ -f ./bg_cosmic.sh ] && [ ! -x ./bg_cosmic.sh ]; then
    chmod +x ./bg_cosmic.sh
  fi
  ./bg_cosmic.sh &
fi

trap 'kill -s SIGTERM $(jobs -p)' EXIT SIGINT SIGTERM

LD_PRELOAD="$LD_PRELOAD_BAK" ./steamshim
