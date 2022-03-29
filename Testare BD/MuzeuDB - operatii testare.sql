USE MuzeuDB
GO

IF OBJECT_ID('vw_GetRandomValue', 'V') IS NOT NULL
    DROP VIEW vw_GetRandomValue

GO

CREATE VIEW vw_GetRandomValue
AS
	SELECT [Random Value] = RAND()

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'FN' AND name = 'uf_GenerateString')
	DROP FUNCTION uf_GenerateString

GO

CREATE FUNCTION uf_GenerateString(@len TINYINT)
RETURNS VARCHAR(255) AS
BEGIN
	IF @len = 0
		RETURN ''

	DECLARE @str VARCHAR(255) = ''

	DECLARE @cont TINYINT = 0

	DECLARE @random TINYINT
	DECLARE @minRand TINYINT = 97
	DECLARE @maxRand TINYINT = 97 + 26 - 1

	WHILE @cont < @len
	BEGIN
		SET @random = (SELECT * FROM vw_GetRandomValue) * (@maxRand - @minRand) + @minRand
		IF @cont = 0
			SET @random = @random - 32
		SET @str = @str + CHAR(@random)
		
		SET @cont = @cont + 1
	END

	RETURN @str
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'FN' AND name = 'uf_GenerateName')
	DROP FUNCTION uf_GenerateName

GO

CREATE FUNCTION uf_GenerateName()
RETURNS VARCHAR(13) AS
BEGIN
	DECLARE @lenName TINYINT
	DECLARE @name VARCHAR(13) = ''

	DECLARE @random FLOAT
	DECLARE @minLenName TINYINT = 3
	DECLARE @maxLenName TINYINT = 13

	SELECT @random = [Random Value] FROM vw_GetRandomValue

	SET @lenName = @random * (@maxLenName - @minLenName) + @minLenName
	SET @name = dbo.uf_GenerateString(@lenName)

	RETURN @name
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_SelectFromViewGhizi')
	DROP PROCEDURE usp_SelectFromViewGhizi

GO

CREATE PROCEDURE usp_SelectFromViewGhizi
AS
	SELECT * FROM vw_Ghizi
	ORDER BY 'Nume ghid turistic', 'Prenume ghid turistic'

--GO

--EXEC usp_SelectFromViewGhizi

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_SelectFromViewFosileDinozauri')
	DROP PROCEDURE usp_SelectFromViewFosileDinozauri

GO

CREATE PROCEDURE usp_SelectFromViewFosileDinozauri
AS
	SELECT * FROM vw_FosileDinozauri
	ORDER BY Epoca ASC, 'Familie dinozaur' DESC, [Nume complet ghid]

--GO

--EXEC usp_SelectFromViewFosileDinozauri

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_SelectFromViewVizitatoriGhizi')
	DROP PROCEDURE usp_SelectFromViewVizitatoriGhizi

GO

CREATE PROCEDURE usp_SelectFromViewVizitatoriGhizi
AS
	SELECT * FROM vw_VizitatoriGhizi
	ORDER BY [Numar total vizitatori] DESC, [Varsta medie vizitatori] ASC

--GO

--EXEC usp_SelectFromViewVizitatoriGhizi

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_SelectFromViews')
	DROP PROCEDURE usp_SelectFromViews

GO

-- PROCEDURA STOCATA PENTRU OPERATIILE DE SELECTARE DIN VIEW-URI (EVALUARE)
CREATE PROCEDURE usp_SelectFromViews
AS
BEGIN
	EXEC usp_SelectFromViewGhizi
	EXEC usp_SelectFromViewFosileDinozauri
	EXEC usp_SelectFromViewVizitatoriGhizi
END

--GO

--EXEC usp_SelectFromViews

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DeleteFromGhizi')
	DROP PROCEDURE usp_DeleteFromGhizi

GO

CREATE PROCEDURE usp_DeleteFromGhizi
AS
BEGIN
	DELETE FROM Ghizi
	PRINT 'Au fost sterse ' + CONVERT(VARCHAR(MAX), @@ROWCOUNT) + ' inregistrari din tabelul/tabela <Ghizi>!'
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DeleteFromFosileDinozauri')
	DROP PROCEDURE usp_DeleteFromFosileDinozauri

GO

CREATE PROCEDURE usp_DeleteFromFosileDinozauri
AS
BEGIN
	--DELETE FROM StanduriDinozauri
	
	DELETE FROM FosileDinozauri
	PRINT 'Au fost sterse ' + CONVERT(VARCHAR(MAX), @@ROWCOUNT) + ' inregistrari din tabelul/tabela <FosileDinozauri>!'
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DeleteFromVizitatoriGhizi')
	DROP PROCEDURE usp_DeleteFromVizitatoriGhizi

GO

CREATE PROCEDURE usp_DeleteFromVizitatoriGhizi
AS
BEGIN
	DELETE FROM VizitatoriGhizi
	PRINT 'Au fost sterse ' + CONVERT(VARCHAR(MAX), @@ROWCOUNT) + ' inregistrari din tabelul/tabela <VizitatoriGhizi>!'
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DeleteFromTables')
	DROP PROCEDURE usp_DeleteFromTables

