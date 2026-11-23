# Lektion 5: Advanced SQL - DCL & TCL

## Lernziele

Der/die Studierende ist in der Lage...
- Berechtigungen im Datenbanksystem umzusetzen
- Zu erkennen wann Transaktionen in SQL Datenbanken eingesetzt werden sollen
- Den Einsatzzweck von Transaktionen zu erklären
- Ein Berechtigungskonzept und die entsprechende Berechtigungsmatrix zu erstellen
- Einen MariaDB-Server für den Netzwerkzugriff freizugeben und Benutzer mit passendem Host-Teil anzulegen

## DCL - Data Control Language

**DCL** = SQL-Befehle zur Kontrolle von Zugriffsrechten

### Wichtigste DCL-Befehle

- `GRANT` - Rechte vergeben
- `REVOKE` - Rechte entziehen

## User Management

### User erstellen

```sql
-- User erstellen
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';

-- User von überall
CREATE USER 'username'@'%' IDENTIFIED BY 'password';

-- User von bestimmter IP
CREATE USER 'username'@'192.168.1.100' IDENTIFIED BY 'password';
```

### User löschen

```sql
DROP USER 'username'@'localhost';
```

### Password ändern

```sql
-- Eigenes Password
SET PASSWORD = PASSWORD('new_password');

-- Password eines anderen Users (als root)
SET PASSWORD FOR 'username'@'localhost' = PASSWORD('new_password');

-- Modern (MySQL 5.7+)
ALTER USER 'username'@'localhost' IDENTIFIED BY 'new_password';
```

### User auflisten

```sql
-- Alle User anzeigen
SELECT User, Host FROM mysql.user;

-- Aktueller User
SELECT CURRENT_USER();
```

## GRANT - Rechte vergeben

### Syntax

```sql
GRANT privilege_type ON database.table TO 'user'@'host';
```

### Privilege-Typen

**Daten-Operationen:**
- `SELECT` - Daten lesen
- `INSERT` - Daten einfügen
- `UPDATE` - Daten ändern
- `DELETE` - Daten löschen

**Struktur-Operationen:**
- `CREATE` - Tabellen/DBs erstellen
- `ALTER` - Tabellen ändern
- `DROP` - Tabellen/DBs löschen
- `INDEX` - Indizes erstellen/löschen

**Administrative Rechte:**
- `ALL PRIVILEGES` - Alle Rechte
- `GRANT OPTION` - Rechte weitergeben können
- `CREATE USER` - User erstellen
- `RELOAD` - Server neu laden

### Beispiele

**Basis-Rechte:**
```sql
-- SELECT auf eine Datenbank
GRANT SELECT ON hftm_library.* TO 'reader'@'localhost';

-- SELECT, INSERT, UPDATE auf eine Tabelle
GRANT SELECT, INSERT, UPDATE ON hftm_library.books TO 'editor'@'localhost';

-- Alle Rechte auf eine Datenbank
GRANT ALL PRIVILEGES ON hftm_library.* TO 'admin'@'localhost';

-- Rechte aktivieren
FLUSH PRIVILEGES;
```

**Spezifische Spalten:**
```sql
-- Nur bestimmte Spalten
GRANT SELECT (Titel, AuthorsID), UPDATE (Titel) 
ON hftm_library.books TO 'limited_user'@'localhost';
```

**Mit GRANT OPTION:**
```sql
-- User kann Rechte weitergeben
GRANT SELECT, INSERT ON hftm_library.* TO 'manager'@'localhost' 
WITH GRANT OPTION;
```

## REVOKE - Rechte entziehen

```sql
-- Einzelne Rechte entziehen
REVOKE INSERT, UPDATE ON hftm_library.books FROM 'editor'@'localhost';

-- Alle Rechte entziehen
REVOKE ALL PRIVILEGES ON hftm_library.* FROM 'user'@'localhost';

-- GRANT OPTION entziehen
REVOKE GRANT OPTION ON hftm_library.* FROM 'manager'@'localhost';

-- Rechte aktivieren
FLUSH PRIVILEGES;
```

## Berechtigungskonzept erstellen

### Schritt 1: Rollen definieren

**Beispiel: Library System**

