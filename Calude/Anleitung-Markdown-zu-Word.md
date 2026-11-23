# Anleitung: Markdown zu Word konvertieren

## Dateien für Studierende

Die folgenden Skripte wurden erstellt:
- `Skript-Kompakt-DE.md` (Deutsch)
- `Skript-Kompakt-FR.md` (Français)

---

## Methode 1: Pandoc (Empfohlen)

### Installation
1. Pandoc herunterladen: https://pandoc.org/installing.html
2. Installieren

### Konvertierung
```bash
# Deutsch
pandoc Skript-Kompakt-DE.md -o Skript-Kompakt-DE.docx

# Französisch
pandoc Skript-Kompakt-FR.md -o Skript-Kompakt-FR.docx
```

### Mit Inhaltsverzeichnis
```bash
pandoc Skript-Kompakt-DE.md -o Skript-Kompakt-DE.docx --toc
```

---

## Methode 2: Online-Konverter

### Cloudconvert
1. Gehe zu: https://cloudconvert.com/md-to-docx
2. Upload `.md` Datei
3. Wähle "docx" als Output
4. Konvertieren & Download

### Dillinger
1. Gehe zu: https://dillinger.io
2. Öffne `.md` Datei
3. Export als Word

---

## Methode 3: VS Code + Extension

### Installation
1. VS Code öffnen
2. Extension "Markdown PDF" installieren
3. Oder "Docs Markdown" Extension

### Konvertierung
1. `.md` Datei öffnen
2. `Ctrl+Shift+P` (Windows) oder `Cmd+Shift+P` (Mac)
3. "Markdown PDF: Export (docx)" wählen

---

## Methode 4: Microsoft Word direkt

### Word 2016 oder neuer
1. Word öffnen
2. Datei > Öffnen
3. `.md` Datei auswählen
4. Word konvertiert automatisch
5. Als `.docx` speichern

---

## Formatierung nach Konvertierung

Nach der Konvertierung können Sie in Word:
- Schriftart anpassen (empfohlen: Arial oder Calibri)
- Überschriften-Styles anwenden
- Seitenzahlen hinzufügen
- Kopf-/Fußzeilen anpassen
- HFTM Logo hinzufügen

---

## Empfohlenes Word-Layout

**Seite:**
- Format: A4
- Ränder: 2.5cm rundum

**Schrift:**
- Überschrift 1: 18pt, Fett
- Überschrift 2: 16pt, Fett
- Überschrift 3: 14pt, Fett
- Fließtext: 11pt
- Code: Courier New, 10pt

**Header:**
- Links: SY302 Databases
- Rechts: HFTM Systemtechnik

**Footer:**
- Mitte: Seitenzahlen

---

## Tipps

✅ **Markdown Vorteile:**
- Einfach zu bearbeiten
- Versionskontrolle mit Git
- Klein & portabel
- Überall lesbar

✅ **Word Vorteile:**
- Gewohnte Umgebung für Studierende
- Einfach zu drucken
- Kommentare & Markierungen möglich

💡 **Tipp:** Beide Formate anbieten!

---

## Beispiel-Struktur für Abgabe

```
SY302-Skripte/
├── Skript-Kompakt-DE.md
├── Skript-Kompakt-DE.docx
├── Skript-Kompakt-DE.pdf
├── Skript-Kompakt-FR.md
├── Skript-Kompakt-FR.docx
└── Skript-Kompakt-FR.pdf
```

---

## Erstellung PDF (Bonus)

```bash
# Mit Pandoc
pandoc Skript-Kompakt-DE.md -o Skript-Kompakt-DE.pdf

# Oder in Word: Datei > Speichern unter > PDF
```

---

**Die Skripte sind bereit zur Abgabe an Studierende!**
