#!/usr/bin/env bash
# nsummary.sh — Step 8: final summary
#!/usr/bin/env bash
# nsetup.sh — Step 1: create directories with ASCII banner


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
