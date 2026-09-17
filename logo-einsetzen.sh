#!/usr/bin/env bash
# Setzt die Original-Logodatei überall auf der Website ein.
#
#   ./logo-einsetzen.sh ~/Desktop/ska-logo.png
#
# Standard: Die Datei enthält den kompletten Schriftzug ("Lockup").
# Enthält sie NUR die Bildmarke ohne Text, mit --nur-marke aufrufen.
set -euo pipefail
cd "$(dirname "$0")"

SRC="${1:-}"
MODE="${2:-lockup}"
[ "${1:-}" = "--nur-marke" ] && { SRC="${2:-}"; MODE="marke"; }
[ "${2:-}" = "--nur-marke" ] && MODE="marke"

if [ -z "$SRC" ] || [ ! -f "$SRC" ]; then
  echo "Datei nicht gefunden. Aufruf:  ./logo-einsetzen.sh /Pfad/zum/logo.svg" >&2
  exit 1
fi

EXT="${SRC##*.}"; EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')
DEST="assets/img/logo-original.$EXT"
cp "$SRC" "$DEST"
echo "→ übernommen: $DEST"

TMP=$(mktemp -d)

# ---------- 1. In Header und Footer verdrahten ----------
python3 - "$DEST" "$MODE" <<'PY'
import sys, pathlib, re, subprocess
dest, mode = sys.argv[1], sys.argv[2]

# Seitenverhältnis der Originaldatei bestimmen
w = h = None
if dest.endswith('.svg'):
    t = pathlib.Path(dest).read_text(encoding='utf-8', errors='ignore')
    m = re.search(r'viewBox\s*=\s*"([\d.\-\s]+)"', t)
    if m:
        v = m.group(1).split()
        w, h = float(v[2]), float(v[3])
else:
    out = subprocess.run(['sips','-g','pixelWidth','-g','pixelHeight',dest],
                         capture_output=True, text=True).stdout
    pw = re.search(r'pixelWidth:\s*(\d+)', out); ph = re.search(r'pixelHeight:\s*(\d+)', out)
    if pw and ph: w, h = float(pw.group(1)), float(ph.group(1))
ratio = (w/h) if (w and h) else 2.0

# Im Lockup-Modus muss das Logo deutlich höher stehen, sonst ist der
# Schriftzug in der Grafik nicht mehr lesbar; die Kopfzeile wächst mit.
disp_h = 64 if mode == 'lockup' else 42
disp_w = round(disp_h * ratio)

for f in ('_partials/header.html', '_partials/footer.html'):
    p = pathlib.Path(f); s = p.read_text(encoding='utf-8')
    s = re.sub(r'src="assets/img/logo[^"]*"', 'src="%s"' % dest, s)
    s = re.sub(r'(class="logo__mark"[^>]*?)width="\d+" height="\d+"',
               r'\1width="%d" height="%d"' % (disp_w, disp_h), s)
    s = s.replace('<a class="logo"', '<a class="logo logo--lockup"' if mode == 'lockup' else '<a class="logo"')
    s = s.replace('<a class="logo logo--lockup logo--lockup"', '<a class="logo logo--lockup"')
    s = s.replace('alt=""', 'alt="SKA Gebäude Service"')
    p.write_text(s, encoding='utf-8')

css = pathlib.Path('assets/css/style.css'); c = css.read_text(encoding='utf-8')
marker = '/* --- Original-Logo (von logo-einsetzen.sh gesetzt) --- */'
block = f'''
{marker}
.logo--lockup .logo__mark{{height:{disp_h}px;width:auto}}
.logo--lockup>span{{position:absolute;left:-9999px}}   /* Name steckt schon in der Grafik */
.header:has(.logo--lockup) .header__bar{{height:{disp_h+30}px}}
.header:has(.logo--lockup)~main .nav{{top:{disp_h+30}px}}
@media(max-width:960px){{
  .nav{{top:{disp_h+30}px}}
}}
@media(max-width:760px){{
  .logo--lockup .logo__mark{{height:{disp_h-14}px}}
  .header:has(.logo--lockup) .header__bar{{height:{disp_h+16}px}}
  .nav{{top:{disp_h+16}px}}
}}
'''
if marker in c:
    c = c[:c.index(marker)].rstrip() + '\n' + block
else:
    c = c.rstrip() + '\n' + block
css.write_text(c, encoding='utf-8')
print('   Header/Footer/CSS angepasst (Modus: %s, %dx%d)' % (mode, disp_w, disp_h))
PY

# ---------- 2. Favicon + Touch-Icon aus dem Original ----------
if [ "$EXT" = "svg" ]; then
  qlmanage -t -s 512 -o "$TMP" "$DEST" >/dev/null 2>&1 || true
  CAND="$TMP/$(basename "$DEST").png"
else
  cp "$DEST" "$TMP/sq.png"
  SIDE=$(sips -g pixelWidth "$TMP/sq.png" | awk '/pixelWidth/{print $2}')
  sips -p "$SIDE" "$SIDE" --padColor FFFFFF "$TMP/sq.png" >/dev/null 2>&1
  sips -z 512 512 "$TMP/sq.png" >/dev/null 2>&1
  CAND="$TMP/sq.png"
fi
if [ -f "$CAND" ]; then
  cp "$CAND" assets/img/icon-512.png
  cp "$CAND" assets/img/apple-touch-icon.png
  sips -z 180 180 assets/img/apple-touch-icon.png >/dev/null 2>&1
  echo "→ icon-512.png + apple-touch-icon.png erzeugt"
fi

# ---------- 3. OG-Vorschaubild 1200x630 mit dem Original ----------
python3 - "$DEST" <<'PY'
import sys, base64, pathlib, mimetypes
src = pathlib.Path(sys.argv[1])
mime = mimetypes.guess_type(src.name)[0] or 'image/png'
b64 = base64.b64encode(src.read_bytes()).decode()
pathlib.Path('assets/img/og-source.svg').write_text(f'''<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 1200 630">
  <defs><radialGradient id="glow" cx="78%" cy="6%" r="72%">
    <stop offset="0%" stop-color="#D9A441" stop-opacity="0.26"/>
    <stop offset="100%" stop-color="#D9A441" stop-opacity="0"/>
  </radialGradient></defs>
  <rect width="1200" height="630" fill="#0B2027"/>
  <rect width="1200" height="630" fill="url(#glow)"/>
  <image x="300" y="70" width="600" height="360" preserveAspectRatio="xMidYMid meet"
         xlink:href="data:{mime};base64,{b64}"/>
  <text x="600" y="510" text-anchor="middle" fill="#B7CBD0"
        font-family="'Inter','Segoe UI',Arial,sans-serif" font-size="30">Hausmeisterservice · Winterdienst · Gartenpflege · Trockenbau</text>
  <text x="600" y="558" text-anchor="middle" fill="#8FA8AF"
        font-family="'Inter','Segoe UI',Arial,sans-serif" font-size="27">Leonberg · Stuttgart · Böblingen · Sindelfingen — 0179 6957453</text>
</svg>
''', encoding='utf-8')
PY
qlmanage -t -s 1200 -o "$TMP" assets/img/og-source.svg >/dev/null 2>&1 || true
if [ -f "$TMP/og-source.svg.png" ]; then
  cp "$TMP/og-source.svg.png" assets/img/og.png
  sips -c 630 1200 assets/img/og.png >/dev/null 2>&1
  echo "→ og.png (1200x630) erzeugt"
fi

rm -rf "$TMP"
./build.sh
echo
echo "Fertig. Vorschau:  python3 -m http.server 4321 --directory \"$PWD\""
