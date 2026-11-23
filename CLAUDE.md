# SY302 Datenbanken – Kursunterlagen (HFTM)

## Konventionen
- Jede Lektion gibt es auf Deutsch (`Lektion NN/LektionNN-*.md`) und Französisch (`Lektion NN/LeconNN-*-FR.md`).
  Beide Fassungen müssen inhaltlich identisch sein: gleiche Abschnitte in gleicher Reihenfolge,
  gleiche Codeblöcke (nur Kommentare/Texte übersetzt). Änderungen immer in beiden Sprachen nachführen.
- Deutsch in Schweizer Rechtschreibung (ss statt ß).
- Beispiel-DB ist die HFTM Library (`SQL-Dumps/HFTM Library.sql`), Spaltennamen wie im Dump
  (z.B. `books.Titel`, `books.AuthorsID`, `lends.Date_From`). Node.js-Beispiele bauen auf
  `Lektion 07/db-nodejs-demo/db.js` auf.
- `Calude/` ist eine ältere Kopie der Unterlagen – nicht bearbeiten.

## PDFs
- Markdown ist die Quelle; PDFs mit `python tools/build-exports.py [datei.md ...]` erzeugen
  (pandoc + Word, Vorlage `Vorlage/Vorlage_KleineDokumente.dotx`). Keine .docx mehr pflegen.
- Markdown wird als `gfm+hard_line_breaks` gelesen: aufeinanderfolgende Zeilen bleiben getrennte Zeilen.

## Kursplanung (verbindlich, siehe README-Uebersicht.md)
- Unit N = Lektion N. Credits: L01–L05 = Credit 1–5, L06 keiner (Repetition + Projektstart),
  L07 = Theorieprüfung SQL (30%) + Credit 6, L08 = Abgabe DB-Design + Credit 7, L09–L11 = Credit 8–10.
  Projektabgabe auf GitLab nach Unit 12, Präsentation in Unit 13.
- Jeder Credit 0–5 Punkte (20% total); Punkte in `Uebungen/` sind interne Raster.
- Keine konkreten Daten in die Unterlagen schreiben (Kurs läuft jährlich).
- Offene Punkte stehen in `TODO.md`.
