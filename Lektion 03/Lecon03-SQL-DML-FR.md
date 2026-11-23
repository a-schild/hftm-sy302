# Leçon 3: SQL DML - Data Manipulation Language

## Objectifs d'apprentissage

L'étudiant(e) est capable de...
- Expliquer et appliquer les commandes DML
- Utiliser des commandes SQL DML simples
- Remplir une base de données simple avec des données et exécuter des requêtes
- Effectuer des opérations CREATE, UPDATE, DELETE

## Qu'est-ce que le DML?

**DML (Data Manipulation Language)** = Commandes SQL pour manipuler les données

Les quatre opérations de base (CRUD):
- **C**reate → `INSERT`
- **R**ead → `SELECT`
- **U**pdate → `UPDATE`
- **D**elete → `DELETE`

## La base de données HFTM Library

Pour cette leçon, nous travaillons avec la base de données **HFTM Library**.

### Schéma de la base de données

**Tables principales:**
- `authors` - Auteurs
- `books` - Livres
- `publishers` - Éditeurs
- `genres` - Genres
- `customers` - Clients
- `places` - Lieux
- `lends` - Prêts

**Tables de relations:**
- `authors_publishers` - N:M entre auteurs et éditeurs
- `authors_genres` - N:M entre auteurs et genres

### Configuration de la base de données

```sql
-- 1. Créer la base de données
CREATE DATABASE hftm_library;
USE hftm_library;

-- 2. Exécuter le script SQL
SOURCE /path/to/HFTM_Library.sql;

-- 3. Vérifier les tables
SHOW TABLES;

-- 4. Afficher la structure d'une table
DESCRIBE authors;
-- ou
SHOW COLUMNS FROM authors;
```

## INSERT - Insérer des données

### Syntaxe

```sql
-- Toutes les colonnes
INSERT INTO table VALUES (value1, value2, value3, ...);

-- Colonnes spécifiques
INSERT INTO table (column1, column2) VALUES (value1, value2);

-- Plusieurs lignes à la fois
INSERT INTO table (column1, column2) VALUES 
    (value1a, value2a),
    (value1b, value2b),
    (value1c, value2c);
```

### Exemples

**INSERT simple:**
```sql
-- Ajouter un auteur
INSERT INTO authors (lastname, firstname) 
VALUES ('Tolkien', 'J.R.R.');
```

**Plusieurs enregistrements:**
```sql
-- Plusieurs lieux en une fois
INSERT INTO places (zip, city) VALUES 
    (33016, 'Ottawa'), 
    (33017, 'Mississauga'), 
    (33018, 'Hamilton'), 
    (33019, 'Oshawa');
```

**Avec sous-requête:**
```sql
-- Auteur avec LocationID de la table places
INSERT INTO authors (lastname, firstname, address, location_id, email) 
VALUES ( 
    'Jordan', 
    'Robert',
    'Fiction Street 12',
    (SELECT id FROM places WHERE zip='25000'),
    'robert.jordan@hftm.ch'
);
```

### AUTO_INCREMENT

Avec PRIMARY KEY et AUTO_INCREMENT, l'ID **ne doit pas** être spécifié:

```sql
-- L'ID est attribué automatiquement
INSERT INTO authors (lastname, firstname) 
VALUES ('King', 'Stephen');

-- Récupérer le dernier ID inséré
SELECT LAST_INSERT_ID();
```

### Valeurs DEFAULT

```sql
-- Table avec valeurs par défaut
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- INSERT sans status et created_at
INSERT INTO users (username) VALUES ('max_mueller');
-- status sera automatiquement 'active', created_at sera l'horodatage actuel
```

## SELECT - Interroger des données

### Syntaxe SELECT de base

```sql
-- Toutes les colonnes, toutes les lignes
SELECT * FROM table;

-- Colonnes spécifiques
SELECT column1, column2 FROM table;

-- Avec condition WHERE
SELECT * FROM table WHERE condition;

-- Avec ORDER BY (tri)
SELECT * FROM table ORDER BY column ASC;  -- Ascendant
SELECT * FROM table ORDER BY column DESC; -- Descendant

-- Avec LIMIT (limiter le nombre)
SELECT * FROM table LIMIT 10;

-- LIMIT avec OFFSET (pour la pagination)
SELECT * FROM table LIMIT 10 OFFSET 20;  -- Lignes 21-30
```

