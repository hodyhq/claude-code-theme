#!/usr/bin/env bash
# Generate a preview image for the theme from the wallpaper + palette swatches.
# No screenshots — fully synthetic, safe to publish. Requires ImageMagick 7.
# Usage: ./generate-preview.sh [wallpaper.png] [out.png] [WIDTHxHEIGHT]
set -e

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALL="${1:-$HERE/../wallpaper/contents/images/3840x2160.png}"
OUT="${2:-$HERE/../previews/preview.png}"
SIZE="${3:-1280x720}"
W="${SIZE%x*}"; H="${SIZE#*x}"

FONT="$(fc-match -f '%{file}' 'DejaVu Sans' 2>/dev/null || true)"
FONTBOLD="$(fc-match -f '%{file}' 'DejaVu Sans:bold' 2>/dev/null || true)"
[ -n "$FONT" ] && FONT="-font $FONT"
[ -n "$FONTBOLD" ] && FONTBOLD="-font $FONTBOLD"

# palette: "hex|label"
SW=( "#1F1E1D|bg" "#30302E|surface" "#E8E6DC|text" "#D97757|accent" \
     "#E0876A|hover" "#BD5D3A|deep" "#8FA05A|green" "#E0A363|yellow" \
     "#7B96A8|blue" "#B08497|magenta" )

# base: wallpaper cropped to size
TMP="$(mktemp --suffix=.png)"; trap 'rm -f "$TMP"' EXIT
magick "$WALL" -resize "${SIZE}^" -gravity center -extent "$SIZE" "$TMP"

# card geometry
CW=1040; CH=210; CX=$(( (W-CW)/2 )); CY=$(( H-CH-70 ))
n=${#SW[@]}; pad=40; gap=18
size=$(( (CW-2*pad-(n-1)*gap)/n ))
sy=$(( CY+92 ))

DRAW="roundrectangle $CX,$CY $((CX+CW)),$((CY+CH)) 24,24"
SWDRAW=""
LABELS=""
i=0
for item in "${SW[@]}"; do
  hex="${item%%|*}"; lab="${item##*|}"
  x=$(( CX+pad+i*(size+gap) ))
  SWDRAW="$SWDRAW -fill '$hex' -draw 'roundrectangle $x,$sy $((x+size)),$((sy+size)) 12,12'"
  LABELS="$LABELS -fill '#B7B5A9' -annotate +$((x))+$((sy+size+26)) '$lab'"
  i=$((i+1))
done

# compose
eval magick "$TMP" \
  -fill "'rgba(31,30,29,0.86)'" -draw "'$DRAW'" \
  -fill "'rgba(217,119,87,1)'" $FONTBOLD -pointsize 40 -annotate +$((CX+pad))+$((CY+50)) "'Claude Code'" \
  -fill "'#9A988F'" $FONT -pointsize 18 -annotate +$((CX+pad+2))+$((CY+76)) "'KDE Plasma Global Theme'" \
  $SWDRAW \
  $FONT -pointsize 15 $LABELS \
  "'$OUT'"

echo "Wrote $OUT ($SIZE)"
