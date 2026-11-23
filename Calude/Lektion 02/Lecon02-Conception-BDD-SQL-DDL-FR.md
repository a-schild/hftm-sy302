# Leçon 2: Conception de bases de données & SQL DDL

## Objectifs d'apprentissage

L'étudiant(e) est capable de...
- Expliquer le processus de conception de bases de données
- Modéliser une base de données relationnelle avec 3 tables
- Lire et créer un diagramme ER
- Implémenter un diagramme ER simple avec des commandes SQL

## Processus de conception de bases de données

Une bonne conception de base de données est la base d'une application fonctionnelle!

### Phases de la conception de bases de données

```
1. Analyse des besoins
        ↓
2. Conception conceptuelle (Modèle ER)
        ↓
3. Conception logique (Relations)
        ↓
4. Normalisation
        ↓
5. Conception physique (SQL DDL)
```

## 1. Analyse des besoins

### Poser des questions

- **Quelles données** doivent être stockées?
- **Qui** utilise la base de données?
- **Quelles opérations** sont effectuées?
- **Quelles relations** existent entre les données?
- **Quelles contraintes** (restrictions) s'appliquent?

### Exemple: Centre médical

**Scénario:** Un centre médical souhaite gérer les patients, les médecins et les rendez-vous.

**Besoins:**
- Les patients ont un nom, une date de naissance, une adresse, un téléphone
- Les médecins ont un nom, une spécialité, un téléphone
- Les rendez-vous connectent les patients aux médecins
- Un patient peut avoir plusieurs rendez-vous
- Un médecin peut avoir plusieurs rendez-vous
- Les rendez-vous ont une date, une heure, un motif

## 2. Modèle ER (Entity-Relationship)

Un **diagramme ER** visualise les entités et leurs relations.

### Éléments de base

**Entité (Entity):**
- Un objet du monde réel
- Représentation: Rectangle
- Exemple: Patient, Doctor, Appointment

**Attribut:**
- Propriété d'une entité
- Représentation: Ovale
- Exemple: Name, BirthDate, Address

**Clé primaire (Primary Key):**
- Identification unique d'une entité
- Représentation: Attribut souligné
- Exemple: patient_id, doctor_id

**Relation (Relationship):**
- Connexion entre entités
- Représentation: Losange
- Exemple: "has appointment with"

### Cardinalités

Décrivent combien d'entités sont en relation:

**1:1 (Un-à-Un)**
- Un A appartient à exactement un B
- Un B appartient à exactement un A
- Exemple: Person ↔ Passport

**1:N (Un-à-Plusieurs)**
- Un A peut avoir plusieurs B
- Un B appartient à exactement un A
- Exemple: Author → Books (Un auteur écrit plusieurs livres)

**N:M (Plusieurs-à-Plusieurs)**
- Un A peut avoir plusieurs B
- Un B peut avoir plusieurs A
- Exemple: Students ↔ Courses (Les étudiants suivent plusieurs cours, les cours ont plusieurs étudiants)

### Notation du diagramme ER (Notation Chen)

```
┌─────────────┐
│   Patient   │  ← Entité
│─────────────│
│ patient_id  │  ← Primary Key (souligné)
│ name        │  ← Attribut
│ birth_date  │
└─────────────┘
       │
       │ 1
       │
       ◇ has appointment with  ← Relation
       │
       │ N
       │
┌─────────────┐
│   Doctor    │
│─────────────│
│ doctor_id   │
│ name        │
│ specialty   │
└─────────────┘
```

### Exemple: Diagramme ER du centre médical

```
┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│   Patient    │          │ Appointment  │          │   Doctor     │
│──────────────│          │──────────────│          │──────────────│
│ patient_id   │ 1     N  │appointment_id│ N     1  │ doctor_id    │
│ first_name   │──────────│ patient_id   │──────────│ name         │
│ last_name    │          │ doctor_id    │          │ specialty    │
│ birth_date   │          │ date         │          │ phone        │
│ address      │          │ time         │          └──────────────┘
│ phone        │          │ reason       │
└──────────────┘          └──────────────┘
```

**Relations:**
- Un patient a N rendez-vous (1:N)
- Un médecin a N rendez-vous (1:N)
- Un rendez-vous appartient à 1 patient et 1 médecin

## 3. Normalisation

**Objectif:** Minimiser la redondance, maximiser l'intégrité des données

### Formes normales

#### 1ère Forme Normale (1NF)

**Règle:** Chaque attribut contient uniquement des valeurs atomiques (indivisibles)

❌ **Pas en 1NF:**
```
┌────┬──────────┬─────────────────────────┐
│ id │ name     │ phone_numbers           │
├────┼──────────┼─────────────────────────┤
│ 1  │ Mueller  │ 079 123 45 67, 031 123  │
└────┴──────────┴─────────────────────────┘
```

