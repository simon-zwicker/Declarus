#!/bin/sh
# Metadata fixtures run the full common API/mock suite in isolated LuaJIT processes.
set -eu
cd "$(dirname "$0")/.."
test_log=$(mktemp /tmp/declarus-clients.XXXXXX)
trap 'rm -f "$test_log"' EXIT HUP INT TERM
for client in retail forever era tbc titan mists; do
    if luajit Tests/Run.lua "$client" > "$test_log" 2>&1; then
        printf '%s: passed\n' "$client"
    else
        cat "$test_log"
        exit 1
    fi
done
