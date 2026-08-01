#!/bin/bash

COSMIC_BG_CONFIG="$HOME/.config/cosmic/com.system76.CosmicBackground/v1/all"
FALLBACK_IMAGE="$HOME/Desktop/ONESHOT_hint.png"
INIT_CONFIG="$(cat $COSMIC_BG_CONFIG)"

bg_changed=false

trap "echo '$INIT_CONFIG' > '$COSMIC_BG_CONFIG'; exit" EXIT SIGINT SIGTERM

while true; do
  if [ -f "$FALLBACK_IMAGE" ] && [ "$bg_changed" = false ]; then
    if cmp -s "$FALLBACK_IMAGE" "./Wallpaper/desktop.png" || cmp -s "$FALLBACK_IMAGE" "./Wallpaper/desktop.bmp"; then
      BG_COLOR="(0.125, 0.015625, 0.1015625)"
    else
      BG_COLOR="(0.0, 0.0, 0.0)"
    fi
    cat << EOF > "$COSMIC_BG_CONFIG"
(
    output: "all",
    source: Path("$FALLBACK_IMAGE"),
    filter_by_theme: true,
    rotation_frequency: 300,
    filter_method: Lanczos,
    scaling_mode: Fit($BG_COLOR),
    sampling_method: Alphanumeric,
)
EOF
    bg_changed=true
  elif [ ! -f "$FALLBACK_IMAGE" ] && [ "$bg_changed" = true ]; then
    echo "$INIT_CONFIG" > "$COSMIC_BG_CONFIG"
    bg_changed=false
  fi
  sleep 1
done