✅ **En 1NF:**
```
┌────┬──────────┬───────────────┬─────────┐
│ id │ name     │ phone1        │ phone2  │
├────┼──────────┼───────────────┼─────────┤
│ 1  │ Mueller  │ 079 123 45 67 │ 031 123 │
└────┴──────────┴───────────────┴─────────┘
```

**Ou mieux: Table séparée**
```
persons:                   phone_numbers:
┌────┬──────────┐         ┌────┬───────────┬───────────────┐
│ id │ name     │         │ id │ person_id │ number        │
├────┼──────────┤         ├────┼───────────┼───────────────┤
│ 1  │ Mueller  │         │ 1  │ 1         │ 079 123 45 67 │
└────┴──────────┘         │ 2  │ 1         │ 031 123 45 00 │
                          └────┴───────────┴───────────────┘
```

#### 2ème Forme Normale (2NF)

**Règle:** 1NF + Tous les attributs non-clés dépendent entièrement de la clé primaire

**Problème:** Dépendances partielles

❌ **Pas en 2NF:**
```
order_items:
┌──────────┬────────────┬──────────────┬──────────┬───────┐
│ order_id │ product_id │ product_name │ quantity │ price │
├──────────┼────────────┼──────────────┼──────────┼───────┤
│ 1        │ 101        │ Laptop       │ 2        │ 1200  │
│ 1        │ 102        │ Mouse        │ 5        │ 25    │
└──────────┴────────────┴──────────────┴──────────┴───────┘
```
Problème: `product_name` dépend uniquement de `product_id`, pas de `order_id`

✅ **En 2NF:**
```
order_items:                    products:
┌──────────┬────────────┬──────┐ ┌────────────┬──────────────┬───────┐
│ order_id │ product_id │ qty  │ │ product_id │ product_name │ price │
├──────────┼────────────┼──────┤ ├────────────┼──────────────┼───────┤
│ 1        │ 101        │ 2    │ │ 101        │ Laptop       │ 1200  │
│ 1        │ 102        │ 5    │ │ 102        │ Mouse        │ 25    │
└──────────┴────────────┴──────┘ └────────────┴──────────────┴───────┘
```

#### 3ème Forme Normale (3NF)

**Règle:** 2NF + Pas de dépendances transitives

**Problème:** Un attribut non-clé dépend d'un autre attribut non-clé

❌ **Pas en 3NF:**
```
employees:
┌────┬──────────┬────────────┬──────────────┐
│ id │ name     │ department │ dept_location│
├────┼──────────┼────────────┼──────────────┤
│ 1  │ Mueller  │ IT         │ Bern         │
│ 2  │ Schmidt  │ IT         │ Bern         │
│ 3  │ Meyer    │ HR         │ Zurich       │
└────┴──────────┴────────────┴──────────────┘
```
Problème: `dept_location` dépend de `department`, pas directement de id

✅ **En 3NF:**
```
employees:                       departments:
┌────┬──────────┬──────────────┐ ┌───────────────┬──────┬──────────┐
│ id │ name     │ department_id│ │ department_id │ name │ location │
├────┼──────────┼──────────────┤ ├───────────────┼──────┼──────────┤
│ 1  │ Mueller  │ 1            │ │ 1             │ IT   │ Bern     │
│ 2  │ Schmidt  │ 1            │ │ 2             │ HR   │ Zurich   │
│ 3  │ Meyer    │ 2            │ └───────────────┴──────┴──────────┘
└────┴──────────┴──────────────┘
```

## 4. SQL DDL (Data Definition Language)

Commandes SQL pour **définir** la structure de la base de données.

### Types de données dans MariaDB/MySQL

**Types numériques:**
```sql
INT             -- Entier (-2147483648 à 2147483647)
BIGINT          -- Grand entier
DECIMAL(10,2)   -- Nombre à virgule fixe (10 chiffres, 2 décimales)
FLOAT           -- Nombre à virgule flottante
DOUBLE          -- Nombre à virgule flottante double précision
```

**Types de texte:**
```sql
CHAR(10)        -- Longueur fixe (toujours 10 caractères, rempli d'espaces)
VARCHAR(255)    -- Longueur variable (jusqu'à 255 caractères)
TEXT            -- Texte plus long (jusqu'à 65,535 caractères)
LONGTEXT        -- Très long texte (jusqu'à 4GB)
```

**Types de date/heure:**
```sql
DATE            -- Date (YYYY-MM-DD)
TIME            -- Heure (HH:MM:SS)
DATETIME        -- Date et heure (YYYY-MM-DD HH:MM:SS)
TIMESTAMP       -- Horodatage (automatique lors d'INSERT/UPDATE)
YEAR            -- Année (YYYY)
```