### Conditions WHERE

**Opérateurs de comparaison:**
```sql
-- Égal
SELECT * FROM authors WHERE lastname = 'Tolkien';

-- Différent
SELECT * FROM authors WHERE lastname != 'Tolkien';
-- ou
SELECT * FROM authors WHERE lastname <> 'Tolkien';

-- Plus grand / Plus petit
SELECT * FROM places WHERE zip > 33015;
SELECT * FROM books WHERE published_date < '2000-01-01';

-- Plus grand ou égal / Plus petit ou égal
SELECT * FROM places WHERE zip >= 33016 AND zip <= 33019;
```

**Opérateurs logiques:**
```sql
-- AND
SELECT * FROM authors 
WHERE lastname = 'Matthews' AND firstname = 'Summer';

-- OR
SELECT * FROM authors 
WHERE lastname = 'Hornby' OR lastname = 'Rowling';

-- Combiné (attention aux parenthèses!)
SELECT * FROM books 
WHERE (published_date > '2000-01-01' AND genre_id = 3) 
   OR (published_date < '1950-01-01');

-- NOT
SELECT * FROM authors WHERE NOT lastname = 'Tolkien';
```

**LIKE - Recherche de motifs:**
```sql
-- Nom de famille commence par 'M'
SELECT * FROM authors WHERE lastname LIKE 'M%';

-- Nom de famille se termine par 'son'
SELECT * FROM authors WHERE lastname LIKE '%son';

-- Nom de famille contient 'ann'
SELECT * FROM authors WHERE lastname LIKE '%ann%';

-- Exactement 5 caractères (avec _)
SELECT * FROM authors WHERE lastname LIKE '_____';

-- Case-insensitive dans MySQL/MariaDB (par défaut)
SELECT * FROM authors WHERE lastname LIKE 'tolkien';
```

**IN - Liste de valeurs:**
```sql
-- Nom de famille est Tolkien, Rowling ou King
SELECT * FROM authors 
WHERE lastname IN ('Tolkien', 'Rowling', 'King');

-- Avec sous-requête
SELECT * FROM books 
WHERE author_id IN (SELECT id FROM authors WHERE lastname LIKE 'M%');
```

**BETWEEN - Plage de valeurs:**
```sql
-- ZIP entre 33016 et 33019
SELECT * FROM places 
WHERE zip BETWEEN 33016 AND 33019;

-- Date entre deux valeurs
SELECT * FROM books 
WHERE published_date BETWEEN '2000-01-01' AND '2010-12-31';
```

**IS NULL / IS NOT NULL:**
```sql
-- Email n'est pas défini
SELECT * FROM authors WHERE email IS NULL;

-- Email est défini
SELECT * FROM authors WHERE email IS NOT NULL;
```

### Tri (ORDER BY)

```sql
-- Ascendant (par défaut)
SELECT * FROM authors ORDER BY lastname ASC;
-- ou simplement
SELECT * FROM authors ORDER BY lastname;

-- Descendant
SELECT * FROM authors ORDER BY lastname DESC;

-- Plusieurs colonnes
SELECT * FROM authors 
ORDER BY lastname ASC, firstname ASC;

-- Par colonne calculée
SELECT firstname, lastname, YEAR(CURDATE()) - YEAR(birth_date) AS age
FROM authors 
ORDER BY age DESC;
```

### LIMIT et OFFSET

```sql
-- Seulement les 10 premiers
SELECT * FROM books LIMIT 10;

-- Lignes 11-20 (pour la pagination)
SELECT * FROM books LIMIT 10 OFFSET 10;

-- Forme courte (LIMIT offset, count)
SELECT * FROM books LIMIT 10, 10;  -- Lignes 11-20
```

### DISTINCT - Supprimer les doublons

