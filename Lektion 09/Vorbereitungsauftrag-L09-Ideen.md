# Vorbereitungsauftrag Lektion 9: KI & Datenbanken

## Ideen für Vorbereitungsaufträge

### Option 1: KI-Tool Exploration (Empfohlen - 30 Min.)

**Aufgabe:**
Teste eines oder mehrere der folgenden KI-Tools und dokumentiere deine Erfahrungen:

**Tools:**
- ChatGPT (https://chat.openai.com)
- Claude (https://claude.ai)
- GitHub Copilot (falls verfügbar)
- Perplexity AI (https://perplexity.ai)

**Zu testen:**
1. **SQL-Query generieren lassen:**
   - Frage: "Erstelle eine SQL-Query für eine Bibliotheksdatenbank: Zeige alle Bücher, die mehr als 3x ausgeliehen wurden, sortiert nach Anzahl Ausleihen."
   
2. **Code Review:**
   - Gib dem Tool einen deiner bisherigen SQL-Queries oder Node.js Code
   - Frage: "Kannst du diesen Code verbessern? Gibt es Sicherheitsprobleme oder Performance-Optimierungen?"

3. **Fehlersuche:**
   - Gib einen fehlerhaften Code/Query
   - Frage: "Was ist hier falsch und wie kann ich es beheben?"

**Dokumentiere:**
- Welches Tool hast du verwendet?
- Welche Fragen hast du gestellt?
- Wie hilfreich waren die Antworten? (1-5 Sterne)
- Was hat funktioniert, was nicht?
- Würdest du das Tool wieder verwenden?

**Format:** Kurzes Dokument oder Notizen (1-2 Seiten)

---

### Option 2: Eigene Datenbank mit KI optimieren (45 Min.)

**Aufgabe:**
Verwende ein KI-Tool um deine bisherige Projektdatenbank zu verbessern.

**Schritte:**
1. **ER-Diagramm reviewen lassen:**
   ```
   Prompt: "Ich habe folgendes Datenbankdesign: [dein Design beschreiben]
   Kannst du mögliche Verbesserungen vorschlagen?"
   ```

2. **Query-Optimierung:**
   - Nimm eine komplexe Query aus deinem Projekt
   - Frage KI nach Optimierungsmöglichkeiten
   - Teste beide Versionen

3. **Index-Empfehlungen:**
   ```
   Prompt: "Für diese Tabellen und typischen Queries, welche Indexes würdest du empfehlen?"
   ```

**Abgabe:**
- Vorher/Nachher Vergleich
- Was hat die KI vorgeschlagen?
- Was hast du umgesetzt?
- Welche Verbesserungen konntest du messen?

---

### Option 3: KI-Prompting üben (20 Min.)

**Aufgabe:**
Lerne effektives Prompting für Datenbank-Aufgaben.

**Teste verschiedene Prompt-Stile:**

**Schlechter Prompt:**
```
"Erstelle Datenbank für Shop"
```

**Guter Prompt:**
```
"Erstelle ein Datenbankschema für einen Online-Shop mit folgenden Anforderungen:
- Produkte mit Kategorien
- Benutzer mit Adressen
- Bestellungen mit mehreren Produkten
- Bewertungen von Benutzern
Verwende MariaDB Syntax und achte auf Normalisierung (3NF)."
```

**Sehr guter Prompt:**
```
"Als erfahrener Datenbankarchitekt, erstelle ein Datenbankschema für einen Online-Shop:

ANFORDERUNGEN:
- Produkte (Name, Preis, Lagerbestand, Kategorie)
- Mehrere Kategorien pro Produkt möglich
- Benutzer (Email, Name, mehrere Adressen)
- Bestellungen (Datum, Status, Lieferadresse)
- Bestellpositionen (Produkt, Menge, Preis zum Kaufzeitpunkt)
- Bewertungen (1-5 Sterne, Text, Datum)

CONSTRAINTS:
- MariaDB 10.5+
- Normalisiert (3NF)
- Mit Foreign Keys und sinnvollen Indexes
- Soft Delete für Benutzer

AUSGABE:
- ER-Diagramm (Text-basiert)
- CREATE TABLE Statements mit allen Constraints
- Beispiel-Daten (INSERT Statements)
```

**Teste mindestens 3 verschiedene Prompt-Qualitäten** und vergleiche die Ergebnisse.

**Abgabe:** Screenshots oder Text mit deinen Prompts und den KI-Antworten

---

### Option 4: KI vs. Dokumentation (30 Min.)

**Aufgabe:**
Vergleiche KI-generierte Lösungen mit offizieller Dokumentation.

**Beispiel-Problem:**
"Wie erstelle ich einen Full-Text Search Index in MariaDB?"

**Quellen vergleichen:**
1. **KI-Tool deiner Wahl** - Frage stellen
2. **Offizielle MariaDB Docs** - https://mariadb.com/kb/en/fulltext-index-overview/
3. **Stack Overflow** - Suche nach dem Problem

**Dokumentiere:**
- Welche Quelle war am verständlichsten?
- Welche Quelle war am genauesten?
- Welche Quelle war am schnellsten?
- Welche Vor-/Nachteile hat jede Quelle?

**Abgabe:** Tabelle oder Vergleich mit Bewertung

---

### Option 5: Prompt Engineering Challenge (45 Min.)

**Aufgabe:**
Versuche mit einem einzigen Prompt eine vollständige, funktionierende Lösung zu erhalten.

**Challenge-Szenarien:**

**Challenge 1: API Endpoint erstellen**
```
"Erstelle einen vollständigen Express.js API Endpoint:
- Route: GET /api/books/:id/reviews
- Holt alle Reviews für ein Buch mit JOIN
- Mit Error Handling
- Nur Reviews von aktiven Benutzern
- Sortiert nach Datum (neueste zuerst)
- Mit Pagination (10 pro Seite)
"
```

**Challenge 2: Datenbank-Migration**
```
"Erstelle ein Migration-Script für folgendes Szenario:
- Bestehende Tabelle 'users' hat 'name' (VARCHAR)
- Ändern in 'first_name' und 'last_name'
- Bestehende Namen aufteilen (bei erstem Leerzeichen)
- Mit Rollback-Möglichkeit
- Safe für Production (keine Daten verlieren)
"
```

**Challenge 3: Performance-Problem**
```
"Diese Query ist zu langsam (>2 Sekunden bei 10.000 Rows):
[füge eine langsame Query ein]
Optimiere sie und erkläre warum sie jetzt schneller ist."
```

**Abgabe:** 
- Dein Prompt
- KI-Antwort
- Hast du es getestet? Funktioniert es?
- Was musstest du nachträglich ändern?

---

### Option 6: KI-Kritik üben (30 Min.)

**Aufgabe:**
Lass KI bewusst schlechten Code generieren und lerne Fehler zu erkennen.

**Schritt 1 - Schlechten Code generieren:**
```
Prompt: "Erstelle eine User-Registration API mit Express, 
aber ignoriere alle Security Best Practices."
```

**Schritt 2 - Analysieren:**
Finde mindestens 5 Sicherheitsprobleme oder schlechte Praktiken im generierten Code.

**Schritt 3 - Verbessern:**
```
Prompt: "Hier ist unsicherer Code: [Code einfügen]
Liste alle Sicherheitsprobleme auf und erstelle eine sichere Version."
```

**Abgabe:**
- Originaler "schlechter" Code
- Deine Analyse (gefundene Probleme)
- Verbesserte Version
- Was hast du dabei gelernt?

---

### Option 7: Eigene KI-Assisted Feature (60 Min.)

**Aufgabe:**
Implementiere ein neues Feature für dein Projekt mit KI-Unterstützung.

**Beispiel-Features:**
- Search-Funktion mit Filter
- Export zu CSV/Excel
- Email-Benachrichtigungen
- Dashboard mit Statistiken
- User-Rollen und Permissions

**Prozess:**
1. **Feature planen** (mit oder ohne KI)
2. **Mit KI implementieren** (Schritt für Schritt)
3. **Testen und debuggen** (KI für Fehlersuche nutzen)
4. **Dokumentieren** (README mit KI erstellen)

**Abgabe:**
- Welches Feature hast du implementiert?
- Welche KI-Tools hast du verwendet?
- Welche Prompts waren am hilfreichsten?
- Screenshots oder Demo-Video
- Wie viel Zeit hast du gespart (Schätzung)?

---

### Option 8: KI-Datenbank-Quiz erstellen (30 Min.)

**Aufgabe:**
Verwende KI um Lernmaterialien für den SQL-Test zu erstellen.

**Was erstellen:**
1. **Quiz-Fragen:**
   ```
   Prompt: "Erstelle 10 Multiple-Choice Fragen zu SQL JOINs 
   mit unterschiedlichen Schwierigkeitsgraden."
   ```

2. **Flashcards:**
   ```
   Prompt: "Erstelle 20 Flashcards für SQL DDL Befehle 
   (Vorderseite: Befehl, Rückseite: Erklärung + Beispiel)"
   ```

3. **Übungsaufgaben:**
   ```
   Prompt: "Erstelle 5 realistische Datenbank-Szenarien mit Aufgaben, 
   die verschiedene SQL-Konzepte abdecken."
   ```

**Abgabe:**
- Deine generierten Lernmaterialien
- Hast du die Quiz-Fragen selbst gelöst?
- Waren sie hilfreich?
- Würdest du KI für Prüfungsvorbereitung empfehlen?

---

## Quick-Aufgaben (10-15 Min.)

Falls du wenig Zeit hast, hier kurze Alternativen:

### Quick 1: Ein Prompt, drei Tools
Stelle dieselbe Datenbank-Frage an 3 verschiedene KI-Tools. Vergleiche die Antworten.

### Quick 2: Code-Erklärung
Nimm komplexen SQL-Code aus dem Kurs und lass ihn von KI erklären. War die Erklärung verständlich?

### Quick 3: Alternative Lösungen
Zeige KI deine Lösung einer Übung und frage: "Gibt es andere Wege dies zu lösen?"

### Quick 4: Error Message Helper
Kopiere eine Fehlermeldung die du hattest in KI und frage nach der Lösung.

### Quick 5: Naming Convention
Frage KI: "Was sind Best Practices für Datenbank-Naming Conventions?" Vergleiche mit dem was du bisher verwendet hast.

---

## Reflexionsfragen (für alle Optionen)

Am Ende deiner Vorbereitung, beantworte kurz:

1. **Vertrauen:** Wie sehr vertraust du KI-generierten Code? (1-10)
2. **Nützlichkeit:** Wie hilfreich war KI für deine Aufgabe? (1-10)
3. **Zukunft:** Wirst du KI in zukünftigen Projekten einsetzen?
4. **Grenzen:** Was sind die Grenzen von KI bei Datenbank-Aufgaben?
5. **Lernen:** Hilft KI beim Lernen oder macht es faul?

---

## Tipps für effektive KI-Nutzung

✅ **Sei spezifisch** - Je genauer dein Prompt, desto besser die Antwort
✅ **Kontext geben** - Erkläre was du bereits hast/weisst
✅ **Iterieren** - Erste Antwort nicht perfekt? Nachfragen!
✅ **Verifizieren** - Teste den Code, verlasse dich nicht blind darauf
✅ **Verstehen** - Nutze KI zum Lernen, nicht nur zum Copy-Paste
✅ **Dokumentieren** - Notiere was funktioniert hat für später

---

## Abgabe

**Was:** 
- Mindestens eine Option vollständig bearbeitet
- Dokumentation/Notizen deiner Erfahrungen
- Reflexionsfragen beantwortet

**Wie:**
- PDF, Word, Markdown oder direkt in Teams/Moodle
- Mit Screenshots/Code-Beispielen
- 1-3 Seiten (je nach Option)

**Wann:**
- Vor Lektion 9
- Spätestens: [Datum einfügen]

---

**Viel Spass beim Experimentieren mit KI-Tools!** 🤖

Die Erfahrungen aus diesem Vorbereitungsauftrag werden wir in Lektion 9 diskutieren und vertiefen.

© 2024 HFTM
