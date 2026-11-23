# Listes de contrôle pour les étudiants - Leçons 1-6

## Liste 1: Leçon 1 - Fondamentaux

### Théorie comprise
- [ ] Je peux expliquer ce qu'est une base de données
- [ ] Je connais la différence entre données et informations
- [ ] Je comprends ce qu'est un SGBD et ses avantages
- [ ] Je peux expliquer les propriétés ACID
- [ ] Je connais différents types de SGBD (SQL vs NoSQL)

### Compétences pratiques
- [ ] MariaDB/MySQL est installé
- [ ] HeidiSQL ou autre client est installé
- [ ] Je peux me connecter à la base de données
- [ ] Je peux exécuter des commandes SQL simples

### Credit 1
- [ ] Questions théoriques répondues
- [ ] Les 4 exercices complétés
- [ ] Soumission en PDF/Word
- [ ] Remis dans les délais

---

## Liste 2: Leçon 2 - Conception de BDD & DDL

### Théorie comprise
- [ ] Je peux lire et créer des diagrammes ER
- [ ] Je comprends les cardinalités (1:1, 1:N, N:M)
- [ ] Je connais les 3 formes normales (1NF, 2NF, 3NF)
- [ ] Je peux identifier les redondances dans les modèles de données

### SQL DDL
- [ ] Je peux créer une base de données (CREATE DATABASE)
- [ ] Je peux créer des tables (CREATE TABLE)
- [ ] Je connais tous les types de données importants (INT, VARCHAR, DATE, etc.)
- [ ] Je peux définir les contraintes:
  - [ ] PRIMARY KEY
  - [ ] FOREIGN KEY
  - [ ] NOT NULL
  - [ ] UNIQUE
  - [ ] CHECK
  - [ ] DEFAULT
- [ ] Je peux modifier des tables (ALTER TABLE)
- [ ] Je peux supprimer des tables (DROP TABLE)

### Credit 2 - Cartes des cours d'eau
- [ ] Liste Excel avec champs de données créée
  - [ ] Au moins 10 champs
  - [ ] Types de données définis
  - [ ] Contraintes spécifiées
- [ ] Diagramme ER créé
  - [ ] Au moins 3 entités
  - [ ] Tous les attributs présents
  - [ ] Clés primaires marquées
  - [ ] Relations avec cardinalités
- [ ] Script SQL DDL écrit
  - [ ] CREATE DATABASE
  - [ ] Les 3 tables avec CREATE TABLE
  - [ ] Toutes les contraintes implémentées
  - [ ] Données de test insérées (optionnel)
- [ ] Tous les fichiers soumis en ZIP

---

## Liste 3: Leçon 3 - SQL DML

### INSERT compris
- [ ] Je peux insérer des lignes individuelles
- [ ] Je peux insérer plusieurs lignes en une fois
- [ ] Je peux utiliser des sous-requêtes dans INSERT
- [ ] Je comprends AUTO_INCREMENT

### SELECT compris
- [ ] Je peux interroger toutes les données (SELECT *)
- [ ] Je peux sélectionner des colonnes spécifiques
- [ ] Je peux utiliser les conditions WHERE:
  - [ ] Opérateurs de comparaison (=, !=, >, <)
  - [ ] LIKE pour la recherche de motifs
  - [ ] IN pour les listes
  - [ ] BETWEEN pour les plages
  - [ ] IS NULL / IS NOT NULL
- [ ] Je peux trier les résultats (ORDER BY)
- [ ] Je peux limiter les résultats (LIMIT, OFFSET)
- [ ] Je peux utiliser DISTINCT
- [ ] Je comprends les fonctions d'agrégation:
  - [ ] COUNT()
  - [ ] SUM()
  - [ ] AVG()
  - [ ] MIN(), MAX()

### UPDATE compris
- [ ] Je peux mettre à jour des lignes individuelles
- [ ] Je peux mettre à jour plusieurs lignes
- [ ] J'utilise TOUJOURS WHERE (sauf intentionnellement tous)
- [ ] Je peux mettre à jour avec des sous-requêtes
- [ ] Je teste les commandes UPDATE d'abord avec SELECT

