USE MuzeuDB
GO

DELETE FROM [dbo].[TestViews]
DELETE FROM [dbo].[TestTables]
DELETE FROM [dbo].[Views]
DELETE FROM [dbo].[Tables]
DELETE FROM [dbo].[Tests]

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
	
	DECLARE @idTestView INT
	SELECT @idTestView = MAX([dbo].[Tests].[TestID]) FROM Tests

	DECLARE @idViewMin INT
	SET @idViewMin = (SELECT MIN(ViewID) FROM [dbo].[Views])

	DECLARE @idViewMax INT
	SET @idViewMax = (SELECT MAX(ViewID) FROM [dbo].[Views])

	WHILE @idViewMin <= @idViewMax
	BEGIN
		IF (SELECT COUNT(*) FROM [dbo].[Views] WHERE ViewID = @idViewMin) = 0
		BEGIN
			SET @idViewMin = @idViewMin + 1
			CONTINUE
		END

		INSERT INTO [TestViews] VALUES
		(@idTestView, @idViewMin)

		SET @idViewMin = @idViewMin + 1
	END

	/*
	INSERT INTO [TestViews] VALUES
	(@idTestView, @idViewMin + 0),
	(@idTestView, @idViewMin + 1),
	(@idTestView, @idViewMin + 2)
	*/
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

	DECLARE @idTestMin INT = (SELECT MIN(TestID) FROM [dbo].[Tests])

	DECLARE @idTableMin INT = (SELECT MIN(TableID) FROM [dbo].[Tables])
	
	INSERT INTO TestTables VALUES
	(@idTestMin + 0, @idTableMin + 0, NULL, 3), -- testul 1 (de stergere/delete) cu tabelul 1 (tabelul/tabela Ghizi cu PK si FK)
	(@idTestMin + 0, @idTableMin + 1, NULL, 2), -- testul 1 (de stergere/delete) cu tabelul 2 (tabelul/tabela FosileDinozauri cu PK si fara FK)
	(@idTestMin + 0, @idTableMin + 2, NULL, 1); -- testul 1 (de stergere/delete) cu tabelul 3 (tabelul/tabela de legatura (intermediara) VizitatoriGhizi cu doua PK)

	INSERT INTO TestTables(TestID, TableID, NoOfRows, Position) VALUES
	-- Pentru testul 2 (de inserare)
	(@idTestMin + 1, @idTableMin + 0, 100, 3),  -- testul 2 (de inserare/adaugare  100 de inregistrari/date/linii) in tabelul/tabela 1 (Ghizi)
	(@idTestMin + 1, @idTableMin + 1, 100, 2),  -- testul 2 (de inserare/adaugare  100 de inregistrari/date/linii) in tabelul/tabela 2 (FosileDinozauri)
	(@idTestMin + 1, @idTableMin + 2, 100, 1),  -- testul 2 (de inserare/adaugare  100 de inregistrari/date/linii) in tabelul/tabela 3 (VizitatoriGhizi)
	-- Pentru testul 3 (de inserare)
	(@idTestMin + 2, @idTableMin + 0, 500, 3),  -- testul 3 (de inserare/adaugare  500 de inregistrari/date/linii) in tabelul/tabela 1 (Ghizi)
	(@idTestMin + 2, @idTableMin + 1, 500, 2),  -- testul 3 (de inserare/adaugare  500 de inregistrari/date/linii) in tabelul/tabela 2 (FosileDinozauri)
	(@idTestMin + 2, @idTableMin + 2, 500, 1),  -- testul 3 (de inserare/adaugare  500 de inregistrari/date/linii) in tabelul/tabela 3 (VizitatoriGhizi)
	-- Pentru testul 4 (de inserare)
	(@idTestMin + 3, @idTableMin + 0, 1000, 3), -- testul 4 (de inserare/adaugare 1000 de inregistrari/date/linii) in tabelul/tabela 1 (Ghizi)
	(@idTestMin + 3, @idTableMin + 1, 1000, 2), -- testul 4 (de inserare/adaugare 1000 de inregistrari/date/linii) in tabelul/tabela 2 (FosileDinozauri)
	(@idTestMin + 3, @idTableMin + 2, 1000, 1); -- testul 4 (de inserare/adaugare 1000 de inregistrari/date/linii) in tabelul/tabela 3 (VizitatoriGhizi)
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