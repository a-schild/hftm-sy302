# Leçon 4: SQL JOINs & UNION

## Objectifs d'apprentissage

L'étudiant(e) est capable de...
- Utiliser des commandes SQL DML simples
- Remplir une base de données simple avec des données et exécuter des requêtes
- Comprendre et appliquer les JOINs
- Combiner des données de plusieurs tables
- Accéder à une base de données distante avec HeidiSQL via un tunnel SSH

## Pourquoi les JOINs?

Dans les bases de données relationnelles, les données sont **réparties sur plusieurs tables**. Avec les JOINs, nous pouvons **réunir** ces données.

### Exemple

```
Table: books                   Table: authors
┌────┬────────┬───────────┐   ┌────┬───────────┬──────────┐
│ ID │ Titel  │ AuthorsID │   │ ID │ Firstname │ Lastname │
├────┼────────┼───────────┤   ├────┼───────────┼──────────┤
│ 1  │ Hobbit │ 10        │   │ 10 │ J.R.R.    │ Tolkien  │
│ 2  │ 1984   │ 15        │   │ 15 │ George    │ Orwell   │
└────┴────────┴───────────┘   └────┴───────────┴──────────┘
```

**Objectif:** Afficher les livres avec les noms d'auteurs

```
┌────────┬──────────┐
│ Titel  │ Lastname │
├────────┼──────────┤
│ Hobbit │ Tolkien  │
│ 1984   │ Orwell   │
└────────┴──────────┘
```

## INNER JOIN

L'**INNER JOIN** ne retourne que les lignes qui ont une correspondance dans **les deux** tables.

### Syntaxe

```sql
SELECT columns
FROM table1
INNER JOIN table2 ON table1.column = table2.column;
```

### Diagramme de Venn

```
┌──────────┐  ┌──────────┐
│          │  │          │
│   A      │  │     B    │
│      ┌───┼──┼───┐      │
│      │///│  │///│      │
│      │///│  │///│      │
│      └───┼──┼───┘      │
│          │  │          │
└──────────┘  └──────────┘
   Seulement l'intersection
```

### Exemples

**Livres avec noms d'auteurs:**
```sql
SELECT 
    books.Titel,
    authors.Lastname,
    authors.Firstname
FROM books
INNER JOIN authors ON books.AuthorsID = authors.ID;
```

**Avec alias (plus court):**
```sql
SELECT 
    b.Titel,
    a.Lastname,
    a.Firstname
FROM books b
INNER JOIN authors a ON b.AuthorsID = a.ID;
```

**Plusieurs JOINs:**
```sql
SELECT 
    b.Titel,
    a.Lastname AS author,
    g.Genre,
    p.Name AS publisher
FROM books b
INNER JOIN authors a ON b.AuthorsID = a.ID
INNER JOIN genres g ON b.GenresID = g.ID
INNER JOIN publishers p ON b.PublishersID = p.ID;
```

**Avec condition WHERE:**
```sql
SELECT 
    b.Titel,
    a.Lastname
FROM books b
INNER JOIN authors a ON b.AuthorsID = a.ID
WHERE a.Lastname = 'Tolkien';
```

## LEFT JOIN (LEFT OUTER JOIN)

Le **LEFT JOIN** retourne **toutes les lignes** de la table de gauche, même s'il n'y a pas de correspondance dans la table de droite.

### Syntaxe

```sql
SELECT columns
FROM table1
LEFT JOIN table2 ON table1.column = table2.column;
```

### Diagramme de Venn

```
┌──────────┐  ┌──────────┐
│//////////│  │          │
│//////////│  │     B    │
│//////┌───┼──┼───┐      │
│//////│///│  │///│      │
│//////│///│  │///│      │
│//////└───┼──┼───┘      │
│//////////│  │          │
└──────────┘  └──────────┘
   Tout de A + Intersection
```

### Exemples

**Tous les auteurs avec leurs livres (même les auteurs sans livres):**
```sql
SELECT 
    a.Lastname,
    a.Firstname,
    b.Titel
FROM authors a
LEFT JOIN books b ON a.ID = b.AuthorsID
ORDER BY a.Lastname;
```