| Rolle | Beschreibung | Rechte |
|-------|--------------|--------|
| Administrator | Volle Kontrolle | ALL PRIVILEGES |
| Librarian | Bücher verwalten | SELECT, INSERT, UPDATE, DELETE auf books, authors |
| Customer Service | Kunden und Ausleihen verwalten | SELECT, INSERT, UPDATE auf customers, lends |
| Reader | Nur Lesezugriff | SELECT auf alle Tabellen |
| Reporter | Reports erstellen | SELECT auf alle Tabellen |

### Schritt 2: Berechtigungsmatrix

|  | books | authors | customers | lends | publishers |
|--|-------|---------|-----------|-------|------------|
| **Administrator** | ALL | ALL | ALL | ALL | ALL |
| **Librarian** | CRUD | CRUD | R | R | R |
| **Customer Service** | R | R | CRUD | CRUD | - |
| **Reader** | R | R | - | - | - |
| **Reporter** | R | R | R | R | R |

Legende: CRUD = Create, Read, Update, Delete; R = Read only; - = Kein Zugriff

### Schritt 3: Implementation

```sql
-- 1. Administrator
CREATE USER 'db_admin'@'localhost' IDENTIFIED BY 'admin_pw';
GRANT ALL PRIVILEGES ON hftm_library.* TO 'db_admin'@'localhost' 
WITH GRANT OPTION;

-- 2. Librarian
CREATE USER 'librarian'@'localhost' IDENTIFIED BY 'lib_pw';
GRANT SELECT, INSERT, UPDATE, DELETE ON hftm_library.books TO 'librarian'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON hftm_library.authors TO 'librarian'@'localhost';
GRANT SELECT ON hftm_library.customers TO 'librarian'@'localhost';
GRANT SELECT ON hftm_library.lends TO 'librarian'@'localhost';
GRANT SELECT ON hftm_library.publishers TO 'librarian'@'localhost';

-- 3. Customer Service
CREATE USER 'customer_service'@'localhost' IDENTIFIED BY 'cs_pw';
GRANT SELECT ON hftm_library.books TO 'customer_service'@'localhost';
GRANT SELECT ON hftm_library.authors TO 'customer_service'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON hftm_library.customers TO 'customer_service'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON hftm_library.lends TO 'customer_service'@'localhost';

-- 4. Reader (Read-only)
CREATE USER 'reader'@'localhost' IDENTIFIED BY 'reader_pw';
GRANT SELECT ON hftm_library.books TO 'reader'@'localhost';
GRANT SELECT ON hftm_library.authors TO 'reader'@'localhost';

-- 5. Reporter
CREATE USER 'reporter'@'localhost' IDENTIFIED BY 'report_pw';
GRANT SELECT ON hftm_library.* TO 'reporter'@'localhost';

-- Rechte aktivieren
FLUSH PRIVILEGES;
```

### Rechte überprüfen

```sql
-- Rechte eines Users anzeigen
SHOW GRANTS FOR 'librarian'@'localhost';

-- Eigene Rechte anzeigen
SHOW GRANTS;
```

## TCL - Transaction Control Language

**TCL** = SQL-Befehle zur Steuerung von Transaktionen

### Die 3 TCL-Befehle

- `START TRANSACTION` / `BEGIN` - Transaktion starten
- `COMMIT` - Änderungen bestätigen
- `ROLLBACK` - Änderungen rückgängig machen

## Was sind Transaktionen?

Eine **Transaktion** ist eine Folge von SQL-Befehlen, die als **atomare Einheit** behandelt werden.

### ACID-Eigenschaften (Wiederholung)

- **Atomicity**: Alles oder nichts
- **Consistency**: Konsistenter Zustand
- **Isolation**: Unabhängig von anderen Transaktionen
- **Durability**: Dauerhaft gespeichert nach COMMIT

## Wann Transaktionen verwenden?

### Use Cases

✅ **Transaktion nötig:**
- Geldtransfer (Abbuchung + Gutschrift)
- Bestellung (Bestand reduzieren + Bestellung erstellen)
- User-Registrierung (User + Profile + Permissions)
- Buchausleihe (Buch als ausgeliehen markieren + Ausleihe eintragen)

❌ **Transaktion nicht nötig:**
- Einzelne SELECT-Abfragen
- Einzelne INSERT/UPDATE/DELETE Operationen
- Daten die unabhängig sind

### Beispiel: Geldtransfer

**Ohne Transaktion (GEFÄHRLICH!):**
```sql
-- Wenn hier ein Fehler auftritt, ist Geld weg!
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
-- Server-Crash hier = Geld verloren!
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
```

