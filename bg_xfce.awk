BEGIN {
  types["rgba1"] = "-t double -t double -t double -t double";
  types["color-style"] = "-t int";
  types["image-style"] = "-t int";
  types["last-image"] = "-t string";

  delete displays;
  cmd="xrandr --query | grep \" connected\"";
  while ((cmd | getline display) > 0) {
    split(display, display_info, /\s/);
    displays[length(displays)] = display_info[1];
  }
  close(cmd);

  delete old_properties;
  cmd = "xfconf-query -c xfce4-desktop -p /backdrop/screen0 -l -v";
  while ((cmd | getline line) > 0) {
    property = line; sub(/\s.*/, "", property);
    value = line; sub(/^.*?\s+/, "", value);
    old_properties[property] = value;
    print property " | " value;
  }
  close(cmd);
}

/^set: \/backdrop\/screen0\/monitor0\/workspace0/ {
  basename = get_basename($2);
  if (!(basename in types) && basename != "color1") { print $2" has no known type"; next; }
  value = get_value($2);
  value_arg=value_to_arg(value, basename);
  if (basename=="color1") { basename="rgba1"; }
  for (i in displays) {
    property = "/backdrop/screen0/monitor" displays[i] "/workspace0/" basename;
    system("xfconf-query -c xfce4-desktop -p \"" property "\" -n " types[basename] " " value_arg);
  }
}

/^reset: \/backdrop\/screen0\/monitor0\/workspace0/ {
  basename = get_basename($2);
  if (basename=="color1") { basename = "rgba1"; }
  reset_display_property(basename);
}

# END {
#   for (basename in types) {
#     reset_display_property(basename)
#   }
# }



function get_basename(str) {
  sub(/^.*\//, "", str);
  return str;
}

function get_value(property,   _rawval) {
  cmd = "xfconf-query -c xfce4-desktop -l -v -p \"" property "\" -l -v";
  cmd | getline _rawval;
  close(cmd);
  sub(/^.*?\s+/, "", _rawval);
  return _rawval;
}

function value_to_arg(str, bn,   _vals, _arg) {
  if (bn == "color1" || bn == "rgba1") {
    gsub(/[\[\]]/, "", str);
    split(str, _vals, ",");
    for (i in _vals) {
      if (bn=="color1") {
        _vals[i] = _vals[i]/65535;
      }
      _arg = _arg"-s "_vals[i]" ";
    }
  } else {
    _arg = "-s "str;
  }
  return _arg;
}

function reset_display_property(basename,   _value, _property, i) {
  for (i in displays) {
    _property = "/backdrop/screen0/monitor" displays[i] "/workspace0/" basename;
    _value = old_properties[_property];
    if (_value == "") {
      system("xfconf-query -c xfce4-desktop -p \"" _property "\" -r");
    } else {
      system("xfconf-query -c xfce4-desktop -p \"" _property "\" -n " types[basename] " " value_to_arg(_value));
    }
  }
}
