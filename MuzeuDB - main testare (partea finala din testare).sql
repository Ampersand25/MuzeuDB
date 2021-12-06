USE MuzeuDB
GO

/*
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_TestRunnerAllTables100')
	DROP PROCEDURE usp_TestRunnerAllTables100

GO

CREATE PROCEDURE usp_TestRunnerAllTables100
AS
BEGIN
	DECLARE @startTime DATETIME
	DECLARE @intermediateTime DATETIME
	DECLARE @finishTime DATETIME
	
	SET @startTime = GETDATE()
	EXEC usp_ExecuteOneTest 1
	EXEC usp_ExecuteOneTest 2
	SET @intermediateTime = GETDATE()

	EXEC usp_ExecuteOneTest 5
	SET @finishTime = GETDATE()

	INSERT INTO [dbo].[TestRuns] (Description, StartAt, EndAt) VALUES
	(N'Test care sterge toate inregistrarile din cele 3 tabele/tabeluri (Ghizi, FosileDinozauri si VizitatoriGhizi), insereaza 100 de inregistrari in acestea si evalueaza datele din cele 3 view-uri corespunzatoare tabelelor supuse testarii', @startTime, @finishTime)

	INSERT INTO dbo.[TestRunTables] (TestRunID, TableID, StartAt, EndAt) VALUES
	(1, 1, @startTime, @intermediateTime),
	(1, 2, @startTime, @intermediateTime),
	(1, 3, @startTime, @intermediateTime)

	INSERT INTO [dbo].TestRunViews VALUES
	(1, 1, @intermediateTime, @finishTime),
	(1, 2, @intermediateTime, @finishTime),
	(1, 3, @intermediateTime, @finishTime)
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_TestRunnerAllTables500')
	DROP PROCEDURE usp_TestRunnerAllTables500

GO

CREATE PROCEDURE usp_TestRunnerAllTables500
AS
BEGIN
	DECLARE @startTime DATETIME
	DECLARE @intermediateTime DATETIME
	DECLARE @finishTime DATETIME
	
	SET @startTime = GETDATE()
	EXEC usp_ExecuteOneTest 1
	EXEC usp_ExecuteOneTest 3
	SET @intermediateTime = GETDATE()

	EXEC usp_ExecuteOneTest 5
	SET @finishTime = GETDATE()

	INSERT INTO [dbo].[TestRuns] (Description, StartAt, EndAt) VALUES
	(N'Test care sterge toate inregistrarile din cele 3 tabele/tabeluri (Ghizi, FosileDinozauri si VizitatoriGhizi), insereaza 500 de inregistrari in acestea si evalueaza datele din cele 3 view-uri corespunzatoare tabelelor supuse testarii', @startTime, @finishTime)

	INSERT INTO dbo.[TestRunTables] (TestRunID, TableID, StartAt, EndAt) VALUES
	(2, 1, @startTime, @intermediateTime),
	(2, 2, @startTime, @intermediateTime),
	(2, 3, @startTime, @intermediateTime)

	INSERT INTO [dbo].TestRunViews VALUES
	(2, 1, @intermediateTime, @finishTime),
	(2, 2, @intermediateTime, @finishTime),
	(2, 3, @intermediateTime, @finishTime)
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_TestRunnerAllTables1000')
	DROP PROCEDURE usp_TestRunnerAllTables1000

GO

CREATE PROCEDURE usp_TestRunnerAllTables1000
AS
BEGIN
	DECLARE @startTime DATETIME
	DECLARE @intermediateTime DATETIME
	DECLARE @finishTime DATETIME
	
	SET @startTime = GETDATE()
	EXEC usp_ExecuteOneTest 1
	EXEC usp_ExecuteOneTest 4
	SET @intermediateTime = GETDATE()

	EXEC usp_ExecuteOneTest 5
	SET @finishTime = GETDATE()

	INSERT INTO [dbo].[TestRuns] (Description, StartAt, EndAt) VALUES
	(N'Test care sterge toate inregistrarile din cele 3 tabele/tabeluri (Ghizi, FosileDinozauri si VizitatoriGhizi), insereaza 1000 de inregistrari in acestea si evalueaza datele din cele 3 view-uri corespunzatoare tabelelor supuse testarii', @startTime, @finishTime)

	INSERT INTO dbo.[TestRunTables] (TestRunID, TableID, StartAt, EndAt) VALUES
	(3, 1, @startTime, @intermediateTime),
	(3, 2, @startTime, @intermediateTime),
	(3, 3, @startTime, @intermediateTime)

	INSERT INTO [dbo].TestRunViews VALUES
	(3, 1, @intermediateTime, @finishTime),
	(3, 2, @intermediateTime, @finishTime),
	(3, 3, @intermediateTime, @finishTime)
END

GO
*/

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_TestRunnerAllTables')
	DROP PROCEDURE usp_TestRunnerAllTables

