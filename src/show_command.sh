#!/usr/bin/env bash

# Verify if the config file exists
if [[ ! -f "$config_file" ]]; then
  echo "The config file was not found: $config_file"
  echo "Execute 'copydots init' to create one"
  exit 1
fi

cat "$config_file"