# Travail préparatoire Leçon 11 : Pattern MVC & Frameworks

## Objectif

Préparation pour la leçon 11, dans laquelle nous structurerons les projets Express selon le pattern MVC et utiliserons des ORMs (Object-Relational Mapping).

## Tâches

### 1. Recherche sur le Pattern MVC (env. 30 minutes)

Fais des recherches sur le **Pattern Model-View-Controller (MVC)** et réponds par écrit aux questions suivantes :

**a) Compréhension de base :**
- Qu'est-ce que le pattern MVC et à quoi sert-il ?
- Quels sont les trois composants principaux et quelle est la responsabilité de chaque composant ?
- Dessine un diagramme simple qui montre comment les trois composants interagissent entre eux.

**b) Avantages & Inconvénients :**
- Nomme au moins 3 avantages du pattern MVC
- Y a-t-il aussi des inconvénients ou des situations où MVC n'est pas idéal ?

**c) Application pratique :**
- Comment structurerais-tu une API REST simple pour une bibliothèque (livres, auteurs) selon MVC ?
- Quels fichiers/classes créerais-tu ?
- Quel code appartient à quelle couche ?

**d) Comparaison :**
- Quelle est la différence entre "Model" dans MVC et "Model" dans la conception de base de données (ERD) ?

### 2. Analyser le projet existant (env. 20 minutes)

Examine ton projet d'API REST actuel :

- Où se trouve actuellement le code pour l'accès à la BD ?
- Où se trouve la logique métier (validation, calculs) ?
- Où sont traités les requêtes HTTP ?
- Le code est-il déjà structuré selon MVC ? Si non, comment le restructurerais-tu ?

Crée un bref aperçu (les points-clés suffisent) :
```
Structure actuelle :
- Fichier X : contient [accès BD / logique métier / traitement des requêtes]
- Fichier Y : ...

Propositions d'amélioration pour MVC :
- Couche Model : [qu'est-ce qui va ici ?]
- Couche Controller : [qu'est-ce qui va ici ?]
- Couche Route : [qu'est-ce qui va ici ?]
```

### 3. Framework vs. Library (env. 10 minutes)

Recherche brièvement la différence entre un **Framework** et une **Library**.

Réponds :
- Quelle est la principale différence ?
- Express.js est-il un framework ou une library ? Pourquoi ?
- Connais-tu d'autres exemples de frameworks Node.js ?

### 4. Connaissance préalable sur les ORM (optionnel, env. 15 minutes)

Si tu as le temps, informe-toi brièvement sur **ORM (Object-Relational Mapping)** :

- Qu'est-ce qu'un ORM ?
- Quels sont les ORMs connus pour Node.js ?
- Quels sont les avantages et inconvénients des ORMs par rapport aux requêtes SQL brutes ?

---

## Remise

**Format :** 
- Fichier Markdown (`.md`) ou document Word (`.docx`)
- Structuré selon les questions ci-dessus
- Utiliser tes propres mots (pas de réponses copiées-collées)

**Volume :**
- 1-2 pages (sans diagramme)
- Les points-clés et de brèves explications suffisent

**Échéance :** 
Avant le début de la leçon 11

---

## Ressources (Recommandations)

- [Pattern MVC - Wikipedia](https://fr.wikipedia.org/wiki/Mod%C3%A8le-vue-contr%C3%B4leur)
- [MVC Explained - Mozilla Developer Network](https://developer.mozilla.org/fr/docs/Glossary/MVC)
- [Pattern MVC dans Node.js - YouTube/Tutorials]
- Propre recherche : "MVC Pattern Web Development"

## Évaluation

Ce travail préparatoire n'est **pas noté**, mais il t'aide à mieux comprendre la leçon 11 et à participer activement. Les connaissances acquises seront intégrées dans ton projet Credit 10.

---

**Bonne préparation !**
