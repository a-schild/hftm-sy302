# Leçon 9: IA dans l'environnement de base de données

## Objectifs d'apprentissage

L'étudiant(e) est capable de...
- Expliquer comment l'IA peut être utilisée dans le contexte des bases de données
- Utiliser Claude AI pour générer des requêtes SQL
- Générer des données de test avec l'IA
- Analyser et optimiser des requêtes avec l'IA
- Créer de la documentation automatiquement

## L'IA et les bases de données

L'**Intelligence Artificielle** change la façon dont nous travaillons avec les bases de données.

### Cas d'usage de l'IA dans les bases de données

**1. Génération de requêtes SQL**
- Écrire des requêtes complexes en langage naturel
- Optimiser les requêtes existantes
- Débogage de requêtes SQL

**2. Génération de données de test**
- Créer des datasets réalistes
- Générer des données cohérentes
- Anonymiser les données de production

**3. Modélisation de bases de données**
- Créer des diagrammes ER à partir de descriptions
- Suggérer des améliorations de design
- Vérifier la normalisation

**4. Optimisation et analyse**
- Analyser les performances
- Suggérer des index
- Identifier les goulots d'étranglement

**5. Documentation**
- Générer automatiquement de la documentation
- Créer des commentaires de code
- Expliquer les requêtes complexes

## Utiliser Claude AI pour SQL

### Génération de requêtes SQL

**Prompt:**
```
Écris une requête SQL pour:
- Trouver tous les livres publiés après 2010
- Avec leurs auteurs
- Triés par titre
- Seulement les livres disponibles (stock > 0)

Tables: books (id, title, author_id, published_date, amount_in_stock)
        authors (id, firstname, lastname)
```

**Réponse Claude:**
```sql
SELECT 
    b.title,
    b.published_date,
    b.amount_in_stock,
    CONCAT(a.firstname, ' ', a.lastname) AS author_name
FROM books b
INNER JOIN authors a ON b.author_id = a.id
WHERE b.published_date > '2010-01-01'
    AND b.amount_in_stock > 0
ORDER BY b.title;
```

### Optimisation de requêtes

**Prompt:**
```
Optimise cette requête:

SELECT * FROM books 
WHERE author_id IN (
    SELECT id FROM authors WHERE lastname LIKE '%Smith%'
);
```

**Réponse Claude:**
```sql
-- Optimisé avec JOIN au lieu de subquery
SELECT b.*
FROM books b
INNER JOIN authors a ON b.author_id = a.id
WHERE a.lastname LIKE '%Smith%';

-- Ou avec EXISTS (souvent plus rapide)
SELECT b.*
FROM books b
WHERE EXISTS (
    SELECT 1 
    FROM authors a 
    WHERE a.id = b.author_id 
        AND a.lastname LIKE '%Smith%'
);
```

### Expliquer des requêtes complexes

**Prompt:**
```
Explique cette requête en détail:

SELECT 
    g.genre,
    COUNT(b.id) AS book_count,
    AVG(b.amount_in_stock) AS avg_stock
FROM genres g
LEFT JOIN books b ON g.id = b.genre_id
GROUP BY g.id, g.genre
HAVING COUNT(b.id) > 5
ORDER BY book_count DESC;
```

**Réponse Claude:**
Cette requête fait une analyse des genres de livres:
1. **SELECT**: Sélectionne le nom du genre, compte les livres et calcule le stock moyen
2. **LEFT JOIN**: Inclut tous les genres, même sans livres
3. **GROUP BY**: Regroupe par genre
4. **HAVING**: Filtre seulement les genres avec plus de 5 livres
5. **ORDER BY**: Trie par nombre de livres (décroissant)

## Génération de données de test

### Avec Claude AI

**Prompt:**
```
Génère 10 INSERT statements pour la table books avec des données réalistes:

CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author_id INT,
    isbn VARCHAR(20),
    published_date DATE,
    price DECIMAL(10,2),
    amount_in_stock INT
);

Les author_id doivent être entre 1 et 50.
```

**Réponse Claude:**
```sql
INSERT INTO books (title, author_id, isbn, published_date, price, amount_in_stock) VALUES
('The Midnight Library', 12, '978-0525559474', '2020-08-13', 24.99, 45),
('Project Hail Mary', 8, '978-0593135204', '2021-05-04', 28.99, 32),
('The Seven Husbands of Evelyn Hugo', 23, '978-1501161933', '2017-06-13', 16.99, 67),
('Atomic Habits', 15, '978-0735211292', '2018-10-16', 27.00, 89),
('Where the Crawdads Sing', 34, '978-0735219090', '2018-08-14', 26.00, 54),
('Educated', 41, '978-0399590504', '2018-02-20', 28.00, 43),
('The Silent Patient', 19, '978-1250301697', '2019-02-05', 26.99, 38),
('Circe', 28, '978-0316556347', '2018-04-10', 27.00, 51),
('The Invisible Life of Addie LaRue', 7, '978-0765387561', '2020-10-06', 27.99, 29),
('Anxious People', 12, '978-1501160837', '2020-09-08', 27.00, 41);
```