GO

-- PROCEDURA STOCATA PENTRU OPERATIILE DE STERGERE DIN TABELE
CREATE PROCEDURE usp_DeleteFromTables
AS
BEGIN
	DECLARE @deletedRowsTotal SMALLINT = 0

	EXEC usp_DeleteFromVizitatoriGhizi
	SET @deletedRowsTotal = @deletedRowsTotal + CONVERT(VARCHAR(MAX), @@ROWCOUNT)

	EXEC usp_DeleteFromFosileDinozauri
	SET @deletedRowsTotal = @deletedRowsTotal + CONVERT(VARCHAR(MAX), @@ROWCOUNT)

	EXEC usp_DeleteFromGhizi
	SET @deletedRowsTotal = @deletedRowsTotal + CONVERT(VARCHAR(MAX), @@ROWCOUNT)

	PRINT 'Au fost sterse in total: ' + CONVERT(VARCHAR(MAX), @deletedRowsTotal) + ' inregistrari din cele 3 tabele de test!'
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_InsertIntoGhizi')
	DROP PROCEDURE usp_InsertIntoGhizi

GO

CREATE PROCEDURE usp_InsertIntoGhizi(@numberOfRows SMALLINT)
AS
BEGIN
	IF @numberOfRows <= 0
		THROW 50002, '[X]Numar invalid de inregistrari!', 1

	DECLARE @cont SMALLINT
	SET @cont = 1

	DECLARE @pow10 BIGINT = 1000000000000
	IF (SELECT COUNT(*) FROM Ghizi) <> 0
		SET @pow10 = CONVERT(BIGINT, (SELECT MAX(CNPGhid) FROM Ghizi)) + 1

	DECLARE @minRand FLOAT = 1.60
	DECLARE @maxRand FLOAT = 1.95
	DECLARE @rand FLOAT

	DECLARE @cnpGhid CHAR(13)
	DECLARE @nume VARCHAR(50)
	DECLARE @prenume VARCHAR(50)
	DECLARE @inaltime FLOAT
	DECLARE @dataNasterii DATE

	WHILE @cont <= @numberOfRows
	BEGIN
		SET @cnpGhid = CONVERT(CHAR(13), @pow10 + @cont - 1)
		--SET @nume = 'Nume ghid ' + CONVERT(VARCHAR(MAX), @cont)
		SET @nume = dbo.uf_GenerateName()
		--SET @prenume = 'Prenume ghid ' + CONVERT(VARCHAR(MAX), @cont)
		SET @prenume = dbo.uf_GenerateName()

		SET @rand = RAND() * (@maxRand - @minRand) + @minRand
		SET @inaltime = FLOOR(@rand * 100) / 100.00

		SET @dataNasterii = DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 365 * 50) * -1, getdate()) --DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 65530), 0)

		INSERT INTO Ghizi(CNPGhid, Nume, Prenume, Inaltime, DataNasterii) VALUES
		(@cnpGhid, @nume, @prenume, @inaltime, @dataNasterii)

		SET @cont = @cont + 1
	END

	PRINT 'Au fost inserate ' + CONVERT(VARCHAR(MAX), @numberOfRows) + ' inregistrari in tabelul/tabela <Ghizi>'
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_InsertIntoFosileDinozauri')
	DROP PROCEDURE usp_InsertIntoFosileDinozauri

GO