**Trouver les auteurs SANS livres:**
```sql
SELECT 
    a.Lastname,
    a.Firstname
FROM authors a
LEFT JOIN books b ON a.ID = b.AuthorsID
WHERE b.ID IS NULL;
```

**Clients avec nombre de prêts:**
```sql
SELECT 
    c.Lastname,
    c.Firstname,
    COUNT(l.ID) AS loan_count
FROM customers c
LEFT JOIN lends l ON c.ID = l.CustomerID
GROUP BY c.ID, c.Lastname, c.Firstname
ORDER BY loan_count DESC;
```

## RIGHT JOIN (RIGHT OUTER JOIN)

Le **RIGHT JOIN** retourne **toutes les lignes** de la table de droite, même s'il n'y a pas de correspondance dans la table de gauche.

### Syntaxe

```sql
SELECT columns
FROM table1
RIGHT JOIN table2 ON table1.column = table2.column;
```

### Diagramme de Venn

```
┌──────────┐  ┌──────────┐
│          │  │//////////│
│   A      │  │//////////│
│      ┌───┼──┼───┐//////│
│      │///│  │///│//////│
│      │///│  │///│//////│
│      └───┼──┼───┘//////│
│          │  │//////////│
└──────────┘  └──────────┘
   Intersection + Tout de B
```

### Exemple

**Tous les livres avec auteurs (même les livres sans auteur assigné):**
```sql
SELECT 
    b.Titel,
    a.Lastname,
    a.Firstname
FROM authors a
RIGHT JOIN books b ON a.ID = b.AuthorsID;
```

**Note:** RIGHT JOIN est utilisé moins souvent. On peut généralement réécrire la requête avec LEFT JOIN:

```sql
-- Même requête avec LEFT JOIN
SELECT 
    b.Titel,
    a.Lastname,
    a.Firstname
FROM books b
LEFT JOIN authors a ON b.AuthorsID = a.ID;
```

## FULL OUTER JOIN

Le **FULL OUTER JOIN** retourne **toutes les lignes** des deux tables.

### Diagramme de Venn

```
┌──────────┐  ┌──────────┐
│//////////│  │//////////│
│//////////│  │//////////│
│//////┌───┼──┼───┐//////│
│//////│///│  │///│//////│
│//////│///│  │///│//////│
│//////└───┼──┼───┘//////│
│//////////│  │//////////│
└──────────┘  └──────────┘
        Tout de A et B
```

**IMPORTANT:** MySQL/MariaDB ne supporte pas directement FULL OUTER JOIN!

### Solution de contournement avec UNION

```sql
-- Simulation avec UNION
SELECT 
    a.Lastname,
    b.Titel
FROM authors a
LEFT JOIN books b ON a.ID = b.AuthorsID

UNION

SELECT 
    a.Lastname,
    b.Titel
FROM authors a
RIGHT JOIN books b ON a.ID = b.AuthorsID;
```

## CROSS JOIN

Le **CROSS JOIN** crée le **produit cartésien** des deux tables (chaque ligne de A avec chaque ligne de B).

### Exemple

```sql
-- Toutes les combinaisons d'auteurs et de genres
SELECT 
    a.Lastname,
    g.Genre
FROM authors a
CROSS JOIN genres g;
```

**Résultat:**
```
Si authors a 100 lignes et genres 10 lignes,
cela donne 100 * 10 = 1000 lignes!
```

**Utilisation:**
- Rare en pratique
- Générer des données de test
- Toutes les combinaisons possibles

## SELF JOIN

Un **SELF JOIN** connecte une table avec elle-même.

L'exemple suivant utilise la table d'exemple séparée `employees`; elle ne fait pas partie de la base de données HFTM Library.

### Exemple: Employés et leurs superviseurs

```sql
-- Table: employees
-- id | name      | manager_id
-- 1  | Boss      | NULL
-- 2  | Manager1  | 1
-- 3  | Employee1 | 2

SELECT 
    e.name AS employee,
    m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

**Résultat:**
```
┌───────────┬──────────┐
│ employee  │ manager  │
├───────────┼──────────┤
│ Boss      │ NULL     │
│ Manager1  │ Boss     │
│ Employee1 │ Manager1 │
└───────────┴──────────┘
```

## Relations N:M avec JOINs

Pour les relations N:M, nous devons joindre via la **table intermédiaire**.

### Exemple: Auteurs et éditeurs

```sql
-- Tous les auteurs avec leurs éditeurs
SELECT 
    a.Lastname,
    a.Firstname,
    p.Name AS publisher
