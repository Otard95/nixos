filepath=$(jq -r '.tool_input.file_path')

case "$filepath" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.php|*.go)
    echo '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"Have you remembered to read critical rules, docs, etc.? **ONLY** read/do relevant things, be critical."}}'
    ;;
esac
