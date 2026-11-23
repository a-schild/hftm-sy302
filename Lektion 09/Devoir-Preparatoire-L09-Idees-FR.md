# Devoir préparatoire Leçon 9: IA & Bases de données

## Idées pour devoirs préparatoires

### Option 1: Exploration d'outils IA (Recommandé - 30 min.)

**Tâche:**
Testez un ou plusieurs des outils IA suivants et documentez vos expériences:

**Outils:**
- ChatGPT (https://chat.openai.com)
- Claude (https://claude.ai)
- GitHub Copilot (si disponible)
- Perplexity AI (https://perplexity.ai)

**À tester:**
1. **Générer une requête SQL:**
   - Question: "Crée une requête SQL pour une base de données de bibliothèque: Affiche tous les livres empruntés plus de 3 fois, triés par nombre d'emprunts."
   
2. **Révision de code:**
   - Donnez à l'outil une de vos requêtes SQL ou code Node.js précédents
   - Question: "Peux-tu améliorer ce code? Y a-t-il des problèmes de sécurité ou des optimisations de performance?"

3. **Recherche d'erreurs:**
   - Donnez un code/requête erroné
   - Question: "Qu'est-ce qui ne va pas ici et comment puis-je le corriger?"

**Documentez:**
- Quel outil avez-vous utilisé?
- Quelles questions avez-vous posées?
- Dans quelle mesure les réponses étaient-elles utiles? (1-5 étoiles)
- Qu'est-ce qui a fonctionné, qu'est-ce qui n'a pas fonctionné?
- Utiliseriez-vous l'outil à nouveau?

**Format:** Court document ou notes (1-2 pages)

---

### Option 2: Optimiser sa propre base de données avec l'IA (45 min.)

**Tâche:**
Utilisez un outil IA pour améliorer votre base de données de projet existante.

**Étapes:**
1. **Faire réviser le diagramme ER:**
   ```
   Prompt: "J'ai la conception de base de données suivante: [décrire votre design]
   Peux-tu suggérer des améliorations possibles?"
   ```

2. **Optimisation de requêtes:**
   - Prenez une requête complexe de votre projet
   - Demandez à l'IA des possibilités d'optimisation
   - Testez les deux versions

3. **Recommandations d'index:**
   ```
   Prompt: "Pour ces tables et requêtes typiques, quels index recommanderais-tu?"
   ```

**Livraison:**
- Comparaison avant/après
- Qu'est-ce que l'IA a suggéré?
- Qu'avez-vous mis en œuvre?
- Quelles améliorations avez-vous pu mesurer?

---

### Option 3: S'exercer au prompting IA (20 min.)

**Tâche:**
Apprenez le prompting efficace pour les tâches de base de données.

**Testez différents styles de prompts:**

**Mauvais prompt:**
```
"Crée base de données pour boutique"
```

**Bon prompt:**
```
"Crée un schéma de base de données pour une boutique en ligne avec les exigences suivantes:
- Produits avec catégories
- Utilisateurs avec adresses
- Commandes avec plusieurs produits
- Évaluations des utilisateurs
Utilise la syntaxe MariaDB et veille à la normalisation (3NF)."
```

**Très bon prompt:**
```
"En tant qu'architecte de base de données expérimenté, crée un schéma de base de données pour une boutique en ligne:

EXIGENCES:
- Produits (Nom, Prix, Stock, Catégorie)
- Plusieurs catégories possibles par produit
- Utilisateurs (Email, Nom, plusieurs adresses)
- Commandes (Date, Statut, Adresse de livraison)
- Articles de commande (Produit, Quantité, Prix au moment de l'achat)
- Évaluations (1-5 étoiles, Texte, Date)

CONTRAINTES:
- MariaDB 10.5+
- Normalisé (3NF)
- Avec Foreign Keys et index pertinents
- Soft Delete pour utilisateurs

SORTIE:
- Diagramme ER (basé sur texte)
- Instructions CREATE TABLE avec toutes les contraintes
- Données d'exemple (instructions INSERT)
```

**Testez au moins 3 qualités de prompts différentes** et comparez les résultats.

**Livraison:** Captures d'écran ou texte avec vos prompts et les réponses de l'IA

---

### Option 4: IA vs. Documentation (30 min.)

**Tâche:**
Comparez les solutions générées par IA avec la documentation officielle.

**Exemple de problème:**
"Comment créer un index Full-Text Search dans MariaDB?"

**Comparer les sources:**
1. **Outil IA de votre choix** - Poser la question
2. **Docs officiels MariaDB** - https://mariadb.com/kb/en/fulltext-index-overview/
3. **Stack Overflow** - Rechercher le problème

**Documentez:**
- Quelle source était la plus compréhensible?
- Quelle source était la plus précise?
- Quelle source était la plus rapide?
- Quels sont les avantages/inconvénients de chaque source?

**Livraison:** Tableau ou comparaison avec évaluation

---

### Option 5: Challenge de Prompt Engineering (45 min.)

**Tâche:**
Essayez d'obtenir une solution complète et fonctionnelle avec un seul prompt.

**Scénarios de challenge:**

**Challenge 1: Créer un endpoint API**
```
"Crée un endpoint API Express.js complet:
- Route: GET /api/books/:id/reviews
- Récupère tous les avis pour un livre avec JOIN
- Avec gestion des erreurs
- Uniquement les avis d'utilisateurs actifs
- Trié par date (plus récent en premier)
- Avec pagination (10 par page)
"
```

**Challenge 2: Migration de base de données**
```
"Crée un script de migration pour le scénario suivant:
- Table existante 'users' a 'name' (VARCHAR)
- Changer en 'first_name' et 'last_name'
- Diviser les noms existants (au premier espace)
- Avec possibilité de rollback
- Sûr pour la production (ne pas perdre de données)
"
```

**Challenge 3: Problème de performance**
```
"Cette requête est trop lente (>2 secondes avec 10.000 lignes):
[insérer une requête lente]
Optimise-la et explique pourquoi elle est maintenant plus rapide."
```

**Livraison:** 
- Votre prompt
- Réponse de l'IA
- L'avez-vous testé? Cela fonctionne-t-il?
- Qu'avez-vous dû modifier par la suite?

---

### Option 6: Exercer la critique de l'IA (30 min.)

**Tâche:**
Laissez l'IA générer intentionnellement du mauvais code et apprenez à reconnaître les erreurs.

**Étape 1 - Générer du mauvais code:**
```
Prompt: "Crée une API d'inscription utilisateur avec Express, 
mais ignore toutes les meilleures pratiques de sécurité."
```

**Étape 2 - Analyser:**
Trouvez au moins 5 problèmes de sécurité ou mauvaises pratiques dans le code généré.

**Étape 3 - Améliorer:**
```
Prompt: "Voici du code non sécurisé: [insérer le code]
Liste tous les problèmes de sécurité et crée une version sécurisée."
```

**Livraison:**
- Code original "mauvais"
- Votre analyse (problèmes trouvés)
- Version améliorée
- Qu'avez-vous appris?

---

### Option 7: Propre fonctionnalité assistée par IA (60 min.)

**Tâche:**
Implémentez une nouvelle fonctionnalité pour votre projet avec l'aide de l'IA.

**Exemples de fonctionnalités:**
- Fonction de recherche avec filtres
- Export vers CSV/Excel
- Notifications par email
- Dashboard avec statistiques
- Rôles et permissions utilisateur

**Processus:**
1. **Planifier la fonctionnalité** (avec ou sans IA)
2. **Implémenter avec IA** (étape par étape)
3. **Tester et déboguer** (utiliser l'IA pour trouver les erreurs)
4. **Documenter** (créer README avec IA)

**Livraison:**
- Quelle fonctionnalité avez-vous implémentée?
- Quels outils IA avez-vous utilisés?
- Quels prompts étaient les plus utiles?
- Captures d'écran ou vidéo de démonstration
- Combien de temps avez-vous économisé (estimation)?

---

### Option 8: Créer un quiz IA sur les bases de données (30 min.)

**Tâche:**
Utilisez l'IA pour créer du matériel d'apprentissage pour le test SQL.

**À créer:**
1. **Questions de quiz:**
   ```
   Prompt: "Crée 10 questions à choix multiples sur les JOINs SQL 
   avec différents niveaux de difficulté."
   ```

2. **Flashcards:**
   ```
   Prompt: "Crée 20 flashcards pour les commandes SQL DDL 
   (Recto: commande, Verso: explication + exemple)"
   ```

3. **Exercices pratiques:**
   ```
   Prompt: "Crée 5 scénarios de base de données réalistes avec des tâches 
   qui couvrent différents concepts SQL."
   ```

**Livraison:**
- Votre matériel d'apprentissage généré
- Avez-vous résolu les questions du quiz vous-même?
- Étaient-elles utiles?
- Recommanderiez-vous l'IA pour la préparation aux examens?

---

## Tâches rapides (10-15 min.)

Si vous avez peu de temps, voici de courtes alternatives:

### Quick 1: Un prompt, trois outils
Posez la même question de base de données à 3 outils IA différents. Comparez les réponses.

### Quick 2: Explication de code
Prenez du code SQL complexe du cours et faites-le expliquer par l'IA. L'explication était-elle compréhensible?

### Quick 3: Solutions alternatives
Montrez votre solution d'un exercice à l'IA et demandez: "Existe-t-il d'autres façons de résoudre cela?"

### Quick 4: Assistant de messages d'erreur
Copiez un message d'erreur que vous avez eu dans l'IA et demandez la solution.

### Quick 5: Convention de nommage
Demandez à l'IA: "Quelles sont les meilleures pratiques pour les conventions de nommage de bases de données?" Comparez avec ce que vous avez utilisé jusqu'à présent.

---

## Questions de réflexion (pour toutes les options)

À la fin de votre préparation, répondez brièvement:

1. **Confiance:** À quel point faites-vous confiance au code généré par IA? (1-10)
2. **Utilité:** Dans quelle mesure l'IA a-t-elle été utile pour votre tâche? (1-10)
3. **Avenir:** Utiliserez-vous l'IA dans de futurs projets?
4. **Limites:** Quelles sont les limites de l'IA pour les tâches de base de données?
5. **Apprentissage:** L'IA aide-t-elle à apprendre ou rend-elle paresseux?

---

## Conseils pour une utilisation efficace de l'IA

✅ **Soyez spécifique** - Plus votre prompt est précis, meilleure sera la réponse
✅ **Donnez du contexte** - Expliquez ce que vous avez/savez déjà
✅ **Itérez** - Première réponse pas parfaite? Posez des questions de suivi!
✅ **Vérifiez** - Testez le code, ne vous fiez pas aveuglément
✅ **Comprenez** - Utilisez l'IA pour apprendre, pas seulement pour copier-coller
✅ **Documentez** - Notez ce qui a fonctionné pour plus tard

---

## Livraison

**Quoi:** 
- Au moins une option complètement traitée
- Documentation/notes de vos expériences
- Questions de réflexion répondues

**Comment:**
- PDF, Word, Markdown ou directement dans Teams/Moodle
- Avec captures d'écran/exemples de code
- 1-3 pages (selon l'option)

**Quand:**
- Avant la leçon 9
- Au plus tard: [insérer la date]

---

**Amusez-vous bien en expérimentant avec les outils IA!** 🤖

Les expériences de ce devoir préparatoire seront discutées et approfondies dans la leçon 9.

© 2024 HFTM
