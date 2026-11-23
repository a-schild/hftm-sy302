# Leçon 4: SQL JOINs & UNION

## Objectifs d'apprentissage

L'étudiant(e) est capable de...
- Utiliser des commandes SQL DML simples
- Remplir une base de données simple avec des données et exécuter des requêtes
- Comprendre et appliquer les JOINs
- Combiner des données de plusieurs tables

## Pourquoi les JOINs?

Dans les bases de données relationnelles, les données sont **réparties sur plusieurs tables**. Avec les JOINs, nous pouvons **réunir** ces données.

### Exemple

```
Table: books                   Table: authors
┌────┬────────┬───────────┐   ┌────┬──────────┬─────────┐
│ id │ title  │ author_id │   │ id │ name     │ country │
├────┼────────┼───────────┤   ├────┼──────────┼─────────┤
│ 1  │ Hobbit │ 10        │   │ 10 │ Tolkien  │ UK      │
│ 2  │ 1984   │ 15        │   │ 15 │ Orwell   │ UK      │
└────┴────────┴───────────┘   └────┴──────────┴─────────┘
```

**Objectif:** Afficher les livres avec les noms d'auteurs

```
┌────────┬──────────┐
│ title  │ name     │
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
    books.title,
    authors.lastname,
    authors.firstname
FROM books
INNER JOIN authors ON books.author_id = authors.id;
```

**Avec alias (plus court):**
```sql
SELECT 
    b.title,
    a.lastname,
    a.firstname
FROM books b
INNER JOIN authors a ON b.author_id = a.id;
```

**Plusieurs JOINs:**
```sql
SELECT 
    b.title,
    a.lastname AS author,
    g.genre,
    p.name AS publisher
FROM books b
INNER JOIN authors a ON b.author_id = a.id
INNER JOIN genres g ON b.genre_id = g.id
INNER JOIN publishers p ON b.publisher_id = p.id;
```

**Avec condition WHERE:**
```sql
SELECT 
    b.title,
    a.lastname
FROM books b
INNER JOIN authors a ON b.author_id = a.id
WHERE a.lastname = 'Tolkien';
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
    a.lastname,
    a.firstname,
    b.title
FROM authors a
LEFT JOIN books b ON a.id = b.author_id
ORDER BY a.lastname;
```

**Trouver les auteurs SANS livres:**
```sql
SELECT 
    a.lastname,
    a.firstname
FROM authors a
LEFT JOIN books b ON a.id = b.author_id
WHERE b.id IS NULL;
```

**Clients avec nombre de prêts:**
```sql
SELECT 
    c.lastname,
    c.firstname,
    COUNT(l.id) AS loan_count
FROM customers c
LEFT JOIN lends l ON c.id = l.customer_id
GROUP BY c.id, c.lastname, c.firstname
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

### Exemple

**Tous les livres avec auteurs (même les livres sans auteur assigné):**
```sql
SELECT 
    b.title,
    a.lastname,
    a.firstname
FROM authors a
RIGHT JOIN books b ON a.id = b.author_id;
```

**Note:** RIGHT JOIN est utilisé moins souvent. On peut généralement réécrire la requête avec LEFT JOIN:

```sql
-- Même requête avec LEFT JOIN
SELECT 
    b.title,
    a.lastname,
    a.firstname
FROM books b
LEFT JOIN authors a ON b.author_id = a.id;
```

## FULL OUTER JOIN

Le **FULL OUTER JOIN** retourne **toutes les lignes** des deux tables.

**IMPORTANT:** MySQL/MariaDB ne supporte pas directement FULL OUTER JOIN!

### Solution de contournement avec UNION

```sql
-- Simulation avec UNION
SELECT 
    a.lastname,
    b.title
FROM authors a
LEFT JOIN books b ON a.id = b.author_id

UNION

SELECT 
    a.lastname,
    b.title
FROM authors a
RIGHT JOIN books b ON a.id = b.author_id;
```

## CROSS JOIN

Le **CROSS JOIN** crée le **produit cartésien** des deux tables (chaque ligne de A avec chaque ligne de B).

### Exemple

```sql
-- Toutes les combinaisons d'auteurs et de genres
SELECT 
    a.lastname,
    g.genre
FROM authors a
CROSS JOIN genres g;
```

**Résultat:**
```
Si authors a 100 lignes et genres 10 lignes,
cela donne 100 * 10 = 1000 lignes!
```

## SELF JOIN

Un **SELF JOIN** connecte une table avec elle-même.

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
    a.lastname,
    a.firstname,
    p.name AS publisher
FROM authors a
INNER JOIN authors_publishers ap ON a.id = ap.author_id
INNER JOIN publishers p ON ap.publisher_id = p.id;
```

### Exemple: Auteurs et leurs genres

```sql
-- Auteurs avec tous leurs genres
SELECT 
    a.lastname,
    a.firstname,
    GROUP_CONCAT(g.genre SEPARATOR ', ') AS genres
FROM authors a
INNER JOIN authors_genres ag ON a.id = ag.author_id
INNER JOIN genres g ON ag.genre_id = g.id
GROUP BY a.id, a.lastname, a.firstname;
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
SELECT lastname, firstname, 'Author' AS type
FROM authors
UNION
SELECT lastname, firstname, 'Customer' AS type
FROM customers
ORDER BY lastname;
```

