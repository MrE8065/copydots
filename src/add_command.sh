#!/usr/bin/env bash

# Verify if the config file exists
if [[ ! -f "$config_file" ]]; then
  echo "The config file was not found: $config_file"
  echo "Execute 'copydots init' to create one"
  exit 1
fi

eval "$(yaml_load "$config_file")"

# Get the output folder (current directory by default)
output_dir="${args[--output]:-$(pwd)}"

# Check if the output directory exists
if [[ ! -d "$output_dir" ]]; then
  echo "The output folder doesn't exist: $output_dir"
  exit 1
fi

for var in $(compgen -A variable | grep '_path$'); do
  key="${var%_path}"
  path="${!var}"

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
    echo "Adding $key: $path → $output_dir"
  fi

  cp -r "$path" "$output_dir"

  # Clean obsolete files/directories
  while IFS= read -r -d '' existing_item; do
    base_name="$(basename "$existing_item")"

    keep=false
    for var in $(compgen -A variable | grep '_path$'); do
      path="${!var}"
      [[ "$path" =~ ^~(.*)$ ]] && path="$HOME${BASH_REMATCH[1]}"
      [[ "$(basename "$path")" == "$base_name" ]] && keep=true && break
    done

    if ! $keep; then
      echo "Removing obsolete: $existing_item"
      rm -rf "$existing_item"
    fi
  done < <(find "$output_dir" -mindepth 1 -maxdepth 1 -print0)

done