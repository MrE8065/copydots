#!/usr/bin/env bash

# Verify if the config file exists
if [[ -f "$config_file" ]]; then
  echo "The config file '$config_file' already exists. Nothing was done."
  exit 1
fi

# Create example config file
cat > "$config_file" <<EOL
my_folder:
  path: "/path/to/folder"
  desc: "A folder i want"

my_file:
  path: "/path/to/file"
  desc: "An important file"

my_file:
  path: "/path/to/file"
  desc: "An sepecial file"
  output: "/different/path"
EOL

echo "The config file '$config_file' was created successfully"