### Script Node.js avec IA

```javascript
// generateTestData.js
const Anthropic = require('@anthropic-ai/sdk');
const pool = require('./config/database');

const client = new Anthropic({
    apiKey: process.env.ANTHROPIC_API_KEY
});

async function generateTestData() {
    const prompt = `
    Génère 20 INSERT statements pour une table authors:
    CREATE TABLE authors (
        id INT PRIMARY KEY AUTO_INCREMENT,
        firstname VARCHAR(50),
        lastname VARCHAR(50),
        email VARCHAR(100),
        birth_date DATE
    );
    
    Données réalistes avec noms variés et dates de naissance entre 1950 et 1990.
    `;
    
    const message = await client.messages.create({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 2000,
        messages: [{
            role: 'user',
            content: prompt
        }]
    });
    
    const sqlStatements = message.content[0].text;
    console.log('Generated SQL:', sqlStatements);
    
    // Optionnel: Exécuter directement
    // await pool.query(sqlStatements);
}

generateTestData();
```

## Design de bases de données avec l'IA

### Créer un diagramme ER

**Prompt:**
```
Crée un design de base de données pour un système de gestion de restaurant:

Exigences:
- Tables: Menu items, Orders, Customers, Employees, Tables
- Un client peut avoir plusieurs commandes
- Une commande peut avoir plusieurs items
- Les employés servent les tables
- Relations N:M où approprié

Format: Texte structuré avec tables, colonnes et relations
```

**Réponse Claude:**
```
TABLES:

customers
- customer_id (PK)
- first_name
- last_name
- email
- phone
- created_at

menu_items
- item_id (PK)
- name
- description
- price
- category
- available

orders
- order_id (PK)
- customer_id (FK → customers)
- table_id (FK → tables)
- employee_id (FK → employees)
- order_date
- total_amount
- status

order_items (Junction Table)
- order_item_id (PK)
- order_id (FK → orders)
- item_id (FK → menu_items)
- quantity
- item_price

tables
- table_id (PK)
- table_number
- capacity
- status

employees
- employee_id (PK)
- first_name
- last_name
- position
- hire_date

RELATIONS:
- customers 1:N orders
- orders N:M menu_items (via order_items)
- tables 1:N orders
- employees 1:N orders
```

## Intégration de Claude AI dans votre application

### Installation

```bash
npm install @anthropic-ai/sdk
```

### Configuration

```javascript
// config/claude.js
const Anthropic = require('@anthropic-ai/sdk');

const client = new Anthropic({
    apiKey: process.env.ANTHROPIC_API_KEY
});

module.exports = client;
```

### Exemple: Générateur de requêtes SQL

```javascript
// controllers/aiController.js
const claude = require('../config/claude');

exports.generateQuery = async (req, res) => {
    try {
        const { description, tables } = req.body;
        
        const prompt = `
        Génère une requête SQL pour: ${description}
        
        Schéma de base de données disponible:
        ${tables}
        
        Réponds uniquement avec la requête SQL, sans explication.
        `;
        
        const message = await claude.messages.create({
            model: 'claude-sonnet-4-20250514',
            max_tokens: 1024,
            messages: [{
                role: 'user',
                content: prompt
            }]
        });
        
        const sqlQuery = message.content[0].text;
        
        res.json({
            query: sqlQuery,
            description: description
        });
        
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error generating query' });
    }
};
```

### Exemple: Analyse de données

```javascript
exports.analyzeData = async (req, res) => {
    try {
        const { query, data } = req.body;
        
        const prompt = `
        Analyse ces données de base de données:
        
        Requête: ${query}
        Résultats: ${JSON.stringify(data, null, 2)}
        
        Fournis:
        1. Résumé des insights clés
        2. Tendances intéressantes
        3. Recommandations
        `;
        
        const message = await claude.messages.create({
            model: 'claude-sonnet-4-20250514',
            max_tokens: 2000,
            messages: [{
                role: 'user',
                content: prompt
            }]
        });
        
        const analysis = message.content[0].text;
        
        res.json({
            analysis: analysis,
            dataPoints: data.length
        });
        
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error analyzing data' });
    }
};
```

## Documentation automatique

### Générer des commentaires de code

**Prompt:**
```
Ajoute des commentaires JSDoc à cette fonction:

async function getBooksWithAuthors() {
    const sql = `
        SELECT b.*, a.firstname, a.lastname
        FROM books b
        INNER JOIN authors a ON b.author_id = a.id
        WHERE b.amount_in_stock > 0
    `;
    const [rows] = await pool.query(sql);
    return rows;
}
```

**Réponse Claude:**
```javascript
/**
 * Récupère tous les livres disponibles avec leurs auteurs
 * 
 * Effectue une jointure entre les tables books et authors pour obtenir
 * les informations complètes. Ne retourne que les livres en stock.
 * 
 * @async
 * @returns {Promise<Array>} Tableau d'objets contenant les détails des livres et auteurs
 * @throws {Error} Si la requête de base de données échoue
 * 
 * @example
 * const books = await getBooksWithAuthors();
 * // [{id: 1, title: "Book", firstname: "John", lastname: "Doe"}, ...]
 */
async function getBooksWithAuthors() {
    const sql = `
        SELECT 
            b.*,
            a.firstname,
            a.lastname
        FROM books b
        INNER JOIN authors a ON b.author_id = a.id
        WHERE b.amount_in_stock > 0
    `;
    const [rows] = await pool.query(sql);
    return rows;
}
```

