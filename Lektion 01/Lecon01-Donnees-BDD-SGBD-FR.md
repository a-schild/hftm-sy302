# Leçon 1: Données, Bases de données et SGBD

## Objectifs d'apprentissage

L'étudiant(e) est capable de...
- Expliquer l'utilité des bases de données
- Énumérer les différents types de bases de données avec leurs caractéristiques de base
- Identifier les problèmes de base de données (redondance, incohérence)

## Qu'est-ce que les données?

**Données** = Faits représentés sous forme structurée ou non structurée.

### Différence: Données vs Information vs Connaissance

```
Données → Information → Connaissance → Sagesse
```

| Concept | Description | Exemple |
|---------|-------------|---------|
| **Données** | Faits bruts sans contexte | 25, 42, "Müller" |
| **Information** | Données avec signification | Température: 25°C, Âge: 42 ans, Nom: Müller |
| **Connaissance** | Information comprise | "À 25°C, les gens se sentent à l'aise" |
| **Sagesse** | Connaissance appliquée | "Régler la climatisation à 25°C" |

### Propriétés des données

1. **Contenu**: Quelles informations sont disponibles?
2. **Structure**: Comment les données sont-elles organisées?
3. **Syntaxe**: Y a-t-il des règles de représentation?
4. **Sémantique**: Que signifient les données?

## Problèmes de qualité des données

### 1. Redondance

**Définition:** Les mêmes données sont stockées plusieurs fois.

**Exemple:**
```
Customer 1: Name="Max Müller", Address="Main St. 1", City="Bern"
Customer 2: Name="Max Müller", Address="Main St. 1", City="Bern"
```

**Problèmes:**
- Plus d'espace de stockage
- Incohérence possible lors des mises à jour
- Plus difficile à maintenir

### 2. Incohérence

**Définition:** Données contradictoires dans le système.

**Exemple:**
```
Table 1: Customer "Max Müller" lives in "Bern"
Table 2: Customer "Max Müller" lives in "Zurich"
```

**Causes:**
- Stockage redondant des données
- Manque de synchronisation
- Maintenance manuelle des données

### 3. Manque d'intégrité des données

**Problèmes d'intégrité:**
- Valeurs manquantes (NULL où non autorisé)
- Types de données incorrects (texte dans un champ numérique)
- Relations violées (référence à des données inexistantes)

## Exercice pratique: Analyse d'un tableau Excel

**Fichier:** `SY302-01 - KassaBonTotal.xlsx`

### Instructions (20 minutes)

Analysez la première feuille du fichier Excel:

1. **Contenu**: Quelles informations sont disponibles?
   - Quelles colonnes existent?
   - Quel type de données est stocké?

2. **Syntaxe**: Y a-t-il une syntaxe reconnaissable? Est-elle cohérente/uniforme?
   - Les formats de date sont-ils uniformes?
   - Les prix sont-ils formatés uniformément?
   - Y a-t-il des espaces, des caractères spéciaux?

3. **Redondances**: Y a-t-il des redondances dans le tableau? Si oui, lesquelles?
   - Les données sont-elles stockées plusieurs fois?
   - Où les données pourraient-elles être externalisées?

4. **Cohérence**: Les données sont-elles cohérentes?
   - Y a-t-il des contradictions?
   - Quelles sont les conséquences des incohérences?

### Problèmes typiques dans Excel/Fichiers plats

- **Pas de types de données**: Tout peut être partout
- **Pas de validation**: Entrées erronées possibles
- **Pas de relations**: Stockage redondant des données
- **Pas de transactions**: Les données peuvent devenir incohérentes
- **Recherche difficile**: Pas de requêtes efficaces
- **Pas de multi-utilisateurs**: Conflits lors d'accès simultanés

## Qu'est-ce qu'une base de données?

**Base de données** = Collection organisée de données structurées

### Avantages des bases de données

1. **Structuration**: Organisation claire des données
2. **Évitement de la redondance**: Les données ne sont stockées qu'une fois
3. **Cohérence des données**: Les règles garantissent des données correctes
4. **Intégrité des données**: Les relations entre les données sont préservées
5. **Accès multi-utilisateurs**: Plusieurs utilisateurs simultanément
6. **Sécurité**: Droits d'accès et authentification
7. **Backup & Recovery**: Sauvegarde automatique
8. **Recherche efficace**: Requêtes rapides même avec de grandes quantités de données

## SGBD - Système de Gestion de Base de Données

**SGBD** = Logiciel pour gérer les bases de données