FROM authors a
INNER JOIN authors_publishers ap ON a.ID = ap.AuthorsID
INNER JOIN publishers p ON ap.PublishersID = p.ID;
```

### Exemple: Auteurs et leurs genres

```sql
-- Auteurs avec tous leurs genres
SELECT 
    a.Lastname,
    a.Firstname,
    GROUP_CONCAT(g.Genre SEPARATOR ', ') AS genres
FROM authors a
INNER JOIN authors_genres ag ON a.ID = ag.AuthorsID
INNER JOIN genres g ON ag.GenresID = g.ID
GROUP BY a.ID, a.Lastname, a.Firstname;
```

## UNION

**UNION** combine les résultats de deux ou plusieurs instructions SELECT **verticalement** (lignes les unes sous les autres).

### Syntaxe

```sql
SELECT columns FROM table1
UNION
SELECT columns FROM table2;
```

### Règles pour UNION

1. Même **nombre de colonnes** dans chaque SELECT
2. Les colonnes doivent avoir des **types de données compatibles**
3. Les colonnes sont combinées par **position** (pas par nom)
4. **UNION** supprime les doublons
5. **UNION ALL** conserve les doublons

### Exemples

**UNION simple:**
```sql
-- Tous les auteurs et tous les clients dans une liste
SELECT Lastname, Firstname, 'Author' AS type
FROM authors
UNION
SELECT Lastname, Firstname, 'Customer' AS type
FROM customers
ORDER BY Lastname;
```

**UNION ALL (avec doublons):**
```sql
SELECT Lastname FROM authors
UNION ALL
SELECT Lastname FROM customers;
-- Si un nom est dans les deux tables, il apparaît 2 fois
```

**Exemple pratique: Liste de contacts complète**
```sql
SELECT 
    CONCAT(Firstname, ' ', Lastname) AS name,
    Email,
    'Author' AS category
FROM authors
WHERE Email IS NOT NULL

UNION

SELECT 
    CONCAT(Firstname, ' ', Lastname) AS name,
    Email,
    'Customer' AS category
FROM customers
WHERE Email IS NOT NULL

ORDER BY name;
```

## Fonctions d'agrégation avec JOINs

### COUNT, SUM, AVG, MIN, MAX

```sql
-- Nombre de livres par auteur
SELECT 
    a.Lastname,
    a.Firstname,
    COUNT(b.ID) AS book_count
FROM authors a
LEFT JOIN books b ON a.ID = b.AuthorsID
GROUP BY a.ID, a.Lastname, a.Firstname
ORDER BY book_count DESC;

-- Nombre moyen de livres par éditeur
SELECT 
    p.Name,
    AVG(b.AmountInStock) AS avg_stock,
    SUM(b.AmountInStock) AS total_stock
FROM publishers p
LEFT JOIN books b ON p.ID = b.PublishersID
GROUP BY p.ID, p.Name;

-- Livre le plus ancien et le plus récent par genre
SELECT 
    g.Genre,
    MIN(b.Published_Date) AS oldest,
    MAX(b.Published_Date) AS newest
FROM genres g
INNER JOIN books b ON g.ID = b.GenresID
GROUP BY g.ID, g.Genre;
```

## HAVING - Filtrage après agrégation

**WHERE** filtre avant le regroupement, **HAVING** filtre après le regroupement.

```sql
-- Auteurs avec plus de 5 livres
SELECT 
    a.Lastname,
    a.Firstname,
    COUNT(b.ID) AS book_count
FROM authors a
INNER JOIN books b ON a.ID = b.AuthorsID
GROUP BY a.ID, a.Lastname, a.Firstname
HAVING COUNT(b.ID) > 5
ORDER BY book_count DESC;

-- Genres avec en moyenne plus de 100 livres en stock
SELECT 
    g.Genre,
    AVG(b.AmountInStock) AS avg_stock
