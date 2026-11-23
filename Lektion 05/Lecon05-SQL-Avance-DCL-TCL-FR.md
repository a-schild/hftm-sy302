# Leçon 5: SQL Avancé - DCL & TCL

## Objectifs d'apprentissage

L'étudiant(e) est capable de...
- Mettre en œuvre les permissions dans le système de base de données
- Reconnaître quand les transactions doivent être utilisées dans les bases de données SQL
- Expliquer le but des transactions
- Créer un concept de permissions et la matrice de permissions correspondante

## DCL - Data Control Language

**DCL** = Commandes SQL pour contrôler les droits d'accès

### Commandes DCL principales

- `GRANT` - Accorder des droits
- `REVOKE` - Retirer des droits

## Gestion des utilisateurs

### Créer un utilisateur

```sql
-- Créer un utilisateur
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';

-- Utilisateur de partout
CREATE USER 'username'@'%' IDENTIFIED BY 'password';

-- Utilisateur d'une IP spécifique
CREATE USER 'username'@'192.168.1.100' IDENTIFIED BY 'password';
```

### Supprimer un utilisateur

```sql
DROP USER 'username'@'localhost';
```

### Changer le mot de passe

```sql
-- Son propre mot de passe
SET PASSWORD = PASSWORD('new_password');

-- Mot de passe d'un autre utilisateur (en tant que root)
SET PASSWORD FOR 'username'@'localhost' = PASSWORD('new_password');

-- Moderne (MySQL 5.7+)
ALTER USER 'username'@'localhost' IDENTIFIED BY 'new_password';
```

### Lister les utilisateurs

```sql
-- Afficher tous les utilisateurs
SELECT User, Host FROM mysql.user;

-- Utilisateur actuel
SELECT CURRENT_USER();
```

## GRANT - Accorder des droits

### Syntaxe

```sql
GRANT privilege_type ON database.table TO 'user'@'host';
```

### Types de privilèges

**Opérations sur les données:**
- `SELECT` - Lire les données
- `INSERT` - Insérer des données
- `UPDATE` - Modifier les données
- `DELETE` - Supprimer des données

**Opérations sur la structure:**
- `CREATE` - Créer des tables/BDs
- `ALTER` - Modifier des tables
- `DROP` - Supprimer des tables/BDs
- `INDEX` - Créer/supprimer des index

**Droits administratifs:**
- `ALL PRIVILEGES` - Tous les droits
- `GRANT OPTION` - Pouvoir transmettre des droits
- `CREATE USER` - Créer des utilisateurs
- `RELOAD` - Recharger le serveur

### Exemples

**Droits de base:**
```sql
-- SELECT sur une base de données
GRANT SELECT ON hftm_library.* TO 'reader'@'localhost';

-- SELECT, INSERT, UPDATE sur une table
GRANT SELECT, INSERT, UPDATE ON hftm_library.books TO 'editor'@'localhost';

-- Tous les droits sur une base de données
GRANT ALL PRIVILEGES ON hftm_library.* TO 'admin'@'localhost';

-- Activer les droits
FLUSH PRIVILEGES;
```

**Colonnes spécifiques:**
```sql
-- Seulement certaines colonnes
GRANT SELECT (Titel, AuthorsID), UPDATE (Titel) 
ON hftm_library.books TO 'limited_user'@'localhost';
```

**Avec GRANT OPTION:**
```sql
-- L'utilisateur peut transmettre des droits
GRANT SELECT, INSERT ON hftm_library.* TO 'manager'@'localhost' 
WITH GRANT OPTION;
```

## REVOKE - Retirer des droits

```sql
-- Retirer des droits individuels
REVOKE INSERT, UPDATE ON hftm_library.books FROM 'editor'@'localhost';

-- Retirer tous les droits
REVOKE ALL PRIVILEGES ON hftm_library.* FROM 'user'@'localhost';

-- Retirer GRANT OPTION
REVOKE GRANT OPTION ON hftm_library.* FROM 'manager'@'localhost';

-- Activer les droits
FLUSH PRIVILEGES;
```

## Créer un concept de permissions

### Étape 1: Définir les rôles

**Exemple: Système de bibliothèque**

| Rôle | Description | Droits |
|------|-------------|--------|
| Administrator | Contrôle complet | ALL PRIVILEGES |
| Librarian | Gérer les livres | SELECT, INSERT, UPDATE, DELETE sur books, authors |
| Customer Service | Gérer clients et prêts | SELECT, INSERT, UPDATE sur customers, lends |
| Reader | Accès en lecture seule | SELECT sur toutes les tables |
| Reporter | Créer des rapports | SELECT sur toutes les tables |