**Mit Transaktion (SICHER):**
```sql
START TRANSACTION;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

-- Nur wenn beide erfolgreich:
COMMIT;

-- Bei Fehler:
-- ROLLBACK;
```

## Transaktionen in der Praxis

### Grundstruktur

```sql
START TRANSACTION;

-- SQL-Befehle hier
-- ...

-- Alles ok?
COMMIT;

-- Oder bei Fehler:
-- ROLLBACK;
```

### Beispiel: Buchausleihe

```sql
START TRANSACTION;

-- 1. Prüfen ob Buch verfügbar
SELECT AmountInStock FROM books WHERE ID = 42;
-- Wenn AmountInStock > 0:

-- 2. Bestand reduzieren
UPDATE books SET AmountInStock = AmountInStock - 1 WHERE ID = 42;

-- 3. Ausleihe eintragen
INSERT INTO lends (CustomerID, BookID, Date_From, Date_To, Price)
VALUES (15, 42, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 5.00);

-- Alles erfolgreich?
COMMIT;

-- Bei Fehler (z.B. Kunde existiert nicht):
-- ROLLBACK;
```

### Beispiel: Bestellung

```sql
START TRANSACTION;

-- 1. Bestellung erstellen
INSERT INTO orders (customer_id, order_date, total)
VALUES (123, NOW(), 0);

SET @order_id = LAST_INSERT_ID();

-- 2. Bestellpositionen hinzufügen
INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES 
    (@order_id, 10, 2, 29.99),
    (@order_id, 15, 1, 49.99);

-- 3. Bestand reduzieren
UPDATE products SET stock = stock - 2 WHERE id = 10;
UPDATE products SET stock = stock - 1 WHERE id = 15;

-- 4. Gesamtpreis aktualisieren
UPDATE orders 
SET total = (SELECT SUM(quantity * price) FROM order_items WHERE order_id = @order_id)
WHERE id = @order_id;

COMMIT;
```

## Isolation Levels

Transaktionen können unterschiedlich stark isoliert sein.

### Die 4 Isolation Levels

| Level | Dirty Read | Non-Repeatable Read | Phantom Read |
|-------|------------|---------------------|--------------|
| READ UNCOMMITTED | ✅ Möglich | ✅ Möglich | ✅ Möglich |
| READ COMMITTED | ❌ Nicht möglich | ✅ Möglich | ✅ Möglich |
| REPEATABLE READ | ❌ Nicht möglich | ❌ Nicht möglich | ✅ Möglich |
| SERIALIZABLE | ❌ Nicht möglich | ❌ Nicht möglich | ❌ Nicht möglich |

**MySQL/MariaDB Standard:** REPEATABLE READ

### Isolation Level setzen

```sql
-- Für die Session
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Für die nächste Transaktion
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Global (für alle neuen Verbindungen)
SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

### Probleme bei niedrigen Isolation Levels

**Dirty Read:**
- Transaktion A liest Daten die Transaktion B noch nicht committed hat
- B macht ROLLBACK → A hat falsche Daten gelesen

**Non-Repeatable Read:**
- Transaktion A liest Daten zweimal
- Zwischen den Reads ändert Transaktion B die Daten
- A bekommt unterschiedliche Ergebnisse

**Phantom Read:**
- Transaktion A macht SELECT mit WHERE
- Transaktion B fügt passende Zeilen hinzu
- A macht nochmal SELECT → plötzlich mehr Zeilen

## SAVEPOINT - Teilweises Rollback

Mit SAVEPOINT kann man innerhalb einer Transaktion Zwischenstände markieren.

```sql
START TRANSACTION;

INSERT INTO customers (Lastname, Firstname, LocationID) VALUES ('Customer 1', 'Test', 1);
SAVEPOINT sp1;

INSERT INTO customers (Lastname, Firstname, LocationID) VALUES ('Customer 2', 'Test', 1);
SAVEPOINT sp2;

INSERT INTO customers (Lastname, Firstname, LocationID) VALUES ('Customer 3', 'Test', 1);

-- Nur bis sp2 zurück
ROLLBACK TO SAVEPOINT sp2;
-- Customer 3 ist weg, Customer 1 und 2 noch da

-- Alles bestätigen
COMMIT;
```

## Autocommit

MySQL/MariaDB hat standardmässig **Autocommit aktiviert**. Jeder SQL-Befehl wird sofort committed.

```sql
-- Autocommit Status prüfen
SELECT @@autocommit;  -- 1 = an, 0 = aus

