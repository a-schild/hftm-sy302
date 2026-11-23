# Lektion 1: Daten, Datenbanken und DBMS

## Lernziele

Der/die Studierende ist in der Lage...
- Den Nutzen von Datenbanken zu erklären
- Die unterschiedlichen Datenbankarten mit ihren Grundeigenschaften aufzulisten
- Grundlegende Datenprobleme (Redundanz, Inkonsistenz) zu erkennen

## Was sind Daten?

**Daten** sind Fakten, die in einer strukturierten oder unstrukturierten Form dargestellt werden.

### Unterschied: Daten vs. Information vs. Wissen

```
Daten → Information → Wissen → Weisheit
```

| Begriff | Beschreibung | Beispiel |
|---------|--------------|----------|
| **Daten** | Rohe Fakten ohne Kontext | 25, 42, "Müller" |
| **Information** | Daten mit Bedeutung | Temperatur: 25°C, Alter: 42 Jahre, Name: Müller |
| **Wissen** | Verstandene Information | "Bei 25°C fühlen sich Menschen wohl" |
| **Weisheit** | Angewandtes Wissen | "Klimaanlage auf 25°C stellen" |

### Eigenschaften von Daten

1. **Inhalt**: Was für Informationen sind vorhanden?
2. **Struktur**: Wie sind die Daten organisiert?
3. **Syntax**: Gibt es Regeln für die Darstellung?
4. **Semantik**: Was bedeuten die Daten?

## Datenqualitätsprobleme

### 1. Redundanz

**Definition:** Dieselben Daten werden mehrfach gespeichert.

**Beispiel:**
```
Kunde 1: Name="Max Müller", Adresse="Hauptstr. 1", Stadt="Bern"
Kunde 2: Name="Max Müller", Adresse="Hauptstr. 1", Stadt="Bern"
```

**Probleme:**
- Mehr Speicherplatz
- Inkonsistenz bei Updates möglich
- Schwieriger zu warten

### 2. Inkonsistenz

**Definition:** Widersprüchliche Daten im System.

**Beispiel:**
```
Tabelle 1: Kunde "Max Müller" wohnt in "Bern"
Tabelle 2: Kunde "Max Müller" wohnt in "Zürich"
```

**Ursachen:**
- Redundante Datenspeicherung
- Fehlende Synchronisation
- Manuelle Datenpflege

### 3. Fehlende Datenintegrität

**Integritätsprobleme:**
- Fehlende Werte (NULL wo nicht erlaubt)
- Falsche Datentypen (Text in Zahlenfeld)
- Verletzte Beziehungen (Verweis auf nicht existierende Daten)

## Praktische Übung: Analyse einer Excel-Tabelle

**Datei:** `SY302-01 - KassaBonTotal.xlsx`

### Aufgabenstellung (20 Minuten)

Analysiere das erste Blatt der Excel-Datei auf:

1. **Inhalt**: Was für Informationen sind vorhanden?
   - Welche Spalten gibt es?
   - Welche Art von Daten werden gespeichert?

2. **Syntax**: Ist eine Syntax erkennbar? Ist diese stimmig/einheitlich?
   - Sind Datumsformate einheitlich?
   - Sind Preise einheitlich formatiert?
   - Gibt es Leerzeichen, Sonderzeichen?

3. **Redundanzen**: Hat es Redundanzen in der Tabelle? Wenn ja, welche?
   - Werden Daten mehrfach gespeichert?
   - Wo könnten Daten ausgelagert werden?

4. **Konsistenz**: Sind die Daten konsistent?
   - Gibt es Widersprüche?
   - Welche Auswirkungen haben Inkonsistenzen?

### Typische Probleme in Excel/Flat Files

- **Keine Datentypen**: Alles kann überall stehen
- **Keine Validierung**: Fehlerhafte Eingaben möglich
- **Keine Beziehungen**: Redundante Datenspeicherung
- **Keine Transaktionen**: Daten können inkonsistent werden
- **Schwierige Suche**: Keine effizienten Queries
- **Keine Mehrbenutzerfähigkeit**: Konflikte bei gleichzeitigem Zugriff

## Was ist eine Datenbank?

**Datenbank** = Organisierte Sammlung strukturierter Daten

### Vorteile von Datenbanken

1. **Strukturierung**: Klare Organisation der Daten
2. **Vermeidung von Redundanz**: Daten werden nur einmal gespeichert
3. **Datenkonsistenz**: Regeln gewährleisten korrekte Daten
4. **Datenintegrität**: Beziehungen zwischen Daten bleiben erhalten
5. **Mehrbenutzerzugriff**: Mehrere User gleichzeitig
6. **Sicherheit**: Zugriffsrechte und Authentifizierung
7. **Backup & Recovery**: Automatische Sicherung
8. **Effiziente Suche**: Schnelle Queries auch bei grossen Datenmengen

