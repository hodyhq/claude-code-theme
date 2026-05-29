#!/usr/bin/env bash
# Install the "Claude Code" KDE Plasma Global Theme + terminal themes.
# Re-runnable. Backs up any file it overwrites.
set -e

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
APPLY="${1:-apply}"   # pass "noapply" to install files without switching the live theme

echo "==> Installing Claude Code theme"

# 1. Plasma color scheme
mkdir -p "$DATA/color-schemes"
cp "$HERE/colors/ClaudeCode.colors" "$DATA/color-schemes/"

# 2. Look-and-Feel (Global Theme) package
mkdir -p "$DATA/plasma/look-and-feel"
rm -rf "$DATA/plasma/look-and-feel/com.hody.claude-code"
cp -r "$HERE/lookandfeel/com.hody.claude-code" "$DATA/plasma/look-and-feel/"

# 3. Wallpaper package
mkdir -p "$DATA/wallpapers"
rm -rf "$DATA/wallpapers/ClaudeCode"
cp -r "$HERE/wallpaper" "$DATA/wallpapers/ClaudeCode"

# 4. Konsole profile + color scheme
mkdir -p "$DATA/konsole"
cp "$HERE/konsole/ClaudeCode.colorscheme" "$DATA/konsole/"
cp "$HERE/konsole/ClaudeCode.profile"     "$DATA/konsole/"

# 5. Alacritty colors (importable file; does not overwrite your config)
mkdir -p "$CONF/alacritty"
cp "$HERE/alacritty/claude-code.toml" "$CONF/alacritty/"
echo "    alacritty: add  import = [\"~/.config/alacritty/claude-code.toml\"]  under [general]"

if [ "$APPLY" = "apply" ] && command -v plasma-apply-lookandfeel >/dev/null 2>&1; then
    echo "==> Applying theme to the current session"
    plasma-apply-lookandfeel -a com.hody.claude-code || true
    # Global theme doesn't force colors by default in newer Plasma; set explicitly.
    plasma-apply-colorscheme ClaudeCode || true
    plasma-apply-desktoptheme breeze-dark || true
    command -v kwriteconfig6 >/dev/null && kwriteconfig6 --file kdeglobals --group General --key AccentColor "217,119,87"
    command -v kwriteconfig6 >/dev/null && kwriteconfig6 --file konsolerc --group "Desktop Entry" --key DefaultProfile "ClaudeCode.profile"
    plasma-apply-wallpaperimage "$DATA/wallpapers/ClaudeCode/contents/images/3840x2160.png" || true
    qdbus org.kde.KWin /KWin org.kde.KWin.reconfigure 2>/dev/null || true
fi

echo "==> Done. Pick 'Claude Code' in System Settings > Colors & Themes > Global Theme."