CREATE PROCEDURE usp_InsertIntoFosileDinozauri(@numberOfRows SMALLINT)
AS
BEGIN
	IF @numberOfRows <= 0
		THROW 50002, '[X]Numar invalid de inregistrari!', 1

	DECLARE @cont SMALLINT
	SET @cont = 1

	DECLARE @rand TINYINT

	DECLARE @minOaseDino INT = 155
	DECLARE @maxOaseDino INT = 220

	DECLARE @fosilaDinozaurID INT = 0
	IF (SELECT COUNT(*) FROM FosileDinozauri) != 0
		SELECT @fosilaDinozaurID = MAX(FosilaDinozaurID) + 1 FROM FosileDinozauri

	DECLARE @tipDinozaur VARCHAR(50)
	DECLARE @familieDinozaur VARCHAR(50)
	DECLARE @epoca VARCHAR(50)
	DECLARE @nrOase INT
	DECLARE @cnpGhid VARCHAR(50)

	WHILE @cont <= @numberOfRows
	BEGIN
		SET @rand = CONVERT(INT, FLOOR(RAND() * 100) + 1)

		IF @rand % 6 = 0
		BEGIN
			SET @tipDinozaur = 'Tyrannosaurus ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
			SET @familieDinozaur = 'Tyrannosauridae ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
			SET @epoca = 'Cretacicului superior ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
		END
		ELSE IF @rand % 6 = 1
		BEGIN
			SET @tipDinozaur = 'Torosaurus ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
			SET @familieDinozaur = 'Ceratopsidae ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
			SET @epoca = 'Maastrichtiana ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
		END
		ELSE IF @rand % 6 = 2
		BEGIN
			SET @tipDinozaur = 'Rhamphorhynchus ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
			SET @familieDinozaur = 'Rhamphorhynchidae ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
			SET @epoca = 'Jurasicul tarziu ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
		END
		ELSE IF @rand % 6 = 3
		BEGIN
			SET @tipDinozaur = 'Mosasaurus ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
			SET @familieDinozaur = 'Mosasauridae ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
			SET @epoca = 'Cretacicului superior ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
		END
		ELSE IF @rand % 6 = 4
		BEGIN
			SET @tipDinozaur = 'Herrerasaurus ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
			SET @familieDinozaur = 'Herrerasauridae ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
			SET @epoca = 'Triassicul tarziu ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
		END
		ELSE
		BEGIN
			SET @tipDinozaur = 'Shantungosaurus ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
			SET @familieDinozaur = 'Hadrosauridae ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
			SET @epoca = 'Cretacicului superior ' + CONVERT(VARCHAR(MAX), @fosilaDinozaurID)
		END

		SET @nrOase = (@fosilaDinozaurID % (@maxOaseDino - @minOaseDino + 1)) + @minOaseDino
		SET @cnpGhid = (SELECT TOP(1) CNPGhid FROM Ghizi ORDER BY NEWID())
		
		INSERT INTO FosileDinozauri(FosilaDinozaurID, TipDinozaur, FamilieDinozaur, Epoca, NrOase, CNPGhid) VALUES
		(@fosilaDinozaurID, @tipDinozaur, @familieDinozaur, @epoca, @nrOase, @cnpGhid)
		
		SET @fosilaDinozaurID = @fosilaDinozaurID + 1
		SET @cont = @cont + 1
	END
	
	PRINT 'Au fost inserate ' + CONVERT(VARCHAR(MAX), @numberOfRows) + ' inregistrari in tabelul/tabela <FosileDinozauri>'
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_InsertIntoVizitatoriGhizi')
	DROP PROCEDURE usp_InsertIntoVizitatoriGhizi

GO

CREATE PROCEDURE usp_InsertIntoVizitatoriGhizi(@numberOfRows SMALLINT)
AS
BEGIN
	IF @numberOfRows <= 0
		THROW 50002, '[X]Numar invalid de inregistrari!', 1

	DECLARE @cont SMALLINT
	SET @cont = 1

	DECLARE @exist BIT

	DECLARE @minNrLegitimatieVizitator INT = (SELECT MIN(Vizitatori.NrLegitimatie) FROM Vizitatori)
	DECLARE @maxNrLegitimatieVizitator INT = (SELECT MAX(V.NrLegitimatie) FROM Vizitatori AS V)

	DECLARE @nrLegitimatieVizitator INT = @minNrLegitimatieVizitator
	DECLARE @cnpGhid VARCHAR(50)

	WHILE @cont <= @numberOfRows
	BEGIN
		SET @exist = 1
		
		WHILE @exist = 1
		BEGIN
			SET @cnpGhid = (SELECT TOP(1) CNPGhid FROM Ghizi ORDER BY NEWID())
			SELECT @exist = COUNT(*) FROM VizitatoriGhizi WHERE CNPGhid = @cnpGhid AND NrLegitimatie = @nrLegitimatieVizitator
		END

		INSERT INTO VizitatoriGhizi VALUES
		(@nrLegitimatieVizitator, @cnpGhid)

		IF @nrLegitimatieVizitator = @maxNrLegitimatieVizitator
			SET @nrLegitimatieVizitator = @minNrLegitimatieVizitator
		ELSE
			SET @nrLegitimatieVizitator = @nrLegitimatieVizitator + 1

		SET @cont = @cont + 1
	END
	
	PRINT 'Au fost inserate ' + CONVERT(VARCHAR(MAX), @numberOfRows) + ' inregistrari in tabelul/tabela <VizitatoriGhizi>'
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_InsertIntoTables')
	DROP PROCEDURE usp_InsertIntoTables

GO

-- PROCEDURA STOCATA PENTRU OPERATIILE DE INSERARE IN TABELE
CREATE PROCEDURE usp_InsertIntoTables(@numberOfRows SMALLINT)
AS
BEGIN
	IF @numberOfRows <= 0
		THROW 50002, '[X]Numar invalid de inregistrari!', 1

	EXEC usp_InsertIntoGhizi @numberOfRows
	EXEC usp_InsertIntoFosileDinozauri @numberOfRows
	EXEC usp_InsertIntoVizitatoriGhizi @numberOfRows
	
	--PRINT 'Au fost inserate ' + CONVERT(VARCHAR(4), @numberOfRows) + ' inregistrari in fiecare din cele 3 tabele de test'
END

GO

--EXEC usp_DeleteFromTables
--EXEC usp_InsertIntoTables 1000
--EXEC usp_SelectFromViews