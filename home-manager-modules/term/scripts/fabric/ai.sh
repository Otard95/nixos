#!/usr/bin/env bash

usage() {
  echo "usage: $0 [-p <pattern>] [<prompt>]"
  echo
  echo "  Options:"
  echo "    -h              Show this help"
  echo "    -p <pattern>    Pattern to use. Leave blank for interactive. '-' for no pattern"
  echo "    -S              Don't stream output"
}

args=("-s")
while getopts "hp:S" o; do
  case "$o" in
    p) pattern="$OPTARG" ;;
    S) args=() ;;
    h) usage; exit 0 ;;
  esac
done

shift $((OPTIND - 1))
prompt="$1"

if [ -t 0 ]; then
  piped=""
else
  piped="$(cat)"
fi

if [[ -z "$pattern" ]]; then
  pattern="$(fabric --listpatterns | fzf)"
fi

if [ "$pattern" != "-" ]; then
  args+=("-p" "$pattern")
fi

printf "%s\n\n# ADDITIONAL CONTEXT:\n\n%s\n" "$prompt" "$piped" | fabric "${args[@]}"
