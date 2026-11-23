# Übung 13: Projekt-Abschluss & Präsentation

## Credit 13: Finale Präsentation (20 Punkte)

### Übersicht

Die finale Präsentation ist der Höhepunkt des Kurses. Sie demonstrieren Ihr vollständiges Projekt vor der Klasse und zeigen, was Sie gelernt haben.

**Gewichtung:** 20 Punkte = 20% der Gesamtnote (zusätzlich zu 30% Projektcode)

**Dauer:** 7 Minuten Präsentation + 3 Minuten Fragen

---

## Anforderungen

### 1. Projekt muss komplett sein

#### Backend (Pflicht)
- [ ] Alle CRUD Endpoints funktionieren
- [ ] Mindestens 2 JOIN Endpoints
- [ ] Error Handling implementiert
- [ ] Input Validation vorhanden
- [ ] Prepared Statements überall

#### Datenbank (Pflicht)
- [ ] Mindestens 4 Tabellen
- [ ] Alle Foreign Keys korrekt
- [ ] ER-Diagramm erstellt
- [ ] SQL Dump funktioniert
- [ ] Testdaten vorhanden

#### Frontend (Optional, aber empfohlen)
- [ ] Kann Daten anzeigen (GET)
- [ ] Kann Daten erstellen (POST)
- [ ] Kann Daten bearbeiten (PUT)
- [ ] Kann Daten löschen (DELETE)

#### Dokumentation (Pflicht)
- [ ] README.md komplett
- [ ] API Dokumentation
- [ ] Installation Instructions
- [ ] Screenshots vorhanden

---

### 2. Präsentations-Struktur (7 Minuten)

#### Minute 1: Intro & Projektidee (1 Min)
- Was ist dein Projekt?
- Welches Problem löst es?
- Für wen ist es gedacht?

**Beispiel:**
> "Mein Projekt ist eine Bibliotheksverwaltung für die HFTM. Es ermöglicht Studierenden, Bücher zu suchen, auszuleihen und zu reservieren. Bibliothekare können den Bestand verwalten."

---

#### Minuten 2-3: Datenbank-Design (2 Min)
- Zeige ER-Diagramm
- Erkläre wichtigste Tabellen
- Erkläre Beziehungen
- Warum diese Struktur?

**Zeige:**
- ER-Diagramm (Bildschirm teilen)
- Erkläre 2-3 wichtigste Tabellen
- Erkläre 1-2 wichtige Beziehungen

**Beispiel:**
> "Meine Datenbank hat 5 Tabellen: Users, Books, Authors, Lends, und Categories. Users und Books haben eine N:M Beziehung über die Lends-Tabelle, weil ein User mehrere Bücher ausleihen kann und ein Buch von verschiedenen Usern ausgeliehen werden kann."

---

#### Minuten 4-6: Live Demo (3 Min)
- Backend API demonstrieren
- Frontend zeigen (falls vorhanden)
- 2-3 Hauptfunktionen zeigen

**Demo-Ablauf:**
1. Zeige Daten abrufen (GET)
2. Zeige Daten erstellen (POST)
3. Zeige eine Besonderheit deines Projekts

**Tipps:**
- Vorbereitet sein mit offener Postman Collection
- Oder Frontend bereits geöffnet
- Backup: Screenshots falls Live-Demo nicht funktioniert

---

#### Minute 7: Technologie & Learnings (1 Min)
- Welche Technologien verwendet?
- Was war die größte Herausforderung?
- Was hast du gelernt?

**Beispiel:**
> "Ich habe Node.js mit Express für das Backend verwendet, MySQL für die Datenbank, und React für das Frontend. Die größte Herausforderung war die Implementierung der N:M Beziehung für die Ausleihen. Ich habe viel über JOINs und Datenbank-Design gelernt."

---

### 3. Fragen & Antworten (3 Minuten)

**Häufige Fragen:**
- Wie würdest du X erweitern/verbessern?
- Warum hast du Technologie X gewählt?
- Wie funktioniert Feature Y genau?
- Was würdest du anders machen?

**Vorbereitung:**
- Überlege dir mögliche Fragen
- Sei ehrlich wenn du etwas nicht weißt
- Zeige, dass du verstehst was du gebaut hast

