# GLSimpleSQL Interpreter

## Description
Interpréteur de requêtes SQL simplifiées développé avec Flex (analyseur lexical) et Bison (analyseur syntaxique) pour le cours de Théorie des Langages et Compilation.

## Fonctionnalités

### Commandes SQL Supportées
- **CREATE TABLE** : Création de tables avec types de données
- **INSERT INTO** : Insertion de données (avec ou sans spécification de champs)
- **SELECT** : Interrogation de données (avec clause WHERE optionnelle)
- **UPDATE** : Modification de données
- **DELETE** : Suppression de données
- **DROP TABLE** : Suppression de tables

### Types de Données
- `INT` : Entiers
- `FLOAT` : Nombres réels
- `VARCHAR(n)` : Chaînes de caractères de longueur maximale n
- `BOOL` : Booléens (TRUE/FALSE)

### Opérateurs
- **Comparaison** : `=`, `!=`, `<`, `>`, `<=`, `>=`
- **Logiques** : `AND`, `OR`, `NOT`

### Vérifications Sémantiques
L'interpréteur détecte les erreurs suivantes :
1. Table inexistante dans une requête
2. Champ inexistant dans une table
3. Incohérence entre nombre de champs et nombre de valeurs (INSERT)
4. Tentative de créer une table déjà existante
5. Tentative de supprimer une table inexistante (DROP)
6. Erreurs syntaxiques

### Statistiques
Pour chaque requête valide, l'interpréteur affiche :
- **SELECT** : Table, nombre de champs, présence de WHERE, conditions, opérateurs logiques
- **INSERT** : Table, nombre de valeurs
- **UPDATE** : Table, nombre de champs modifiés, présence de WHERE

## Compilation

### Prérequis
- GCC (compilateur C)
- Flex (analyseur lexical)
- Bison (analyseur syntaxique)
- Make

### Installation des dépendances (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install gcc flex bison make
```

### Compilation du projet
```bash
make
```

### Nettoyage des fichiers de compilation
```bash
make clean
```

## Utilisation

### Mode interactif
```bash
./bin/glsimplesql
```
Tapez vos requêtes SQL et terminez avec `Ctrl+D`.

### Mode fichier
```bash
./bin/glsimplesql fichier.sql
```

### Exemples

#### Exemple 1 : Création et interrogation
```sql
CREATE TABLE Etudiant (
    id INT,
    nom VARCHAR(50),
    age INT
);

INSERT INTO Etudiant VALUES (1, 'Diallo', 20);
SELECT * FROM Etudiant;
```

#### Exemple 2 : Requêtes avec conditions
```sql
SELECT nom, age FROM Etudiant WHERE age > 18;
UPDATE Etudiant SET age = 21 WHERE id = 1;
DELETE FROM Etudiant WHERE age < 18;
```

#### Exemple 3 : Gestion des tables
```sql
CREATE TABLE Produit (id INT, nom VARCHAR(100), prix FLOAT);
DROP TABLE Produit;
```

## Structure du Projet

```
.
├── Makefile                  # Fichier de compilation
├── README.md                 # Ce fichier
├── GRAMMAIRE_BNF.md          # Grammaire formelle
├── Rapport_Final_GLSimpleSQL.md # Rapport détaillé du projet
├── src/                      # Dossier des sources
│   ├── main.c               # Programme principal
│   ├── sql_lexer.l          # Analyseur lexical (Flex)
│   ├── sql_parser.y         # Analyseur syntaxique (Bison)
│   ├── symbol_table.c       # Implémentation de la table des symboles
│   └── symbol_table.h       # Interface de la table des symboles
├── tests/                    # Dossier des tests SQL
│   ├── test.sql             # Tests requêtes valides
│   ├── test_examples.sql    # Exemples variés
│   └── test_errors.sql      # Tests détection erreurs
├── docs/                     # Documentation et cahier des charges
│   └── cahier_des_charges.pdf
├── build/                   # Fichiers générés (créé lors de la compilation)
└── bin/                     # Exécutable (créé lors de la compilation)
```

## Caractéristiques Techniques

### Analyseur Lexical (Flex)
- Reconnaissance des mots-clés SQL (case-insensitive)
- Identification des types de données
- Gestion des commentaires (`--` et `/* */`)
- Détection des constantes (entières, réelles, chaînes, booléennes)

### Analyseur Syntaxique (Bison)
- Grammaire complète du langage GLSimpleSQL
- Gestion des priorités d'opérateurs
- Récupération d'erreurs syntaxiques

### Table des Symboles
- Stockage des tables créées avec leurs champs et types
- Vérification de l'existence des tables et champs
- Gestion dynamique de la mémoire

### Actions Sémantiques
- Calcul de statistiques pour chaque requête
- Vérifications de cohérence
- Messages d'erreur détaillés avec numéros de ligne

## Messages d'Erreur

L'interpréteur fournit des messages d'erreur clairs :

```
ERREUR SÉMANTIQUE ligne 5 :
  La table 'Produit' n'existe pas.

ERREUR SÉMANTIQUE ligne 8 :
  Le champ 'prix' n'existe pas dans la table 'Client'.

ERREUR SÉMANTIQUE ligne 12 :
  INSERT INTO Client : 3 valeurs fournies mais 4 champs attendus.
```

## Tests

Le projet inclut plusieurs types de tests :

### Tests de base
```bash
make test
```

### Tests manuels
Créez un fichier de test et exécutez-le :
```bash
echo "CREATE TABLE Test (id INT); SELECT * FROM Test;" > tests/my_test.sql
./bin/glsimplesql tests/my_test.sql
```

## Limitations

Ce projet est un **interpréteur éducatif** :
- Il ne stocke pas réellement les données
- Il ne crée pas de base de données physique
- Il analyse et vérifie uniquement la syntaxe et la sémantique des requêtes
- Il affiche des statistiques sur les requêtes

## Auteur

**El-yass Hasnaoui**

Projet développé dans le cadre du module **THL et Compilation (I513)**  
Filière : LST GL S5  
Année universitaire : 2025-2026

## Licence

Projet académique - Université Moulay Ismail
