USE MuzeuDB
GO

CREATE OR ALTER FUNCTION dbo.uf_ChecksThePattern (@str VARCHAR(MAX), @pattern VARCHAR(MAX))
RETURNS BIT
AS
BEGIN
    --IF @str NOT LIKE @pattern
    --    RETURN 0
    --RETURN 1

	IF @str LIKE @pattern
        RETURN 1
    RETURN 0
END

GO

CREATE OR ALTER FUNCTION dbo.uf_ContainsOnlyLettersAndSpaces (@str VARCHAR(MAX))
RETURNS BIT
AS
BEGIN
    DECLARE @pattern VARCHAR(50) = '%[^A-Za-z ]%'

	IF (dbo.uf_ChecksThePattern(@str, @pattern) = 1)
		RETURN 0
	RETURN 1
END

GO

CREATE OR ALTER FUNCTION dbo.uf_ContainsOnlyDigits (@str VARCHAR(MAX))
RETURNS BIT
AS
BEGIN
    DECLARE @pattern VARCHAR(50) = '%[^0-9]%'
    
    IF (dbo.uf_ChecksThePattern(@str, @pattern) = 0)
		RETURN 1
	RETURN 0
END

GO

CREATE OR ALTER FUNCTION dbo.uf_ValidareMaterialBijuterie (@material VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @valid BIT = 1

    IF (@material IS NULL OR LEN(@material) = 0)
        SET @valid = 0

	IF (dbo.uf_ContainsOnlyLettersAndSpaces(@material) <> 1) -- IF (dbo.uf_ContainsOnlyLettersAndSpaces(@material) != 1)
															 -- IF (dbo.uf_ContainsOnlyLettersAndSpaces(@material) = 0)
		SET @valid = 0
	
	IF (@material NOT IN ('Aur', 'Argint', 'Bronz', 'Alt material'))
        SET @valid = 0

	RETURN @valid
END

GO

CREATE OR ALTER FUNCTION dbo.uf_ValidareValoareBijuterie (@valoare INT)
RETURNS BIT
AS
BEGIN
	DECLARE @valid BIT = 1

    IF (@valoare < 0)
        SET @valid = 0
	
    IF (@valoare < 100)
        SET @valid = 0;

	RETURN @valid
END

GO

CREATE OR ALTER FUNCTION dbo.uf_ValidareCNPPaznic (@cnpPaznic VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @valid BIT = 1

    IF (@cnpPaznic IS NULL OR LEN(@cnpPaznic) = 0)
        SET @valid = 0

	IF (dbo.uf_ContainsOnlyDigits(@cnpPaznic) <> 1) -- IF (dbo.uf_ContainsOnlyDigits(@cnpPaznic) != 1)
													-- IF (dbo.uf_ContainsOnlyDigits(@cnpPaznic) = 0)
		SET @valid = 0
	
	IF (LEN(@cnpPaznic) != 13)
		SET @valid = 0

	RETURN @valid
END

GO

CREATE OR ALTER PROCEDURE dbo.sp_ValidareBijuterie
@material VARCHAR(50), @valoare INT, @cnpPaznic VARCHAR(50)
AS
BEGIN
	DECLARE @errors NVARCHAR(MAX) = ''

	IF (dbo.uf_ValidareMaterialBijuterie(@material) = 0)
		SET @errors = 'Material invalid!' + CHAR(13) + CHAR(10)

	IF (dbo.uf_ValidareValoareBijuterie(@valoare) = 0)
		SET @errors = @errors + 'Valoare invalida!' + CHAR(13) + CHAR(10)

	IF (dbo.uf_ValidareCNPPaznic(@cnpPaznic) = 0)
		SET @errors = @errors + 'CNP paznic invalid!' + CHAR(13) + CHAR(10)
	
	IF (LEN(@errors) <> 0) -- IF (LEN(@errorsString) != 0)
		RAISERROR(@errors, 14, 1)
END

GO

-- INSERARE IN TABELUL/TABELA 'Vizitatori'
CREATE OR ALTER PROCEDURE dbo.sp_InserareBijuterii
@material VARCHAR(50), @valoare INT, @cnpPaznic VARCHAR(50)
AS
BEGIN
	EXEC dbo.sp_ValidareBijuterie @material, @valoare, @cnpPaznic
	
	INSERT INTO [MuzeuDB].[dbo].[Bijuterii] (Material, Valoare, CNPPaznic) VALUES
	(@material, @valoare, @cnpPaznic)
END

GO

-- INSERARE IN TABELUL/TABELA 'VizitatoriVase'
CREATE OR ALTER PROCEDURE dbo.sp_InserareVizitatoriBijuterii
AS
BEGIN
	DECLARE @nrLegitimatie INT
	SELECT @nrLegitimatie = MAX(NrLegitimatie)
	FROM [MuzeuDB].[dbo].[Vizitatori]

	DECLARE @bijuterieID INT
	SELECT @bijuterieID = MAX(BijuterieID)
	FROM [MuzeuDB].[dbo].[Bijuterii]

	INSERT INTO [MuzeuDB].[dbo].[VizitatoriBijuterii] (NrLegitimatie, BijuterieID) VALUES
	(@nrLegitimatie, @bijuterieID)
END

GO

CREATE OR ALTER PROCEDURE dbo.sp_InserareBijuteriiVizitatori
@material VARCHAR(50), @valoare INT, @cnpPaznic VARCHAR(50),
@nume VARCHAR(50), @prenume VARCHAR(50), @varsta INT
AS
BEGIN
	-- FIRST TRANSACTION
	BEGIN TRANSACTION
	
	BEGIN TRY
		EXEC sp_InserareBijuterii @material, @valoare, @cnpPaznic
		
		COMMIT TRANSACTION
		PRINT '-----First transaction commited successfully-----'
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT 'First transaction error message: "' + ERROR_MESSAGE() + '"' + CHAR(13) + CHAR(10)
		PRINT '-----First transaction rollbacked-----'
	END CATCH

	-- SECOND TRANSACTION
	BEGIN TRANSACTION

	BEGIN TRY
		EXEC sp_InserareVizitatori @nume, @prenume, @varsta

		COMMIT TRANSACTION
		PRINT '-----Second transaction commited successfully-----'
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT 'Second transaction error message: "' + ERROR_MESSAGE() + '"' + CHAR(13) + CHAR(10)
		PRINT '-----Second transaction rollbacked-----'
	END CATCH

	-- THIRD TRANSACTION
	BEGIN TRANSACTION

	BEGIN TRY
		EXEC sp_InserareVizitatoriBijuterii

		COMMIT TRANSACTION
		PRINT '-----Third transaction commited successfully-----'
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT 'Third transaction error message: "' + ERROR_MESSAGE() + '"' + CHAR(13) + CHAR(10)
		PRINT '-----Third transaction rollbacked-----'
	END CATCH
END

GO

CREATE OR ALTER PROCEDURE dbo.sp_StatusTabele
AS
BEGIN
	SELECT * FROM [MuzeuDB].[dbo].[Bijuterii]
	SELECT * FROM [MuzeuDB].[dbo].[Vizitatori]
	SELECT * FROM [MuzeuDB].[dbo].[VizitatoriBijuterii]
END

GO

CREATE OR ALTER PROCEDURE dbo.sp_InserareBijuteriiVizitatoriWrapper
@material VARCHAR(50), @valoare INT, @cnpPaznic VARCHAR(50),
@nume VARCHAR(50), @prenume VARCHAR(50), @varsta INT
AS
BEGIN
	EXEC dbo.sp_StatusTabele
	EXEC dbo.sp_InserareBijuteriiVizitatori @material, @valoare, @cnpPaznic, @nume, @prenume, @varsta
	EXEC dbo.sp_StatusTabele
END

GO

SELECT * FROM [MuzeuDB].[dbo].[Paznici]

-- APELURI CU SUCCES
EXEC dbo.sp_InserareBijuteriiVizitatoriWrapper 'Bronz', 50000, '1800407860583', 'Sebastian', 'Vinicius', 32

-- APELURI FARA SUCCES
EXEC dbo.sp_InserareBijuteriiVizitatoriWrapper 'Alt material', 29815, '1670628732875', 'Geor(ge', 'Lap)orte', 2