#!/usr/bin/env bash
# nfetch.sh — Step 7: fetch additional scripts
cat <<'EOF'
 ____       _   _   _               _   _       
/ ___|  ___| |_| |_(_)_ __   __ _  | | | |_ __  
\___ \ / _ \ __| __| | '_ \ / _` | | | | | '_ \ 
 ___) |  __/ |_| |_| | | | | (_| | | |_| | |_) |
|____/ \___|\__|\__|_|_| |_|\__, |  \___/| .__/ 
                            |___/        |_|    
  
EOF

dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"

echo "Fetching bridge.log and name.sh into $root_dir"
cd "$root_dir" || exit
wget -O bridge.log https://raw.githubusercontent.com/Neural-Agent-Modelling-Engine/Scripts/main/v0.0.2/bridge.log
wget -O name.sh   https://raw.githubusercontent.com/Neural-Agent-Modelling-Engine/Scripts/main/v0.0.2/name.sh

echo "Fetch complete."
