#!/usr/bin/env bash

# Verify if the config file exists
if [[ ! -f "$config_file" ]]; then
  echo "The config file was not found: $config_file"
  echo "Execute 'copydots init' to create one"
  exit 1
fi

eval "$(yaml_load "$config_file")"

# Get the default output folder (current directory by default)
default_output_dir="${args[--output]:-$(pwd)}"

# Check if the default output directory exists
if [[ ! -d "$default_output_dir" ]]; then
  echo "The default output folder doesn't exist: $default_output_dir"
  exit 1
fi

for var in $(compgen -A variable | grep '_path$'); do
  key="${var%_path}"
  path="${!var}"

  # Check if there's a specific output for this entry
  output_var="${key}_output"
  if [[ -n "${!output_var}" ]]; then
    # Use specific output path
    output_dir="${!output_var}"

    # Expand tilde if present
    if [[ "$output_dir" =~ ^~(.*)$ ]]; then
      output_dir="$HOME${BASH_REMATCH[1]}"
    fi

    # Check if the custom output directory exists
    if [[ ! -d "$output_dir" ]]; then
      echo "Warning: '$output_dir' doesn't exist. Skipping '$key'..."
      continue
    fi
  else
    # Use default output directory
    output_dir="$default_output_dir"
  fi

  # Expand tilde in path if present
  if [[ "$path" =~ ^~(.*)$ ]]; then
    path="$HOME${BASH_REMATCH[1]}"
  fi

  if [[ ! -e "$path" ]]; then
    echo "Warning: '$path' doesn't exist. Skipping '$key'..."
    continue
  fi

  # Base name of the file or directory
  base_name="$(basename "$path")"
  dest_path="$output_dir/$base_name"

  # If destination exists, remove first and show "Updating". Otherwise, show "Adding"
  if [[ -e "$dest_path" ]]; then
      echo "Updating $key: '$dest_path'"
      rm -rf "$dest_path"
  else
    if [[ "$output_dir" != "$default_output_dir" ]]; then
      echo "Adding $key: $path → $output_dir (custom output)"
    else
      echo "Adding $key: $path → $output_dir"
    fi
  fi

  cp -r "$path" "$output_dir"
done

# Clean obsolete files/directories only from default output directory
while IFS= read -r -d '' existing_item; do
  base_name="$(basename "$existing_item")"
  source_found=false
  source_path=""

  # Check if this item corresponds to any entry that uses default output
  for var in $(compgen -A variable | grep '_path$'); do
    key="${var%_path}"
    path="${!var}"
    output_var="${key}_output"

    # Only consider items that use default output directory
    if [[ -z "${!output_var}" ]]; then
      [[ "$path" =~ ^~(.*)$ ]] && path="$HOME${BASH_REMATCH[1]}"
      if [[ "$(basename "$path")" == "$base_name" ]]; then
        source_found=true
        source_path="$path"
        break
      fi
    fi
  done

  # Only remove if source was found but no longer exists in filesystem
  if $source_found && [[ ! -e "$source_path" ]]; then
    echo "Removing obsolete (source removed): $existing_item"
    rm -rf "$existing_item"
  fi
done < <(find "$default_output_dir" -mindepth 1 -maxdepth 1 -print0)

# Clean obsolete files from custom output directories
declare -A output_to_files
declare -A output_to_dirs

# First pass: collect current outputs and their files
for var in $(compgen -A variable | grep '_path$'); do
    key="${var%_path}"
    path="${!var}"
    output_var="${key}_output"
    
    if [[ -n "${!output_var}" ]]; then
        output_dir="${!output_var}"
        [[ "$output_dir" =~ ^~(.*)$ ]] && output_dir="$HOME${BASH_REMATCH[1]}"
        
        # Store both the file and its parent directory
        output_to_files["$output_dir/$(basename "$path")"]="$path"
        output_to_dirs["$output_dir"]=1
    fi
done

# Second pass: check each custom output file
for output_path in "${!output_to_files[@]}"; do
    if [[ -e "$output_path" ]]; then
        source_path="${output_to_files[$output_path]}"
        [[ "$source_path" =~ ^~(.*)$ ]] && source_path="$HOME${BASH_REMATCH[1]}"
        
        # If source path no longer exists in filesystem, remove the output
        if [[ ! -e "$source_path" ]]; then
            echo "Removing obsolete (source removed): $output_path"
            rm -rf "$output_path"
        fi
    fi
done