### Fonctions d'un SGBD

- **Définition des données** (DDL): Définir la structure de la base de données
- **Manipulation des données** (DML): Insérer, modifier, supprimer des données
- **Requêtes de données**: Rechercher et récupérer des données
- **Contrôle d'accès**: Gérer les utilisateurs et les droits
- **Gestion des transactions**: Assurer les propriétés ACID
- **Backup & Recovery**: Sauvegarde des données

### SGBD connus

**Relationnels:**
- MySQL / MariaDB (Open Source)
- PostgreSQL (Open Source)
- Oracle Database (Commercial)
- Microsoft SQL Server (Commercial)
- SQLite (Embarqué)

**NoSQL:**
- MongoDB (Orienté documents)
- Redis (Key-Value)
- Cassandra (Column-Family)
- Neo4j (Graphe)

## Types de bases de données

### 1. Bases de données relationnelles (RDBMS)

**Concept:** Données dans des tables (relations) avec des relations

**Propriétés:**
- Tables avec lignes et colonnes
- Primary Keys et Foreign Keys
- SQL comme langage de requête
- Transactions ACID
- Normalisation

**Utilisation:**
- Applications d'entreprise (ERP, CRM)
- E-Commerce
- Banque
- Partout où il y a des données structurées avec des relations

**Exemple de structure:**
```
Table: customers
+----+----------+-------------------+
| id | name     | email             |
+----+----------+-------------------+
| 1  | Mueller  | mueller@email.ch  |
| 2  | Schmidt  | schmidt@email.ch  |
+----+----------+-------------------+

Table: orders
+----+-----------+-------------+--------+
| id | date      | customer_id | total  |
+----+-----------+-------------+--------+
| 1  | 2024-10-01| 1           | 99.90  |
| 2  | 2024-10-05| 2           | 149.50 |
+----+-----------+-------------+--------+
```

### 2. Bases de données orientées documents

**Concept:** Données sous forme de documents JSON

**Propriétés:**
- Schéma flexible
- Structures imbriquées
- Pas besoin de JOIN
- Évolutivité horizontale

**Utilisation:**
- Gestion de contenu
- Catalogues
- Profils utilisateurs
- Analyses en temps réel

**Exemple:** MongoDB
```json
{
    "_id": "507f1f77bcf86cd799439011",
    "name": "Max Mueller",
    "email": "mueller@email.ch",
    "orders": [
        {
            "order_id": 1,
            "date": "2024-10-01",
            "total": 99.90
        }
    ]
}
```

### 3. Bases de données Key-Value

**Concept:** Paires clé-valeur simples

**Propriétés:**
- Très rapide
- Structure simple
- En mémoire possible
- Bon pour le cache

**Utilisation:**
- Stockage de sessions
- Cache
- Applications temps réel

**Exemple:** Redis
```
SET user:1001 "Max Mueller"
SET session:abc123 '{"userId":1001,"expires":"2024-12-31"}'
GET user:1001  // Returns: "Max Mueller"
```

### 4. Bases de données Column-Family

**Concept:** Colonnes au lieu de lignes comme unité de stockage

**Propriétés:**
- Optimisé pour les performances de lecture
- Grandes quantités de données
- Évolutivité horizontale
- Cohérence éventuelle

**Utilisation:**
- Big Data
- Analytics
- Données de séries temporelles
- IoT

**Exemple:** Cassandra

### 5. Bases de données de graphes

**Concept:** Données sous forme de nœuds et d'arêtes (relations)

**Propriétés:**
- Les relations sont des citoyens de première classe
- Traversée efficace
- Structure flexible

**Utilisation:**
- Réseaux sociaux
- Systèmes de recommandation
- Détection de fraude
- Analyse de réseau

**Exemple:** Neo4j
```
(Max)-[:KNOWS]->(Anna)
(Max)-[:WORKS_AT]->(HFTM)
(Anna)-[:WORKS_AT]->(HFTM)
```

## Où sont stockées les données?

### Distribution géographique

