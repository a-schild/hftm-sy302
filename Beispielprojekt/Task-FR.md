# Exercice: Système de Gestion des Installations Électriques

**Durée:** 45 minutes  
**Taille du groupe:** 2-3 étudiants  
**Niveau de difficulté:** Moyen à avancé

---

## **Scénario**

L'entreprise **TechElec GmbH** gère les installations électriques et les services de maintenance dans plusieurs bâtiments. Jusqu'à présent, on travaille avec des tableurs et des carnets de bord papier – un système chaotique. Vous devez concevoir une base de données pour numériser les processus suivants:

- **Techniciens** avec leurs spécialisations (installations électriques, gestion des armoires électriques, programmation d'API, systèmes de sécurité)
- **Clients** et leurs **sites d'exploitation** (bâtiments/sites de production)
- **Installations** sur chaque site (systèmes d'alimentation électrique, tableaux de commande, automates)
- **Contrats de maintenance** liés aux installations
- **Interventions de travail** (maintenance préventive, réparations, inspections)

---

## **Analyse des Besoins**

### **1. Techniciens et Qualifications**
- Un technicien a un nom, un numéro de personnel et un statut (actif/inactif)
- Chaque technicien peut posséder **plusieurs qualifications** (p.ex. installation électrique ET programmation d'automates)
- Les qualifications sont standardisées et réutilisables
- Chaque qualification dispose d'un numéro de certification et d'une date d'expiration

### **2. Clients et Sites d'Exploitation**
- Un client a: nom de l'entreprise, personne de contact, numéro de téléphone
- Un client peut exploiter **plusieurs sites** (usine A, usine B, bureau)
- Chaque site dispose de: nom, adresse, personne responsable, ID du site
- Un site appartient à exactement un client

### **3. Installations**
- Les installations sont des systèmes spécifiques sur un site
- Exemples: tableaux principaux, système d'éclairage de secours, système de contrôle API, système de détection d'incendie
- Attributs: ID installation, type, description, année de construction, statut (actif/en maintenance/désactivé)
- Un site peut avoir **plusieurs installations**
- Une installation appartient à exactement un site

### **4. Contrats de Maintenance**
- Un contrat est conclu avec **un client** (pas par site)
- Un contrat concerne **une ou plusieurs installations** du client
- Attributs du contrat: ID contrat, date de début, date de fin, fréquence de maintenance (mensuelle, trimestrielle, annuelle)
- Un contrat a un **technicien principal responsable**
- Mais: le travail de maintenance peut être effectué par d'autres techniciens qualifiés

### **5. Interventions de Travail**
- Les interventions naissent des contrats de maintenance (maintenance programmée) ou comme réparations (non planifiées)
- Attributs: ID intervention, date, heure, statut (planifiée/en cours/terminée), description, durée estimée
- Une intervention concerne **une installation**
- Une intervention est effectuée par **un ou plusieurs techniciens**
- Pour chaque technicien dans l'intervention: heures de travail réelles, activités effectuées

---

## **Vos Tâches** (dans cet ordre)

### **Tâche 1: Analyse des Besoins & Schéma Conceptuel (Diagramme ER)**
*(Durée: env. 12 minutes)*

1. Identifiez tous les **types d'entités** et leurs **relations**
2. Pour chaque entité: Quels sont les attributs?
3. Marquez les clés primaires et étrangères
4. Documentez:
   - Toutes les relations 1:N
   - Toutes les relations N:M (et les tables de jonction nécessaires)
   - Les cardinalités (obligatoire ou optionnel?)

**Livrable:** Diagramme ER (graphique ASCII, format texte ou croquis) ou documentation écrite de toutes les entités avec leurs relations.

---

### **Tâche 2: Schéma Logique**
*(Durée: env. 12 minutes)*

Traduisez votre schéma conceptuel en **tables relationnelles normalisées**:

- Pour chaque table: définissez les noms de colonnes, les types de données
- Marquez PRIMARY KEY (PK) et FOREIGN KEY (FK)
- Appliquez les règles de normalisation (objectif: 3e forme normale)
- Considérez les index appropriés (clés étrangères, champs de recherche)

**Livrable:** Définition de la structure des tables (peut être du pseudocode ou des commentaires SQL).

---

### **Tâche 3: Implémentation DDL & Données de Test**
*(Durée: env. 18 minutes)*

Écrivez un **script SQL complet** qui:

1. Contient les instructions **CREATE TABLE** pour toutes les tables
   - Clés primaires et contraintes de clé étrangère avec intégrité référentielle
   - Contraintes NOT NULL où approprié
   - Valeurs par défaut sensées

2. Contient des **instructions INSERT** avec des données de test réalistes:
   - Au minimum **5 techniciens** avec différentes qualifications
   - Au minimum **3 clients** avec un total de 5+ sites
   - Au minimum **6 installations** (types différents)
   - Au minimum **3 contrats de maintenance** (un contrat peut couvrir plusieurs installations)
   - Au minimum **5 interventions** (mélange d'intervention planifiées et terminées)
   - Plusieurs techniciens par intervention (démontrer la relation N:M)

Le script SQL doit être **exécutable sans erreurs** et construire une base de données cohérente.

---

## **Exigences de Remise**

1. **Schéma conceptuel** (Tâche 1): Diagramme ER ou documentation des relations
2. **Schéma logique** (Tâche 2): Définition de la structure des tables
3. **Script SQL** (Tâche 3): Code complet et exécutable avec CREATE TABLE et INSERT

Le SQL doit **fonctionner** dans votre base de données (MySQL, PostgreSQL, SQLite, SQL Server) – testez d'abord!

---

## **Critères d'Évaluation**

- ✓ Tous les types d'entités correctement identifiés (6+ tables attendues)
- ✓ Relations 1:N et N:M correctement modélisées
- ✓ Normalisation effectuée (pas de données redondantes)
- ✓ Intégrité référentielle réalisée via contraintes FK
- ✓ Données de test réalistes et significatives (5+ enregistrements par table)
- ✓ SQL syntaxiquement correct et exécutable
- ✓ Documentation claire (commentaires dans le code, diagrammes lisibles)

---

## **Défi Optionnel** (s'il vous reste du temps)

Écrivez 2-3 **requêtes SELECT** utiles:
- Toutes les interventions pour un technicien spécifique le mois dernier
- Quels techniciens sont qualifiés pour une installation spécifique?
- Vue d'ensemble de toutes les installations dont le contrat de maintenance expire bientôt

---

## **Remarques pour les Étudiants**

De votre formation (électricien/automaticien), vous connaissez déjà:
- Les systèmes physiques (armoires électriques, câbles, contrôleurs, automates)
- Les concepts de maintenance (préventive, corrective, inspections)
- Les séquences de travail et les dépendances
- La planification des ressources

**Votre tâche:** Traduire cette réalité commerciale dans une base de données. Posez-vous: *Qui a besoin de consulter quoi et pourquoi?* Une bonne conception de base de données rend les opérations efficaces et les données fiables.

---

## **Conseils de Procédure**

1. **Commencez par les types d'entités** – ne surpensiez pas
2. Demandez-vous: "Est-ce une table séparée ou juste une propriété d'une autre entité?"
3. Pour les relations N:M: **créez une table de jonction**
4. Utilisez des **noms significatifs** (Technicien, pas Tech; Contrat_Maintenance, pas CM)
5. **Testez les instructions INSERT** – si elles échouent, votre schéma a un problème
6. **Intégrez tôt les contraintes de clé étrangère** – elles préviennent les mauvaises données

---

## **Nombre Attendu de Tables**

Vous devriez arriver à **6-7 tables**:
1. Techniciens
2. Qualifications
3. Techniciens_Qualifications (N:M)
4. Clients
5. Sites_Exploitation
6. Installations
7. Contrats_Maintenance
8. Contrats_Installations (N:M)
9. Interventions_Travail
10. Interventions_Techniciens (N:M)

**Conseil:** Pas toutes n'ont besoin d'être des tables séparées – réfléchissez aux dépendances!