**Autres types:**
```sql
BOOLEAN         -- TRUE/FALSE (stocké comme TINYINT(1))
ENUM('A','B')   -- Énumération
JSON            -- Données JSON
BLOB            -- Données binaires (par ex. images)
```

### CREATE DATABASE

```sql
-- Créer une base de données
CREATE DATABASE medical_center;

-- Avec Character Set
CREATE DATABASE medical_center 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

-- Sélectionner la base de données
USE medical_center;

-- Supprimer la base de données (ATTENTION!)
DROP DATABASE medical_center;

-- Supprimer uniquement si elle existe
DROP DATABASE IF EXISTS medical_center;
```

### CREATE TABLE

**Structure de base:**
```sql
CREATE TABLE table_name (
    column1 DATATYPE [CONSTRAINTS],
    column2 DATATYPE [CONSTRAINTS],
    ...
    [TABLE CONSTRAINTS]
);
```

**Exemple: Table patients**
```sql
CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Exemple: Table doctors**
```sql
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Exemple: Table appointments avec Foreign Keys**
```sql
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    reason VARCHAR(255),
    status ENUM('scheduled', 'completed', 'cancelled') DEFAULT 'scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Contraintes Foreign Key
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
```

### Contraintes (Constraints)

**PRIMARY KEY:**
- Identification unique de chaque ligne
- Ne peut pas être NULL
- Une seule Primary Key par table

```sql
-- Comme contrainte de colonne
column_name INT PRIMARY KEY

-- Comme contrainte de table
PRIMARY KEY (column_name)

-- Primary Key composée
PRIMARY KEY (column1, column2)
```

**FOREIGN KEY:**
- Référence la Primary Key d'une autre table
- Assure l'intégrité référentielle

```sql
FOREIGN KEY (column) REFERENCES other_table(column)
    ON DELETE CASCADE        -- Lors de la suppression du parent
    ON UPDATE CASCADE        -- Lors de la mise à jour du parent
```

**Options ON DELETE / ON UPDATE:**
- `CASCADE`: Supprimer/modifier automatiquement
- `SET NULL`: Mettre à NULL
- `RESTRICT`: Empêcher la suppression/modification
- `NO ACTION`: Aucune action (par défaut)

**NOT NULL:**
- Le champ ne peut pas être vide

```sql
column_name VARCHAR(50) NOT NULL
```

**UNIQUE:**
- La valeur doit être unique (mais NULL est autorisé)

```sql
email VARCHAR(100) UNIQUE
```

**DEFAULT:**
- Valeur par défaut si rien n'est spécifié

```sql
status VARCHAR(20) DEFAULT 'active'
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

**CHECK:**
- La condition doit être remplie

```sql
age INT CHECK (age >= 0 AND age <= 150)
price DECIMAL(10,2) CHECK (price > 0)
```

**AUTO_INCREMENT:**
- Incrémentation automatique (généralement pour les Primary Keys)

```sql
id INT PRIMARY KEY AUTO_INCREMENT
```

### ALTER TABLE

Modifier les tables existantes:

```sql
-- Ajouter une colonne
ALTER TABLE patients 
ADD COLUMN insurance VARCHAR(50);

-- Modifier une colonne
ALTER TABLE patients 
MODIFY COLUMN phone VARCHAR(30);

-- Renommer une colonne
ALTER TABLE patients 
CHANGE COLUMN phone phone_number VARCHAR(30);

-- Supprimer une colonne
ALTER TABLE patients 
DROP COLUMN insurance;

-- Ajouter une contrainte
ALTER TABLE appointments
ADD CONSTRAINT fk_patient
FOREIGN KEY (patient_id) REFERENCES patients(patient_id);

-- Supprimer une contrainte
ALTER TABLE appointments
DROP FOREIGN KEY fk_patient;

-- Renommer une table
ALTER TABLE appointments 
RENAME TO medical_appointments;
```

### DROP TABLE

```sql
-- Supprimer une table
DROP TABLE appointments;

-- Supprimer uniquement si elle existe
DROP TABLE IF EXISTS appointments;

-- Supprimer plusieurs tables
DROP TABLE IF EXISTS appointments, patients, doctors;
```

### TRUNCATE TABLE

Supprimer toutes les données, garder la structure:

```sql
-- Supprimer toutes les lignes (plus rapide que DELETE)
TRUNCATE TABLE appointments;

-- IMPORTANT: AUTO_INCREMENT est réinitialisé!
```

## Relations N:M en SQL

Pour les relations N:M, on a besoin d'une **table intermédiaire** (Junction Table).

**Exemple: Students et Courses**

```
Student (N) ←→ (M) Course
```

**Solution:**
```
Student (1) → (N) Enrollments (N) ← (1) Course
```

```sql
-- Table students
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- Table courses
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    credits INT
);