### Étape 2: Matrice de permissions

|  | books | authors | customers | lends | publishers |
|--|-------|---------|-----------|-------|------------|
| **Administrator** | ALL | ALL | ALL | ALL | ALL |
| **Librarian** | CRUD | CRUD | R | R | R |
| **Customer Service** | R | R | CRUD | CRUD | - |
| **Reader** | R | R | - | - | - |
| **Reporter** | R | R | R | R | R |

Légende: CRUD = Create, Read, Update, Delete; R = Read only; - = Pas d'accès

### Étape 3: Implémentation

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

-- 4. Reader (Lecture seule)
CREATE USER 'reader'@'localhost' IDENTIFIED BY 'reader_pw';
GRANT SELECT ON hftm_library.books TO 'reader'@'localhost';
GRANT SELECT ON hftm_library.authors TO 'reader'@'localhost';

-- 5. Reporter
CREATE USER 'reporter'@'localhost' IDENTIFIED BY 'report_pw';
GRANT SELECT ON hftm_library.* TO 'reporter'@'localhost';

-- Activer les droits
FLUSH PRIVILEGES;
```

### Vérifier les droits

```sql
-- Afficher les droits d'un utilisateur
SHOW GRANTS FOR 'librarian'@'localhost';

-- Afficher ses propres droits
SHOW GRANTS;
```

## TCL - Transaction Control Language

**TCL** = Commandes SQL pour contrôler les transactions

### Les 3 commandes TCL

- `START TRANSACTION` / `BEGIN` - Démarrer une transaction
- `COMMIT` - Confirmer les modifications
- `ROLLBACK` - Annuler les modifications

## Qu'est-ce qu'une transaction?

Une **transaction** est une séquence de commandes SQL traitées comme une **unité atomique**.

### Propriétés ACID (rappel)

- **Atomicity**: Tout ou rien
- **Consistency**: État cohérent
- **Isolation**: Indépendant des autres transactions
- **Durability**: Stocké de manière permanente après COMMIT

## Quand utiliser les transactions?

### Cas d'usage

✅ **Transaction nécessaire:**
- Transfert d'argent (débit + crédit)
- Commande (réduire stock + créer commande)
- Inscription utilisateur (User + Profile + Permissions)
- Prêt de livre (marquer comme emprunté + enregistrer prêt)

❌ **Transaction pas nécessaire:**
- Requêtes SELECT individuelles
- Opérations INSERT/UPDATE/DELETE individuelles
- Données indépendantes

### Exemple: Transfert d'argent

**Sans transaction (DANGEREUX!):**
```sql
-- Si une erreur se produit ici, l'argent est perdu!
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
-- Crash serveur ici = argent perdu!
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
```

**Avec transaction (SÛR):**
```sql
START TRANSACTION;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

-- Seulement si les deux réussissent:
COMMIT;

-- En cas d'erreur:
-- ROLLBACK;
```

## Transactions en pratique

### Structure de base

```sql
START TRANSACTION;

-- Commandes SQL ici
-- ...

-- Tout est ok?
COMMIT;

-- Ou en cas d'erreur:
-- ROLLBACK;
```

### Exemple: Prêt de livre

```sql
START TRANSACTION;

-- 1. Vérifier si le livre est disponible
SELECT AmountInStock FROM books WHERE ID = 42;
-- Si AmountInStock > 0:

-- 2. Réduire le stock
UPDATE books SET AmountInStock = AmountInStock - 1 WHERE ID = 42;

-- 3. Enregistrer le prêt
INSERT INTO lends (CustomerID, BookID, Date_From, Date_To, Price)
VALUES (15, 42, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 5.00);

-- Tout s'est bien passé?
COMMIT;

-- En cas d'erreur (ex: client n'existe pas):
-- ROLLBACK;
```

### Exemple: Commande

```sql
START TRANSACTION;

-- 1. Créer la commande
INSERT INTO orders (customer_id, order_date, total)
VALUES (123, NOW(), 0);

SET @order_id = LAST_INSERT_ID();

-- 2. Ajouter les articles de commande
INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES 
    (@order_id, 10, 2, 29.99),
    (@order_id, 15, 1, 49.99);

-- 3. Réduire le stock
UPDATE products SET stock = stock - 2 WHERE id = 10;
UPDATE products SET stock = stock - 1 WHERE id = 15;

