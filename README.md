# SKA Gebäude Service — Website

Statische Website für **SKA Gebäude Service**, Inhaber Sait Kalcik, Tonweg 8, 71229 Leonberg
(0179 6957453, Info.ska.gebaudeservice@gmail.com). Kein Build-Tool, kein Framework — reines
HTML/CSS/JS, läuft auf jedem Webspace, Vercel, Netlify oder GitHub Pages.

## Seiten

```
index.html        Startseite — Hero mit Notrufkarte, WhatsApp-Servicewahl, 9 Leistungen,
                  Einsatzgebiet, Ablauf, FAQ
leistungen.html   Alle acht Leistungsbereiche im Detail, jeder mit eigenem WhatsApp-Button
notdienst.html    Elektro-Notdienst 24/7 — Sofortmaßnahmen, typische Einsätze, Kosten
kontakt.html      Kontaktdaten, Bürozeiten, Anfrageformular
danke.html        Dankeseite (noindex)
impressum.html    Impressum  → Felder […] ausfüllen
datenschutz.html  Datenschutzerklärung → Felder […] ausfüllen

src/              Quelldateien — hier bearbeiten
_partials/        header.html + footer.html, einmal pflegen, überall gültig
_archiv/          vorherige Fassung der Website, falls Inhalte zurückgeholt werden sollen
build.sh          baut src/ + _partials/ → fertige HTML-Dateien im Stammverzeichnis
assets/css/style.css · assets/js/main.js · assets/img/
```

### Bearbeiten

Immer in `src/` bzw. `_partials/` ändern, danach:

```bash
./build.sh
```

`build.sh` hängt an CSS und JS automatisch einen Inhalts-Hash an (`style.css?v=2b7b4eab`), damit
Besucher nach einer Änderung nicht die alte Datei aus dem Browser-Cache bekommen. **Nach jeder
Änderung an CSS oder JS also `./build.sh` laufen lassen**, sonst zeigt die Seite live den alten Stand.

### Lokal ansehen

```bash
python3 -m http.server 4321 --directory /Users/rizgarazadkalcik/ska-gebaeudeservice
```

## Das WhatsApp-Kernstück

Der Abschnitt `#service` auf der Startseite ist der wichtigste Teil der Seite: neun Kacheln, eine je
Leistung. Ein Tipp darauf öffnet WhatsApp mit einer **bereits geschriebenen Nachricht** für genau
diese Leistung, inklusive der Felder, die wir für ein Angebot brauchen (Adresse, Umfang, Termin).

Der Grund für diesen Aufbau: Die häufigste Hürde ist nicht die Kontaktaufnahme, sondern die Frage
„was schreibe ich denn?“. Mit vorgeschriebenen Feldern kommt die Anfrage vollständig an, statt in
fünf Nachrichten hin und her.

Die Texte stehen als `data-wa`-Attribut direkt an den Kacheln in `src/index.html` (und an den
Buttons der einzelnen Abschnitte in `src/leistungen.html`). Zeilenumbrüche im Text werden als
`&#10;` geschrieben.

**Die Zielnummer steht an genau einer Stelle:** `CONFIG.whatsapp` in `assets/js/main.js`
(aktuell `491796957453`). Sie gilt für alle Kacheln und für das Anfrageformular.

Es wird **nichts automatisch versendet** — WhatsApp öffnet sich mit vorbereitetem Text, absenden
muss der Kunde selbst. So steht es auch in der Datenschutzerklärung.

## Logo

Die Logodateien sind **unverändert** übernommen worden:

- `assets/img/logo-mark.svg` — Bildmarke, wird in Kopf- und Fußzeile verwendet
- `assets/img/logo-full.svg` — komplettes Logo mit Schriftzug, für Druck und Fahrzeug
- `assets/img/favicon.svg`, `apple-touch-icon.png`, `icon-512.png`, `og.png`

Die Farbpalette der Website ist aus dem Logo abgeleitet: Gold `#D9A441` auf Anthrazit `#0D0F12`.
Schrift: **Archivo** für Überschriften, **Barlow** für Fließtext.

**Das OG-Bild** (`assets/img/og.png`, das Vorschaubild beim Teilen eines Links) nennt noch die alte
Leistungsliste. Neu erzeugen aus `assets/img/og-source.svg`:

```bash
qlmanage -t -s 1200 -o /tmp/ska assets/img/og-source.svg && cp /tmp/ska/og-source.svg.png assets/img/og.png && sips -c 630 1200 assets/img/og.png
```

## VOR DEM LIVEGANG

