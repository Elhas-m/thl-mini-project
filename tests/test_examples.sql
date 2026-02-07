-- ============================================================================
-- FICHIER DE TESTS COMPLET POUR GLSimpleSQL
-- ============================================================================

-- ============================================================================
-- SECTION 1 : Tests de CREATE TABLE
-- ============================================================================

-- Test 1.1 : Table simple avec INT
CREATE TABLE Test1 (
    id INT,
    age INT
);

-- Test 1.2 : Table avec tous les types
CREATE TABLE Personne (
    id INT,
    nom VARCHAR(50),
    prenom VARCHAR(100),
    salaire FLOAT,
    actif BOOL
);

-- Test 1.3 : Table avec un seul champ
CREATE TABLE Simple (
    valeur INT
);

-- ============================================================================
-- SECTION 2 : Tests de INSERT INTO
-- ============================================================================

-- Test 2.1 : INSERT avec toutes les valeurs
INSERT INTO Personne VALUES (1, 'Diallo', 'Mamadou', 5000.50, TRUE);

-- Test 2.2 : INSERT avec des valeurs négatives et FALSE
INSERT INTO Personne VALUES (2, 'Sow', 'Aissatou', -100.0, FALSE);

-- Test 2.3 : INSERT avec champs spécifiés
INSERT INTO Personne (id, nom) VALUES (3, 'Ba');

-- Test 2.4 : INSERT avec ordre différent des champs
INSERT INTO Personne (nom, id, prenom) VALUES ('Kane', 4, 'Ibrahima');

-- ============================================================================
-- SECTION 3 : Tests de SELECT
-- ============================================================================

-- Test 3.1 : SELECT * simple
SELECT * FROM Personne;

-- Test 3.2 : SELECT un seul champ
SELECT nom FROM Personne;

-- Test 3.3 : SELECT plusieurs champs
SELECT id, nom, prenom FROM Personne;

-- Test 3.4 : SELECT avec WHERE simple
SELECT * FROM Personne WHERE id = 1;

-- Test 3.5 : SELECT avec WHERE et opérateurs de comparaison
SELECT nom, salaire FROM Personne WHERE salaire > 1000;
SELECT nom FROM Personne WHERE salaire >= 5000.50;
SELECT nom FROM Personne WHERE id < 3;
SELECT nom FROM Personne WHERE id <= 2;
SELECT nom FROM Personne WHERE id != 1;

-- Test 3.6 : SELECT avec WHERE et AND
SELECT * FROM Personne WHERE id = 1 AND actif = TRUE;

-- Test 3.7 : SELECT avec WHERE et OR
SELECT * FROM Personne WHERE id = 1 OR id = 2;

-- Test 3.8 : SELECT avec WHERE complexe (AND et OR)
SELECT nom, prenom FROM Personne WHERE salaire > 1000 AND actif = TRUE OR id = 3;

-- Test 3.9 : SELECT avec WHERE et NOT
SELECT * FROM Personne WHERE NOT actif = FALSE;

-- Test 3.10 : SELECT avec parenthèses dans WHERE
SELECT * FROM Personne WHERE (id = 1 OR id = 2) AND actif = TRUE;

-- ============================================================================
-- SECTION 4 : Tests de UPDATE
-- ============================================================================

-- Test 4.1 : UPDATE un seul champ
UPDATE Personne SET salaire = 6000 WHERE id = 1;

-- Test 4.2 : UPDATE plusieurs champs
UPDATE Personne SET nom = 'Diallo-Modifié', salaire = 7000.75 WHERE id = 1;

-- Test 4.3 : UPDATE avec WHERE complexe
UPDATE Personne SET actif = TRUE WHERE salaire < 0 AND id > 0;

-- ============================================================================
-- SECTION 5 : Tests de DELETE
-- ============================================================================

-- Test 5.1 : DELETE avec WHERE simple
DELETE FROM Personne WHERE id = 3;

-- Test 5.2 : DELETE avec WHERE complexe
DELETE FROM Personne WHERE salaire < 0 OR actif = FALSE;

-- Test 5.3 : DELETE tous les enregistrements (sans WHERE)
DELETE FROM Test1;

-- ============================================================================
-- SECTION 6 : Tests de DROP TABLE
-- ============================================================================

-- Test 6.1 : DROP table existante
DROP TABLE Test1;

-- Test 6.2 : DROP table créée précédemment
DROP TABLE Simple;

-- ============================================================================
-- SECTION 7 : Tests avec Case-Insensitivity
-- ============================================================================

-- Test 7.1 : Minuscules
create table TestCase (id int);
insert into TestCase values (1);
select * from TestCase;

-- Test 7.2 : Mélange majuscules/minuscules
Select * From TestCase Where id = 1;
Update TestCase Set id = 2 Where id = 1;
Delete From TestCase;
Drop Table TestCase;

-- ============================================================================
-- SECTION 8 : Tests avec Commentaires
-- ============================================================================

-- Ceci est un commentaire sur une ligne
CREATE TABLE TestComments (id INT); -- Commentaire en fin de ligne

/* 
   Ceci est un commentaire
   sur plusieurs lignes
*/
SELECT * FROM TestComments;

/* Commentaire multiligne compact */ INSERT INTO TestComments VALUES (1);

DROP TABLE TestComments;

-- ============================================================================
-- FIN DES TESTS VALIDES
-- ============================================================================
