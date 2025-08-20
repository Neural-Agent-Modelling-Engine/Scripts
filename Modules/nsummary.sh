#!/usr/bin/env bash
# nsummary.sh — Step 8: final summary


cat <<'EOF'


  ____                      _      _       
 / ___|___  _ __ ___  _ __ | | ___| |_ ___ 
| |   / _ \| '_ ` _ \| '_ \| |/ _ \ __/ _ \
| |__| (_) | | | | | | |_) | |  __/ ||  __/
 \____\___/|_| |_| |_| .__/|_|\___|\__\___|
                     |_|                   

                     
╔╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╤╗
╟┼┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┴┼╢
╟┤                               ├╢
╟┤             SAS.6             ├╢
╟┤                               ├╢
╟┤ NEURAL AGENT MODELLING ENGINE ├╢
╟┤         NAME - V0.0.2         ├╢
╟┤                               ├╢
╟┤     Product by Bornelabs™     ├╢
╟┤      www.bornelabs.tech       ├╢
╟┤                               ├╢
╟┼┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┬┼╢
╚╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╧╝ 


EOF



# Accept optional target directory arg, default to "NAME"
dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"
models_dir="$root_dir/llama.cpp/models"

# Create folders
echo "Creating target directory at $root_dir"
mkdir -p "$models_dir"
echo "Done."

dir_name="${1:-NAME}"
base_dir="$(pwd)"
root_dir="$base_dir/$dir_name"
build_dir="$root_dir/llama.cpp/build"
models_dir="$root_dir/llama.cpp/models"
config_file="$root_dir/model.conf"

# read the model name for display
if [ -f "$config_file" ]; then
  # shellcheck disable=SC1090
  source "$config_file"
else
  model="(not selected)"
fi

cat <<EOF

Setup Summary for project '$dir_name':

  • Root directory: $root_dir  
  • Built llama.cpp: $build_dir  
  • Model file:      $models_dir/tinyllama-$model.gguf  
  • Extra scripts:   $root_dir/bridge.log, $root_dir/name.sh  

EOF

# Ensure ~/.bashrc exists
touch ~/.bashrc

# Clean Autostart block
block='# Auto-start nwatcher.sh (one per session)
if [ -f "$HOME/NAME/nwatcher.sh" ]; then
    if ! pgrep -f "nwatcher.sh.*$$" > /dev/null; then
        bash "$HOME/NAME/nwatcher.sh" $$
    fi
fi'

# Add block only if it is not already present
grep -qxF "# Auto-start nwatcher.sh (one per session)" ~/.bashrc || echo "$block" >> ~/.bashrc

echo "Autostart for nwatcher.sh added to ~/.bashrc"

# Launch the Bornelabs NAME app immediately
echo "Launching Bornelabs NAME app..."
am start -n tech.bornelabs.name/io.kodular.brianxborne.NAME.Screen1
