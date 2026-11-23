# Leçon 6: Révision SQL & Lancement du projet

## Vue d'ensemble

**Partie 1:** Révision SQL et test d'exemple pour se préparer à l'examen théorique de l'unité 7 (90 minutes)
**Partie 2:** Lancement du projet et choix du thème (30 minutes)

## Partie 1: Préparation à l'examen théorique SQL

L'examen théorique a lieu à l'**unité 7** (avant la partie Node.js). Aujourd'hui, nous révisons la matière et résolvons un test d'exemple.

### Format de l'examen théorique (unité 7)

- **Durée:** 90 minutes
- **Pondération:** 30% de la note totale
- **Moyens auxiliaires:** Aucun (sauf stylo et papier)
- **Format:** Écrit ou sur ordinateur

### Thèmes d'examen

#### 1. Modélisation de données (25%)

**Diagrammes ER:**
- Identifier les entités
- Définir les attributs
- Reconnaître les relations (1:1, 1:N, N:M)
- Déterminer les cardinalités
- Primary et Foreign Keys

**Normalisation:**
- 1ère Forme Normale (1NF): Valeurs atomiques
- 2ème Forme Normale (2NF): Dépendance fonctionnelle complète
- 3ème Forme Normale (3NF): Pas de dépendances transitives
- Reconnaître et éliminer les redondances

**Exemples de questions:**
```
1. Voici un tableau. Identifiez les redondances et anomalies.
2. Normalisez le tableau jusqu'à la 3ème forme normale.
3. Créez un diagramme ER pour le scénario suivant: [...]
4. Dessinez les relations entre les entités suivantes: [...]
```

#### 2. SQL DDL (20%)

**CREATE TABLE:**
- Choisir les types de données
- Définir les contraintes (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT)
- AUTO_INCREMENT
- Actions ON DELETE / ON UPDATE

**ALTER TABLE:**
- Ajouter/modifier/supprimer des colonnes
- Ajouter/supprimer des contraintes

**Exemples de questions:**
```sql
1. Créez une table 'orders' avec les exigences suivantes: [...]
2. Ajoutez une contrainte Foreign Key: [...]
3. Changez le type de données d'une colonne: [...]
4. Quelle est la différence entre CHAR et VARCHAR?
```

#### 3. SQL DML (25%)

**INSERT:**
- Lignes simples et multiples
- Avec sous-requêtes
- Valeurs DEFAULT

**SELECT:**
- Conditions WHERE (=, !=, >, <, LIKE, IN, BETWEEN, IS NULL)
- ORDER BY, LIMIT, OFFSET
- DISTINCT
- Opérateurs logiques (AND, OR, NOT)

**UPDATE:**
- Avec WHERE
- Avec sous-requêtes
- Plusieurs colonnes

**DELETE:**
- Avec WHERE
- Avec sous-requêtes

**Exemples de questions:**
```sql
1. Insérez un nouveau client: [...]
2. Trouvez tous les livres publiés en 2020
3. Mettez à jour le prix de tous les livres d'un éditeur
4. Supprimez tous les clients sans commandes
```

#### 4. JOINs (20%)

**Types de JOIN:**
- INNER JOIN
- LEFT JOIN
- RIGHT JOIN
- Expliquer les différences

**Relations N:M:**
- Joindre via une table intermédiaire

**Plusieurs JOINs:**
- Connecter 3-4 tables

**Exemples de questions:**
```sql
1. Affichez tous les livres avec leurs auteurs (INNER JOIN)
2. Affichez tous les auteurs, même sans livres (LEFT JOIN)
3. Trouvez les auteurs sans livres
4. Listez toutes les commandes avec clients et produits
```

#### 5. Fonctions d'agrégation (10%)

**Fonctions:**
- COUNT, SUM, AVG, MIN, MAX
- GROUP BY
- HAVING

**Exemples de questions:**
```sql
1. Combien de livres chaque auteur a-t-il?
2. Prix moyen de tous les livres par genre
3. Genres avec plus de 10 livres
4. Top 5 des clients par valeur de commande
```

### Test d'exemple (pour s'exercer)

#### Exercice 1: Diagramme ER (8 points)

Un centre de fitness souhaite introduire un système de réservation pour les cours.

