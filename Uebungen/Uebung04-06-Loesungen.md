# Übungsblatt 4: SQL JOINs & UNION

## Credit 4 - Fortgeschrittene Abfragen (10 Punkte)

### Teil A: INNER JOIN (3 Punkte)

### Aufgabe 1: Bücher mit Autoren (1 Punkt)

Zeige alle Bücher mit Vor- und Nachname des Autors:

```sql
-- Deine Lösung hier
```

### Aufgabe 2: Vollständige Buchinfo (1 Punkt)

Zeige Bücher mit Autor, Verlag und Genre:

```sql
-- Deine Lösung hier
```

### Aufgabe 3: Bücher eines Autors (1 Punkt)

Zeige alle Bücher von "J.K. Rowling":

```sql
-- Deine Lösung hier
```

---

## Teil B: LEFT JOIN (2 Punkte)

### Aufgabe 4: Autoren ohne Bücher (1 Punkt)

Finde alle Autoren, die noch keine Bücher haben:

```sql
-- Deine Lösung hier
```

### Aufgabe 5: Verlage mit Buchanzahl (1 Punkt)

Zeige alle Verlage mit der Anzahl ihrer Bücher (auch 0):

```sql
-- Deine Lösung hier
```

---

## Teil C: Aggregationen mit JOINs (3 Punkte)

### Aufgabe 6: Top 10 Autoren (1 Punkt)

Zeige die 10 Autoren mit den meisten Büchern:

```sql
-- Deine Lösung hier
```

### Aufgabe 7: Durchschnittspreis pro Verlag (1 Punkt)

Berechne den Durchschnittspreis der Bücher pro Verlag:

```sql
-- Deine Lösung hier
```

### Aufgabe 8: Aktive Ausleihen (1 Punkt)

Zeige alle aktuellen Ausleihen mit Kundennamen und Buchtiteln:

```sql
-- Deine Lösung hier
```

---

## Teil D: UNION (2 Punkte)

### Aufgabe 9: Kontaktliste (1 Punkt)

Erstelle eine Kontaktliste mit allen Autoren und Kunden:

```sql
-- Deine Lösung hier
```

### Aufgabe 10: Statistik (1 Punkt)

Zeige Statistiken: Anzahl Bücher pro Genre und gesamt:

```sql
-- Deine Lösung hier
```

---

## Lösungen

### Teil A: INNER JOIN

```sql
-- Aufgabe 1
SELECT 
    b.title,
    a.firstname,
    a.lastname
FROM books b
INNER JOIN authors a ON b.author_id = a.id
ORDER BY b.title;

-- Aufgabe 2
SELECT 
    b.title,
    CONCAT(a.firstname, ' ', a.lastname) AS author,
    p.name AS publisher,
    g.genre
FROM books b
INNER JOIN authors a ON b.author_id = a.id
INNER JOIN publishers p ON b.publisher_id = p.id
INNER JOIN genres g ON b.genre_id = g.id
ORDER BY b.title;

-- Aufgabe 3
SELECT 
    b.title,
    b.published_date,
    b.price
FROM books b
INNER JOIN authors a ON b.author_id = a.id
WHERE a.firstname = 'J.K.' AND a.lastname = 'Rowling'
ORDER BY b.published_date;
```

### Teil B: LEFT JOIN

```sql
-- Aufgabe 4
SELECT 
    a.firstname,
    a.lastname,
    a.email
FROM authors a
LEFT JOIN books b ON a.id = b.author_id
WHERE b.id IS NULL;

-- Aufgabe 5
SELECT 
    p.name AS publisher,
    COUNT(b.id) AS book_count
FROM publishers p
LEFT JOIN books b ON p.id = b.publisher_id
GROUP BY p.id, p.name
ORDER BY book_count DESC;
```

### Teil C: Aggregationen mit JOINs