### DELETE compris
- [ ] Je peux supprimer des lignes individuelles
- [ ] J'utilise TOUJOURS WHERE (sauf intentionnellement tous)
- [ ] Je comprends la différence DELETE vs TRUNCATE
- [ ] Je teste les commandes DELETE d'abord avec SELECT

### Credit 3 - HFTM Library
- [ ] Base de données HFTM Library importée
- [ ] Tous les exercices INSERT résolus
- [ ] Tous les exercices SELECT résolus
- [ ] Tous les exercices UPDATE résolus
- [ ] Tous les exercices DELETE résolus
- [ ] Fichier SQL avec toutes les solutions créé
- [ ] Code commenté
- [ ] Soumis en fichier .sql

---

## Liste 4: Leçon 4 - JOINs & UNION

### JOINs compris
- [ ] Je comprends INNER JOIN
- [ ] Je comprends LEFT JOIN
- [ ] Je comprends RIGHT JOIN
- [ ] Je connais la différence entre les JOINs
- [ ] Je peux joindre plusieurs tables
- [ ] Je peux joindre des relations N:M via des tables de jonction

### Agrégations avec JOINs
- [ ] Je peux utiliser GROUP BY avec JOINs
- [ ] Je comprends HAVING
- [ ] Je peux agréger sur des données jointes

### UNION compris
- [ ] Je comprends UNION
- [ ] Je connais la différence UNION vs UNION ALL
- [ ] Je peux combiner les résultats de différentes requêtes

### Credit 4
- [ ] Tous les exercices INNER JOIN résolus
- [ ] Tous les exercices LEFT JOIN résolus
- [ ] Exercices d'agrégation avec JOINs résolus
- [ ] Exercices UNION résolus
- [ ] Fichier SQL soumis

---

## Liste 5: Leçon 5 - DCL & TCL

### DCL (Data Control Language)
- [ ] Je peux créer des utilisateurs (CREATE USER)
- [ ] Je peux accorder des droits (GRANT)
- [ ] Je peux révoquer des droits (REVOKE)
- [ ] Je comprends différentes permissions:
  - [ ] SELECT, INSERT, UPDATE, DELETE
  - [ ] CREATE, ALTER, DROP
  - [ ] ALL PRIVILEGES
- [ ] Je peux créer un concept de permissions
- [ ] Je connais le principe du moindre privilège

### TCL (Transaction Control Language)
- [ ] Je comprends ce que sont les transactions
- [ ] Je peux expliquer ACID:
  - [ ] Atomicity
  - [ ] Consistency
  - [ ] Isolation
  - [ ] Durability
- [ ] Je peux utiliser les transactions:
  - [ ] START TRANSACTION
  - [ ] COMMIT
  - [ ] ROLLBACK
- [ ] Je sais quand les transactions sont nécessaires
- [ ] Je comprends les niveaux d'isolation

### Credit 5 - Centre médical
- [ ] Concept de permissions créé
  - [ ] 4 rôles décrits
  - [ ] Matrice de permissions remplie
  - [ ] Commandes SQL pour tous les utilisateurs
- [ ] Transactions implémentées
  - [ ] Réservation de rendez-vous avec transaction
  - [ ] Transfert de patient avec transaction
  - [ ] ACID expliqué pour les deux
- [ ] Documentation complète
- [ ] Soumis

---

## Liste 6: Préparation à l'examen théorique (unité 7)

### Révision théorie
- [ ] Diagrammes ER: Je peux les dessiner et les lire
- [ ] Formes normales: Je reconnais les violations et peux normaliser
- [ ] Cardinalités: Je comprends 1:1, 1:N, N:M
- [ ] ACID: Je peux expliquer les 4 propriétés
- [ ] Contraintes: Je connais toutes les importantes

### Révision SQL DDL
- [ ] CREATE DATABASE / USE
- [ ] CREATE TABLE avec toutes les contraintes
- [ ] ALTER TABLE
- [ ] DROP TABLE
- [ ] Choisir les bons types de données

### Révision SQL DML
- [ ] INSERT (simple, multiple, avec sous-requête)
- [ ] SELECT (WHERE, ORDER BY, LIMIT)
- [ ] UPDATE (avec WHERE!)
- [ ] DELETE (avec WHERE!)
- [ ] Agrégations (COUNT, SUM, AVG, MIN, MAX)

