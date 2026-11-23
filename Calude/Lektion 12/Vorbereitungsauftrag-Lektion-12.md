# Vorbereitungsauftrag Lektion 12: Security Best Practices

## Ziel

Vorbereitung auf Lektion 12, in der wir MQTT-Integration und Security-Aspekte in Webprojekten behandeln. Der Fokus liegt auf dem Verständnis grundlegender Sicherheitsthemen.

## Aufgaben

### 1. Web Security Grundlagen (ca. 30 Minuten)

Recherchiere die folgenden **Security-Themen** und beantworte die Fragen:

#### a) SQL Injection
- Was ist SQL Injection?
- Zeige ein konkretes Beispiel einer anfälligen SQL-Query
- Wie kann man SQL Injection verhindern?
- Was sind Prepared Statements / Parameterized Queries?

#### b) Cross-Site Scripting (XSS)
- Was ist XSS?
- Nenne ein einfaches Beispiel eines XSS-Angriffs
- Wie kann man sich gegen XSS schützen?

#### c) Passwort-Sicherheit
- Warum sollte man Passwörter NIEMALS im Klartext speichern?
- Was ist Hashing? Was ist Salting?
- Welche Hash-Algorithmen sind empfohlen (z.B. bcrypt, argon2)?

#### d) HTTPS vs HTTP
- Was ist der Unterschied zwischen HTTP und HTTPS?
- Warum ist HTTPS wichtig für Web-Anwendungen?
- Was bedeutet "Man-in-the-Middle" Angriff?

### 2. Authentication vs. Authorization (ca. 15 Minuten)

Erkläre den Unterschied zwischen **Authentication** (Authentifizierung) und **Authorization** (Autorisierung):

- **Authentication:** Wer bist du? (Beispiel?)
- **Authorization:** Was darfst du? (Beispiel?)

Überlege dir ein konkretes Beispiel aus dem Alltag (z.B. Bibliothek, Online-Shop, Bank).

### 3. Environment Variables & Secrets (ca. 10 Minuten)

Beantworte folgende Fragen zu **Umgebungsvariablen und Secrets**:

- Was sind Environment Variables?
- Warum sollte man Passwörter, API-Keys und DB-Credentials NICHT direkt im Code speichern?
- Was ist eine `.env` Datei?
- Warum sollte `.env` NICHT ins Git-Repository committet werden?
- Was steht stattdessen im Repository (`.env.example`)?

### 4. OWASP Top 10 (optional, ca. 15 Minuten)

Falls du Zeit hast, informiere dich über die **OWASP Top 10**:

- Was ist OWASP?
- Was sind die "OWASP Top 10"?
- Nenne 3 der häufigsten Sicherheitsprobleme aus der Liste
- Welche davon könnten in deinem aktuellen REST API Projekt relevant sein?

### 5. Reflexion: Dein aktuelles Projekt (ca. 15 Minuten)

Analysiere dein bisheriges REST API Projekt aus Security-Perspektive:

**Checkliste:**
- [ ] Verwendest du Prepared Statements oder sind SQL-Injections möglich?
- [ ] Speicherst du DB-Credentials im Code oder in `.env`?
- [ ] Validierst du User-Input bevor du ihn in die DB schreibst?
- [ ] Gibt deine API zu viele Fehlerdetails preis (Stack Traces)?
- [ ] Hast du eine `.env` Datei und ist sie in `.gitignore`?

**Identifiziere 2-3 konkrete Verbesserungen** für dein Projekt.

---

## Abgabe

**Format:** 
- Markdown-Datei (`.md`) oder Word-Dokument (`.docx`)
- Strukturiert nach den obigen Fragen
- Eigene Worte verwenden + Quellen angeben bei Code-Beispielen

**Umfang:**
- 2-3 Seiten
- Mix aus Stichpunkten und kurzen Erklärungen
- Code-Beispiele für SQL Injection willkommen

**Deadline:** 
Vor Beginn von Lektion 12

---

## Ressourcen (Empfehlungen)

### Allgemein
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [MDN Web Security](https://developer.mozilla.org/en-US/docs/Web/Security)

### SQL Injection
- [SQL Injection Explained - OWASP](https://owasp.org/www-community/attacks/SQL_Injection)
- [SQL Injection Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)

### Passwörter
- [Password Storage Cheat Sheet - OWASP](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [bcrypt vs argon2 - Was ist besser?](https://security.stackexchange.com/)

### XSS
- [Cross-Site Scripting (XSS) - OWASP](https://owasp.org/www-community/attacks/xss/)

### Allgemeine Best Practices
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)

---

## Bewertung

Dieser Vorbereitungsauftrag wird **nicht benotet**, ist aber essentiell für:
- Verständnis der Sicherheitsthemen in Lektion 12
- Verbesserung deines Credit 10 Projekts
- Professionelle Entwicklung von Web-Anwendungen

**Hinweis:** Security ist kein "Nice-to-Have", sondern ein **Muss** in der professionellen Softwareentwicklung. Die hier gelernten Konzepte sind fundamental für deine Karriere.

---

## Zusätzliche Herausforderung (optional)

Falls du tiefer einsteigen möchtest:

1. **Installiere ein Security-Tool:**
   - `npm audit` - prüft deine Dependencies auf bekannte Schwachstellen
   - Führe es in deinem Projekt aus: `npm audit`
   - Dokumentiere die Findings

2. **Teste dein API mit Postman/curl:**
   - Versuche gezielt SQL Injection in deine Endpoints
   - Dokumentiere: Ist dein API anfällig?

---

**Viel Erfolg bei der Vorbereitung und dem bewussten Umgang mit Security!**
