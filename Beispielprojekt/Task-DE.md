# Übungsaufgabe: Verwaltungssystem für Elektroinstallationen

**Dauer:** 45 Minuten  
**Gruppengröße:** 2-3 Studierender  
**Schwierigkeitsgrad:** Mittel bis Fortgeschritten

---

## **Szenario**

Das Unternehmen **TechElec GmbH** verwaltet Elektroinstallationen und Wartungsdienstleistungen in mehreren Gebäuden. Bisher arbeitet man mit Tabellenkalkulationen und Papierlogbüchern – ein chaotisches System. Sie sollen eine Datenbank entwerfen, um folgende Prozesse zu digitalisieren:

- **Techniker** mit ihren Spezialisierungen (Elektroinstallationen, Schaltanlagenmanagement, SPS-Programmierung, Sicherheitssysteme)
- **Kunden** und deren **Betriebsstellen** (Gebäude/Fabrikationsstandorte)
- **Installationen** an jeder Betriebsstelle (Stromversorgungssysteme, Schaltschränke, Steuerungen)
- **Wartungsverträge** gebunden an Installationen
- **Arbeitseinsätze** (vorbeugende Wartung, Reparaturen, Inspektionen)

---

## **Anforderungsanalyse**

### **1. Techniker und Qualifikationen**
- Ein Techniker hat einen Namen, eine Personalnummer und einen Status (aktiv/inaktiv)
- Jeder Techniker kann **mehrere Qualifikationen** besitzen (z.B. Elektroinstallation UND SPS-Programmierung)
- Qualifikationen sind standardisiert und wiederverwendbar
- Zu jeder Qualifikation gibt es eine Zertifizierungsnummer und ein Gültigkeitsdatum

### **2. Kunden und Betriebsstellen**
- Ein Kunde hat Firmenname, Kontaktperson und Telefonnummer
- Ein Kunde kann **mehrere Betriebsstellen** betreiben (Fabrik A, Fabrik B, Büro)
- Jede Betriebsstelle hat: Name, Adresse, Verantwortliche Person, Betriebsstellen-ID
- Eine Betriebsstelle gehört zu genau einem Kunde

### **3. Installationen**
- Installationen sind spezifische Systeme an einer Betriebsstelle
- Beispiele: Hauptschaltanlagen, Notbeleuchtungssystem, SPS-Steuersystem, Brandmeldeanlage
- Attribute: Installations-ID, Typ, Beschreibung, Baujahr, Status (aktiv/in Wartung/stillgelegt)
- Eine Betriebsstelle kann **mehrere Installationen** haben
- Eine Installation gehört zu genau einer Betriebsstelle

### **4. Wartungsverträge**
- Ein Vertrag wird mit **einem Kunden** abgeschlossen (nicht pro Betriebsstelle)
- Ein Vertrag bezieht sich auf **eine oder mehrere Installationen** des Kunden
- Vertrag-Attribute: Vertrags-ID, Startdatum, Enddatum, Wartungsfrequenz (monatlich, vierteljährlich, jährlich)
- Ein Vertrag hat einen **primär verantwortlichen Techniker**
- Aber: Wartungsarbeiten können auch von anderen qualifizierten Technikern durchgeführt werden

### **5. Arbeitseinsätze**
- Arbeitseinsätze entstehen aus Wartungsverträgen (geplante Wartung) oder als Reparaturen (ungeplant)
- Attribute: Einsatz-ID, Datum, Uhrzeit, Status (geplant/in Arbeit/abgeschlossen), Beschreibung, geschätzte Dauer
- Ein Arbeitseinsatz bezieht sich auf **eine Installation**
- Ein Arbeitseinsatz wird von **einem oder mehreren Technikern** durchgeführt
- Für jeden Techniker im Einsatz erfasst man: tatsächliche Arbeitsstunden, durchgeführte Tätigkeiten

---

## **Ihre Aufgaben** (in dieser Reihenfolge)

### **Aufgabe 1: Anforderungsanalyse & Konzeptschema (ER-Diagramm)**
*(Dauer: ca. 12 Minuten)*

1. Identifizieren Sie alle **Entitätstypen** und ihre **Beziehungen**
2. Für jede Entität: Welche Attribute gehören dazu?
3. Markieren Sie Primär- und Fremdschlüssel
4. Dokumentieren Sie:
   - Alle 1:N-Beziehungen
   - Alle N:M-Beziehungen (und benötigte Verbindungstabellen)
   - Kardinalitäten (obligatorisch oder optional?)

**Abgabe:** ER-Diagramm (ASCII-Grafik, Textformat oder Skizze) oder schriftliche Dokumentation aller Entitäten mit ihren Beziehungen.

---

### **Aufgabe 2: Logisches Schema**
*(Dauer: ca. 12 Minuten)*

Übersetzen Sie Ihr Konzeptschema in **normalisierte relationale Tabellen**:

- Für jede Tabelle definieren Sie: Spaltennamen, Datentypen
- Markieren Sie PRIMARY KEY (PK) und FOREIGN KEY (FK)
- Wenden Sie Normalisierungsregeln an (Ziel: 3. Normalform)
- Beachten Sie sinnvolle Indizes (Fremdschlüssel, Suchfelder)

**Abgabe:** Tabellendefinition (kann Pseudocode oder SQL-Kommentar sein).

---

### **Aufgabe 3: DDL-Implementierung & Testdaten**
*(Dauer: ca. 18 Minuten)*

Schreiben Sie ein vollständiges **SQL-Script**, das:

1. **CREATE TABLE** Statements für alle Tabellen enthält
   - PRIMARY KEYS und FOREIGN KEY Constraints mit referentieller Integrität
   - NOT NULL Constraints wo angemessen
   - Sinnvolle Defaults

2. **INSERT-Statements** mit realistischen Testdaten:
   - Mindestens **5 Techniker** mit verschiedenen Qualifikationen
   - Mindestens **3 Kunden** mit insgesamt 5+ Betriebsstellen
   - Mindestens **6 Installationen** (verschiedene Typen)
   - Mindestens **3 Wartungsverträge** (ein Vertrag kann mehrere Installationen abdecken)
   - Mindestens **5 Arbeitseinsätze** (Mix aus geplanten und abgeschlossenen)
   - Mehrere Techniker je Arbeitseinsatz (N:M-Relation nachweisen)

Das SQL-Script muss **fehlerlos ausführbar** sein und eine konsistente Datenbank aufbauen.

---

## **Abgabeanforderungen**

1. **Konzeptschema** (Aufgabe 1): ER-Diagramm oder Beziehungsdokumentation
2. **Logisches Schema** (Aufgabe 2): Tabellenstruktur-Definition
3. **SQL-Script** (Aufgabe 3): Kompletter, ausführbarer Code mit CREATE TABLE und INSERT

Das SQL muss in Ihrer Datenbank (MySQL, PostgreSQL, SQLite, SQL Server) **funktionieren** – testen Sie vorher!

---

## **Bewertungskriterien**

- ✓ Alle Entitätstypen korrekt identifiziert (6+ Tabellen erwartet)
- ✓ 1:N und N:M Beziehungen korrekt modelliert
- ✓ Normalisierung durchgeführt (keine redundanten Daten)
- ✓ Referentielle Integrität via FK Constraints realisiert
- ✓ Realistische und aussagekräftige Testdaten (5+ Datensätze pro Tabelle)
- ✓ SQL syntaktisch korrekt und ausführbar
- ✓ Klare Dokumentation (Kommentare im Code, übersichtliche Diagramme)

---

## **Optionale Herausforderung** (wenn Zeit übrig ist)

Schreiben Sie 2-3 nützliche **SELECT-Queries**:
- Alle Arbeitseinsätze für einen bestimmten Techniker im letzten Monat
- Welche Techniker sind für eine bestimmte Installation qualifiziert?
- Übersicht aller Installationen, deren Wartungsvertrag demnächst abläuft

---

## **Hinweise für Studierendes**

Aus Ihrer Ausbildung (Elektroinstallateur/Automatiker) kennen Sie bereits:
- Physische Systeme (Schaltschränke, Leitungen, Steuerungen, SPS)
- Wartungskonzepte (vorbeugende, Reparatur, Inspektionen)
- Arbeitsabläufe und Abhängigkeiten
- Ressourcenplanung

**Ihre Aufgabe:** Diese geschäftliche Realität in eine Datenbank übersetzen. Denken Sie daran: *Wer muss was abfragen können und warum?* Gutes Datenbankdesign macht Betriebsabläufe effizient und Daten zuverlässig.

---

## **Tipps zum Vorgehen**

1. **Starten Sie mit Entitätstypen** – nicht überdenken
2. Fragen Sie sich: "Ist das eine separate Tabelle oder nur eine Eigenschaft einer anderen Entität?"
3. Bei N:M-Beziehungen: **Verbindungstabelle** erstellen
4. **Aussagekräftige Namen** verwenden (Techniker, nicht Tech; Wartungsvertrag, nicht WV)
5. **INSERT-Statements testen** – wenn sie fehlschlagen, hat Ihr Schema ein Problem
6. **Foreign Key Constraints früh einbauen** – sie verhindern fehlerhafte Daten

---

## **Expected Table Count**

Sie sollten auf **6-7 Tabellen** kommen:
1. Techniker
2. Qualifikationen
3. Techniker_Qualifikationen (N:M)
4. Kunden
5. Betriebsstellen
6. Installationen
7. Wartungsverträge
8. Verträge_Installationen (N:M)
9. Arbeitseinsätze
10. Arbeitseinsätze_Techniker (N:M)

**Tipp:** Nicht alle müssen separate Tabellen sein – durchdenken Sie die Abhängigkeiten!