**Exigences:**
- Les membres ont un nom, une date de naissance, un numéro de membre
- Les cours ont un nom, une description, un nombre maximum de participants
- Les entraîneurs ont un nom, une spécialisation
- Un cours est dirigé par un entraîneur
- Un membre peut réserver plusieurs cours
- Un cours peut avoir plusieurs participants
- Les réservations ont une date de réservation

**Tâches:**
a) Dessinez un diagramme ER avec toutes les entités, attributs et relations
b) Marquez les Primary Keys
c) Indiquez les cardinalités

#### Exercice 2: Normalisation (6 points)

Voici un tableau:

```
course_bookings:
┌────────┬──────────┬──────────────┬─────────────┬───────────┬─────────────┐
│member_id│ name    │ course1      │ course2     │ trainer1  │ trainer2    │
├────────┼──────────┼──────────────┼─────────────┼───────────┼─────────────┤
│ 1      │ Mueller  │ Yoga         │ Spinning    │ Anna      │ Tom         │
│ 2      │ Schmidt  │ Yoga         │ NULL        │ Anna      │ NULL        │
└────────┴──────────┴──────────────┴─────────────┴───────────┴─────────────┘
```

a) Quelles violations de formes normales voyez-vous? (2 points)
b) Normalisez jusqu'à la 3ème forme normale (4 points)

#### Exercice 3: SQL DDL (10 points)

Créez les tables pour le centre de fitness:

a) Table `members` avec:
   - member_id (Primary Key, Auto Increment)
   - first_name, last_name (non NULL)
   - birth_date
   - membership_number (UNIQUE)
   - created_at (Default: horodatage actuel)

b) Table `courses` avec les colonnes et contraintes appropriées

c) Table `bookings` (table intermédiaire) avec Foreign Keys et ON DELETE CASCADE

#### Exercice 4: SQL DML (12 points)

La base de données HFTM Library est donnée.

a) Insérez un nouveau livre: "Database Systems" de "Ramakrishnan", ISBN "978-0072465631", année 2002 (2 points)

b) Trouvez tous les livres publiés entre 2000 et 2010, triés par titre (2 points)

c) Mettez à jour tous les livres de l'éditeur "Old Press" vers "New Press" (2 points)

d) Supprimez tous les genres qui n'ont pas de livres (2 points)

e) Affichez les 10 livres les plus récents avec auteur et genre (4 points)

#### Exercice 5: JOINs (10 points)

a) Listez tous les livres avec les noms d'auteurs (INNER JOIN) (2 points)

b) Affichez tous les auteurs, même sans livres (LEFT JOIN) (2 points)

c) Trouvez les auteurs qui n'ont pas de livres (3 points)

d) Affichez tous les prêts actuels avec nom du client, titre du livre et date de retour (3 points)

#### Exercice 6: Agrégations (8 points)

a) Combien de livres y a-t-il par genre? (2 points)

b) Quel auteur a écrit le plus de livres? (Top 5) (3 points)

c) Nombre moyen de livres par éditeur (2 points)

d) Genres avec au moins 20 livres (1 point)

#### Exercice 7: Transactions (6 points)

a) Expliquez ce que signifie ACID (2 points)

b) Écrivez une transaction pour le scénario suivant:
   - Un client emprunte un livre
   - Le stock doit être réduit
   - Le prêt doit être enregistré
   - En cas d'erreur: Rollback (4 points)

### Conseils pour la solution

**Gestion du temps:**
- 5 min: Lire le test
- 20 min: Diagramme ER et normalisation
- 15 min: SQL DDL
- 30 min: SQL DML et JOINs
- 15 min: Agrégations
- 5 min: Relire et corriger

**Conseils:**
- Lisez les questions attentivement
- Évitez les erreurs de syntaxe
- En cas de doute: écrivez des commentaires
- Gardez un œil sur le temps
- Les questions faciles d'abord

## Partie 2: Lancement du projet

Après la révision, nous commençons le projet principal du cours!

### Vue d'ensemble du projet

**Objectif:** Application web dynamique avec API REST et base de données

**Pondération:** 50% de la note totale

**Composants:**
1. Conception de base de données (Diagramme ER + SQL)
2. Backend API REST (Node.js + Express)
3. Frontend (HTML/CSS/JavaScript)
4. Documentation
5. Présentation