GO

CREATE PROCEDURE usp_TestRunnerAllTables(@numberOfRecords INT)
AS
BEGIN
	IF @numberOfRecords <= 0
		THROW 50002, '[X]Numarul de inregistrari ce pot fi inserate trebuie sa fie un numar natural nenul!', 1

	IF @numberOfRecords NOT IN (100, 500, 1000)
		THROW 50003, '[X]Numar invalid de inregistrari!', 1

	DECLARE @startTime DATETIME
	DECLARE @intermediateTime DATETIME
	DECLARE @finishTime DATETIME
	
	SET @startTime = GETDATE()
	EXEC usp_ExecuteOneTest 1

	IF @numberOfRecords = 100
		EXEC usp_ExecuteOneTest 2
	ELSE IF @numberOfRecords = 500
		EXEC usp_ExecuteOneTest 3
	ELSE
		EXEC usp_ExecuteOneTest 4
	SET @intermediateTime = GETDATE()

	EXEC usp_ExecuteOneTest 5
	SET @finishTime = GETDATE()

	DECLARE @description NVARCHAR(2000)
	SET @description = N'Test care sterge toate inregistrarile din cele 3 tabele/tabeluri (Ghizi, FosileDinozauri si VizitatoriGhizi), insereaza ' + CONVERT(NVARCHAR(4), @numberOfRecords) + ' de inregistrari in acestea si evalueaza datele din cele 3 view-uri corespunzatoare tabelelor supuse testarii'

	INSERT INTO [dbo].[TestRuns] (Description, StartAt, EndAt) VALUES
	(@description, @startTime, @finishTime)

	--DECLARE @id INT
	--SET @id = (SELECT [TestRunID] FROM TestRuns WHERE Description = @description)

	DECLARE @id INT = @@IDENTITY

	INSERT INTO dbo.[TestRunTables] (TestRunID, TableID, StartAt, EndAt) VALUES
	(@id, 1, @startTime, @intermediateTime),
	(@id, 2, @startTime, @intermediateTime),
	(@id, 3, @startTime, @intermediateTime)

	INSERT INTO [dbo].TestRunViews (TestRunID, ViewID, StartAt, EndAt) VALUES
	(@id, 1, @intermediateTime, @finishTime),
	(@id, 2, @intermediateTime, @finishTime),
	(@id, 3, @intermediateTime, @finishTime)
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_TestRunnerOneTable')
	DROP PROCEDURE usp_TestRunnerOneTable

GO