-- 4. Mettre à jour le prix total
UPDATE orders 
SET total = (SELECT SUM(quantity * price) FROM order_items WHERE order_id = @order_id)
WHERE id = @order_id;

COMMIT;
```

## Niveaux d'isolation

Les transactions peuvent être isolées à différents degrés.

### Les 4 niveaux d'isolation

| Niveau | Dirty Read | Non-Repeatable Read | Phantom Read |
|--------|------------|---------------------|--------------|
| READ UNCOMMITTED | ✅ Possible | ✅ Possible | ✅ Possible |
| READ COMMITTED | ❌ Pas possible | ✅ Possible | ✅ Possible |
| REPEATABLE READ | ❌ Pas possible | ❌ Pas possible | ✅ Possible |
| SERIALIZABLE | ❌ Pas possible | ❌ Pas possible | ❌ Pas possible |

**MySQL/MariaDB Standard:** REPEATABLE READ

### Définir le niveau d'isolation

```sql
-- Pour la session
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Pour la prochaine transaction
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Global (pour toutes les nouvelles connexions)
SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

### Problèmes avec les niveaux d'isolation bas

**Dirty Read:**
- Transaction A lit des données que Transaction B n'a pas encore committées
- B fait ROLLBACK → A a lu de fausses données

**Non-Repeatable Read:**
- Transaction A lit des données deux fois
- Entre les lectures, Transaction B modifie les données
- A obtient des résultats différents

**Phantom Read:**
- Transaction A fait SELECT avec WHERE
- Transaction B ajoute des lignes correspondantes
- A refait SELECT → soudainement plus de lignes

## SAVEPOINT - Rollback partiel

Avec SAVEPOINT, on peut marquer des états intermédiaires dans une transaction.

```sql
START TRANSACTION;

INSERT INTO customers (Lastname, Firstname, LocationID) VALUES ('Customer 1', 'Test', 1);
SAVEPOINT sp1;

INSERT INTO customers (Lastname, Firstname, LocationID) VALUES ('Customer 2', 'Test', 1);
SAVEPOINT sp2;

INSERT INTO customers (Lastname, Firstname, LocationID) VALUES ('Customer 3', 'Test', 1);

-- Revenir seulement jusqu'à sp2
ROLLBACK TO SAVEPOINT sp2;
-- Customer 3 est supprimé, Customer 1 et 2 sont toujours là

-- Tout confirmer
COMMIT;
```

## Autocommit

MySQL/MariaDB a **Autocommit activé** par défaut. Chaque commande SQL est immédiatement committée.

```sql
-- Vérifier le statut d'autocommit
SELECT @@autocommit;  -- 1 = activé, 0 = désactivé

-- Désactiver autocommit
SET autocommit = 0;

-- Maintenant il faut committer manuellement
INSERT INTO books (...) VALUES (...);
COMMIT;

-- Réactiver autocommit
SET autocommit = 1;
```

## Verrous (Locks)

Les transactions peuvent verrouiller des lignes ou des tables (lock).

### Verrous au niveau des lignes

```sql
START TRANSACTION;

-- Verrouiller la ligne pour mise à jour
SELECT * FROM books WHERE ID = 42 FOR UPDATE;

-- Maintenant aucun autre utilisateur ne peut modifier cette ligne
UPDATE books SET AmountInStock = AmountInStock - 1 WHERE ID = 42;

COMMIT;  -- Le verrou est libéré
```

### Verrou partagé (Shared Lock)

```sql
START TRANSACTION;

-- Les autres peuvent lire, mais pas modifier
SELECT * FROM books WHERE ID = 42 LOCK IN SHARE MODE;

-- ...

COMMIT;
```

### Verrous au niveau des tables

```sql
-- Verrouiller la table pour écriture
LOCK TABLES lends WRITE;

-- Seule cette session peut écrire
UPDATE lends SET Price = Price * 1.1;

-- Libérer le verrou
UNLOCK TABLES;
```

## Deadlocks (Interblocages)

Un **Deadlock** se produit lorsque deux transactions se bloquent mutuellement.

### Exemple

```
Transaction A:                  Transaction B:
1. Verrouille ligne 1          1. Verrouille ligne 2
2. Attend ligne 2...           2. Attend ligne 1...
   ↓ DEADLOCK! ↓                  ↓ DEADLOCK! ↓
```

**Solution MySQL:** Une transaction est automatiquement annulée (ROLLBACK)