## DBMS - Datenbankmanagementsystem

**DBMS** = Software zur Verwaltung von Datenbanken

### Funktionen eines DBMS

- **Datendefinition** (DDL): Struktur der Datenbank definieren
- **Datenmanipulation** (DML): Daten einfügen, ändern, löschen
- **Datenabfrage**: Daten suchen und abrufen
- **Zugriffskontrolle**: Benutzer und Rechte verwalten
- **Transaktionsverwaltung**: ACID-Eigenschaften sicherstellen
- **Backup & Recovery**: Datensicherung

### Bekannte DBMS

**Relational:**
- MySQL / MariaDB (Open Source)
- PostgreSQL (Open Source)
- Oracle Database (Kommerziell)
- Microsoft SQL Server (Kommerziell)
- SQLite (Eingebettet)

**NoSQL:**
- MongoDB (Dokumentenorientiert)
- Redis (Key-Value)
- Cassandra (Column-Family)
- Neo4j (Graph)

## Datenbankarten

### 1. Relationale Datenbanken (RDBMS)

**Konzept:** Daten in Tabellen (Relationen) mit Beziehungen

**Eigenschaften:**
- Tabellen mit Zeilen und Spalten
- Primary Keys und Foreign Keys
- SQL als Abfragesprache
- ACID-Transaktionen
- Normalisierung

**Verwendung:**
- Geschäftsanwendungen (ERP, CRM)
- E-Commerce
- Banking
- Überall wo strukturierte Daten mit Beziehungen

**Beispiel-Struktur:**
```
Tabelle: Kunden
+----+----------+-------------------+
| ID | Name     | Email             |
+----+----------+-------------------+
| 1  | Müller   | mueller@email.ch  |
| 2  | Schmidt  | schmidt@email.ch  |
+----+----------+-------------------+

Tabelle: Bestellungen
+----+-----------+--------+-------+
| ID | Datum     | Kunde  | Total |
+----+-----------+--------+-------+
| 1  | 2024-10-01| 1      | 99.90 |
| 2  | 2024-10-05| 2      | 149.50|
+----+-----------+--------+-------+
```

### 2. Dokumentenorientierte Datenbanken

**Konzept:** Daten als JSON-ähnliche Dokumente

**Eigenschaften:**
- Flexibles Schema
- Verschachtelte Strukturen
- Kein JOIN nötig
- Horizontal skalierbar

**Verwendung:**
- Content Management
- Kataloge
- User-Profile
- Real-time Analytics

**Beispiel:** MongoDB
```json
{
    "_id": "507f1f77bcf86cd799439011",
    "name": "Max Müller",
    "email": "mueller@email.ch",
    "orders": [
        {
            "order_id": 1,
            "date": "2024-10-01",
            "total": 99.90
        }
    ]
}
```

### 3. Key-Value Stores

**Konzept:** Einfache Schlüssel-Wert-Paare

**Eigenschaften:**
- Sehr schnell
- Einfache Struktur
- In-Memory möglich
- Gut für Caching

**Verwendung:**
- Session-Storage
- Caching
- Real-time Anwendungen

**Beispiel:** Redis
```
SET user:1001 "Max Müller"
SET session:abc123 '{"userId":1001,"expires":"2024-12-31"}'
GET user:1001  // Returns: "Max Müller"
```

### 4. Column-Family Stores

**Konzept:** Spalten statt Zeilen als Speichereinheit

**Eigenschaften:**
- Optimiert für Lese-Performance
- Grosse Datenmengen
- Horizontal skalierbar
- Eventual Consistency

**Verwendung:**
- Big Data
- Analytics
- Time-Series Daten
- IoT

**Beispiel:** Cassandra

### 5. Graph-Datenbanken

**Konzept:** Daten als Knoten und Kanten (Beziehungen)

**Eigenschaften:**
- Beziehungen sind First-Class Citizens
- Effiziente Traversierung
- Flexible Struktur

**Verwendung:**
- Social Networks
- Empfehlungssysteme
- Fraud Detection
- Netzwerkanalyse

**Beispiel:** Neo4j
```
(Max)-[:KENNT]->(Anna)
(Max)-[:ARBEITET_BEI]->(HFTM)
(Anna)-[:ARBEITET_BEI]->(HFTM)
```

## Wo werden Daten gespeichert?

### Geografische Verteilung

**Cloud-Anbieter Rechenzentren:**
- AWS: Weltweit (Regionen: EU-West (Irland), EU-Central (Frankfurt))
- Microsoft Azure: Weltweit (Schweiz, Deutschland, etc.)
- Google Cloud: Weltweit (Belgien, Niederlande für EU)

**Schweizer Cloud-Anbieter:**
- Swisscom
- Infomaniak
- Nine

**Rechtliche Aspekte:**
- Datenschutz (DSGVO, DSG)
- Datenhoheit
- Compliance-Anforderungen

