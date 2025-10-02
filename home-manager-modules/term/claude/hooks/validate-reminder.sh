filepath=$(jq -r '.tool_input.file_path')

case "$filepath" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.php|*.go)
    echo '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"Have you tested, built, linted, etc.? If this is applicable"}}'
    ;;
esac
