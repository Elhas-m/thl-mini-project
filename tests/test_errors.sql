-- ============================================================================
-- FICHIER DE TESTS D'ERREURS POUR GLSimpleSQL
-- ============================================================================
-- Ce fichier teste TOUTES les détections d'erreurs
-- ============================================================================

-- ============================================================================
-- SECTION 1 : Erreurs de Table Inexistante
-- ============================================================================

-- Erreur 1.1 : SELECT sur table inexistante
SELECT * FROM TableInexistante;

-- Erreur 1.2 : INSERT sur table inexistante
INSERT INTO TableInexistante VALUES (1, 'test');

-- Erreur 1.3 : UPDATE sur table inexistante
UPDATE TableInexistante SET id = 1 WHERE id = 0;

-- Erreur 1.4 : DELETE sur table inexistante
DELETE FROM TableInexistante WHERE id = 1;

-- Erreur 1.5 : DROP sur table inexistante
DROP TABLE TableInexistante;

-- ============================================================================
-- SECTION 2 : Erreurs de Champ Inexistant
-- ============================================================================

-- Créer une table pour tester
CREATE TABLE TestErreurs (
    id INT,
    nom VARCHAR(50),
    age INT
);

-- Erreur 2.1 : SELECT avec champ inexistant
SELECT champInexistant FROM TestErreurs;

-- Erreur 2.2 : SELECT avec un champ valide et un invalide
SELECT nom, champInexistant FROM TestErreurs;

-- Erreur 2.3 : SELECT avec WHERE et champ inexistant
SELECT * FROM TestErreurs WHERE champInexistant = 1;

-- Erreur 2.4 : UPDATE avec champ inexistant dans SET
UPDATE TestErreurs SET champInexistant = 10 WHERE id = 1;

-- Erreur 2.5 : UPDATE avec champ inexistant dans WHERE
UPDATE TestErreurs SET nom = 'test' WHERE champInexistant = 1;

-- ============================================================================
-- SECTION 3 : Erreurs de Nombre de Valeurs (INSERT)
-- ============================================================================

-- Erreur 3.1 : Trop peu de valeurs
INSERT INTO TestErreurs VALUES (1, 'Nom');

-- Erreur 3.2 : Trop de valeurs
INSERT INTO TestErreurs VALUES (1, 'Nom', 25, 'Extra');

-- Erreur 3.3 : Une seule valeur au lieu de trois
INSERT INTO TestErreurs VALUES (1);

-- Erreur 3.4 : INSERT avec champs spécifiés mais mauvais nombre de valeurs
INSERT INTO TestErreurs (id, nom, age) VALUES (1, 'Test');

-- ============================================================================
-- SECTION 4 : Erreurs de Table Déjà Existante
-- ============================================================================

-- Erreur 4.1 : Créer une table qui existe déjà
CREATE TABLE TestErreurs (num INT);

-- Erreur 4.2 : Créer exactement la même table
CREATE TABLE TestErreurs (id INT, nom VARCHAR(50), age INT);

-- ============================================================================
-- SECTION 5 : Erreurs Syntaxiques
-- ============================================================================

-- Erreur 5.1 : SELECT sans FROM
SELECT id, nom;

-- Erreur 5.2 : SELECT FROM mais pas de table
SELECT * FROM;

-- Erreur 5.3 : SELECT * avec autres champs (si vous l'interdisez)
-- Note: Ceci peut être autorisé selon votre implémentation
-- SELECT *, nom FROM TestErreurs;

-- Erreur 5.4 : INSERT sans VALUES
INSERT INTO TestErreurs (1, 'test');

-- Erreur 5.5 : INSERT INTO sans nom de table
INSERT INTO VALUES (1);

-- Erreur 5.6 : CREATE TABLE sans parenthèses
CREATE TABLE Mauvais id INT;

-- Erreur 5.7 : CREATE TABLE avec parenthèses vides
CREATE TABLE Vide ();

-- Erreur 5.8 : UPDATE sans SET
UPDATE TestErreurs nom = 'test' WHERE id = 1;

-- Erreur 5.9 : UPDATE sans WHERE (syntaxiquement correct mais attention)
-- Note: Ceci devrait être VALIDE selon votre grammaire

-- Erreur 5.10 : DELETE sans FROM
DELETE TestErreurs WHERE id = 1;

-- Erreur 5.11 : WHERE sans condition
SELECT * FROM TestErreurs WHERE;

-- Erreur 5.12 : Opérateur incomplet
SELECT * FROM TestErreurs WHERE id =;

-- Erreur 5.13 : AND sans deuxième condition
SELECT * FROM TestErreurs WHERE id = 1 AND;

-- Erreur 5.14 : Parenthèse non fermée
SELECT * FROM TestErreurs WHERE (id = 1;

-- Erreur 5.15 : Virgule en trop dans liste de champs
SELECT id, nom, FROM TestErreurs;

-- ============================================================================
-- SECTION 6 : Erreurs de Types (si implémenté)
-- ============================================================================

-- Note: Ces erreurs ne sont PAS vérifiées dans votre implémentation actuelle
-- mais c'est une extension possible

-- Erreur 6.1 : VARCHAR sans taille (devrait fonctionner avec défaut 255)
-- CREATE TABLE TestType (nom VARCHAR);

-- Erreur 6.2 : Type inconnu
-- CREATE TABLE TestType (id UNKNOWN_TYPE);

-- ============================================================================
-- NETTOYAGE
-- ============================================================================

DROP TABLE TestErreurs;

-- ============================================================================
-- FIN DES TESTS D'ERREURS
-- ============================================================================