1. **Impressum ausfüllen** — `src/impressum.html`: USt-IdNr. oder Kleinunternehmer-Hinweis nach
   § 19 UStG mit Steuernummer, Betriebsnummer der Handwerkskammer, Betriebshaftpflichtversicherung.
   Ein unvollständiges Impressum ist in Deutschland abmahnfähig.
2. **Datenschutzerklärung ausfüllen** — `src/datenschutz.html`: Hosting-Anbieter mit Anschrift,
   Speicherdauer der Server-Logfiles.
3. **Domain ist festgelegt: `skagebaeudeservice.de`** (registriert bei Porkbun, zeigt derzeit auf
   eine Parkseite). Kanonisch ist die Adresse **ohne www** — beim Hosting bitte
   `www.skagebaeudeservice.de` per 301 auf `skagebaeudeservice.de` umleiten, damit Google nicht
   zwei Varianten derselben Seite sieht. HTTPS ist Pflicht, sonst stimmt die Datenschutzerklärung nicht.
4. **Fotos einsetzen** — alle Bildflächen sind markierte Platzhalter (`<div class="ph">`). Gebraucht
   werden: Elektroinstallation, Kabeltrasse, Montage, Renovierung, Malerarbeiten, Hausmeister,
   Garten, Winterdienst, Notdiensteinsatz.
5. **OG-Bild neu erzeugen** (siehe oben).
6. **Google-Unternehmensprofil**: Kategorie auf **Elektriker** bzw. **Hausmeisterdienst** stellen
   (steht aktuell auf „Generalunternehmer“), Website-Link eintragen, Fotos hochladen.

## Aussagen, die stimmen müssen

Diese Zusagen stehen so auf der Seite und sollten nur bleiben, wenn sie zutreffen:

- **„Notdienst rund um die Uhr, auch nachts und an Feiertagen“** — das ist ein Versprechen an
  Menschen in einer Notlage. Wenn nachts niemand ans Telefon geht, ist der Schaden größer als der
  Nutzen der Seite.
- „Betriebshaftpflicht besteht“ (Startseite, Impressum)
- „Preis vor dem ersten Handgriff“ und „Preis am Telefon, bevor wir losfahren“ (Notdienstseite)
- „Rechnung mit ausgewiesenem Lohnanteil nach § 35a EStG“ (FAQ)

## Offener Punkt: Elektroinstallation und Handwerksrolle

Die Seite bewirbt **Elektroarbeiten und einen Elektro-Notdienst**. Das Elektrotechniker-Handwerk ist
**Anlage A Nr. 25 der Handwerksordnung** — zulassungspflichtig. Voraussetzung ist ein Meisterbrief
oder eine gleichwertige Berechtigung plus Eintragung in die Handwerksrolle; für Arbeiten an
Anlagen am Netz zusätzlich die Eintragung ins Installateurverzeichnis des Netzbetreibers
(§ 13 NAV). Beides liegt derzeit nicht vor — Feld 29 der Gewerbeanmeldung ist leer.

Deshalb steht an den betreffenden Stellen (Startseite, Leistungen, Notdienst) der Hinweis, dass
Arbeiten, die **Anschluss, Messung, Prüfung und Abnahme nach VDE** erfordern, gemeinsam mit einem
eingetragenen Elektrofachbetrieb ausgeführt werden. Dieser Satz ist keine Floskel — bitte nicht
entfernen, solange die Eintragung fehlt.

Wege zur eigenen Eintragung:

| Weg | Voraussetzung |
|---|---|
| **§ 7b HwO Altgesellenregelung** | Gesellenbrief plus sechs Jahre Berufserfahrung, davon vier in leitender Stellung. Elektrotechniker gehört **nicht** zu den ausgenommenen Handwerken (ausgenommen sind Anlage A Nr. 12 und 33–37). |
| **Meisterprüfung** | in Teilzeit etwa zwei bis drei Jahre |
| **Angestellter Betriebsleiter** | Person mit Meisterbrief als technischer Betriebsleiter |
| **§ 8 HwO Ausnahmebewilligung** | Einzelfallentscheidung |

Aus dem SGK-Auszug (türkische Sozialversicherung) geht hervor, dass Sait Kalcik 2012, 2021 und 2022
unter dem Berufscode **7411 (Bauelektriker)** gemeldet war — zusammen rund acht Monate. Das ist ein
Beleg, reicht für § 7b aber nicht aus. Entscheidend wäre ein **Gesellenbrief oder eine anerkannte
Berufsausbildung im Elektrobereich**; ohne den greift § 7b nicht.
