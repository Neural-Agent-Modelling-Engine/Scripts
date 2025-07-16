#!/usr/bin/env bash
# nfetch.sh — Step 7: fetch additional scripts

dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"

echo "Fetching bridge.log and name.sh into $root_dir"
cd "$root_dir" || exit
wget -O bridge.log https://raw.githubusercontent.com/Neural-Agent-Modelling-Engine/Scripts/main/v0.0.2/bridge.log
wget -O name.sh   https://raw.githubusercontent.com/Neural-Agent-Modelling-Engine/Scripts/main/v0.0.2/name.sh

echo "Fetch complete."
