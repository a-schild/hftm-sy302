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
- Offene Frage (Stand 2026-11): Credit-Nummerierung ab Lektion 7 – Lektionen sagen L07=Credit 6 … L11=Credit 10,
  die Checklisten L07-13 sagen L07=Credit 7, L08=Credit 8 (L01-06-Checklisten: Credit 6 = SQL-Test).