---

## Bewertungsraster Credit 13

### Präsentation (20 Punkte)

| Kriterium | Punkte | Beschreibung |
|-----------|--------|--------------|
| **Projektidee & Intro** | 2 | Klare Erklärung des Problems und der Lösung |
| **Datenbank-Design** | 4 | ER-Diagramm, Tabellen, Beziehungen erklärt |
| **Live Demo** | 6 | Backend funktioniert, Funktionen demonstriert |
| **Technisches Verständnis** | 4 | Kann Technologien und Entscheidungen erklären |
| **Fragen beantworten** | 2 | Verständnis des eigenen Codes |
| **Zeit & Professionalität** | 2 | 7 Min eingehalten, professionell präsentiert |
| **TOTAL** | **20** | |

---

## Vorbereitung - Checkliste

### 2 Wochen vorher
- [ ] Projekt-Code fertigstellen
- [ ] Alle Features testen
- [ ] Dokumentation schreiben
- [ ] ER-Diagramm erstellen
- [ ] Screenshots machen

### 1 Woche vorher
- [ ] Präsentations-Folien erstellen (optional)
- [ ] Demo vorbereiten (Postman oder Frontend)
- [ ] Überlegen welche Features zeigen
- [ ] Backup-Screenshots vorbereiten
- [ ] Zeit stoppen (max 7 min)

### 1 Tag vorher
- [ ] Komplette Präsentation durchspielen
- [ ] Mit jemandem üben
- [ ] Alle Programme/Tools testen
- [ ] Backup-Plan überlegen
- [ ] Ausgeschlafen sein! 😊

### Am Präsentationstag
- [ ] Früh da sein
- [ ] Laptop geladen
- [ ] Internet-Verbindung testen
- [ ] Postman/Tools geöffnet
- [ ] Tief durchatmen 🧘

---

## Präsentations-Template

### Slide 1: Titel
```
Projekt: [Name]
Student: [Dein Name]
Kurs: SY302 Databases
Datum: [Datum]
```

### Slide 2: Projektidee
```
Problem:
- Was ist das Problem?

Lösung:
- Wie löst dein Projekt das?

Zielgruppe:
- Für wen ist es?
```

### Slide 3: ER-Diagramm
```
[Bild des ER-Diagramms]

Haupttabellen:
- Tabelle 1: Beschreibung
- Tabelle 2: Beschreibung
- Tabelle 3: Beschreibung
```

### Slide 4: Technologie-Stack
```
Backend:
- Node.js + Express

Datenbank:
- MySQL / MongoDB

Frontend: (optional)
- React / Vue / HTML

Tools:
- Postman, Git, VS Code
```

### Slide 5: Demo
```
[Screenshot oder Live-Demo]

Features:
1. Feature 1
2. Feature 2
3. Feature 3
```

### Slide 6: Learnings
```
Herausforderungen:
- Challenge 1
- Challenge 2

Was ich gelernt habe:
- Learning 1
- Learning 2

Verbesserungen:
- Was würde ich anders machen?
```

### Slide 7: Fragen?
```
Vielen Dank!

Fragen?
```

**Hinweis:** Slides sind OPTIONAL! Du kannst auch ohne präsentieren.

---

## Demo-Varianten

### Option 1: Postman Demo (Empfohlen für Backend-Only)

**Vorbereitung:**
1. Postman Collection mit allen Endpoints
2. Endpoints in logischer Reihenfolge
3. Pre-populated Requests

**Ablauf:**
1. Zeige GET - Daten abrufen
2. Zeige POST - Neue Daten erstellen
3. Zeige JOIN - Verknüpfte Daten

**Beispiel:**
```
1. GET /api/books - "Hier sehen wir alle Bücher..."
2. POST /api/books - "Jetzt erstelle ich ein neues Buch..."
3. GET /api/books/with-authors - "Und hier mit den Autoren..."
```

---

### Option 2: Frontend Demo (Falls vorhanden)

**Vorbereitung:**
1. Frontend gestartet und getestet
2. Test-Daten in DB
3. Features funktionieren

