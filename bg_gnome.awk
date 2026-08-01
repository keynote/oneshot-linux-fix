BEGIN {
  "gsettings get org.gnome.desktop.background picture-uri" | getline init_picture
  "gsettings get org.gnome.desktop.background picture-uri-dark" | getline init_picture_dark
}

index($2, ENVIRON["PWD"]) {
  system("gsettings set org.gnome.desktop.background picture-uri-dark " $2);
  next;
}

$2 == init_picture {
  system("gsettings set org.gnome.desktop.background picture-uri-dark " init_picture_dark);
  next;
}
