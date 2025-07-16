#!/usr/bin/env bash
# ndependencies.sh — Step 2: install deps
cat <<'EOF'
 _____           _     
|_   _|__   ___ | |___ 
  | |/ _ \ / _ \| / __|
  | | (_) | (_) | \__ \
  |_|\___/ \___/|_|___/
  
EOF

dir_name="${1:-NAME}"
echo "Installing dependencies for project '$dir_name'..."

for pkg in git cmake clang make wget unzip aria2c; do
  printf " - Checking %-8s… " "$pkg"
  if ! command -v "$pkg" &>/dev/null; then
    echo "not found; installing."
    if   command -v apt-get &>/dev/null; then sudo apt-get update -y && sudo apt-get install -y "$pkg"
    elif command -v yum     &>/dev/null; then sudo yum install -y "$pkg"
    elif command -v dnf     &>/dev/null; then sudo dnf install -y "$pkg"
    elif command -v pkg     &>/dev/null; then pkg update && pkg install "$pkg"
    else echo "ERROR: no supported package manager" >&2 && exit 1
    fi
  else
    echo "already installed."
  fi
done

echo "All dependencies are in place."
