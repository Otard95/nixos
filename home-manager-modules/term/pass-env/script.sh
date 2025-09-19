#!/usr/bin/env bash

usage() {
  echo "Usage: $0 [OPTIONS] NAME=PASS_NAME... COMMAND [ARG]...
Set each NAME to \"\$(pass show PASS_NAME | head -n1)\" in the environment and run COMMAND.

OPTIONS
    Are the same as env(1), and must come before the envs

EXIT STATUS:
   128    invalid arguments

   129    if secret is not found

   -      the exit status of the env(1) command"
}

# Parse command line arguments
env_options=()
env_vars=()
command_args=()

test_arg_parsing=0
dry=0

# Now parse OPTIONS (same as env(1))
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      usage
      exit 0
      ;;
    --dry)
      dry=1
      shift
      ;;
    --test-arg-parsing)
      test_arg_parsing=1
      shift
      ;;
    -a | --argv0 | -u | --unset | -C | --chdir | -S | --split-string | --block-signal | --default-signal | --ignore-signal)
      env_options+=("$1" "$2")
      shift 2
      ;;
    -*)
      env_options+=("$1")
      shift
      ;;
    *=*)
      # Found NAME=PASS_NAME pattern, we're done with options
      break
      ;;
    *)
      # No more options, check if this is a NAME=PASS_NAME or command
      break
      ;;
  esac
done

# Parse NAME=PASS_NAME pairs  
while [[ $# -gt 0 && "$1" =~ ^[^=]+=[^=]+$ ]]; do
  env_vars+=("$1")
  shift
done

# Remaining arguments are the command and its arguments
command_args=("$@")

# Validate that we have both env vars and a command
if [[ ${#env_vars[@]} -eq 0 ]]; then
  echo "Error: No NAME=PASS_NAME pairs specified" >&2
  usage
  exit 128
fi

if [[ ${#command_args[@]} -eq 0 ]]; then
  echo "Error: No command specified" >&2
  usage
  exit 128
fi

if [[ "$DEBUG" == "true" ]]; then
  echo "[DEBUG] parsed args"
fi

if [[ $test_arg_parsing == 1 ]]; then
echo "
env_options=${env_options[@]}
env_vars=${env_vars[@]}
command_args=${command_args[@]}"
exit 0
fi

# Generate hash from environment variables
generate_hash() {
  local sorted_vars
  # Sort the env_vars array to ensure consistent hashing
  IFS=$'\n' sorted_vars=($(sort <<<"${env_vars[@]}"))
  # Create hash from sorted variables
  printf '%s\n' "${sorted_vars[*]}" | sha256sum | cut -d' ' -f1
}

# Set up cache store path
get_cache_store_path() {
  local main_store_dir="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
  local cache_store_dir="$(dirname "$main_store_dir")/pass-env"
  echo "$cache_store_dir"
}

# Check if cached environment exists
check_cache() {
  local cache_store_dir="$1"
  local hash="$2"
  
  # Try to get cached environment
  local out
  out="$(PASSWORD_STORE_DIR="$cache_store_dir" pass show "$hash" 2>&1)"
  local exit_code=$?
  
  # Check if cache miss (look for error message)
  if grep -q "Error: $hash is not in the password store." <<< "$out"; then
    return 1  # Cache miss
  fi
  
  if [[ $exit_code -eq 0 ]]; then
    echo "$out"
    return 0  # Cache hit
  else
    echo "Error in call to pass: $out"
    exit $exit_code
  fi
}

# Fetch secrets from main password store
get_secrets() {
  local env_assignments=()
  
  # Fetch each secret from the main password store
  for env_var in "${env_vars[@]}"; do
    local name="${env_var%=*}"
    local pass_name="${env_var#*=}"
    
    # Get the full output from pass
    local pass_output
    pass_output=$(pass show "$pass_name" 2>&1)
    local exit_code=$?
    
    # Check if secret not found
    if grep -q "Error: $pass_name is not in the password store." <<< "$pass_output"; then
      echo "Error: Secret '$pass_name' not found in password store" >&2
      exit 129
    fi
    
    if [[ $exit_code -ne 0 ]]; then
      echo "Error: Failed to retrieve secret '$pass_name': $pass_output" >&2
      exit $exit_code
    fi
    
    # Extract just the first line as the secret value
    local secret_value
    secret_value=$(head -n1 <<< "$pass_output")
    
    # Add to environment assignments
    env_assignments+=("$name=$secret_value")
  done
  
  # Create the environment string
  echo "${env_assignments[@]}"
}

# Store environment string in cache
set_cache() {
  local cache_store_dir="$1"
  local hash="$2"
  local env_string="$3"
  
  # Store in cache
  printf '%s\n' "$env_string" | PASSWORD_STORE_DIR="$cache_store_dir" pass insert -e "$hash"
}

if [[ "$DEBUG" == "true" ]]; then
  echo "[DEBUG] funcs created"
fi

# Main execution logic
hash=$(generate_hash)

if [[ "$DEBUG" == "true" ]]; then
  echo "[DEBUG] got hash $hash"
fi

cache_store_dir=$(get_cache_store_path)

if [[ "$DEBUG" == "true" ]]; then
  echo "[DEBUG] got cache_store_dir $cache_store_dir"
fi

# Try to get from cache first
if cached_env=$(check_cache "$cache_store_dir" "$hash"); then
  # Cache hit - use cached environment
  env_string="$cached_env"
  if [[ "$DEBUG" == "true" ]]; then
    echo "[DEBUG] using cached secret: $hash"
  fi
else
  if [[ "$DEBUG" == "true" ]]; then
    echo "[DEBUG] getting secrets"
  fi
  # Cache miss - get secrets
  env_string=$(get_secrets)
  get_secrets_exit_code=$?
  if [[ $get_secrets_exit_code -ne 0 ]]; then
    exit $get_secrets_exit_code
  fi

  if [[ "$DEBUG" == "true" ]]; then
    echo "[DEBUG] got secrets"
  fi
  
  # Store in cache unless dry run
  if [[ $dry -eq 0 ]]; then
    if [[ "$DEBUG" == "true" ]]; then
      echo "[DEBUG] caching"
    fi
    set_cache "$cache_store_dir" "$hash" "$env_string"
  fi
fi

# Convert environment string to array for env command
readarray -t env_assignments <<<"$env_string"

if [[ $dry -eq 1 ]]; then
  # Dry run - print what would be executed
  echo "Would execute:"
  echo "env ${env_options[*]} ${env_assignments[*]} ${command_args[*]}"
else
  # Execute the command with environment variables
  if [[ "$DEBUG" == "true" ]]; then
    echo "[DEBUG] execute"
  fi
  exec env "${env_options[@]}" "${env_assignments[@]}" "${command_args[@]}"
fi

