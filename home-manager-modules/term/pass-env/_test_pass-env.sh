#!/usr/bin/env bash

# Test script for pass-env argument parsing with assertions

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

test_count=0
pass_count=0

assert_output() {
    local test_name="$1"
    local expected="$2"
    shift 2
    local cmd=("$@")

    test_count=$((test_count + 1))
    echo "Test $test_count: $test_name"

    local temp_file=$(mktemp)
    "${cmd[@]}" >"$temp_file" 2>&1 || true  # Don't exit on command failure

    if echo "$expected" | diff - "$temp_file" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        pass_count=$((pass_count + 1))
    else
        echo -e "${RED}✗ FAIL${NC}"
        echo "Expected vs Actual:"
        echo "$expected" | diff -u - "$temp_file" | delta || true
    fi

    rm -f "$temp_file"
    echo
}

echo "============================================================================="
echo "Testing pass-env argument parsing"
echo "============================================================================="
echo

# =============================================================================
# SUCCESS CASES - Valid argument combinations
# =============================================================================

# Test 1: Options + env vars + command
assert_output "Options + env vars + command" '
env_options=-i
env_vars=DB_PASS=mydb/password API_KEY=api/key
command_args=ls -la' \
./pass-env --test-arg-parsing -i DB_PASS=mydb/password API_KEY=api/key ls -la

# Test 2: Multiple options + env vars + command
assert_output "Multiple options + env vars + command" '
env_options=-i -u PATH
env_vars=DB_PASS=mydb/password API_KEY=api/key
command_args=ls -la' \
./pass-env --test-arg-parsing -i -u PATH DB_PASS=mydb/password API_KEY=api/key ls -la

# Test 3: Only env vars + command (no options)
assert_output "Only env vars + command" '
env_options=
env_vars=USER=auth/user PASS=auth/pass
command_args=echo hello world' \
./pass-env --test-arg-parsing USER=auth/user PASS=auth/pass echo hello world

# =============================================================================
# ERROR CASES - Invalid argument combinations
# =============================================================================

# Test 4: No arguments at all
assert_output "Error - No arguments" \
'Error: No NAME=PASS_NAME pairs specified
Usage: ./pass-env [OPTIONS] NAME=PASS_NAME... COMMAND [ARG]...
Set each NAME to "$(pass show PASS_NAME | head -n1)" in the environment and run COMMAND.

OPTIONS
    Are the same as env(1), and must come before the envs

EXIT STATUS:
   128    invalid arguments

   129    if secret is not found

   -      the exit status of the env(1) command' \
./pass-env

# -----------------------------------------------------------------------------

# Test 5: Only options (treated as command, no env vars)
assert_output "Error - Missing envs" \
'Error: No NAME=PASS_NAME pairs specified
Usage: ./pass-env [OPTIONS] NAME=PASS_NAME... COMMAND [ARG]...
Set each NAME to "$(pass show PASS_NAME | head -n1)" in the environment and run COMMAND.

OPTIONS
    Are the same as env(1), and must come before the envs

EXIT STATUS:
   128    invalid arguments

   129    if secret is not found

   -      the exit status of the env(1) command' \
./pass-env -i -u FOO

# -----------------------------------------------------------------------------

# Test 6: Only command (no env vars)
assert_output "Error - Only command" \
'Error: No NAME=PASS_NAME pairs specified
Usage: ./pass-env [OPTIONS] NAME=PASS_NAME... COMMAND [ARG]...
Set each NAME to "$(pass show PASS_NAME | head -n1)" in the environment and run COMMAND.

OPTIONS
    Are the same as env(1), and must come before the envs

EXIT STATUS:
   128    invalid arguments

   129    if secret is not found

   -      the exit status of the env(1) command' \
./pass-env echo "no env vars"

# -----------------------------------------------------------------------------

# Test 7: Only env vars (no command)
assert_output "Error - Only env vars" \
'Error: No command specified
Usage: ./pass-env [OPTIONS] NAME=PASS_NAME... COMMAND [ARG]...
Set each NAME to "$(pass show PASS_NAME | head -n1)" in the environment and run COMMAND.

OPTIONS
    Are the same as env(1), and must come before the envs

EXIT STATUS:
   128    invalid arguments

   129    if secret is not found

   -      the exit status of the env(1) command' \
./pass-env FOO=bar

echo "============================================================================="
echo "Test Results: $pass_count/$test_count tests passed"
echo "============================================================================="

if [[ $pass_count -eq $test_count ]]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed!${NC}"
    exit 1
fi
