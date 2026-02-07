-- Test complet GLSimpleSQL
CREATE TABLE Etudiant (
    id INT,
    nom VARCHAR(50),
    age INT
);

INSERT INTO Etudiant VALUES (1, 'Diallo', 20);
INSERT INTO Etudiant (id, nom) VALUES (2, 'Sow');
SELECT * FROM Etudiant;
SELECT nom, age FROM Etudiant WHERE age > 18;
UPDATE Etudiant SET age = 21 WHERE id = 1;
DELETE FROM Etudiant WHERE age < 18;
DROP TABLE Etudiant;
