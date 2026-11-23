# Listes de contrôle pour les étudiants - Leçons 7-13

## Liste 7: Leçon 7 - Node.js et Bases de données

### Configuration Node.js
- [ ] Node.js installé (version vérifiée)
- [ ] npm fonctionne
- [ ] Projet initialisé (npm init -y)
- [ ] Packages installés (mysql2, dotenv, express)
- [ ] package.json présent

### Connexion à la base de données
- [ ] Fichier .env créé
- [ ] .gitignore pour .env et node_modules
- [ ] database.js avec Connection Pool
- [ ] Connexion testée avec succès
- [ ] Gestion des erreurs implémentée

### Fonctions CRUD
- [ ] Fonction CREATE (INSERT)
- [ ] Fonction READ ALL (SELECT *)
- [ ] Fonction READ ONE (SELECT avec WHERE)
- [ ] Fonction UPDATE
- [ ] Fonction DELETE
- [ ] Toutes les fonctions testées
- [ ] Prepared Statements utilisés
- [ ] Async/Await correct

### Credit 7
- [ ] Structure du projet correcte
- [ ] Toutes les fonctions CRUD implémentées
- [ ] Script de test fonctionne
- [ ] Captures d'écran faites
- [ ] Code commenté
- [ ] Soumis en ZIP

---

## Liste 8: Leçon 8 - API REST avec Express

### Configuration Express
- [ ] Express installé
- [ ] server.js créé
- [ ] Middleware configuré (json, urlencoded)
- [ ] CORS configuré
- [ ] Serveur démarre sans erreur

### Endpoints REST
- [ ] GET /api/books (tous)
- [ ] GET /api/books/:id (un seul)
- [ ] POST /api/books (créer)
- [ ] PUT /api/books/:id (mettre à jour)
- [ ] DELETE /api/books/:id (supprimer)
- [ ] Codes de statut HTTP corrects (200, 201, 404, 500)
- [ ] Gestion des erreurs dans toutes les routes

### Controller & Routes
- [ ] bookController.js créé
- [ ] bookRoutes.js créé
- [ ] Controller séparé des routes
- [ ] Code bien structuré

### Tests
- [ ] Postman installé
- [ ] Collection créée
- [ ] Tous les endpoints testés
- [ ] Captures d'écran faites

### Endpoint JOIN
- [ ] Endpoint avec JOIN implémenté
- [ ] Livres liés aux auteurs
- [ ] Testé

### Credit 8
- [ ] Tous les 5 endpoints CRUD fonctionnent
- [ ] Endpoint JOIN implémenté
- [ ] Collection Postman exportée
- [ ] Captures d'écran de tous les tests
- [ ] Code soumis

---

## Liste 9: Leçon 9 - IA & Bases de données

### Intégration Claude AI (Optionnel)
- [ ] Clé API Anthropic obtenue
- [ ] @anthropic-ai/sdk installé
- [ ] Intégration de base testée

### Génération SQL
- [ ] Claude utilisé pour les requêtes SQL
- [ ] Requêtes validées avant exécution
- [ ] Résultats documentés

### Travail sur le projet
- [ ] Thème du projet défini
- [ ] Diagramme ER créé
- [ ] Script SQL DDL écrit
- [ ] Base de données implémentée

---

## Liste 10: Leçon 10 - NoSQL & MongoDB

### Configuration MongoDB
- [ ] MongoDB installé OU
- [ ] Compte MongoDB Atlas créé
- [ ] Connexion réussie
- [ ] Compass installé (optionnel)

### Bases MongoDB
- [ ] Base de données créée
- [ ] Collection créée
- [ ] Documents insérés
- [ ] Requêtes exécutées

### Mongoose (Optionnel)
- [ ] Mongoose installé
- [ ] Schéma défini
- [ ] Modèle créé
- [ ] CRUD avec Mongoose

### SQL vs NoSQL compris
- [ ] Différences claires
- [ ] Quand utiliser SQL, quand NoSQL
- [ ] Avantages et inconvénients connus

### Décision pour le projet
- [ ] SQL ou NoSQL choisi (avec justification)
- [ ] Implémentation commencée

---

## Liste 11: Leçon 11 - ORM & Sequelize

### Configuration Sequelize (Si utilisé)
- [ ] Sequelize installé
- [ ] Sequelize-cli installé
- [ ] Configuration créée
- [ ] Connexion testée

### Models
- [ ] Tous les modèles définis
- [ ] Validation implémentée
- [ ] Associations définies

### Migrations
- [ ] Fichiers de migration créés
- [ ] Migrations exécutées
- [ ] Seeders créés (optionnel)

### Progrès du projet
- [ ] API Backend à 80% terminée
- [ ] Tous les endpoints CRUD fonctionnent
- [ ] JOINs/Relations implémentés
- [ ] Gestion des erreurs présente

---

## Liste 12: Leçon 12 - Sécurité & MQTT

### Authentification JWT (Si implémenté)
- [ ] jsonwebtoken installé
- [ ] bcrypt installé
- [ ] Endpoint Register
- [ ] Endpoint Login
- [ ] Routes protégées avec middleware

### Sécurité
- [ ] helmet installé et configuré
- [ ] CORS correctement configuré
- [ ] express-rate-limit implémenté
- [ ] Validation des entrées (express-validator)
- [ ] Prepared Statements partout

### MQTT (Optionnel)
- [ ] Package mqtt installé
- [ ] Connexion au broker
- [ ] Publish/Subscribe testé