-- Autocommit ausschalten
SET autocommit = 0;

-- Jetzt muss man manuell committen
INSERT INTO books (...) VALUES (...);
COMMIT;

-- Autocommit wieder einschalten
SET autocommit = 1;
```

## Locks

Transaktionen können Zeilen oder Tabellen sperren (locken).

### Row-Level Locks

```sql
START TRANSACTION;

-- Zeile für Update sperren
SELECT * FROM books WHERE ID = 42 FOR UPDATE;

-- Jetzt kann kein anderer User diese Zeile ändern
UPDATE books SET AmountInStock = AmountInStock - 1 WHERE ID = 42;

COMMIT;  -- Lock wird freigegeben
```

### Shared Lock (Lese-Sperre)

```sql
START TRANSACTION;

-- Andere können lesen, aber nicht ändern
SELECT * FROM books WHERE ID = 42 LOCK IN SHARE MODE;

-- ...

COMMIT;
```

### Table-Level Locks

```sql
-- Tabelle für Schreiben sperren
LOCK TABLES lends WRITE;

-- Nur diese Session kann schreiben
UPDATE lends SET Price = Price * 1.1;

-- Lock freigeben
UNLOCK TABLES;
```

## Deadlocks

Ein **Deadlock** tritt auf, wenn zwei Transaktionen sich gegenseitig blockieren.

### Beispiel

```
Transaktion A:                  Transaktion B:
1. Lock Zeile 1                 1. Lock Zeile 2
2. Wartet auf Zeile 2...        2. Wartet auf Zeile 1...
   ↓ DEADLOCK! ↓                   ↓ DEADLOCK! ↓
```

**MySQL-Lösung:** Eine Transaktion wird automatisch abgebrochen (ROLLBACK)

### Deadlocks vermeiden

1. **Immer gleiche Reihenfolge** bei Locks
2. **Transaktionen kurz halten**
3. **Niedrigere Isolation Levels** (wenn möglich)
4. **Retry-Logik** in Applikation

## Raspberry Pi: MariaDB im Netzwerk freigeben

Bisher ist MariaDB auf dem Raspberry Pi nur über den SSH-Tunnel erreichbar (Lektion 4). Jetzt geben wir den Server im Netzwerk frei und sehen dabei, warum der Host-Teil eines Benutzers (`'student'@'...'`) wichtig ist.

### 1. bind-address ändern

```bash
ssh <benutzer>@<pi-host>
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

```ini
[mysqld]
# bind-address = 127.0.0.1
bind-address = 0.0.0.0
```

```bash
sudo systemctl restart mariadb
sudo ss -tlnp | grep 3306      # muss 0.0.0.0:3306 zeigen
```

### 2. Benutzer für den Netzwerkzugriff

`'student'@'localhost'` gilt nur für Verbindungen vom Raspberry Pi selbst (auch über den SSH-Tunnel). Für den direkten Zugriff aus dem Netzwerk braucht es einen eigenen Benutzer mit passendem Host-Teil:

```sql
-- sudo mariadb
CREATE USER 'student'@'192.168.%' IDENTIFIED BY 'sicheres_passwort';
GRANT SELECT, INSERT, UPDATE, DELETE ON hftm_library.* TO 'student'@'192.168.%';
FLUSH PRIVILEGES;

SELECT User, Host FROM mysql.user WHERE User = 'student';
SHOW GRANTS FOR 'student'@'192.168.%';
```

`192.168.%` ist ein Beispiel. Verwendet das Netz des Schulzimmers (Angabe im Unterricht).

### 3. Direkt mit HeidiSQL verbinden

Neue Sitzung mit Netzwerktyp **MariaDB or MySQL (TCP/IP)**, Hostname `<pi-host>`, Benutzer `student`, Port `3306`. Vergleicht: Welche Rechte hat `student` jetzt, welche über den SSH-Tunnel?

**Sicherheit:** Port 3306 nie ins Internet öffnen. Im Netzwerk nur Benutzer mit eingeschränktem Host-Teil und minimalen Rechten anlegen, nie `'root'@'%'`. Der SSH-Tunnel bleibt die sicherere Variante.

## Praktische Aufgaben

### Aufgabe 1: Berechtigungskonzept Ärztezentrum