```sql
-- Aufgabe 6
SELECT 
    a.firstname,
    a.lastname,
    COUNT(b.id) AS book_count
FROM authors a
LEFT JOIN books b ON a.id = b.author_id
GROUP BY a.id, a.firstname, a.lastname
ORDER BY book_count DESC
LIMIT 10;

-- Aufgabe 7
SELECT 
    p.name AS publisher,
    ROUND(AVG(b.price), 2) AS avg_price,
    COUNT(b.id) AS book_count
FROM publishers p
LEFT JOIN books b ON p.id = b.publisher_id
GROUP BY p.id, p.name
HAVING book_count > 0
ORDER BY avg_price DESC;

-- Aufgabe 8
SELECT 
    CONCAT(c.firstname, ' ', c.lastname) AS customer,
    b.title AS book,
    l.date_from,
    l.date_to,
    DATEDIFF(l.date_to, CURDATE()) AS days_remaining
FROM lends l
INNER JOIN customers c ON l.customer_id = c.id
INNER JOIN books b ON l.book_id = b.id
WHERE l.date_to >= CURDATE()
ORDER BY l.date_to;
```

### Teil D: UNION

```sql
-- Aufgabe 9
SELECT 
    CONCAT(firstname, ' ', lastname) AS name,
    email,
    'Author' AS type
FROM authors
WHERE email IS NOT NULL

UNION

SELECT 
    CONCAT(firstname, ' ', lastname) AS name,
    email,
    'Customer' AS type
FROM customers
WHERE email IS NOT NULL

ORDER BY name;

-- Aufgabe 10
SELECT 
    g.genre AS category,
    COUNT(b.id) AS count
FROM genres g
LEFT JOIN books b ON g.id = b.genre_id
GROUP BY g.id, g.genre

UNION ALL

SELECT 
    'TOTAL' AS category,
    COUNT(*) AS count
FROM books

ORDER BY category;
```

---

## Bewertungsraster

| Teil | Aufgabe | Punkte | Erreicht |
|------|---------|--------|----------|
| A | INNER JOIN (1-3) | 3 | |
| B | LEFT JOIN (4-5) | 2 | |
| C | Aggregationen (6-8) | 3 | |
| D | UNION (9-10) | 2 | |
| **Total** | | **10** | |

---

## Credit 5: SQL Erweitert - Medizinisches Zentrum (10 Punkte)

### Aufgabe 1: Berechtigungskonzept (5 Punkte)

Erstelle ein vollständiges Berechtigungskonzept für das medizinische Zentrum.

**Rollen:**
- Administrator
- Doctor  
- Receptionist
- Patient (read-only auf eigene Daten)

**a) Beschreibung der Rollen (1 Punkt):**

| Rolle | Beschreibung | Zugriff |
|-------|--------------|---------|
| Administrator | Vollzugriff | ALL |
| Doctor | ... | ... |
| Receptionist | ... | ... |
| Patient | ... | ... |

**b) Berechtigungsmatrix (2 Punkte):**

|  | patients | doctors | appointments | medical_records |
|--|----------|---------|--------------|-----------------|
| **Administrator** | CRUD | CRUD | CRUD | CRUD |
| **Doctor** | R | R | CRUD | CRUD |
| **Receptionist** | CRUD | R | CRUD | - |
| **Patient** | R (own) | R | R (own) | R (own) |

**c) SQL Implementierung (2 Punkte):**

```sql
-- Erstelle Benutzer und weise Rechte zu

-- Administrator
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'admin_pw';
GRANT ALL PRIVILEGES ON medical_center.* TO 'admin_user'@'localhost';

-- Doctor
CREATE USER 'doctor_user'@'localhost' IDENTIFIED BY 'doctor_pw';
-- Deine Lösung hier

-- Receptionist
-- Deine Lösung hier

-- Patient (nur Leserechte)
-- Deine Lösung hier

FLUSH PRIVILEGES;
```

---

### Aufgabe 2: Transaktionen (5 Punkte)

### Aufgabe 2a: Buchung eines Termins (2 Punkte)

Implementiere eine Transaktion für die Terminbuchung:

```sql
START TRANSACTION;

-- 1. Prüfe ob Arzt verfügbar ist
-- 2. Erstelle Termin
-- 3. Aktualisiere Verfügbarkeit
-- 4. Sende Bestätigung (simuliert mit INSERT in notifications)

-- Deine Lösung hier

COMMIT;
-- Oder bei Fehler: ROLLBACK;
```

### Aufgabe 2b: Patientenüberweisung (1 Punkt)

Transaktion für Überweisung von einem Arzt zu einem anderen:

```sql
-- Deine Lösung hier
```

### Aufgabe 2c: ACID erklären (2 Punkte)

Erkläre für die Terminbuchung:

**Atomicity:**
```
Deine Erklärung hier
```

**Consistency:**
```
Deine Erklärung hier
```

**Isolation:**
```
Deine Erklärung hier
```

**Durability:**
```
Deine Erklärung hier
```

---

## Lösungen Credit 5

### Aufgabe 1: SQL Implementierung

```sql
-- Administrator (bereits gezeigt)
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'admin_pw';
GRANT ALL PRIVILEGES ON medical_center.* TO 'admin_user'@'localhost' WITH GRANT OPTION;

-- Doctor
CREATE USER 'doctor_user'@'localhost' IDENTIFIED BY 'doctor_pw';
GRANT SELECT ON medical_center.patients TO 'doctor_user'@'localhost';
GRANT SELECT ON medical_center.doctors TO 'doctor_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON medical_center.appointments TO 'doctor_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON medical_center.medical_records TO 'doctor_user'@'localhost';

-- Receptionist
CREATE USER 'reception_user'@'localhost' IDENTIFIED BY 'reception_pw';
GRANT SELECT, INSERT, UPDATE, DELETE ON medical_center.patients TO 'reception_user'@'localhost';
GRANT SELECT ON medical_center.doctors TO 'reception_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON medical_center.appointments TO 'reception_user'@'localhost';

-- Patient (nur Leserechte auf eigene Daten - würde Row-Level Security erfordern)
CREATE USER 'patient_user'@'localhost' IDENTIFIED BY 'patient_pw';
GRANT SELECT ON medical_center.patients TO 'patient_user'@'localhost';
GRANT SELECT ON medical_center.doctors TO 'patient_user'@'localhost';
GRANT SELECT ON medical_center.appointments TO 'patient_user'@'localhost';

FLUSH PRIVILEGES;
```

### Aufgabe 2a: Terminbuchung

```sql
START TRANSACTION;

-- 1. Prüfe Verfügbarkeit
SET @available = (
    SELECT COUNT(*) 
    FROM appointments 
    WHERE doctor_id = 5 
        AND appointment_date = '2024-12-15' 
        AND appointment_time = '10:00:00'
);

-- 2. Wenn verfügbar, erstelle Termin
IF @available = 0 THEN
    INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, reason, status)
    VALUES (10, 5, '2024-12-15', '10:00:00', 'Routine checkup', 'scheduled');
    
    -- 3. Aktualisiere Verfügbarkeit (optional: availability table)
    -- INSERT INTO availability...
    
    -- 4. Benachrichtigung erstellen
    INSERT INTO notifications (patient_id, message, created_at)
    VALUES (10, 'Termin bestätigt für 15.12.2024 um 10:00', NOW());
    
    COMMIT;
    SELECT 'Termin erfolgreich gebucht' AS result;
ELSE
    ROLLBACK;
    SELECT 'Termin nicht verfügbar' AS result;
END IF;
```

### Aufgabe 2b: Überweisung

```sql
START TRANSACTION;

SET @appointment_id = 123;
SET @old_doctor_id = 5;
SET @new_doctor_id = 8;

-- 1. Termin aktualisieren
UPDATE appointments 
SET doctor_id = @new_doctor_id,
    status = 'rescheduled'
WHERE id = @appointment_id AND doctor_id = @old_doctor_id;

-- 2. Log erstellen
INSERT INTO appointment_logs (appointment_id, action, old_doctor_id, new_doctor_id, changed_at)
VALUES (@appointment_id, 'doctor_change', @old_doctor_id, @new_doctor_id, NOW());

-- 3. Patient benachrichtigen
INSERT INTO notifications (patient_id, message, created_at)
SELECT patient_id, 
       CONCAT('Ihr Termin wurde zu Dr. ', (SELECT name FROM doctors WHERE id = @new_doctor_id), ' übertragen'),
       NOW()
FROM appointments WHERE id = @appointment_id;

COMMIT;
```

