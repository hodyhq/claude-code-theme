#!/usr/bin/env bash
# Remove the "Claude Code" theme files. Does not change your active theme;
# switch to another Global Theme first in System Settings if it's applied.
set -e
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"

rm -rf "$DATA/plasma/look-and-feel/com.hody.claude-code"
rm -rf "$DATA/wallpapers/ClaudeCode"
rm -f  "$DATA/color-schemes/ClaudeCode.colors"
rm -f  "$DATA/konsole/ClaudeCode.colorscheme"
rm -f  "$DATA/konsole/ClaudeCode.profile"
rm -f  "$CONF/alacritty/claude-code.toml"

echo "Removed Claude Code theme files."
echo "If it was your active theme, pick a different Global Theme in System Settings."