**UNION ALL (avec doublons):**
```sql
SELECT lastname FROM authors
UNION ALL
SELECT lastname FROM customers;
-- Si un nom est dans les deux tables, il apparaît 2 fois
```

**Exemple pratique: Liste de contacts complète**
```sql
SELECT 
    CONCAT(firstname, ' ', lastname) AS name,
    email,
    'Author' AS category
FROM authors
WHERE email IS NOT NULL

UNION

SELECT 
    CONCAT(firstname, ' ', lastname) AS name,
    email,
    'Customer' AS category
FROM customers
WHERE email IS NOT NULL

ORDER BY name;
```

## Fonctions d'agrégation avec JOINs

### COUNT, SUM, AVG, MIN, MAX

```sql
-- Nombre de livres par auteur
SELECT 
    a.lastname,
    a.firstname,
    COUNT(b.id) AS book_count
FROM authors a
LEFT JOIN books b ON a.id = b.author_id
GROUP BY a.id, a.lastname, a.firstname
ORDER BY book_count DESC;

-- Nombre moyen de livres par éditeur
SELECT 
    p.name,
    AVG(b.amount_in_stock) AS avg_stock,
    SUM(b.amount_in_stock) AS total_stock
FROM publishers p
LEFT JOIN books b ON p.id = b.publisher_id
GROUP BY p.id, p.name;

-- Livre le plus ancien et le plus récent par genre
SELECT 
    g.genre,
    MIN(b.published_date) AS oldest,
    MAX(b.published_date) AS newest
FROM genres g
INNER JOIN books b ON g.id = b.genre_id
GROUP BY g.id, g.genre;
```

## HAVING - Filtrage après agrégation

**WHERE** filtre avant le regroupement, **HAVING** filtre après le regroupement.

```sql
-- Auteurs avec plus de 5 livres
SELECT 
    a.lastname,
    a.firstname,
    COUNT(b.id) AS book_count
FROM authors a
INNER JOIN books b ON a.id = b.author_id
GROUP BY a.id, a.lastname, a.firstname
HAVING COUNT(b.id) > 5
ORDER BY book_count DESC;

-- Genres avec en moyenne plus de 100 livres en stock
SELECT 
    g.genre,
    AVG(b.amount_in_stock) AS avg_stock
FROM genres g
INNER JOIN books b ON g.id = b.genre_id
GROUP BY g.id, g.genre
HAVING AVG(b.amount_in_stock) > 100;
```

## Exercices pratiques

### Exercice 1: JOINs simples

1. Lister tous les livres avec noms d'auteurs, genre et éditeur
2. Afficher tous les clients avec leur lieu de résidence (city)
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
    b.title,
    CONCAT(a.firstname, ' ', a.lastname) AS author,
    g.genre,
    p.name AS publisher,
    b.published_date,
    b.amount_in_stock
FROM books b
INNER JOIN authors a ON b.author_id = a.id
INNER JOIN genres g ON b.genre_id = g.id
INNER JOIN publishers p ON b.publisher_id = p.id
ORDER BY b.title;
```

**Exemple 2: Top 10 des auteurs par nombre de livres**
```sql
SELECT 
    a.lastname,
    a.firstname,
    COUNT(b.id) AS book_count
FROM authors a
LEFT JOIN books b ON a.id = b.author_id
GROUP BY a.id, a.lastname, a.firstname
ORDER BY book_count DESC
LIMIT 10;
```

**Exemple 3: Prêts en retard**
```sql
SELECT 
    CONCAT(c.firstname, ' ', c.lastname) AS customer,
    b.title,
    l.date_from,
    l.date_to,
    DATEDIFF(CURDATE(), l.date_to) AS days_overdue
FROM lends l
INNER JOIN customers c ON l.customer_id = c.id
INNER JOIN books b ON l.book_id = b.id
WHERE l.date_to < CURDATE()
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
    b.title,
    a.lastname,
    g.genre
FROM books b
INNER JOIN authors a 
    ON b.author_id = a.id
INNER JOIN genres g 
    ON b.genre_id = g.id
WHERE b.published_date > '2000-01-01'
ORDER BY b.title;
```

### Utiliser des alias

```sql
-- Utiliser des alias clairs
SELECT 
    b.title,          -- b pour books
    a.lastname,       -- a pour authors
    pub.name          -- pub pour publishers
FROM books b
INNER JOIN authors a ON b.author_id = a.id
INNER JOIN publishers pub ON b.publisher_id = pub.id;
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
INNER JOIN authors a ON b.author_id = a.id;
```

### 2. Noms de colonnes ambigus

❌ **Faux:**
```sql
-- Si les deux tables ont 'id'
SELECT id FROM books b
INNER JOIN authors a ON b.author_id = a.id;
-- Error: Column 'id' in field list is ambiguous
```

✅ **Correct:**
```sql
SELECT b.id, a.id FROM books b
INNER JOIN authors a ON b.author_id = a.id;
```

### 3. GROUP BY sans fonction d'agrégation

❌ **Faux:**
```sql
-- Sans fonction d'agrégation, GROUP BY n'a pas de sens
SELECT a.lastname FROM authors a
GROUP BY a.lastname;
```

✅ **Correct:**
```sql
-- Avec COUNT
SELECT a.lastname, COUNT(*) AS count FROM authors a
GROUP BY a.lastname;
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
- Stored Procedures et Triggers (introduction)