### Aufgabe 2c: ACID Erklärung

**Atomicity (Atomarität):**
Die Terminbuchung wird entweder komplett durchgeführt (Termin erstellt + Benachrichtigung gesendet) oder gar nicht. Bei einem Fehler wird ROLLBACK ausgeführt und nichts gespeichert.

**Consistency (Konsistenz):**
Die Datenbank bleibt konsistent: Es können keine doppelten Termine zur gleichen Zeit beim gleichen Arzt entstehen. Foreign Keys bleiben gültig.

**Isolation (Isolation):**
Wenn zwei Patienten gleichzeitig denselben Termin buchen wollen, wird nur einer erfolgreich sein. Die Transaktionen beeinflussen sich nicht gegenseitig.

**Durability (Dauerhaftigkeit):**
Nach COMMIT ist die Terminbuchung permanent gespeichert, auch bei Serverabsturz bleibt sie erhalten.

---

## Credit 6: Test-Vorbereitung (keine Abgabe)

### Themen für den Test

**1. Datenbankdesign (25%)**
- ER-Diagramme lesen und erstellen
- Entitäten und Beziehungen identifizieren
- Kardinalitäten bestimmen
- Normalformen anwenden

**2. SQL DDL (20%)**
- CREATE TABLE mit Constraints
- PRIMARY KEY, FOREIGN KEY
- Datentypen wählen
- ALTER TABLE

**3. SQL DML (25%)**
- INSERT, UPDATE, DELETE
- SELECT mit WHERE
- Subqueries
- Funktionen

**4. JOINs (20%)**
- INNER JOIN
- LEFT JOIN
- Mehrere JOINs
- Aggregationen mit JOINs

**5. Transaktionen (10%)**
- ACID erklären
- START TRANSACTION, COMMIT, ROLLBACK
- Anwendungsfälle

### Übungsaufgaben

**Aufgabe 1: Schnell-Design**

Erstelle ein ER-Diagramm für ein Restaurant-Reservierungssystem:
- Tables, Reservations, Customers, Menu_Items

**Aufgabe 2: SQL Mix**

```sql
-- 1. Erstelle eine Tabelle 'products' mit allen wichtigen Constraints

-- 2. Füge 3 Produkte ein

-- 3. Finde alle Produkte über 50 CHF

-- 4. Erhöhe alle Preise um 5%

-- 5. Lösche Produkte ohne Stock
```

**Aufgabe 3: JOINs**

```sql
-- Gegeben: orders, customers, order_items, products

-- 1. Alle Bestellungen mit Kundennamen

-- 2. Top 5 Kunden nach Bestellwert

-- 3. Produkte die nie bestellt wurden
```

---

## Bewertungsraster Credits 4-6

| Credit | Aufgabe | Punkte | Erreicht |
|--------|---------|--------|----------|
| **Credit 4** | JOINs & UNION | 10 | |
| **Credit 5** | Berechtigungen + Transaktionen | 10 | |
| **Credit 6** | Test-Vorbereitung | - | Keine Abgabe |

---

## Abgabe Credits 4-5

**Format:** .sql Dateien
**Deadline:** Siehe Moodle
**Naming:** 
- `Credit4_Vorname_Nachname.sql`
- `Credit5_Vorname_Nachname.sql`

## Test-Info (Credit 6 Woche)

**Datum:** Siehe Moodle
**Dauer:** 90 Minuten
**Hilfsmittel:** Keine (außer Stift und Papier)
**Gewichtung:** 30% der Gesamtnote
**Format:** Schriftlich oder am Computer