-- Table intermédiaire (Junction Table)
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    grade DECIMAL(3,1),
    
    FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
        ON DELETE CASCADE,
        
    -- Un étudiant ne peut s'inscrire qu'une fois à un cours
    UNIQUE (student_id, course_id)
);
```

## Exercice pratique: Carte des cours d'eau

### Travail préparatoire (Credit 2)

**Carte des cours d'eau BE-Nord:** [Lien vers la carte]

**Tâche:**
1. Analyser la carte des cours d'eau
2. Déterminer quelles **données** sont disponibles
3. Définir les **types de données** appropriés
4. Créer une liste Excel avec:
   - Colonne 1: Nom du champ de données
   - Colonne 2: Description
   - Colonne 3: Type de données (SQL)
   - Colonne 4: Contraintes (NOT NULL, UNIQUE, etc.)

**Exemple de lignes:**
```
| Field        | Description             | Data Type    | Constraints |
|--------------|-------------------------|--------------|-------------|
| waterway_id  | ID unique               | INT          | PRIMARY KEY, AUTO_INCREMENT |
| name         | Nom du cours d'eau      | VARCHAR(100) | NOT NULL    |
| type         | Lake, River, Stream     | ENUM(...)    | NOT NULL    |
| length_km    | Longueur en kilomètres  | DECIMAL(6,2) | CHECK > 0   |
```

## Résumé

### Le processus de conception

1. **Besoins** collecter
2. **Diagramme ER** créer
3. **Normaliser** (1NF, 2NF, 3NF)
4. **SQL DDL** écrire
5. **Tester** avec des données d'exemple

### Commandes SQL DDL importantes

```sql
CREATE DATABASE    -- Créer une base de données
CREATE TABLE       -- Créer une table
ALTER TABLE        -- Modifier une table
DROP TABLE         -- Supprimer une table
TRUNCATE TABLE     -- Supprimer toutes les données
```

### Bonnes pratiques

✅ **Conventions de nommage:**
- Tables: Pluriel, lowercase, snake_case (`students`, `course_enrollments`)
- Colonnes: Singulier, lowercase, snake_case (`first_name`, `student_id`)
- Primary Keys: `table_id` (ex: `student_id`)
- Foreign Keys: Comme la colonne référencée (ex: `student_id`)

✅ **Primary Keys:**
- Toujours utiliser AUTO_INCREMENT
- INT ou BIGINT
- Jamais de clés naturelles (E-Mail, Username) comme PK

✅ **Types de données:**
- VARCHAR au lieu de CHAR (sauf longueur fixe connue)
- DECIMAL pour l'argent (pas FLOAT!)
- TIMESTAMP pour les horodatages avec auto-update
- ENUM pour les listes de valeurs fixes

✅ **Contraintes:**
- Toujours définir les Foreign Keys
- NOT NULL où approprié
- CHECK Constraints pour la validation
- UNIQUE où les doublons ne sont pas autorisés

❌ **À éviter:**
- Espaces dans les noms
- Mots réservés comme noms (ex: `order`, `user`)
- Plusieurs valeurs dans un champ (1NF!)
- VARCHAR trop large (ex: VARCHAR(10000))

## Devoirs

1. **Terminer le diagramme ER de la carte des cours d'eau**
   - Au moins 3 entités
   - Définir les relations
   - Attributs avec types de données

2. **Créer le script SQL**
   - CREATE DATABASE
   - CREATE TABLE pour toutes les entités
   - Avec toutes les contraintes
   - Commentaires sur les décisions importantes

3. **Créer la base de données dans MariaDB**
   - Utiliser HeidiSQL
   - Exécuter le script
   - Vérifier avec SHOW TABLES

## Outils

- **dbdiagram.io**: Créer des diagrammes ER en ligne
- **draw.io**: Outil de diagramme général
- **HeidiSQL**: Client MySQL/MariaDB
- **MySQL Workbench**: Alternative avec designer ER

## Ressources supplémentaires

- [SQL DDL Tutorial - W3Schools](https://www.w3schools.com/sql/sql_create_table.asp)
- [Database Normalization](https://www.geeksforgeeks.org/normal-forms-in-dbms/)
- [ER Diagram Tutorial](https://www.lucidchart.com/pages/er-diagrams)
- [MariaDB Data Types](https://mariadb.com/kb/en/data-types/)

## Prochaines étapes

Dans la leçon 3, nous apprendrons:
- SQL DML (Data Manipulation Language)
- INSERT, UPDATE, DELETE
- Requêtes SELECT simples
- Travailler avec la base de données HFTM Library
