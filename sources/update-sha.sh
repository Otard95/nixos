#!/usr/bin/env bash
set -euo pipefail

JSON="${1:-images.json}"

while IFS= read -r group; do
  baseUrl=$(jq -r ".\"$group\".baseUrl" "$JSON")
  ext=$(jq -r ".\"$group\".ext" "$JSON")
  count=$(jq ".\"$group\".images | length" "$JSON")

  for i in $(seq 0 $((count - 1))); do
    current=$(jq -r ".\"$group\".images[$i].sha256" "$JSON")
    [[ -n "$current" ]] && continue

    file=$(jq -r ".\"$group\".images[$i].file" "$JSON")
    img_ext=$(jq -r ".\"$group\".images[$i].ext // \"$ext\"" "$JSON")

    echo "Fetching $group/$file..."
    hash=$(nix-prefetch-url "${baseUrl}${file}.${img_ext}")

    tmp=$(mktemp)
    jq ".\"$group\".images[$i].sha256 = \"sha256:$hash\"" "$JSON" > "$tmp"
    mv "$tmp" "$JSON"
  done
done < <(jq -r 'keys[]' "$JSON")