### Révision JOINs
- [ ] INNER JOIN
- [ ] LEFT JOIN
- [ ] RIGHT JOIN
- [ ] JOINs multiples
- [ ] GROUP BY avec JOINs
- [ ] HAVING

### Révision Transactions
- [ ] START TRANSACTION / COMMIT / ROLLBACK
- [ ] Pouvoir expliquer ACID
- [ ] Connaître les cas d'usage

### Préparation pratique au test
- [ ] Tous les anciens exercices refaits
- [ ] Diagrammes ER d'exemple dessinés
- [ ] Tables d'exemple créées
- [ ] Différents JOINs pratiqués
- [ ] Mock-test effectué
- [ ] Gestion du temps pratiquée (90 minutes)

### Le jour de l'examen (unité 7)
- [ ] Reposé et à l'heure
- [ ] Stylo et papier avec moi
- [ ] Rester calme
- [ ] Surveiller le temps
- [ ] Questions faciles d'abord
- [ ] Relire à la fin

---

## Liste maîtresse: Credits 1-5

| Credit | Thème | Date de remise | Statut | Points (0–5) |
|--------|-------|----------------|--------|------|
| Credit 1 | Fondamentaux | __________ | ☐ | ____ |
| Credit 2 | Conception BDD | __________ | ☐ | ____ |
| Credit 3 | SQL DML | __________ | ☐ | ____ |
| Credit 4 | JOINs & UNION | __________ | ☐ | ____ |
| Credit 5 | DCL & TCL | __________ | ☐ | ____ |

**Total Credits (Credit 1–10): ___ / 20% de la note finale**

Chaque credit est évalué de 0 à 5 points; une remise complète dans les délais donne 5 points. Les credits non remis donnent 0 point.

**Examen théorique SQL (unité 7): ___ / 30% de la note finale**

---

## Référence rapide: Commandes SQL les plus importantes

### DDL (Data Definition Language)
```sql
CREATE DATABASE name;
CREATE TABLE name (...);
ALTER TABLE name ...;
DROP TABLE name;
```

### DML (Data Manipulation Language)
```sql
INSERT INTO table VALUES (...);
SELECT * FROM table WHERE ...;
UPDATE table SET ... WHERE ...;
DELETE FROM table WHERE ...;
```

### DCL (Data Control Language)
```sql
CREATE USER 'user'@'host' IDENTIFIED BY 'password';
GRANT privileges ON database.* TO 'user'@'host';
REVOKE privileges ON database.* FROM 'user'@'host';
```

### TCL (Transaction Control Language)
```sql
START TRANSACTION;
COMMIT;
ROLLBACK;
```

### JOINs
```sql
SELECT ... FROM t1 INNER JOIN t2 ON ...;
SELECT ... FROM t1 LEFT JOIN t2 ON ...;
SELECT ... FROM t1 RIGHT JOIN t2 ON ...;
```

---

## Éviter les erreurs courantes

❌ **Erreur:** UPDATE/DELETE sans WHERE
✅ **Correct:** Toujours utiliser WHERE (sauf intentionnellement tous)

❌ **Erreur:** Utiliser SELECT *
✅ **Correct:** Sélectionner uniquement les colonnes nécessaires

❌ **Erreur:** Pas de PRIMARY KEYs définies
✅ **Correct:** Chaque table a besoin d'une PRIMARY KEY

❌ **Erreur:** VARCHAR sans limite
✅ **Correct:** Toujours spécifier la longueur (VARCHAR(100))

❌ **Erreur:** FLOAT pour les montants d'argent
✅ **Correct:** Utiliser DECIMAL(10,2)

❌ **Erreur:** Pas de FOREIGN KEYs
✅ **Correct:** Implémenter les relations avec FOREIGN KEY

❌ **Erreur:** Risque d'injection SQL
✅ **Correct:** Utiliser les Prepared Statements

---

## Ressources utiles

**En ligne:**
- W3Schools SQL Tutorial
- SQLZoo (exercices interactifs)
- Stack Overflow (questions & réponses)

**Outils:**
- HeidiSQL (Client MySQL)
- MySQL Workbench (Alternative)
- dbdiagram.io (Diagrammes ER en ligne)

**Dans le cours:**
- Forum Moodle pour les questions
- Heures de consultation avec l'enseignant
- Groupes d'étude avec les camarades

---

**Bonne chance! 🚀**