CREATE PROCEDURE usp_TestRunnerOneTable(@tableName NVARCHAR(50), @numberOfRows SMALLINT)
AS
BEGIN
	IF LEN(@tableName) = 0
		THROW 50002, '[X]Numele tabelului nu poate sa fie vid!', 1

	IF @tableName NOT IN (N'Ghizi', N'FosileDinozauri', N'VizitatoriGhizi')
		THROW 50003, '[X]Tabelul specificat nu face parte din tabelele disponibile in configuratia de testare actuala!', 1

	IF @numberOfRows <= 0
		THROW 50004, '[X]Numarul de inregistrari ce pot fi inserate trebuie sa fie un numar natural nenul!', 1

	DECLARE @startTime DATETIME
	DECLARE @intermediateTime DATETIME
	DECLARE @finishTime DATETIME

	DECLARE @viewName NVARCHAR(50)
	
	SET @startTime = GETDATE()

	IF @tableName = N'Ghizi'
	BEGIN
		EXEC usp_DeleteFromGhizi
		EXEC usp_InsertIntoGhizi @numberOfRows

		SET @viewName = N'vw_Ghizi'
	END
	ELSE IF @tableName = N'FosileDinozauri'
	BEGIN
		EXEC usp_DeleteFromFosileDinozauri
		EXEC usp_InsertIntoFosileDinozauri @numberOfRows

		SET @viewName = N'vw_FosileDinozauri'
	END
	ELSE
	BEGIN
		EXEC usp_DeleteFromVizitatoriGhizi
		EXEC usp_InsertIntoVizitatoriGhizi @numberOfRows

		SET @viewName = N'vw_VizitatoriGhizi'
	END

	SET @intermediateTime = GETDATE()

	IF @tableName = N'Ghizi'
		EXEC usp_SelectFromViewGhizi
	ELSE IF @tableName = N'FosileDinozauri'
		EXEC usp_SelectFromViewFosileDinozauri
	ELSE
		EXEC usp_SelectFromViewVizitatoriGhizi

	SET @finishTime = GETDATE()

	DECLARE @description NVARCHAR(2000)
	SET @description = N'Test care sterge toate inregistrarile din tabelul/tabela ' + @tableName + ', insereaza ' + CONVERT(NVARCHAR(4), @numberOfRows) + ' de inregistrari in acest tabel si evalueaza datele din view-ul corespunzator'

	INSERT INTO [dbo].[TestRuns] (Description, StartAt, EndAt) VALUES
	(@description, @startTime, @finishTime)

	--DECLARE @id INT
	--SET @id = (SELECT [TestRunID] FROM TestRuns WHERE Description = @description)

	DECLARE @id INT = @@IDENTITY
	DECLARE @idTable INT = (SELECT TableID FROM [dbo].[Tables] WHERE Name = @tableName)
	DECLARE @idView INT = (SELECT ViewID FROM [dbo].[Views] WHERE Name = @viewName)

	INSERT INTO dbo.[TestRunTables] (TestRunID, TableID, StartAt, EndAt) VALUES
	(@id, @idTable, @startTime, @intermediateTime)

	INSERT INTO [dbo].TestRunViews (TestRunID, ViewID, StartAt, EndAt) VALUES
	(@id, @idView, @intermediateTime, @finishTime)
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_TestRunnerAllTablesMain')
	DROP PROCEDURE usp_TestRunnerAllTablesMain

GO

CREATE PROCEDURE usp_TestRunnerAllTablesMain
AS
BEGIN
	DELETE FROM [dbo].[TestRunTables]
	DELETE FROM [dbo].[TestRunViews]
	DELETE FROM [dbo].[TestRuns]

	-- Pentru toate tabelele
	--EXEC dbo.usp_TestRunnerAllTables 100
	--EXEC dbo.usp_TestRunnerAllTables 500
	--EXEC dbo.usp_TestRunnerAllTables 1000

	-- Pentru tabele particulare
	EXEC [dbo].[usp_TestRunnerOneTable] N'Ghizi', 100
	EXEC [dbo].[usp_TestRunnerOneTable] N'FosileDinozauri', 500
	EXEC [dbo].[usp_TestRunnerOneTable] N'VizitatoriGhizi', 1000

	SELECT * FROM TestRuns
	SELECT * FROM TestRunTables
	SELECT * FROM TestRunViews
END

GO

EXEC usp_TestRunnerAllTablesMain