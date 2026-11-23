# Travail préparatoire Leçon 12 : Meilleures pratiques de sécurité

## Objectif

Préparation pour la leçon 12, dans laquelle nous traiterons l'intégration MQTT et les aspects de sécurité dans les projets web. L'accent est mis sur la compréhension des thèmes fondamentaux de sécurité.

## Tâches

### 1. Fondamentaux de la sécurité web (env. 30 minutes)

Recherche les **thèmes de sécurité** suivants et réponds aux questions :

#### a) Injection SQL
- Qu'est-ce que l'injection SQL ?
- Montre un exemple concret d'une requête SQL vulnérable
- Comment peut-on prévenir l'injection SQL ?
- Qu'est-ce que sont les Prepared Statements / Parameterized Queries ?

#### b) Cross-Site Scripting (XSS)
- Qu'est-ce que le XSS ?
- Nomme un exemple simple d'une attaque XSS
- Comment peut-on se protéger contre le XSS ?

#### c) Sécurité des mots de passe
- Pourquoi ne devrait-on JAMAIS stocker les mots de passe en clair ?
- Qu'est-ce que le hashing ? Qu'est-ce que le salting ?
- Quels algorithmes de hachage sont recommandés (par ex. bcrypt, argon2) ?

#### d) HTTPS vs HTTP
- Quelle est la différence entre HTTP et HTTPS ?
- Pourquoi HTTPS est-il important pour les applications web ?
- Que signifie une attaque "Man-in-the-Middle" ?

### 2. Authentication vs. Authorization (env. 15 minutes)

Explique la différence entre **Authentication** (Authentification) et **Authorization** (Autorisation) :

- **Authentication :** Qui es-tu ? (Exemple ?)
- **Authorization :** Que peux-tu faire ? (Exemple ?)

Réfléchis à un exemple concret du quotidien (par ex. bibliothèque, boutique en ligne, banque).

### 3. Variables d'environnement & Secrets (env. 10 minutes)

Réponds aux questions suivantes concernant les **variables d'environnement et secrets** :

- Qu'est-ce que sont les Environment Variables ?
- Pourquoi ne devrait-on PAS stocker les mots de passe, clés API et identifiants de BD directement dans le code ?
- Qu'est-ce qu'un fichier `.env` ?
- Pourquoi `.env` ne devrait-il PAS être committé dans le dépôt Git ?
- Qu'est-ce qui se trouve à la place dans le dépôt (`.env.example`) ?

### 4. OWASP Top 10 (optionnel, env. 15 minutes)

Si tu as le temps, informe-toi sur le **OWASP Top 10** :

- Qu'est-ce que l'OWASP ?
- Qu'est-ce que le "OWASP Top 10" ?
- Nomme 3 des problèmes de sécurité les plus fréquents de la liste
- Lesquels pourraient être pertinents dans ton projet d'API REST actuel ?

### 5. Réflexion : Ton projet actuel (env. 15 minutes)

Analyse ton projet d'API REST actuel du point de vue de la sécurité :

**Liste de contrôle :**
- [ ] Utilises-tu des Prepared Statements ou les injections SQL sont-elles possibles ?
- [ ] Stockes-tu les identifiants de BD dans le code ou dans `.env` ?
- [ ] Valides-tu les entrées utilisateur avant de les écrire dans la BD ?
- [ ] Ton API divulgue-t-elle trop de détails d'erreur (Stack Traces) ?
- [ ] As-tu un fichier `.env` et est-il dans `.gitignore` ?

**Identifie 2-3 améliorations concrètes** pour ton projet.

---

## Remise

**Format :** 
- Fichier Markdown (`.md`) ou document Word (`.docx`)
- Structuré selon les questions ci-dessus
- Utiliser tes propres mots + citer les sources pour les exemples de code

**Volume :**
- 2-3 pages
- Mélange de points-clés et de brèves explications
- Les exemples de code pour l'injection SQL sont les bienvenus

**Échéance :** 
Avant le début de la leçon 12

---

## Ressources (Recommandations)

### Général
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [MDN Web Security](https://developer.mozilla.org/fr/docs/Web/Security)

### Injection SQL
- [SQL Injection Explained - OWASP](https://owasp.org/www-community/attacks/SQL_Injection)
- [SQL Injection Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html)

### Mots de passe
- [Password Storage Cheat Sheet - OWASP](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [bcrypt vs argon2 - Lequel est meilleur ?](https://security.stackexchange.com/)

### XSS
- [Cross-Site Scripting (XSS) - OWASP](https://owasp.org/www-community/attacks/xss/)

### Meilleures pratiques générales
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)

---

## Évaluation

Ce travail préparatoire n'est **pas noté**, mais il est essentiel pour :
- Comprendre les thèmes de sécurité de la leçon 12
- Améliorer ton projet Credit 10
- Le développement professionnel d'applications web

**Remarque :** La sécurité n'est pas un "Nice-to-Have", mais un **Must** dans le développement logiciel professionnel. Les concepts appris ici sont fondamentaux pour ta carrière.

---

## Défi supplémentaire (optionnel)

Si tu veux approfondir :

1. **Installe un outil de sécurité :**
   - `npm audit` - vérifie tes dépendances pour les vulnérabilités connues
   - Exécute-le dans ton projet : `npm audit`
   - Documente les résultats

2. **Teste ton API avec Postman/curl :**
   - Essaie intentionnellement l'injection SQL dans tes endpoints
   - Documente : Ton API est-elle vulnérable ?

---

**Bonne préparation et manipulation consciente de la sécurité !**
