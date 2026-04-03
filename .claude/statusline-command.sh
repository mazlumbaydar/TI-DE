#!/bin/bash
# Claude Code status line: token usage display for Codespace environment

input=$(cat)

remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')

# Build token display
token_info=""
if [ -n "$remaining_pct" ] && [ -n "$ctx_size" ]; then
    remaining_tokens=$(echo "$ctx_size $used_pct" | awk '{printf "%d", $1 * (1 - $2/100)}')
    token_info="$(printf '%dk' $((remaining_tokens / 1000))) left ($(printf '%.0f' "$remaining_pct")% free)"
elif [ -n "$remaining_pct" ]; then
    token_info="$(printf '%.0f' "$remaining_pct")% tokens free"
else
    token_info="tokens: --"
fi

# Model name (shortened)
model_short=""
if [ -n "$model" ]; then
    model_short=" | $model"
fi

printf "%s%s" "$token_info" "$model_short"