```sql
-- Tous les genres différents
SELECT DISTINCT genre_id FROM books;

-- Toutes les combinaisons différentes
SELECT DISTINCT author_id, genre_id FROM books;
```

## UPDATE - Mettre à jour des données

### Syntaxe

```sql
UPDATE table 
SET column1 = value1, column2 = value2
WHERE condition;
```

⚠️ **IMPORTANT:** Sans WHERE, **TOUTES** les lignes sont mises à jour!

### Exemples

**UPDATE simple:**
```sql
-- Changer le code postal d'Oshawa
UPDATE places 
SET zip = 33020
WHERE city = 'Oshawa';
```

**Plusieurs colonnes:**
```sql
-- Mettre à jour les données de l'auteur
UPDATE authors 
SET lastname = 'Armistead', 
    firstname = 'Maupin' 
WHERE lastname = 'Matthews' AND firstname = 'Summer';
```

**Avec sous-requête:**
```sql
-- Changer l'éditeur pour tous les livres de 'B & W Publishing'
UPDATE books 
SET publisher_id = (SELECT id FROM publishers WHERE name = 'Lakewater Press') 
WHERE publisher_id = (SELECT id FROM publishers WHERE name = 'B & W Publishing');
```

**Avec IN et sous-requête:**
```sql
-- Définir location_id pour tous les auteurs dont le nom commence par 'Z'
UPDATE authors 
SET location_id = (SELECT id FROM places WHERE zip = 97499)
WHERE lastname LIKE 'Z%';
```

### Fonctions de chaîne dans UPDATE

```sql
-- Supprimer les espaces au début
UPDATE books 
SET title = TRIM(title) 
WHERE title LIKE ' %';

-- En majuscules
UPDATE authors 
SET lastname = UPPER(lastname);

-- En minuscules
UPDATE authors 
SET email = LOWER(email);

-- Remplacer une sous-chaîne
UPDATE books 
SET title = REPLACE(title, 'old', 'new');
```

### Fonctions de date dans UPDATE

```sql
-- Ajouter 14 jours à la date de retour
UPDATE lends 
SET date_to = DATE_ADD(date_to, INTERVAL 14 DAY) 
WHERE date_to >= CURDATE();

-- Définir la date au premier du mois
UPDATE events 
SET event_date = DATE_FORMAT(event_date, '%Y-%m-01');
```

### Calculs dans UPDATE

```sql
-- Augmenter le prix de 10%
UPDATE books 
SET price = price * 1.10;

-- Réduire le stock de 5
UPDATE books 
SET amount_in_stock = amount_in_stock - 5 
WHERE isbn = 'ISBN-00001';
```

## DELETE - Supprimer des données

### Syntaxe

```sql
DELETE FROM table 
WHERE condition;
```

⚠️ **IMPORTANT:** Sans WHERE, **TOUTES** les lignes sont supprimées!

### Exemples

**Supprimer une seule ligne:**
```sql
-- Supprimer le lieu 'Oshawa'
DELETE FROM places 
WHERE city = 'Oshawa';
```

**Avec sous-requête:**
```sql
-- Supprimer tous les livres d'un auteur
DELETE FROM books 
WHERE author_id = (
    SELECT id FROM authors 
    WHERE firstname = 'Daphne' AND lastname = 'Scott'
);
```

**Plusieurs lignes:**
```sql
-- Supprimer tous les anciens prêts
DELETE FROM lends 
WHERE date_to < '2020-01-01';

-- Tous les livres sans stock
DELETE FROM books 
WHERE amount_in_stock = 0;
```

### TRUNCATE vs DELETE

```sql
-- DELETE: Supprime les lignes individuellement, peut être annulé
DELETE FROM books;

-- TRUNCATE: Plus rapide, supprime toutes les données, réinitialise AUTO_INCREMENT
TRUNCATE TABLE books;
```

**Différences:**
| Fonctionnalité | DELETE | TRUNCATE |
|----------------|--------|----------|
| WHERE possible | ✅ Oui | ❌ Non |
| Vitesse | Plus lent | Plus rapide |
| Rollback | ✅ Oui | ❌ Non |
| AUTO_INCREMENT | Reste | Est réinitialisé |
| Triggers | Sont déclenchés | Ne sont pas déclenchés |