### État du projet
- [ ] Backend complet
- [ ] Frontend commencé
- [ ] Documentation commencée

---

## Liste 13: Leçon 13 - Finalisation & Présentation

### Projet complet
- [ ] API Backend terminée
- [ ] Frontend terminé
- [ ] Toutes les opérations CRUD fonctionnent
- [ ] Design responsive (optionnel)

### Base de données
- [ ] Diagramme ER final
- [ ] Toutes les tables créées
- [ ] Foreign Keys correctes
- [ ] Données de test présentes
- [ ] Dump créé

### Documentation
- [ ] README.md avec:
  - [ ] Description du projet
  - [ ] Instructions d'installation
  - [ ] Documentation API
  - [ ] Captures d'écran
- [ ] Code commenté
- [ ] Dépôt Git nettoyé

### Tests
- [ ] Toutes les fonctions testées
- [ ] Cas limites vérifiés
- [ ] Gestion des erreurs testée
- [ ] Pas de bugs critiques

### Présentation
- [ ] Présentation préparée (5-7 min)
- [ ] Démo en direct répétée
- [ ] Temps chronométré
- [ ] Plan de secours (vidéo/captures d'écran)
- [ ] Questions préparées

### Soumission
- [ ] Code sur GitHub/GitLab
- [ ] README.md complet
- [ ] Dump SQL
- [ ] Fichier .env.example
- [ ] Présentation prête

---

## Liste maîtresse: Finalisation du projet

### Backend (30 points)
- [ ] Tous les endpoints CRUD fonctionnent (10P)
- [ ] Au moins 2 endpoints JOIN (10P)
- [ ] Prepared Statements partout (5P)
- [ ] Gestion des erreurs (5P)

### Frontend (25 points)
- [ ] GET - Afficher les données (5P)
- [ ] POST - Créer des données (7P)
- [ ] PUT - Modifier les données (7P)
- [ ] DELETE - Supprimer des données (6P)

### Base de données (15 points)
- [ ] Diagramme ER (5P)
- [ ] 4-5 tables (4P)
- [ ] Normalisation (3P)
- [ ] Script SQL fonctionne (3P)

### Documentation (10 points)
- [ ] README complet (4P)
- [ ] Documentation API (3P)
- [ ] Code commenté (3P)

### Présentation (20 points)
- [ ] Démo en direct (8P)
- [ ] Design DB expliqué (4P)
- [ ] Questions répondues (4P)
- [ ] Temps & Professionnalisme (4P)

**TOTAL: 100 points = 50% de la note finale**

---

## Timeline du projet

| Semaine | Jalons | Terminé |
|---------|--------|---------|
| 6 | Thème choisi | ☐ |
| 7 | Node.js setup, connexion DB | ☐ |
| 8 | API REST CRUD | ☐ |
| 9 | Design DB finalisé | ☐ |
| 10 | Backend complet | ☐ |
| 11 | Frontend 50% | ☐ |
| 12 | Frontend complet, Docs | ☐ |
| 13 | Présentation | ☐ |

---

## Référence rapide: Commandes importantes

### Node.js / npm
```bash
npm init -y
npm install package-name
npm install --save-dev package-name
npm start
node filename.js
```

### Git
```bash
git init
git add .
git commit -m "message"
git push origin main
```

### MySQL / MariaDB
```bash
mysql -u root -p
SOURCE script.sql;
mysqldump -u root -p dbname > dump.sql
```

---

## Éviter les erreurs fréquentes

### Backend
- ❌ Credentials dans le code
- ❌ Pas de gestion des erreurs
- ❌ SQL Injection possible
- ❌ CORS non configuré
- ❌ Pas de validation des entrées

- ✅ .env pour les credentials
- ✅ Try-catch partout
- ✅ Prepared Statements
- ✅ CORS correctement configuré
- ✅ Middleware de validation

### Frontend
- ❌ URL API codée en dur
- ❌ Pas de messages d'erreur
- ❌ Pas d'état de chargement
- ❌ Pas de confirmation pour DELETE

- ✅ API_URL en variable
- ✅ Retour utilisateur sur erreurs
- ✅ Indicateurs de chargement
- ✅ Dialogue de confirmation pour DELETE

### Projet
- ❌ Commencé trop tard
- ❌ Planifié trop complexe
- ❌ Pas de sauvegardes
- ❌ Git pas utilisé

- ✅ Commencer tôt
- ✅ MVP d'abord, puis étendre
- ✅ Commits réguliers
- ✅ Git dès le début

---

## Conseils pour la présentation

### Préparation
- ✅ Répéter la démo plusieurs fois
- ✅ Enregistrer une vidéo de secours
- ✅ Chronométrer (5-7 min)
- ✅ Anticiper les questions

### Pendant la présentation
- ✅ Rester calme
- ✅ Parler lentement
- ✅ Montrer les fonctions, pas le code
- ✅ En cas d'erreur: montrer le backup

### Questions fréquentes
- Pourquoi cette technologie?
- Comment est structurée la DB?
- Comment étendre X?
- Quel était le plus grand défi?

---

## Ressources

**Documentation:**
- Node.js: nodejs.org/docs
- Express: expressjs.com
- MySQL: dev.mysql.com/doc

**Tutoriels:**
- freeCodeCamp.org
- MDN Web Docs
- YouTube (Traversy Media, Net Ninja)

**Outils:**
- Postman pour les tests API
- VS Code pour le développement
- GitHub pour le contrôle de version
- Figma pour le design UI (optionnel)

---

**Bonne chance avec le projet! 🚀**
