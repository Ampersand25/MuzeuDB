USE MuzeuDB
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_PopulateTables')
	DROP PROCEDURE usp_PopulateTables

GO

CREATE PROCEDURE usp_PopulateTables
AS
BEGIN
	DELETE FROM [Tables]
	
	INSERT INTO [dbo].[Tables] VALUES
	('Ghizi'),
	('FosileDinozauri'),
	('VizitatoriGhizi')
END

-----------------------
GO

EXEC usp_PopulateTables
-----------------------

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_CreateViews')
	DROP PROCEDURE usp_CreateViews

GO

IF OBJECT_ID('vw_Ghizi', 'V') IS NOT NULL
    DROP VIEW vw_Ghizi;

GO

CREATE VIEW vw_Ghizi AS
	SELECT CNPGhid AS 'CNP ghid turistic', [Nume ghid turistic] = Nume, Prenume AS 'Prenume ghid turistic', Inaltime, DataNasterii AS [Data de nastere]
	FROM Ghizi

--GO

--SELECT * FROM vw_Ghizi

GO

IF OBJECT_ID('vw_FosileDinozauri', 'V') IS NOT NULL
    DROP VIEW vw_FosileDinozauri

GO

CREATE VIEW vw_FosileDinozauri AS
	SELECT G.Nume + ' ' + G.Prenume AS 'Nume complet ghid', [Tip dinozaur] = FD.TipDinozaur, FD.Epoca, FD.FamilieDinozaur AS [Familie dinozaur], FD.NrOase AS 'Numar oase dinozaur'
	FROM FosileDinozauri AS FD INNER JOIN Ghizi AS G ON FD.CNPGhid = G.CNPGhid
	--WHERE FD.Epoca IS NOT NULL AND FD.FamilieDinozaur IS NOT NULL AND (FD.TipDinozaur LIKE '%urus' OR FD.TipDinozaur NOT LIKE '%us')

--GO

--SELECT * FROM vw_FosileDinozauri

GO

IF OBJECT_ID('vw_VizitatoriGhizi', 'V') IS NOT NULL
    DROP VIEW vw_VizitatoriGhizi

GO

CREATE VIEW vw_VizitatoriGhizi AS
	SELECT [Nume ghid turistic] = G.Nume + ' ' + G.Prenume, COUNT(V.NrLegitimatie) AS 'Numar total vizitatori', AVG(V.Varsta) AS 'Varsta medie vizitatori', MIN(V.Varsta) AS [Cel mai tanar vizitator], [Cel mai batran vizitator] = MAX(V.Varsta)
	FROM Ghizi G FULL OUTER JOIN VizitatoriGhizi VG ON G.CNPGhid = VG.CNPGhid FULL OUTER JOIN Vizitatori V ON VG.NrLegitimatie = V.NrLegitimatie
	--FROM Ghizi G INNER JOIN VizitatoriGhizi VG ON G.CNPGhid = VG.CNPGhid INNER JOIN Vizitatori V ON VG.NrLegitimatie = V.NrLegitimatie
	--WHERE V.Varsta >= 18
	GROUP BY G.Nume, G.Prenume

--GO

--SELECT * FROM vw_VizitatoriGhizi

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_PopulateViews')
	DROP PROCEDURE usp_PopulateViews

GO

CREATE PROCEDURE usp_PopulateViews
AS
BEGIN
	DELETE FROM [dbo].[Views]
	
	INSERT INTO [Views] VALUES
	('vw_Ghizi'),
	('vw_FosileDinozauri'),
	('vw_VizitatoriGhizi')
END

----------------------
GO

EXEC usp_PopulateViews
----------------------

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_PopulateTests')
	DROP PROCEDURE usp_PopulateTests

GO

CREATE PROCEDURE usp_PopulateTests
AS
BEGIN
	DELETE FROM [dbo].[Tests]
	
	INSERT INTO [dbo].[Tests] VALUES
	('DeleteFromTables'),
	('InsertIntoTables100'),
	('InsertIntoTables500'),
	('InsertIntoTables1000'),
	('SelectFromViews')
END

----------------------
GO

EXEC usp_PopulateTests
----------------------

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_PopulateTestViews')
	DROP PROCEDURE usp_PopulateTestViews

GO

CREATE PROCEDURE usp_PopulateTestViews
AS
BEGIN
	DELETE FROM [TestViews]
	
	INSERT INTO [TestViews] VALUES
	(5, 1),
	(5, 2),
	(5, 3)
END

--------------------------
GO

EXEC usp_PopulateTestViews
--------------------------

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_PopulateTestTables')
	DROP PROCEDURE usp_PopulateTestTables

GO

CREATE PROCEDURE usp_PopulateTestTables
AS
BEGIN
	DELETE FROM TestTables
	
	INSERT INTO TestTables VALUES
	(1, 1, NULL, 3), -- testul 1 (de stergere/delete) cu tabelul 1 (tabelul/tabela Ghizi cu PK si FK)
	(1, 2, NULL, 2), -- testul 1 (de stergere/delete) cu tabelul 2 (tabelul/tabela FosileDinozauri cu PK si fara FK)
	(1, 3, NULL, 1)  -- testul 1 (de stergere/delete) cu tabelul 3 (tabelul/tabela de legatura (intermediara) VizitatoriGhizi cu doua PK)

	INSERT INTO TestTables(TestID, TableID, NoOfRows, Position) VALUES
	-- Pentru testul 2 (de inserare)
	(2, 1, 100, 3),  -- testul 2 (de inserare/adaugare  100 de inregistrari/date/linii) in tabelul/tabela 1 (Ghizi)
	(2, 2, 100, 2),  -- testul 2 (de inserare/adaugare  100 de inregistrari/date/linii) in tabelul/tabela 2 (FosileDinozauri)
	(2, 3, 100, 1),  -- testul 2 (de inserare/adaugare  100 de inregistrari/date/linii) in tabelul/tabela 3 (VizitatoriGhizi)
	-- Pentru testul 3 (de inserare)
	(3, 1, 500, 3),  -- testul 3 (de inserare/adaugare  500 de inregistrari/date/linii) in tabelul/tabela 1 (Ghizi)
	(3, 2, 500, 2),  -- testul 3 (de inserare/adaugare  500 de inregistrari/date/linii) in tabelul/tabela 2 (FosileDinozauri)
	(3, 3, 500, 1),  -- testul 3 (de inserare/adaugare  500 de inregistrari/date/linii) in tabelul/tabela 3 (VizitatoriGhizi)
	-- Pentru testul 4 (de inserare)
	(4, 1, 1000, 3), -- testul 4 (de inserare/adaugare 1000 de inregistrari/date/linii) in tabelul/tabela 1 (Ghizi)
	(4, 2, 1000, 2), -- testul 4 (de inserare/adaugare 1000 de inregistrari/date/linii) in tabelul/tabela 2 (FosileDinozauri)
	(4, 3, 1000, 1)  -- testul 4 (de inserare/adaugare 1000 de inregistrari/date/linii) in tabelul/tabela 3 (VizitatoriGhizi)
END

---------------------------
GO

EXEC usp_PopulateTestTables
---------------------------

GO

SELECT * FROM [dbo].[Tables]
SELECT * FROM [dbo].[Views]
SELECT * FROM [dbo].[Tests]
SELECT * FROM [dbo].[TestTables]
SELECT * FROM [dbo].[TestViews]