### Générer un README pour l'API

**Prompt:**
```
Génère un README.md pour cette API:

Endpoints:
- GET /api/books
- GET /api/books/:id
- POST /api/books
- PUT /api/books/:id
- DELETE /api/books/:id
- GET /api/authors
- POST /api/authors

Base de données: MariaDB
Tech Stack: Node.js, Express, mysql2
```

## Bonnes pratiques avec l'IA

### Validation des résultats

```javascript
// Toujours valider les requêtes SQL générées par l'IA
async function validateAndExecuteQuery(generatedSQL) {
    try {
        // 1. Vérifier les mots-clés dangereux
        const dangerous = ['DROP', 'TRUNCATE', 'DELETE FROM', 'UPDATE'];
        const upperSQL = generatedSQL.toUpperCase();
        
        for (const keyword of dangerous) {
            if (upperSQL.includes(keyword)) {
                throw new Error('Dangerous operation detected');
            }
        }
        
        // 2. Test en lecture seule d'abord
        const [rows] = await pool.query(generatedSQL);
        
        return rows;
        
    } catch (err) {
        console.error('Generated query failed:', err);
        throw err;
    }
}
```

### Limiter l'accès

```javascript
// Ne pas exposer directement la génération SQL aux utilisateurs finaux
exports.generateQuery = async (req, res) => {
    // Vérifier l'authentification
    if (!req.user || !req.user.isAdmin) {
        return res.status(403).json({ error: 'Forbidden' });
    }
    
    // Limiter le rate
    // Valider l'input
    // Générer la requête
};
```

## Exercices pratiques

### Exercice 1: Générateur de requêtes

Créer un endpoint qui:
1. Accepte une description en langage naturel
2. Génère une requête SQL avec Claude
3. Valide la requête
4. Exécute et retourne les résultats

### Exercice 2: Données de test

Utiliser Claude pour:
1. Générer 50 clients réalistes
2. Générer 100 commandes
3. Assurer la cohérence des données (dates, montants)

### Exercice 3: Documentation

Générer automatiquement:
1. Documentation API (Markdown)
2. Commentaires pour toutes les fonctions
3. Diagramme ER en texte

## Considérations éthiques et limites

### Quand utiliser l'IA

✅ **Bon:**
- Générer des données de test
- Documenter le code
- Apprendre SQL
- Optimiser des requêtes
- Analyser les performances

❌ **Problématique:**
- Remplacer complètement la compréhension humaine
- Exécuter du SQL non validé en production
- Partager des données sensibles avec l'IA
- Se fier aveuglément aux résultats

### Sécurité

⚠️ **Important:**
- Ne jamais envoyer de données de production à l'IA
- Toujours valider les requêtes générées
- Ne pas exposer la génération SQL aux utilisateurs
- Respecter la protection des données

## Alternatives et outils

### Outils IA pour bases de données

1. **GitHub Copilot**: Autocomplétion de code
2. **ChatGPT**: Génération de requêtes et documentation
3. **Claude AI**: Analyse et optimisation
4. **Tabnine**: Suggestions de code

### Outils traditionnels

1. **MySQL Workbench**: Visual query builder
2. **DataGrip**: IDE professionnel
3. **pgAdmin**: Pour PostgreSQL
4. **DBeaver**: Multi-plateforme

## Futur de l'IA dans les bases de données

### Tendances

- **Optimisation automatique**: L'IA suggère automatiquement des index
- **Détection d'anomalies**: Identification des patterns inhabituels
- **Self-tuning databases**: Bases de données qui s'optimisent elles-mêmes
- **Natural Language Queries**: Requêtes en langage naturel
- **Automated testing**: Tests générés automatiquement

## Résumé

L'IA peut aider avec:
- ✅ Génération de requêtes SQL
- ✅ Création de données de test
- ✅ Documentation automatique
- ✅ Optimisation de requêtes
- ✅ Analyse de données

Mais toujours:
- ⚠️ Valider les résultats
- ⚠️ Protéger les données sensibles
- ⚠️ Garder la compréhension humaine
- ⚠️ Tester en environnement sûr

## Devoirs

1. **Intégrer Claude AI** dans votre projet
2. **Créer un endpoint** pour la génération de requêtes
3. **Générer des données de test** avec l'IA
4. **Documenter** votre API avec l'aide de l'IA

## Ressources

- [Anthropic Documentation](https://docs.anthropic.com/)
- [Claude AI](https://claude.ai/)
- [Best Practices for AI Code Generation](https://github.blog/2023-06-20-how-to-write-better-prompts-for-github-copilot/)

## Prochaines étapes

Dans la leçon 10:
- NoSQL et MongoDB
- Différences SQL vs NoSQL
- CRUD operations dans MongoDB
- Quand utiliser quelle base de données
