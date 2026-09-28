#!/bin/sh
# SessionEnd hook: stop every chrome-devtools-axi bridge this Claude Code
# session started, whatever CHROME_DEVTOOLS_AXI_SESSION it used. A bridge
# outlives the agent that spawned it, and its headless browser stays running
# until something stops it. Bridges inherit CLAUDE_CODE_SESSION_ID from the
# Bash tool, so bridges owned by other sessions are left alone.

session_id=$(jq -r '.session_id // empty')
[ -n "$session_id" ] || exit 0

state_dir=$HOME/.chrome-devtools-axi
for pid_file in "$state_dir/bridge.pid" "$state_dir"/sessions/*/bridge.pid; do
	[ -f "$pid_file" ] || continue
	pid=$(jq -r '.pid // empty' "$pid_file" 2>/dev/null) || continue
	[ -n "$pid" ] || continue
	ps eww -o command= -p "$pid" 2>/dev/null | tr ' ' '\n' |
		grep -qx "CLAUDE_CODE_SESSION_ID=$session_id" || continue

	session_dir=$(dirname "$pid_file")
	if [ "$session_dir" = "$state_dir" ]; then
		session=default
	else
		session=$(basename "$session_dir")
	fi
	CHROME_DEVTOOLS_AXI_SESSION=$session chrome-devtools-axi stop >/dev/null 2>&1 || true
done
