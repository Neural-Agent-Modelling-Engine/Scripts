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

# Map logical tool names to package names (especially for aria2c → aria2)
declare -A pkgs
pkgs[git]="git"
pkgs[cmake]="cmake"
pkgs[clang]="clang"
pkgs[make]="make"
pkgs[wget]="wget"
pkgs[unzip]="unzip"
pkgs[aria2c]="aria2"  # correct Termux/Ubuntu package for aria2c

for tool in "${!pkgs[@]}"; do
  pkg_name="${pkgs[$tool]}"
  printf " - Checking %-8s… " "$tool"
  if ! command -v "$tool" &>/dev/null; then
    echo "not found; installing ($pkg_name)."
    if   command -v apt-get &>/dev/null; then sudo apt-get update -y && sudo apt-get install -y "$pkg_name"
    elif command -v yum     &>/dev/null; then sudo yum install -y "$pkg_name"
    elif command -v dnf     &>/dev/null; then sudo dnf install -y "$pkg_name"
    elif command -v pkg     &>/dev/null; then pkg update -y && pkg install -y "$pkg_name"
    else echo "ERROR: no supported package manager found." >&2 && exit 1
    fi
  else
    echo "already installed."
  fi
done

echo "All dependencies are in place."
