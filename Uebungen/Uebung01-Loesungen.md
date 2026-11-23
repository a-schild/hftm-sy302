# Übungsblatt 1: Daten, Datenbanken und DBMS

## Credit 1 - Theoriefragen (10 Punkte)

*Bewertung: Die Punkte in dieser Übung sind ein internes Bewertungsraster. Für die Note wird jeder Credit auf 0–5 Punkte skaliert (fristgerechte, vollständige Abgabe = 5 Punkte, nicht abgegeben = 0 Punkte).*

### Aufgabe 1: Grundkonzepte (4 Punkte)

**a)** Erkläre den Unterschied zwischen Daten und Informationen. Gib je ein Beispiel.

**b)** Nenne 4 Vorteile eines DBMS gegenüber dateibasierter Speicherung.

**c)** Was bedeutet ACID? Erkläre jede Eigenschaft in einem Satz.

**d)** Nenne 3 verschiedene DBMS und ihre Haupteinsatzgebiete.

---

### Aufgabe 2: Datentypen (3 Punkte)

Wähle für folgende Daten den passenden SQL-Datentyp und begründe kurz:

**a)** Schweizer Postleitzahl (z.B. 3000, 8001)

**b)** Preis eines Produkts (z.B. 29.95 CHF)

**c)** Beschreibung eines Buches (bis zu 1000 Zeichen)

**d)** Geburtsdatum einer Person

**e)** Status eines Produkts (nur: verfügbar, ausverkauft, vorbestellt)

**f)** ISBN einer Buchnummer (z.B. 978-3-16-148410-0)

---

### Aufgabe 3: ER-Diagramm lesen (3 Punkte)

Gegeben ist folgendes ER-Diagramm:

```
┌───────────┐        ┌───────────┐
│  Student  │        │   Kurs    │
│───────────│        │───────────│
│ id        │ N    M │ id        │
│ name      │────────│ name      │
│ email     │belegt  │ credits   │
└───────────┘        └───────────┘
```

**a)** Welche Kardinalität hat die Beziehung? Erkläre in eigenen Worten.

**b)** Wie viele Kurse kann ein Student belegen?

**c)** Wie viele Studenten können einen Kurs belegen?

**d)** Wie wird diese Beziehung in relationalen Datenbanken umgesetzt?

---

## Lösungen

### Lösung Aufgabe 1:

**a) Daten vs. Informationen:**
- **Daten**: Rohe Fakten ohne Kontext. Beispiel: "25, München, 2024"
- **Informationen**: Daten mit Bedeutung/Kontext. Beispiel: "Person ist 25 Jahre alt, wohnt in München, im Jahr 2024"

**b) Vorteile DBMS:**
1. Datenredundanz vermeiden (eine zentrale Quelle)
2. Datenkonsistenz sicherstellen (Constraints, Transaktionen)
3. Mehrbenutzerzugriff verwalten (gleichzeitige Zugriffe)
4. Zugriffskontrolle (Sicherheit, Berechtigungen)
5. Backup und Recovery (automatische Sicherungen)
6. Datenintegrität (Referenzielle Integrität)

**c) ACID:**
- **Atomicity**: Transaktion wird entweder ganz oder gar nicht ausgeführt
- **Consistency**: Datenbank bleibt in konsistentem Zustand
- **Isolation**: Parallele Transaktionen beeinflussen sich nicht
- **Durability**: Bestätigte Transaktionen bleiben permanent gespeichert

**d) DBMS-Beispiele:**
1. **MySQL/MariaDB**: Webapplikationen, Open Source
2. **PostgreSQL**: Komplexe Anwendungen, erweiterte Features
3. **MongoDB**: NoSQL, flexible Dokumentenstruktur
4. **Oracle**: Enterprise-Anwendungen, Mission-Critical
5. **SQLite**: Embedded Systems, Mobile Apps

### Lösung Aufgabe 2:

| Daten | Datentyp | Begründung |
|-------|----------|------------|
| Postleitzahl | `CHAR(4)` oder `VARCHAR(4)` | Feste Länge, beginnt mit 0 möglich |
| Preis | `DECIMAL(10,2)` | Fixe Dezimalstellen, genau für Geldbeträge |
| Beschreibung | `VARCHAR(1000)` oder `TEXT` | Variable Länge bis 1000 Zeichen |
| Geburtsdatum | `DATE` | Nur Datum, keine Zeit nötig |
| Status | `ENUM('verfügbar','ausverkauft','vorbestellt')` | Feste Werte |
| ISBN | `VARCHAR(20)` | Enthält Bindestriche, variable Länge |

### Lösung Aufgabe 3:

**a) Kardinalität N:M (Viele-zu-Viele)**
Ein Student kann mehrere Kurse belegen, und ein Kurs kann mehrere Studenten haben.

**b)** Ein Student kann **beliebig viele** (0 bis N) Kurse belegen.

**c)** Ein Kurs kann von **beliebig vielen** (0 bis M) Studenten belegt werden.

**d) Umsetzung:** 
Benötigt eine **Zwischentabelle** (Junction Table):

```sql
students (id, name, email)
courses (id, name, credits)
enrollments (id, student_id, course_id, enrollment_date, grade)
```

---

## Bewertung

| Aufgabe | Punkte | Erreicht |
|---------|--------|----------|
| Aufgabe 1a | 1 | |
| Aufgabe 1b | 1 | |
| Aufgabe 1c | 1 | |
| Aufgabe 1d | 1 | |
| Aufgabe 2 (6×0.5) | 3 | |
| Aufgabe 3a-d | 3 | |
| **Total** | **10** | |

---

## Abgabe

- **Format**: PDF oder Word
- **Deadline**: Siehe Moodle
- **Abgabe**: Moodle Upload