### Objectifs du projet

#### 1. Conception de base de données (15 points)

- Diagramme ER avec 4-5 entités
- Au moins 2× relations 1:N
- Au moins 1× relation N:M
- Normalisation jusqu'à la 3ème forme normale
- Script SQL pour la création des tables
- Données de test

#### 2. Implémentation de la base de données (10 points)

- Instructions CREATE TABLE
- Contraintes PRIMARY KEY et FOREIGN KEY
- Types de données appropriés
- Données de test (min. 5 par table)
- Dump DB fonctionnel

#### 3. Backend API REST (30 points)

**Exigences minimales:**
- Node.js + Express
- Connexion à la base de données (mysql2)
- Au moins une ressource avec toutes les opérations CRUD:
  - GET /api/resource (tous)
  - GET /api/resource/:id (un)
  - POST /api/resource (créer)
  - PUT /api/resource/:id (mettre à jour)
  - DELETE /api/resource/:id (supprimer)

**En plus:**
- Au moins 2 endpoints avec opérations JOIN
- Prepared Statements (protection contre l'injection SQL)
- Gestion des erreurs avec codes de statut HTTP appropriés
- .env pour les credentials

#### 4. Connexion Frontend (25 points)

- Frontend dynamique (pas de HTML statique)
- GET - Afficher les données
- POST - Créer des données (formulaire)
- PUT - Éditer des données
- DELETE - Supprimer des données (avec confirmation)
- Design responsive (optionnel, bonus)

#### 5. Présentation (20 points)

- Démo en direct (5-7 minutes)
- Expliquer le design DB
- Montrer toutes les opérations CRUD
- Répondre aux questions techniques
- Respecter le temps
- Apparence professionnelle

### Thèmes de projet

#### Proposition 1: Gestion de bibliothèque

**Entités:** Books, Authors, Genres, Loans, Users

**Fonctionnalités:**
- Gérer les livres (CRUD)
- Enregistrer les prêts
- Recherche par titre/auteur/genre
- Afficher les prêts en retard

#### Proposition 2: Gestionnaire d'événements

**Entités:** Events, Organizers, Locations, Participants, Categories

**Fonctionnalités:**
- Créer et gérer des événements
- Inscrire/désinscrire des participants
- Filtrage par date/catégorie
- Vue calendrier

#### Proposition 3: Gestion de recettes

**Entités:** Recipes, Ingredients, Categories, Reviews, Authors

**Fonctionnalités:**
- Ajouter/éditer des recettes
- Gérer les ingrédients
- Donner des avis
- Recherche par ingrédient/catégorie

#### Proposition 4: Outil de gestion de projet (Simplifié)

**Entités:** Projects, Tasks, TeamMembers, Status, Priorities

**Fonctionnalités:**
- Créer/déplacer des tâches
- Assigner des membres d'équipe
- Mettre à jour le statut
- Vue Kanban

#### Proposition 5: Gestion de véhicules

**Entités:** Vehicles, Owners, Services, Repairs, Workshops

**Fonctionnalités:**
- Enregistrer des véhicules
- Documenter les services
- Afficher l'historique des services
- Rappels de maintenance

#### Thème personnel

Vous pouvez également choisir votre propre thème, tant qu'il remplit les exigences:

**Checklist thème personnel:**
- [ ] 4-5 entités possibles?
- [ ] Au moins 2× relations 1:N?
- [ ] Au moins 1× relation N:M?
- [ ] Opérations CRUD pertinentes?
- [ ] Intéressant pour vous?
- [ ] Réalisable en 6 semaines?

### Jalons

| Semaine | Jalon | Livraison |
|---------|-------|-----------|
| Unit 6 | Choix du thème | - |
| Unit 8 | Design DB | Diagramme ER + Script SQL |
| Unit 9-11 | Travail sur le projet | - |
| Unit 12 | Projet complet | Code, Doc, Dump DB |
| Unit 13 | Présentation | Démo en direct |

### Configuration du projet

**Structure des répertoires:**
```
my-project/
├── database/
│   ├── schema.sql           # Instructions CREATE TABLE
│   ├── data.sql             # Instructions INSERT (données de test)
│   └── er-diagram.png       # Diagramme ER
├── backend/
│   ├── node_modules/
│   ├── controllers/
│   ├── routes/
│   ├── config/
│   │   └── database.js
│   ├── .env
│   ├── .gitignore
│   ├── package.json
│   └── server.js
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── app.js
├── docs/
│   ├── README.md            # Description du projet
│   ├── API.md               # Documentation API
│   └── SETUP.md             # Instructions de configuration
└── README.md
```

### À faire aujourd'hui

1. **Choisir un thème** (ou définir le vôtre)
2. **Noter les exigences**
   - Quelles entités?
   - Quelles relations?
   - Quelles fonctionnalités?
3. **Première esquisse** du diagramme ER

### Semaine prochaine (Unit 7)

- **Examen théorique SQL** (90 minutes, 30% de la note totale)
- Diagramme ER détaillé (remise du design DB à l'unité 8)
- Script SQL pour les tables
- Configurer le projet Node.js
- Premiers endpoints API

### Critères d'évaluation (Détail)

**Conception de base de données (15 points):**
- Diagramme ER complet (5P)
- Normalisation correcte (4P)
- Relations pertinentes (3P)
- Types de données appropriés (3P)

**Implémentation (10 points):**
- Script SQL fonctionne (4P)
- Données de test présentes (3P)
- Contraintes correctes (3P)

**API REST (30 points):**
- CRUD complet (10P)
- Opérations JOIN (10P)
- Prepared Statements (5P)
- Documentation API (5P)

**Frontend (25 points):**
- GET - Affichage (5P)
- POST - Création (7P)
- PUT - Édition (7P)
- DELETE - Suppression (6P)

**Présentation (20 points):**
- Démo en direct (8P)
- Design DB expliqué (4P)
- Questions techniques (4P)
- Temps/Professionnalisme (4P)

## Ressources pour le projet

### Tutoriels & Documentation

- [Node.js Official Docs](https://nodejs.org/docs)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [MySQL2 Package](https://github.com/sidorares/node-mysql2)
- [REST API Best Practices](https://stackoverflow.blog/2020/03/02/best-practices-for-rest-api-design/)

### Outils

- **Design DB:** dbdiagram.io, draw.io
- **Test API:** Postman, Thunder Client (VS Code)
- **Frontend:** VS Code, Live Server Extension
- **Git:** GitHub, GitLab

### Exemples de projets

Dans Moodle, vous trouverez des exemples de projets de semestres précédents pour inspiration.

## Conseils pour réussir

### Gestion du temps

- **Semaine 7:** 20% (Design DB)
- **Semaine 8-9:** 40% (Backend)
- **Semaine 10-11:** 30% (Frontend)
- **Semaine 12:** 10% (Tests, Doc, Polish)

### Éviter les erreurs courantes

❌ **Commencer trop tard**
✅ Commencer tôt avec le design DB

❌ **Thème trop complexe**
✅ Plutôt simple et bien fait que complexe et cassé

❌ **Pas de documentation**
✅ README et API docs dès le début

❌ **Pas de tests**
✅ Tester régulièrement (Postman pour l'API)

❌ **Pas de contrôle de version**
✅ Utiliser Git dès le début

### Support

- **Forum:** Questions dans le forum Moodle
- **Heures de consultation:** Sur rendez-vous
- **Peer-Review:** Échanger avec les camarades

## Checklist pour aujourd'hui

- [ ] Test d'exemple résolu et comparé avec les conseils de solution
- [ ] Thème choisi
- [ ] Premières idées notées
- [ ] Exigences réfléchies
- [ ] Questions notées

## Prochaines étapes

**D'ici la semaine prochaine:**
1. Dessiner le diagramme ER
2. Définir les entités et attributs
3. Fixer les relations
4. Vérifier la normalisation

**Pour Unit 7:**
- Examen théorique SQL: réviser la matière des leçons 1–5
- Node.js installé
- MariaDB fonctionne
- Éditeur de texte prêt (VS Code recommandé)

## Résumé

- **Examen théorique (unité 7):** 30% de la note, bases testées
- **Projet:** 50% de la note, application pratique
- **Credits:** 20% de la note, travail continu
- **Début:** Aujourd'hui avec le choix du thème
- **Objectif:** Application web fonctionnelle avec DB

Bonne chance pour la préparation à l'examen et pour le projet! 🚀
