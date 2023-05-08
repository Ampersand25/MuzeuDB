USE MuzeuDB
GO

CREATE OR ALTER FUNCTION uf_ValidareCuloare (@culoare VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @retval BIT = 1

    IF (@culoare IS NULL OR @culoare = '')
        SET @retval = 0

	RETURN @retval
END

GO

CREATE OR ALTER FUNCTION uf_ValidareMaterial (@material VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @retval BIT = 1

    IF (@material IS NULL OR @material = '')
        SET @retval = 0
	
    IF (@material NOT IN ('Ceramica', 'Argila', 'Lut'))
        SET @retval = 0;

	RETURN @retval
END

GO

CREATE OR ALTER FUNCTION uf_ValidareVechime (@vechime INT)
RETURNS BIT
AS
BEGIN
	DECLARE @retval BIT = 1

    IF (@vechime < 0)
        SET @retval = 0
	
    IF (@vechime < 100)
        SET @retval = 0;

	RETURN @retval
END

GO

CREATE OR ALTER FUNCTION uf_ValidareVitrinaID (@vitrinaID INT)
RETURNS BIT
AS
BEGIN
	DECLARE @retval BIT = 1

    IF (@vitrinaID < 1)
        SET @retval = 0
	
    IF (NOT EXISTS (SELECT *
					FROM [MuzeuDB].[dbo].[Vitrine]
					WHERE VitrinaID = @vitrinaID)
		)
        SET @retval = 0;

	RETURN @retval
END

GO

CREATE OR ALTER PROCEDURE sp_ValidareVas
@culoare VARCHAR(50), @material VARCHAR(50), @vechime INT, @vitrinaID INT
AS
BEGIN
	DECLARE @err VARCHAR(MAX) = ''

	IF (dbo.uf_ValidareCuloare(@culoare) = 0)
		SET @err = 'Culoare invalida!' + CHAR(13) + CHAR(10)

	IF (dbo.uf_ValidareMaterial(@material) = 0)
		SET @err = @err + 'Material invalid!' + CHAR(13) + CHAR(10)

	IF (dbo.uf_ValidareVechime(@vechime) = 0)
		SET @err = @err + 'Vechime invalida!' + CHAR(13) + CHAR(10)

	IF (dbo.uf_ValidareVitrinaID(@vitrinaID) = 0)
		SET @err = @err + 'VitrinaID invalid!' + CHAR(13) + CHAR(10)
	
	IF (LEN(@err) <> 0)
		RAISERROR(@err, 14, 1)
END

GO

-- INSERARE IN TABELUL/TABELA 'Vase'
CREATE OR ALTER PROCEDURE sp_InserareVase
@culoare VARCHAR(50), @material VARCHAR(50), @vechime INT, @vitrinaID INT
AS
BEGIN
	EXEC sp_ValidareVas @culoare, @material, @vechime, @vitrinaID
	
	DECLARE @vasID INT
	SELECT @vasID = MAX(VasID)
	FROM [MuzeuDB].[dbo].[Vase]
	SET @vasID = @vasID + 1
	
	INSERT INTO [MuzeuDB].[dbo].[Vase] (VasID, Culoare, Material, Vechime, VitrinaID) VALUES
	(@vasID, @culoare, @material, @vechime, @vitrinaID)
END

GO

CREATE OR ALTER FUNCTION uf_ValidareNume (@nume VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @retval BIT = 0
    
    IF (@nume IS NOT NULL AND LEN(@nume) <> 0 AND @nume LIKE '%[a-zA-Z]%' AND @nume NOT LIKE '%[^a-zA-Z]%')
        SET @retval = 1

	RETURN @retval
END

GO

CREATE OR ALTER FUNCTION uf_ValidarePrenume (@prenume VARCHAR(50))
RETURNS BIT
AS
BEGIN
    DECLARE @retval BIT = 0
    
    IF (@prenume IS NOT NULL AND LEN(@prenume) <> 0 AND @prenume LIKE '%[a-zA-Z]%' AND @prenume NOT LIKE '%[^a-zA-Z]%')
        SET @retval = 1

	RETURN @retval
END

GO

CREATE OR ALTER FUNCTION uf_ValidareVarsta (@varsta INT)
RETURNS BIT
AS
BEGIN
	DECLARE @retval BIT = 1

    IF (@varsta < 0)
        SET @retval = 0

	IF (@varsta NOT BETWEEN 3 AND 120)
		SET @retval = 0

	RETURN @retval
END

GO

CREATE OR ALTER PROCEDURE sp_ValidareVizitator
@nume VARCHAR(50), @prenume VARCHAR(50), @varsta INT
AS
BEGIN
	DECLARE @err VARCHAR(MAX) = ''

	IF (dbo.uf_ValidareNume(@nume) = 0)
		SET @err = 'Nume invalid!' + CHAR(13) + CHAR(10)

	IF (dbo.uf_ValidarePrenume(@prenume) = 0)
		SET @err = @err + 'Prenume invalid!' + CHAR(13) + CHAR(10)

	IF (dbo.uf_ValidareVarsta(@varsta) = 0)
		SET @err = @err + 'Varsta invalida!' + CHAR(13) + CHAR(10)
	
	IF (LEN(@err) <> 0)
		RAISERROR(@err, 14, 1)
END

GO

-- INSERARE IN TABELUL/TABELA 'Vizitatori'
CREATE OR ALTER PROCEDURE sp_InserareVizitatori
@nume VARCHAR(50), @prenume VARCHAR(50), @varsta INT
AS
BEGIN
	EXEC sp_ValidareVizitator @nume, @prenume, @varsta
	
	INSERT INTO [MuzeuDB].[dbo].[Vizitatori] (Prenume, Nume, Varsta) VALUES
	(@prenume, @nume, @varsta)
END

GO

-- INSERARE IN TABELUL/TABELA 'VizitatoriVase'
CREATE OR ALTER PROCEDURE sp_InserareVizitatoriVase
AS
BEGIN
	DECLARE @nrLegitimatie INT
	SELECT @nrLegitimatie = MAX(NrLegitimatie)
	FROM [MuzeuDB].[dbo].[Vizitatori]

	DECLARE @vasID INT
	SELECT @vasID = MAX(VasID)
	FROM [MuzeuDB].[dbo].[Vase]

	INSERT INTO [MuzeuDB].[dbo].[VizitatoriVase] (NrLegitimatie, VasID) VALUES
	(@nrLegitimatie, @vasID)
END

GO

CREATE OR ALTER PROCEDURE sp_InserareVaseVizitatori
@culoare VARCHAR(50), @material VARCHAR(50), @vechime INT, @vitrinaID INT,
@nume VARCHAR(50), @prenume VARCHAR(50), @varsta INT
AS
BEGIN
	BEGIN TRAN
	
	BEGIN TRY
		EXEC sp_InserareVase @culoare, @material, @vechime, @vitrinaID
		EXEC sp_InserareVizitatori @nume, @prenume, @varsta
		EXEC sp_InserareVizitatoriVase
		
		COMMIT TRAN
		PRINT '-----Transaction commited successfully-----'
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		PRINT 'Error Message: "' + ERROR_MESSAGE() + '"' + CHAR(13) + CHAR(10)
		PRINT '-----Transaction rollbacked-----'
	END CATCH
END

GO

CREATE OR ALTER PROCEDURE sp_StatusTabele
AS
BEGIN
	SELECT * FROM [MuzeuDB].[dbo].[Vase]
	SELECT * FROM [MuzeuDB].[dbo].[Vizitatori]
	SELECT * FROM [MuzeuDB].[dbo].[VizitatoriVase]
END

GO

CREATE OR ALTER PROCEDURE sp_InserareVaseVizitatoriWrapper
@culoare VARCHAR(50), @material VARCHAR(50), @vechime INT, @vitrinaID INT,
@nume VARCHAR(50), @prenume VARCHAR(50), @varsta INT
AS
BEGIN
	EXEC sp_StatusTabele
	EXEC sp_InserareVaseVizitatori @culoare, @material, @vechime, @vitrinaID, @nume, @prenume, @varsta
	EXEC sp_StatusTabele
END

GO

SELECT * FROM [MuzeuDB].[dbo].[Vitrine]

-- APELURI CU SUCCES
EXEC sp_InserareVaseVizitatoriWrapper 'Verde', 'Ceramica', 2375, 10, 'Jane', 'Doe', 45

-- APELURI FARA SUCCES
EXEC sp_InserareVaseVizitatoriWrapper '', 'Metal', -5, 0, 'Alice', 'James', 30
EXEC sp_InserareVaseVizitatoriWrapper 'Turcoaz', 'Argila', 1500, 20, 'Alice&', '^James', 150
EXEC sp_InserareVaseVizitatoriWrapper '', 'Metal', -5, 0, 'Alice&', '^James', 150