## ACID-Eigenschaften

Relationale Datenbanken garantieren **ACID**:

### A - Atomicity (Atomarität)
Transaktion ist unteilbar: Entweder alles oder nichts.

**Beispiel:** Geldüberweisung
```sql
BEGIN TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;  -- Beide Updates oder keines
```

### C - Consistency (Konsistenz)
Datenbank bleibt in konsistentem Zustand.

**Beispiel:** Constraints werden eingehalten
```sql
-- Wenn balance < 0 nicht erlaubt ist, wird Transaktion abgelehnt
CHECK (balance >= 0)
```

### I - Isolation (Isolierung)
Transaktionen beeinflussen sich nicht gegenseitig.

**Beispiel:** Zwei User ändern gleichzeitig Daten
- User A liest Kontostand: 1000 CHF
- User B liest Kontostand: 1000 CHF
- User A bucht ab: 100 CHF
- User B bucht ab: 200 CHF
- Endergebnis: 700 CHF (nicht 800 oder 900)

### D - Durability (Dauerhaftigkeit)
Committed Daten bleiben dauerhaft gespeichert.

**Beispiel:** Nach COMMIT überstehen Daten auch Stromausfall

## CAP-Theorem (für verteilte Systeme)

Bei verteilten Datenbanken kann man nur 2 von 3 haben:

- **C**onsistency (Konsistenz): Alle Knoten sehen dieselben Daten
- **A**vailability (Verfügbarkeit): System antwortet immer
- **P**artition Tolerance (Partitionstoleranz): System funktioniert auch bei Netzwerkausfällen

**Beispiele:**
- **CA**: Relationale DB in einem Rechenzentrum
- **CP**: MongoDB, HBase
- **AP**: Cassandra, DynamoDB

## Vorbereitungsauftrag (Credit 1)

### Aufgabenstellung

1. **Videos anschauen:**
   - Daten und Datenbanken Grundlagen
   - DBMS Einführung

2. **Datenanalyse in deinem Alltag:**
   
   **Teil A - Datenverwendung:**
   Liste auf, wo du in der letzten Woche Daten **verwendet** hast:
   - Mindestens 5 Beispiele
   - Welche Daten? (z.B. Kontakte, Karten, Produkte)
   - Welche Anwendung? (z.B. Google Maps, Online-Shop)
   
   **Teil B - Daten geliefert:**
   Liste auf, wo du in der letzten Woche Daten **geliefert** hast:
   - Mindestens 5 Beispiele
   - Welche Daten? (z.B. Suchbegriffe, Standort, Formular)
   - An wen? (z.B. Google, Instagram, Online-Shop)

3. **Datenspeicherung:**
   - Wo werden diese Daten gespeichert? (Geografisch)
   - Bei welchen Firmen/Behörden?
   - Welche Rechenzentren? (wenn bekannt)

### Beispiel

**Verwendet:**
- Google Maps: Kartenansicht, Verkehrsdaten → Google Server (USA/EU)
- WhatsApp: Chat-Historie → Meta Server (EU)
- Netflix: Film-Katalog → AWS Server (EU)

**Geliefert:**
- Instagram: Likes, Kommentare, Standort → Meta (EU)
- Online-Shop: Name, Adresse, Zahlungsdaten → Shop-Server (CH/EU)
- Suchmaschine: Suchbegriffe, Klicks → Google (USA/EU)

## Zusammenfassung

### Key Takeaways

- **Daten ≠ Information**: Daten brauchen Kontext
- **Datenqualität**: Redundanz und Inkonsistenz vermeiden
- **Datenbanken**: Strukturierte Speicherung mit vielen Vorteilen
- **DBMS**: Software zur Verwaltung von Datenbanken
- **Verschiedene Datenbankarten**: Für verschiedene Anwendungsfälle
- **ACID**: Garantien für relationale Datenbanken

### Wichtige Begriffe

- **Datenbank**: Organisierte Datensammlung
- **DBMS**: Database Management System
- **Redundanz**: Mehrfache Datenspeicherung
- **Inkonsistenz**: Widersprüchliche Daten
- **ACID**: Atomicity, Consistency, Isolation, Durability
- **SQL**: Structured Query Language
- **NoSQL**: Not only SQL

## Nächste Schritte

In Lektion 2 lernen wir:
- Wie man Datenbanken designt
- ER-Diagramme erstellen
- Normalisierung
- SQL DDL (Data Definition Language)

## Zusätzliche Ressourcen

- [What is Data? - Wikipedia](https://en.wikipedia.org/wiki/Data)
- [Database Fundamentals](https://www.oracle.com/database/what-is-database/)
- [ACID Properties](https://en.wikipedia.org/wiki/ACID)
- [CAP Theorem Explained](https://www.ibm.com/topics/cap-theorem)
