#!/usr/bin/env bash
# ndependencies.sh — Step 2: install deps

cat <<'EOF'
 _____           _     
|_   _|__   ___ | |___ 
  | |/ _ \ / _ \| / __| 
  | | (_) | (_) | \__ \
  |_|\___/ \___/|_|___/
  
EOF

dir_name="${1:-NAME}"
echo "Installing dependencies for project '$dir_name'..."

# Map logical tool names to package names (cross-platform deps)
declare -A pkgs
pkgs[git]="git"
pkgs[cmake]="cmake"
pkgs[clang]="clang"
pkgs[make]="make"
pkgs[wget]="wget"
pkgs[unzip]="unzip"
pkgs[aria2c]="aria2"  # correct package for aria2c

# Detect if running inside Termux
is_termux=false
if command -v pkg &>/dev/null && [ -d "$PREFIX" ] && [[ "$PREFIX" == *com.termux* ]]; then
  is_termux=true
fi

# Install cross-platform deps
for tool in "${!pkgs[@]}"; do
  pkg_name="${pkgs[$tool]}"
  printf " - Checking %-10s… " "$tool"
  if ! command -v "$tool" &>/dev/null; then
    echo "not found; installing ($pkg_name)."
    if   command -v apt-get &>/dev/null; then apt-get update -y && apt-get install -y "$pkg_name"
    elif command -v yum     &>/dev/null; then yum install -y "$pkg_name"
    elif command -v dnf     &>/dev/null; then dnf install -y "$pkg_name"
    elif command -v pkg     &>/dev/null; then pkg update -y && pkg install -y "$pkg_name"
    else echo "ERROR: no supported package manager found." >&2 && exit 1
    fi
  else
    echo "already installed."
  fi
done

# Termux-only deps
if $is_termux; then
  echo "Detected Termux — checking Termux-only packages..."
  
  # termux-api
  if ! command -v termux-battery-status &>/dev/null; then
    echo " - termux-api not found; installing."
    pkg update -y && pkg install -y termux-api
  else
    echo " - termux-api already installed."
  fi

  # am command (Android Activity Manager)
  if ! command -v am &>/dev/null; then
    echo " - 'am' command not found; installing android-tools..."
    pkg update -y && pkg install -y android-tools
  else
    echo " - am command available."
  fi
fi

echo "All dependencies are in place."