## Sous-requêtes (Subqueries)

Les sous-requêtes peuvent être utilisées dans INSERT, UPDATE, DELETE et SELECT.

### Dans WHERE

```sql
-- Livres de tous les auteurs dont le nom commence par 'M'
SELECT * FROM books 
WHERE author_id IN (
    SELECT id FROM authors WHERE lastname LIKE 'M%'
);
```

### Dans INSERT

```sql
-- Client avec location_id de sous-requête
INSERT INTO customers (lastname, firstname, location_id)
VALUES ('Mueller', 'Max', 
    (SELECT id FROM places WHERE zip = '25000')
);
```

### Dans UPDATE

```sql
-- Changer le genre d'un livre
UPDATE books 
SET genre_id = (SELECT id FROM genres WHERE genre = 'Science fiction') 
WHERE title = 'Nineteen Eighty Four';
```

### Dans DELETE

```sql
-- Supprimer tous les livres d'un éditeur spécifique
DELETE FROM books 
WHERE publisher_id = (
    SELECT id FROM publishers WHERE name = 'Unwanted Press'
);
```

## Fonctions SQL importantes

### Fonctions de chaîne

```sql
-- Longueur d'une chaîne
SELECT LENGTH('Hello');  -- 5

-- Majuscules / Minuscules
SELECT UPPER('hello');   -- 'HELLO'
SELECT LOWER('HELLO');   -- 'hello'

-- Sous-chaîne
SELECT SUBSTRING('Hello World', 1, 5);  -- 'Hello'
SELECT LEFT('Hello', 2);                 -- 'He'
SELECT RIGHT('Hello', 2);                -- 'lo'

-- Supprimer les espaces
SELECT TRIM('  Hello  ');        -- 'Hello'
SELECT LTRIM('  Hello');         -- 'Hello'
SELECT RTRIM('Hello  ');         -- 'Hello'

-- Concaténation de chaînes
SELECT CONCAT('Hello', ' ', 'World');    -- 'Hello World'
SELECT CONCAT_WS('-', '2024', '10', '10');  -- '2024-10-10'

-- Remplacer
SELECT REPLACE('Hello World', 'World', 'SQL');  -- 'Hello SQL'

-- Remplir
SELECT LPAD('5', 3, '0');   -- '005'
SELECT RPAD('5', 3, '0');   -- '500'
```

### Fonctions de date

```sql
-- Date/Heure actuelle
SELECT CURDATE();           -- 2024-10-10
SELECT CURTIME();           -- 14:30:00
SELECT NOW();               -- 2024-10-10 14:30:00

-- Extraire les parties de date
SELECT YEAR('2024-10-10');   -- 2024
SELECT MONTH('2024-10-10');  -- 10
SELECT DAY('2024-10-10');    -- 10
SELECT DAYNAME('2024-10-10'); -- 'Thursday'

-- Formater la date
SELECT DATE_FORMAT(NOW(), '%d.%m.%Y');        -- '10.10.2024'
SELECT DATE_FORMAT(NOW(), '%W, %M %d, %Y');  -- 'Thursday, October 10, 2024'

-- Calculs de date
SELECT DATE_ADD('2024-10-10', INTERVAL 7 DAY);   -- 2024-10-17
SELECT DATE_SUB('2024-10-10', INTERVAL 1 MONTH); -- 2024-09-10

-- Différence entre dates
SELECT DATEDIFF('2024-12-31', '2024-01-01');  -- 365
```

### Fonctions numériques

```sql
-- Arrondi
SELECT ROUND(3.14159, 2);    -- 3.14
SELECT CEIL(3.1);            -- 4
SELECT FLOOR(3.9);           -- 3

-- Fonctions mathématiques
SELECT ABS(-5);              -- 5
SELECT SQRT(16);             -- 4
SELECT POWER(2, 3);          -- 8
SELECT MOD(10, 3);           -- 1 (reste de 10/3)

-- Nombres aléatoires
SELECT RAND();               -- 0.xxx (entre 0 et 1)
SELECT FLOOR(RAND() * 100);  -- 0-99
```