FROM genres g
INNER JOIN books b ON g.ID = b.GenresID
GROUP BY g.ID, g.Genre
HAVING AVG(b.AmountInStock) > 100;
```

## Raspberry Pi: accès avec HeidiSQL via un tunnel SSH

La base MariaDB du Raspberry Pi (leçon 3) n'est accessible que localement. Avec un tunnel SSH, nous redirigeons un port du portable de manière chiffrée vers le Raspberry Pi.

```
Portable (HeidiSQL) --SSH, port 22--> Raspberry Pi --> MariaDB 127.0.0.1:3306
```

### Variante A: tunnel directement dans HeidiSQL

1. Gestionnaire de sessions → **Nouveau**
2. Type de réseau: **MariaDB or MySQL (SSH tunnel)**
3. Onglet **Paramètres**: nom d'hôte `127.0.0.1`, utilisateur `student`, mot de passe, port `3306`
4. Onglet **Tunnel SSH**:
   - Programme SSH: `plink.exe` (fourni avec HeidiSQL) ou `ssh.exe`
   - Hôte et port SSH: `<pi-host>`, `22`
   - Nom d'utilisateur et mot de passe (ou clé privée) de l'utilisateur du Raspberry Pi
   - Port local: `3307`
5. **Ouvrir**

### Variante B: tunnel en ligne de commande

```bash
ssh -L 3307:127.0.0.1:3306 <utilisateur>@<pi-host>
```

Tant que cette connexion est ouverte, HeidiSQL se connecte normalement à `127.0.0.1`, port `3307`.

### Charger HFTM Library sur le Raspberry Pi

Dans HeidiSQL: **Fichier → Exécuter un fichier SQL** et choisir `HFTM Library.sql` (dossier `Lektion 03`). Le fichier crée lui-même la base `hftm_library`. Exécutez ensuite les exercices JOIN de cette leçon sur le Raspberry Pi.

À la leçon 5, nous ouvrons ensuite MariaDB à l'accès direct depuis le réseau.

## Exercices pratiques

### Exercice 1: JOINs simples

1. Lister tous les livres avec noms d'auteurs, genre et éditeur
2. Afficher tous les clients avec leur lieu de résidence (`places.City`, via `customers.LocationID`)
3. Trouver tous les prêts actuels avec noms de clients et titres de livres

### Exercice 2: LEFT JOIN

1. Afficher tous les auteurs, même ceux sans livres
2. Trouver tous les éditeurs sans livres
3. Lister tous les clients avec le nombre de leurs prêts (même 0)

### Exercice 3: Agrégations

1. Combien de livres chaque auteur a-t-il écrits?
2. Quel genre a le plus de livres?
3. Combien de prêts y a-t-il eu par mois?
4. Quel client a emprunté le plus de livres?

### Exercice 4: Requêtes complexes

1. Auteurs avec leurs genres (en liste séparée par des virgules)
2. Top 5 des livres les plus empruntés avec auteur
3. Éditeurs avec nombre d'auteurs et de livres
4. Durée moyenne de prêt par genre

### Exemples de solutions

**Exemple 1: Livres avec tous les détails**
```sql
SELECT 
    b.Titel,
    CONCAT(a.Firstname, ' ', a.Lastname) AS author,
    g.Genre,
    p.Name AS publisher,
    b.Published_Date,
    b.AmountInStock
FROM books b
INNER JOIN authors a ON b.AuthorsID = a.ID
INNER JOIN genres g ON b.GenresID = g.ID
INNER JOIN publishers p ON b.PublishersID = p.ID
ORDER BY b.Titel;
```

**Exemple 2: Top 10 des auteurs par nombre de livres**
```sql
SELECT 
    a.Lastname,
    a.Firstname,
    COUNT(b.ID) AS book_count
FROM authors a
LEFT JOIN books b ON a.ID = b.AuthorsID
GROUP BY a.ID, a.Lastname, a.Firstname
ORDER BY book_count DESC
LIMIT 10;
```

**Exemple 3: Prêts en retard**
```sql
SELECT 
    CONCAT(c.Firstname, ' ', c.Lastname) AS customer,
    b.Titel,
    l.Date_From,
    l.Date_To,
    DATEDIFF(CURDATE(), l.Date_To) AS days_overdue