**Fournisseurs cloud - Centres de données:**
- AWS: Dans le monde entier (Régions: EU-West (Irlande), EU-Central (Francfort))
- Microsoft Azure: Dans le monde entier (Suisse, Allemagne, etc.)
- Google Cloud: Dans le monde entier (Belgique, Pays-Bas pour l'UE)

**Fournisseurs cloud suisses:**
- Swisscom
- Infomaniak
- Nine

**Aspects juridiques:**
- Protection des données (RGPD, LPD)
- Souveraineté des données
- Exigences de conformité

## Propriétés ACID

Les bases de données relationnelles garantissent **ACID**:

### A - Atomicity (Atomicité)
La transaction est indivisible: tout ou rien.

**Exemple:** Transfert d'argent
```sql
BEGIN TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;  -- Les deux mises à jour ou aucune
```

### C - Consistency (Cohérence)
La base de données reste dans un état cohérent.

**Exemple:** Les contraintes sont respectées
```sql
-- Si balance < 0 n'est pas autorisé, la transaction est rejetée
CHECK (balance >= 0)
```

### I - Isolation
Les transactions ne s'influencent pas mutuellement.

**Exemple:** Deux utilisateurs modifient des données simultanément
- User A lit le solde: 1000 CHF
- User B lit le solde: 1000 CHF
- User A débite: 100 CHF
- User B débite: 200 CHF
- Résultat final: 700 CHF (pas 800 ou 900)

### D - Durability (Durabilité)
Les données committées restent stockées de manière permanente.

**Exemple:** Après COMMIT, les données survivent même à une panne de courant

## Théorème CAP (pour les systèmes distribués)

Dans les bases de données distribuées, on ne peut avoir que 2 des 3:

- **C**onsistency (Cohérence): Tous les nœuds voient les mêmes données
- **A**vailability (Disponibilité): Le système répond toujours
- **P**artition Tolerance (Tolérance aux partitions): Le système fonctionne même en cas de pannes réseau

**Exemples:**
- **CA**: DB relationnelle dans un centre de données
- **CP**: MongoDB, HBase
- **AP**: Cassandra, DynamoDB

## Travail préparatoire (Credit 1)

### Instructions

1. **Regarder les vidéos:**
   - Fondamentaux des données et des bases de données
   - Introduction au SGBD

2. **Analyse des données dans votre quotidien:**
   
   **Partie A - Utilisation des données:**
   Listez où vous avez **utilisé** des données la semaine dernière:
   - Au moins 5 exemples
   - Quelles données? (ex: contacts, cartes, produits)
   - Quelle application? (ex: Google Maps, boutique en ligne)
   
   **Partie B - Données fournies:**
   Listez où vous avez **fourni** des données la semaine dernière:
   - Au moins 5 exemples
   - Quelles données? (ex: termes de recherche, localisation, formulaire)
   - À qui? (ex: Google, Instagram, boutique en ligne)

3. **Stockage des données:**
   - Où ces données sont-elles stockées? (Géographiquement)
   - Chez quelles entreprises/autorités?
   - Quels centres de données? (si connu)

### Exemple

**Utilisé:**
- Google Maps: Vue de la carte, données de trafic → Serveurs Google (USA/UE)
- WhatsApp: Historique de chat → Serveurs Meta (UE)
- Netflix: Catalogue de films → Serveurs AWS (UE)

**Fourni:**
- Instagram: Likes, commentaires, localisation → Meta (UE)
- Boutique en ligne: Nom, adresse, données de paiement → Serveurs boutique (CH/UE)
- Moteur de recherche: Termes de recherche, clics → Google (USA/UE)

## Résumé

### Points clés

- **Données ≠ Information**: Les données ont besoin de contexte
- **Qualité des données**: Éviter la redondance et l'incohérence
- **Bases de données**: Stockage structuré avec de nombreux avantages
- **SGBD**: Logiciel pour gérer les bases de données
- **Différents types de bases de données**: Pour différents cas d'utilisation
- **ACID**: Garanties pour les bases de données relationnelles

### Termes importants

- **Base de données**: Collection de données organisée
- **SGBD**: Système de Gestion de Base de Données
- **Redondance**: Stockage multiple de données
- **Incohérence**: Données contradictoires
- **ACID**: Atomicity, Consistency, Isolation, Durability
- **SQL**: Structured Query Language
- **NoSQL**: Not only SQL

## Prochaines étapes

Dans la leçon 2, nous apprendrons:
- Comment concevoir des bases de données
- Créer des diagrammes ER
- Normalisation
- SQL DDL (Data Definition Language)

## Ressources supplémentaires

- [What is Data? - Wikipedia](https://en.wikipedia.org/wiki/Data)
- [Database Fundamentals](https://www.oracle.com/database/what-is-database/)
- [ACID Properties](https://en.wikipedia.org/wiki/ACID)
- [CAP Theorem Explained](https://www.ibm.com/topics/cap-theorem)