**Ablauf:**
1. Zeige Hauptseite
2. Zeige Create-Funktion
3. Zeige Edit/Delete

---

### Option 3: Hybrid (Backend + Frontend)

**Ablauf:**
1. Zeige Frontend (User-Perspektive)
2. Zeige Backend in Postman (Technische Details)
3. Erkläre Zusammenhang

---

## Backup-Plan

### Was tun wenn...

#### ...die Demo nicht funktioniert?
- 📸 Zeige vorbereitete Screenshots
- 📹 Zeige aufgenommenes Demo-Video
- 💬 Erkläre verbal was passieren sollte

#### ...die Zeit zu knapp wird?
- Fokus auf wichtigste 2-3 Features
- Demo kürzen
- Schneller sprechen (aber verständlich!)

#### ...du eine Frage nicht beantworten kannst?
- Ehrlich sagen "Das weiß ich nicht genau"
- Erklären was du weißt
- Anbieten, es nachzuschauen

#### ...Technik-Probleme?
- Immer Backup-Screenshots dabei haben
- Notfalls auf Paper/Whiteboard erklären
- Ruhig bleiben!

---

## Tipps für eine gute Präsentation

### 🎯 Inhalt
✅ Fokus auf das Wichtigste
✅ Zeige was funktioniert
✅ Erkläre WARUM, nicht nur WAS
✅ Zeige dass du es verstehst

### 🗣️ Vortrag
✅ Langsam und deutlich sprechen
✅ Publikum anschauen (nicht nur Screen)
✅ Begeisterung zeigen
✅ Pausen machen

### ⏱️ Timing
✅ 7 Minuten einhalten
✅ Nicht zu schnell, nicht zu langsam
✅ Stoppe Zeit beim Üben
✅ Plan B wenn Zeit zu knapp

### 🎨 Visualisierung
✅ ER-Diagramm zeigen
✅ Screenshots verwenden
✅ Live Demo wenn möglich
✅ Nicht zu viel Text auf Slides

### 😌 Nervosität
✅ Gut vorbereiten = weniger nervös
✅ Mehrmals üben
✅ Tief durchatmen vor Start
✅ Alle sind auf deiner Seite!

---

## Häufige Fehler vermeiden

### ❌ Zu viele Details
> "Hier ist Zeile 47 wo ich einen Loop gemacht habe und dann..."

### ✅ Big Picture
> "Die API hat 5 Endpoints für CRUD-Operationen. Schauen wir uns einen an..."

---

### ❌ Nur Code zeigen
> *Scrollt durch 500 Zeilen Code*

### ✅ Features demonstrieren
> "Schauen wir uns an wie man ein Buch erstellt. Ich sende eine POST-Request..."

---

### ❌ Keine Struktur
> *Springt wild zwischen Themen*

### ✅ Logischer Aufbau
> "Zuerst die Idee, dann das Design, dann die Demo, dann Learnings"

---

### ❌ Zeit überschreiten
> *Nach 10 Minuten immer noch beim 2. Punkt*

### ✅ Zeit im Griff
> *7 Minuten, alle Punkte abgedeckt*

---

## Nach der Präsentation

### Abgabe (direkt nach Präsentation)
- [ ] Code auf GitHub/GitLab
- [ ] README.md komplett
- [ ] SQL Dump
- [ ] .env.example
- [ ] Präsentations-Slides (optional)

### Selbstreflexion
- Was lief gut?
- Was würdest du nächstes Mal anders machen?
- Was hast du gelernt?

---

## Beispiel-Timing (7 Minuten)

```
00:00 - 00:30  Intro & Begrüßung
00:30 - 01:00  Projektidee erklären
01:00 - 03:00  Datenbank-Design (ER-Diagramm)
03:00 - 06:00  Live Demo (3 Features)
06:00 - 07:00  Technologie & Learnings
07:00 - 10:00  Fragen beantworten
```

---

## Motivations-Spruch

> "Eine gute Präsentation zeigt nicht, dass du ALLES weißt,  
> sondern dass du verstehst, was du gebaut hast.  
> Fokussiere dich auf deine Stärken!" 

---

**Du schaffst das! 🚀**

**Viel Erfolg bei der Präsentation! 🎉**