Erstelle ein Berechtigungskonzept für das Ärztezentrum:

**Rollen:**
- Administrator
- Arzt
- Rezeptionist
- Patient (Read-only auf eigene Daten)

**Erstelle:**
1. Rollen-Beschreibungen
2. Berechtigungsmatrix
3. SQL-Befehle zum Anlegen der User
4. SQL-Befehle zum Vergeben der Rechte

### Aufgabe 2: Transaktionen implementieren

Implementiere folgende Transaktionen für die HFTM Library:

1. **Buchausleihe:**
   - Prüfen ob Buch verfügbar
   - Bestand reduzieren
   - Ausleihe eintragen
   - Mit ROLLBACK bei Fehler

2. **Buch zurückgeben:**
   - Ausleihe als beendet markieren
   - Bestand erhöhen
   - Verspätungsgebühr berechnen (wenn überfällig)

3. **Neues Buch mit Autor:**
   - Autor anlegen (falls nicht existiert)
   - Buch anlegen
   - Verknüpfung erstellen

### Aufgabe 3: Isolation Level Testing

Teste verschiedene Isolation Levels:

1. Öffne zwei MySQL-Sessions
2. Teste Dirty Read mit READ UNCOMMITTED
3. Teste Non-Repeatable Read mit READ COMMITTED
4. Dokumentiere Ergebnisse

## Best Practices

### Transaktionen

✅ **DO:**
- Transaktionen kurz halten
- Nur nötige Operationen einschliessen
- Error-Handling implementieren
- COMMIT nicht vergessen

❌ **DON'T:**
- Lange laufende Transaktionen
- User-Input während Transaktion warten
- SELECT ohne Änderung in Transaktion
- Nested Transactions (nicht unterstützt in MySQL)

### Berechtigungen

✅ **DO:**
- Principle of Least Privilege (nur nötige Rechte)
- Separate User für Applikationen
- Starke Passwörter
- Regelmässige Audits

❌ **DON'T:**
- root-User in Produktion verwenden
- ALL PRIVILEGES ohne Grund
- Passwörter im Klartext speichern
- User mit '%' Host in Produktion

## Zusammenfassung

### DCL - Data Control Language
```sql
GRANT   -- Rechte vergeben
REVOKE  -- Rechte entziehen
```

### TCL - Transaction Control Language
```sql
START TRANSACTION / BEGIN   -- Transaktion starten
COMMIT                      -- Bestätigen
ROLLBACK                    -- Rückgängig
SAVEPOINT                   -- Zwischenstand
```

### ACID
- **A**tomicity: Alles oder nichts
- **C**onsistency: Konsistenter Zustand
- **I**solation: Unabhängig
- **D**urability: Dauerhaft

## Hausaufgaben für Credit 5

1. Erstelle ein Berechtigungskonzept für dein Projekt
2. Implementiere 3 Transaktionen für typische Operationen
3. Teste Transaktionen mit verschiedenen Szenarien (Erfolg, Fehler)
4. Dokumentiere alles in einem Dokument

## Zusätzliche Ressourcen

- [MySQL User Management](https://dev.mysql.com/doc/refman/8.0/en/user-account-management.html)
- [MySQL Transactions](https://dev.mysql.com/doc/refman/8.0/en/commit.html)
- [ACID Properties Explained](https://www.databricks.com/glossary/acid-transactions)
- [SQL Injection Prevention](https://owasp.org/www-community/attacks/SQL_Injection)

## Vorbereitung auf Test

In Unit 7 findet die **Theorieprüfung SQL** statt! Lektion 6 dient der Repetition.

**Themen:**
- Datenmodellierung (ER-Diagramm, Normalisierung)
- SQL DDL (CREATE, ALTER, DROP)
- SQL DML (INSERT, UPDATE, DELETE, SELECT)
- JOINs (INNER, LEFT, RIGHT)
- Aggregat-Funktionen
- Subqueries
- Grundlagen Transaktionen

**Lernempfehlung:**
- Alle bisherigen Aufgaben wiederholen
- SQL-Befehle üben in HeidiSQL
- ER-Diagramme zeichnen können
- Normalisierung verstehen

## Nächste Schritte

In Lektion 6:
- SQL-Repetition und Beispieltest als Vorbereitung auf die Theorieprüfung (Unit 7, 30% der Gesamtnote)
- Projekt-Kickoff
- Thema wählen
- DB-Design starten