FROM lends l
INNER JOIN customers c ON l.CustomerID = c.ID
INNER JOIN books b ON l.BookID = b.ID
WHERE l.Date_To < CURDATE()
ORDER BY days_overdue DESC;
```

## Bonnes pratiques

### Conseils de performance

1. **Index sur les colonnes de JOIN**: Primary et Foreign Keys doivent être indexées
2. **SELECT uniquement les colonnes nécessaires**: Pas de `SELECT *` en production
3. **WHERE avant JOIN**: Filtrer les données tôt
4. **Préférer INNER JOIN**: Si possible (plus rapide que OUTER JOINs)

### Lisibilité

```sql
-- Bien formaté
SELECT 
    b.Titel,
    a.Lastname,
    g.Genre
FROM books b
INNER JOIN authors a 
    ON b.AuthorsID = a.ID
INNER JOIN genres g 
    ON b.GenresID = g.ID
WHERE b.Published_Date > '2000-01-01'
ORDER BY b.Titel;
```

### Utiliser des alias

```sql
-- Utiliser des alias clairs
SELECT 
    b.Titel,          -- b pour books
    a.Lastname,       -- a pour authors
    pub.Name          -- pub pour publishers
FROM books b
INNER JOIN authors a ON b.AuthorsID = a.ID
INNER JOIN publishers pub ON b.PublishersID = pub.ID;
```

## Erreurs courantes à éviter

### 1. Produit cartésien (condition de JOIN oubliée)

❌ **Faux:**
```sql
-- Crée CHAQUE combinaison!
SELECT * FROM books, authors;
```

✅ **Correct:**
```sql
SELECT * FROM books b
INNER JOIN authors a ON b.AuthorsID = a.ID;
```

### 2. Noms de colonnes ambigus

❌ **Faux:**
```sql
-- Si les deux tables ont 'ID'
SELECT ID FROM books b
INNER JOIN authors a ON b.AuthorsID = a.ID;
-- Error: Column 'ID' in field list is ambiguous
```

✅ **Correct:**
```sql
SELECT b.ID, a.ID FROM books b
INNER JOIN authors a ON b.AuthorsID = a.ID;
```

### 3. GROUP BY sans fonction d'agrégation

❌ **Faux:**
```sql
-- Sans fonction d'agrégation, GROUP BY n'a pas de sens
SELECT a.Lastname FROM authors a
GROUP BY a.Lastname;
```

✅ **Correct:**
```sql
-- Avec COUNT
SELECT a.Lastname, COUNT(*) AS count FROM authors a
GROUP BY a.Lastname;
```

## Résumé

### Types de JOIN en aperçu

| Type de JOIN | Description | Utilisation |
|--------------|-------------|-------------|
| INNER JOIN | Seulement les lignes correspondantes | Standard, le plus fréquent |
| LEFT JOIN | Tout de la table de gauche | "Même sans correspondance" |
| RIGHT JOIN | Tout de la table de droite | Rare (réécrire en LEFT) |
| FULL OUTER | Tout des deux tables | Dans MySQL via UNION |
| CROSS JOIN | Produit cartésien | Rare, données de test |
| SELF JOIN | Table avec elle-même | Hiérarchies |

### UNION vs JOIN

- **JOIN**: Combine les colonnes (horizontalement) de différentes tables
- **UNION**: Combine les lignes (verticalement) de différentes requêtes

## Devoirs pour Credit 4

1. Implémenter la base de données du centre médical de la leçon 2
2. Insérer des données de test (min. 5 enregistrements par table)
3. Créer un dump DB (fichier .sql)
4. Exécuter 10 requêtes JOIN différentes
5. Documenter toutes les requêtes avec des commentaires

## Ressources supplémentaires

- [SQL JOINs Visualized](https://joins.spathon.com/)
- [SQL JOIN Tutorial - W3Schools](https://www.w3schools.com/sql/sql_join.asp)
- [Visual Representation of SQL Joins](https://www.codeproject.com/Articles/33052/Visual-Representation-of-SQL-Joins)

## Prochaines étapes

Dans la leçon 5, nous apprendrons:
- SQL avancé (DCL, TCL)
- Transactions et ACID
- Permissions et gestion des utilisateurs
- Niveaux d'isolation, verrous (locks) et deadlocks