## Exercices pratiques

### Exercice 1: Nouvel auteur et livres

1. Ajouter un nouveau lieu: Biel/Bienne, code postal 25000
2. Ajouter un nouvel auteur: Robert Jordan
3. Ajouter un nouvel éditeur: hftm Publishing
4. Lier l'auteur à l'éditeur
5. Ajouter 3 livres de la série "Wheel of Time"
6. Ajouter un nouveau client
7. Créer 3 prêts pour le client

### Exercice 2: Mettre à jour les données

1. Changer l'e-mail de 'Sleepytown Press' en 'john.sleepy@mail.com'
2. Supprimer les espaces de début de tous les titres de livres
3. Mettre à jour l'adresse d'Abdul Murphy
4. Changer le genre de "Nineteen Eighty Four" en "Science fiction"
5. Prolonger tous les prêts actifs de 14 jours

### Exercice 3: Ajouter et remplir des colonnes

1. Ajouter des colonnes pour jour, mois, année de la date de naissance
2. Remplir ces colonnes à partir du champ birth_date
3. Ajouter une colonne pour le format de date suisse (DD.MM.YYYY)
4. Remplir cette colonne

### Exercice 4: Requêtes complexes

1. Trouver tous les livres d'auteurs dont le nom commence par 'M'
2. Trouver tous les éditeurs sans auteurs assignés
3. Lister tous les prêts en retard
4. Compter les livres par genre

## Bonnes pratiques

### À FAIRE ✅

- **Toujours utiliser WHERE** avec UPDATE et DELETE
- **Tester les sous-requêtes** avant de les utiliser dans UPDATE/DELETE
- **Utiliser des transactions** pour plusieurs modifications liées
- **Vérifier les données** avec SELECT d'abord
- **Créer des sauvegardes** avant les modifications importantes

### À NE PAS FAIRE ❌

- **Jamais UPDATE/DELETE sans WHERE** (sauf intentionnellement)
- **Pas de sous-requêtes complexes** sans test
- **Pas d'injection SQL** (toujours utiliser Prepared Statements dans les applications)
- **Ne pas modifier directement en production** sans test

### Conseil de sécurité

```sql
-- Toujours tester d'abord avec SELECT!

-- 1. SELECT pour tester
SELECT * FROM books WHERE publisher_id = 5;

-- 2. Si correct, alors UPDATE
UPDATE books SET price = price * 1.1 WHERE publisher_id = 5;
```

## Transactions

```sql
-- Démarrer une transaction
START TRANSACTION;
-- ou
BEGIN;

-- Plusieurs opérations
INSERT INTO customers (...) VALUES (...);
INSERT INTO lends (...) VALUES (...);
UPDATE books SET amount_in_stock = amount_in_stock - 1 WHERE id = 1;

-- Tout confirmer
COMMIT;

-- Ou tout annuler en cas d'erreur
ROLLBACK;
```

## Devoirs

### Exercice pour Credit 3

Terminer toutes les tâches DML de la feuille d'exercices:
- Opérations INSERT (exercices 1-4)
- Opérations UPDATE (exercice 5)
- Documenter vos commandes SQL
- Tester toutes les requêtes avec SELECT

**À remettre:**
- Fichier SQL avec toutes les commandes
- Commentaires sur les requêtes importantes/complexes
- Captures d'écran des résultats

## Ressources supplémentaires

- [SQL DML Tutorial - W3Schools](https://www.w3schools.com/sql/sql_insert.asp)
- [MySQL String Functions](https://dev.mysql.com/doc/refman/8.0/en/string-functions.html)
- [MySQL Date Functions](https://dev.mysql.com/doc/refman/8.0/en/date-and-time-functions.html)
- [SQL Subqueries](https://www.geeksforgeeks.org/sql-subquery/)

## Prochaines étapes

Dans la leçon 4, nous apprendrons:
- SQL JOINs (INNER, LEFT, RIGHT, FULL)
- UNION
- Requêtes complexes sur plusieurs tables
- Fonctions d'agrégation (COUNT, SUM, AVG, etc.)
