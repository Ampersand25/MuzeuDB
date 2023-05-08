USE MuzeuDB
GO

CREATE OR ALTER FUNCTION uf_ValidareMaterialBijuterie (@material VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @retval BIT = 1

    IF (@material IS NULL OR @material = '')
        SET @retval = 0
	
	IF (@material NOT IN ('Aur', 'Argint', 'Bronz', 'Alt material'))
        SET @retval = 0

	RETURN @retval
END

GO

CREATE OR ALTER FUNCTION uf_ValidareValoareBijuterie (@valoare INT)
RETURNS BIT
AS
BEGIN
	DECLARE @retval BIT = 1

    IF (@valoare < 0)
        SET @retval = 0
	
    IF (@valoare < 100)
        SET @retval = 0;

	RETURN @retval
END

GO

CREATE OR ALTER FUNCTION uf_ValidareCNPPaznic (@cnpPaznic VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @retval BIT = 1

    IF (@cnpPaznic IS NULL OR @cnpPaznic = '')
        SET @retval = 0
	
	IF (LEN(@cnpPaznic) != 13)
		SET @retval = 0

	RETURN @retval
END

GO

CREATE OR ALTER PROCEDURE sp_ValidareBijuterie
@material VARCHAR(50), @valoare INT, @cnpPaznic VARCHAR(50)
AS
BEGIN
	DECLARE @err VARCHAR(MAX) = ''

	IF (dbo.uf_ValidareMaterialBijuterie(@material) = 0)
		SET @err = 'Material invalid!' + CHAR(13) + CHAR(10)

	IF (dbo.uf_ValidareValoareBijuterie(@valoare) = 0)
		SET @err = @err + 'Valoare invalida!' + CHAR(13) + CHAR(10)

	IF (dbo.uf_ValidareCNPPaznic(@cnpPaznic) = 0)
		SET @err = @err + 'CNP paznic invalid!' + CHAR(13) + CHAR(10)
	
	IF (LEN(@err) <> 0)
		RAISERROR(@err, 14, 1)
END

GO

-- INSERARE IN TABELUL/TABELA 'Vizitatori'
CREATE OR ALTER PROCEDURE sp_InserareBijuterii
@material VARCHAR(50), @valoare INT, @cnpPaznic VARCHAR(50)
AS
BEGIN
	EXEC sp_ValidareBijuterie @material, @valoare, @cnpPaznic
	
	INSERT INTO [MuzeuDB].[dbo].[Bijuterii] (Material, Valoare, CNPPaznic) VALUES
	(@material, @valoare, @cnpPaznic)
END

GO

-- INSERARE IN TABELUL/TABELA 'VizitatoriVase'
CREATE OR ALTER PROCEDURE sp_InserareVizitatoriBijuterii
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

CREATE OR ALTER PROCEDURE sp_InserareBijuteriiVizitatori
@material VARCHAR(50), @valoare INT, @cnpPaznic VARCHAR(50),
@nume VARCHAR(50), @prenume VARCHAR(50), @varsta INT
AS
BEGIN
	-- FIRST TRANSACTION
	BEGIN TRAN
	
	BEGIN TRY
		EXEC sp_InserareBijuterii @material, @valoare, @cnpPaznic
		
		COMMIT TRAN
		PRINT '-----First transaction commited successfully-----'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		PRINT 'First transaction error message: "' + ERROR_MESSAGE() + '"' + CHAR(13) + CHAR(10)
		PRINT '-----First transaction rollbacked-----'
	END CATCH

	-- SECOND TRANSACTION
	BEGIN TRAN

	BEGIN TRY
		EXEC sp_InserareVizitatori @nume, @prenume, @varsta

		COMMIT TRAN
		PRINT '-----Second transaction commited successfully-----'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		PRINT 'Second transaction error message: "' + ERROR_MESSAGE() + '"' + CHAR(13) + CHAR(10)
		PRINT '-----Second transaction rollbacked-----'
	END CATCH

	-- THIRD TRANSACTION
	BEGIN TRAN

	BEGIN TRY
		EXEC sp_InserareVizitatoriBijuterii

		COMMIT TRAN
		PRINT '-----Third transaction commited successfully-----'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		PRINT 'Third transaction error message: "' + ERROR_MESSAGE() + '"' + CHAR(13) + CHAR(10)
		PRINT '-----Third transaction rollbacked-----'
	END CATCH
END

GO

CREATE OR ALTER PROCEDURE sp_StatusTabele
AS
BEGIN
	SELECT * FROM [MuzeuDB].[dbo].[Bijuterii]
	SELECT * FROM [MuzeuDB].[dbo].[Vizitatori]
	SELECT * FROM [MuzeuDB].[dbo].[VizitatoriBijuterii]
END

GO

CREATE OR ALTER PROCEDURE sp_InserareBijuteriiVizitatoriWrapper
@material VARCHAR(50), @valoare INT, @cnpPaznic VARCHAR(50),
@nume VARCHAR(50), @prenume VARCHAR(50), @varsta INT
AS
BEGIN
	EXEC sp_StatusTabele
	EXEC sp_InserareBijuteriiVizitatori @material, @valoare, @cnpPaznic, @nume, @prenume, @varsta
	EXEC sp_StatusTabele
END

GO

SELECT * FROM [MuzeuDB].[dbo].[Paznici]

-- APELURI CU SUCCES
EXEC sp_InserareBijuteriiVizitatoriWrapper 'Bronz', 50000, '1800407860583', 'Sebastian', 'Vinicius', 32

-- APELURI FARA SUCCES
EXEC sp_InserareBijuteriiVizitatoriWrapper 'Alt material', 29815, '1670628732875', 'Geor(ge', 'Lap)orte', 2