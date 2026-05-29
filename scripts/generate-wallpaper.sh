#!/usr/bin/env bash
# Regenerate the Claude Code wallpaper. Requires ImageMagick 7 (`magick`).
# Usage: ./generate-wallpaper.sh [output.png] [WIDTHxHEIGHT]
set -e

OUT="${1:-claude-code-dots.png}"
SIZE="${2:-3840x2160}"
W="${SIZE%x*}"; H="${SIZE#*x}"

# Palette
BASE='#1B1A19'        # warm near-black background
GLOW_OUTER='#371D14'  # wide, dim coral glow
GLOW_INNER='#281710'  # soft inner core
DOT='rgba(224,205,184,0.60)'   # warm-sand plus-marks

TILE="$(mktemp --suffix=.png)"
trap 'rm -f "$TILE"' EXIT

# 54px grid cell with a small "+" cross-mark
magick -size 54x54 xc:none -fill "$DOT" \
  -draw "rectangle 22.5,26.1 31.5,27.9" \
  -draw "rectangle 26.1,22.5 27.9,31.5" "$TILE"

magick -size "$SIZE" xc:"$BASE" \
  \( -size 5200x5200 radial-gradient:"$GLOW_OUTER"-black \) -gravity Center -geometry +0+0 -compose Screen -composite \
  \( -size 2800x2800 radial-gradient:"$GLOW_INNER"-black \) -gravity Center -geometry +0+0 -compose Screen -composite \
  \( -size "$SIZE" tile:"$TILE" \) -compose over -composite \
  \( -size "$SIZE" radial-gradient:'rgba(13,13,12,0)'-'rgba(11,11,10,0.90)' \) -compose over -composite \
  -attenuate 0.07 +noise Gaussian -depth 8 -strip -quality 92 "$OUT"

echo "Wrote $OUT ($SIZE)"
