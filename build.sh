#!/usr/bin/env bash
# Baut die statischen Seiten aus src/ + _partials/ ins Projektstammverzeichnis.
# Hängt an CSS/JS automatisch einen Inhalts-Hash an, damit Browser nach einer
# Änderung nicht die alte Datei aus dem Cache ausliefern.
set -euo pipefail
cd "$(dirname "$0")"
python3 - <<'PY'
import pathlib, re, hashlib

root = pathlib.Path('.')
header = (root/'_partials/header.html').read_text(encoding='utf-8')
footer = (root/'_partials/footer.html').read_text(encoding='utf-8')

def h(p):
    return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()[:8]

assets = {'assets/css/style.css': h('assets/css/style.css'),
          'assets/js/main.js':    h('assets/js/main.js')}

for src in sorted((root/'src').glob('*.html')):
    html = src.read_text(encoding='utf-8')
    nav = re.search(r'<!--\s*NAV:(\w+)\s*-->', html)
    hd = header
    if nav:
        key = nav.group(1)
        hd = hd.replace('data-nav="%s"' % key,
                        'data-nav="%s" class="on" aria-current="page"' % key)
    html = html.replace('<!--HEADER-->', hd).replace('<!--FOOTER-->', footer)
    html = re.sub(r'<!--\s*NAV:\w+\s*-->\n?', '', html)
    for path, ver in assets.items():
        html = html.replace('"%s"' % path, '"%s?v=%s"' % (path, ver))
    (root/src.name).write_text(html, encoding='utf-8')
    print('gebaut:', src.name)

print('Asset-Version:', ', '.join('%s=%s' % (k.rsplit("/",1)[1], v) for k, v in assets.items()))
PY