### Éviter les Deadlocks

1. **Toujours même ordre** pour les verrous
2. **Garder les transactions courtes**
3. **Niveaux d'isolation plus bas** (si possible)
4. **Logique de retry** dans l'application

## Exercices pratiques

### Exercice 1: Concept de permissions Centre médical

Créer un concept de permissions pour le centre médical:

**Rôles:**
- Administrator
- Doctor
- Receptionist
- Patient (Lecture seule sur ses propres données)

**Créer:**
1. Descriptions des rôles
2. Matrice de permissions
3. Commandes SQL pour créer les utilisateurs
4. Commandes SQL pour accorder les droits

### Exercice 2: Implémenter des transactions

Implémenter les transactions suivantes pour HFTM Library:

1. **Prêt de livre:**
   - Vérifier si le livre est disponible
   - Réduire le stock
   - Enregistrer le prêt
   - Avec ROLLBACK en cas d'erreur

2. **Retour de livre:**
   - Marquer le prêt comme terminé
   - Augmenter le stock
   - Calculer les frais de retard (si en retard)

3. **Nouveau livre avec auteur:**
   - Créer l'auteur (s'il n'existe pas)
   - Créer le livre
   - Créer la liaison

### Exercice 3: Test des niveaux d'isolation

Tester différents niveaux d'isolation:

1. Ouvrir deux sessions MySQL
2. Tester Dirty Read avec READ UNCOMMITTED
3. Tester Non-Repeatable Read avec READ COMMITTED
4. Documenter les résultats

## Bonnes pratiques

### Transactions

✅ **À FAIRE:**
- Garder les transactions courtes
- N'inclure que les opérations nécessaires
- Implémenter la gestion des erreurs
- Ne pas oublier COMMIT

❌ **À NE PAS FAIRE:**
- Transactions longues
- Attendre une saisie utilisateur pendant une transaction
- SELECT sans modification dans une transaction
- Transactions imbriquées (non supportées dans MySQL)

### Permissions

✅ **À FAIRE:**
- Principe du moindre privilège (seulement les droits nécessaires)
- Utilisateurs séparés pour les applications
- Mots de passe forts
- Audits réguliers

❌ **À NE PAS FAIRE:**
- Utiliser l'utilisateur root en production
- ALL PRIVILEGES sans raison
- Stocker les mots de passe en clair
- Utilisateur avec '%' host en production

## Résumé

### DCL - Data Control Language
```sql
GRANT   -- Accorder des droits
REVOKE  -- Retirer des droits
```

### TCL - Transaction Control Language
```sql
START TRANSACTION / BEGIN   -- Démarrer une transaction
COMMIT                      -- Confirmer
ROLLBACK                    -- Annuler
SAVEPOINT                   -- État intermédiaire
```

### ACID
- **A**tomicity: Tout ou rien
- **C**onsistency: État cohérent
- **I**solation: Indépendant
- **D**urability: Permanent

## Devoirs pour Credit 5

1. Créer un concept de permissions pour votre projet
2. Implémenter 3 transactions pour des opérations typiques
3. Tester les transactions avec différents scénarios (succès, erreur)
4. Tout documenter dans un document

## Ressources supplémentaires

- [MySQL User Management](https://dev.mysql.com/doc/refman/8.0/en/user-account-management.html)
- [MySQL Transactions](https://dev.mysql.com/doc/refman/8.0/en/commit.html)
- [ACID Properties Explained](https://www.databricks.com/glossary/acid-transactions)
- [SQL Injection Prevention](https://owasp.org/www-community/attacks/SQL_Injection)

## Préparation au test

L'**examen théorique SQL** aura lieu à l'unité 7! La leçon 6 sert de révision.

**Thèmes:**
- Modélisation de données (diagramme ER, normalisation)
- SQL DDL (CREATE, ALTER, DROP)
- SQL DML (INSERT, UPDATE, DELETE, SELECT)
- JOINs (INNER, LEFT, RIGHT)
- Fonctions d'agrégation
- Sous-requêtes
- Bases des transactions

**Recommandation d'apprentissage:**
- Réviser tous les exercices précédents
- Pratiquer les commandes SQL dans HeidiSQL
- Savoir dessiner des diagrammes ER
- Comprendre la normalisation

## Prochaines étapes

Dans la leçon 6:
- Révision SQL et test d'exemple pour se préparer à l'examen théorique (unité 7, 30% de la note totale)
- Lancement du projet
- Choix du thème
- Démarrer le design DB
