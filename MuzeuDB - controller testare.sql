USE MuzeuDB
GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ValidateTestID')
	DROP PROCEDURE usp_ValidateTestID

GO

CREATE PROCEDURE usp_ValidateTestID(@testID INT)
AS
BEGIN
	DECLARE @MesajEroare VARCHAR(30)

	IF @testID <= 0
	BEGIN
		SET @MesajEroare = '[X]Id test invalid!';
		THROW 50002, @MesajEroare, 1
	END

	IF (SELECT COUNT(*) FROM [dbo].[Tests] WHERE TestID = @testID) = 0
	BEGIN
		SET @MesajEroare = '[X]Nu exista un test cu id-ul specificat!';
		THROW 50003, @MesajEroare, 1
	END
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_SelectFromGivenView')
	DROP PROCEDURE usp_SelectFromGivenView

GO

CREATE PROCEDURE usp_SelectFromGivenView(@nameView NVARCHAR(50))
AS
BEGIN
	IF @nameView = ''
		THROW 50002, '[X]Nume de view invalid!', 1

	IF (SELECT COUNT(*) FROM [sys].[views] AS V WHERE V.name = @nameView) = 0
		THROW 50003, '[X]Nu exista niciun view cu numele dat!', 1

	DECLARE @querySelectFromView NVARCHAR(MAX)
	SET @querySelectFromView = 'SELECT * FROM [dbo].[' + @nameView + ']'

	EXEC sp_executesql @querySelectFromView

	/*
	IF @nameView = 'vw_Ghizi'
		EXEC usp_SelectFromViewGhizi
	ELSE IF @nameView = 'vw_FosileDinozauri'
		EXEC usp_SelectFromViewFosileDinozauri
	ELSE IF @nameView = 'vw_VizitatoriGhizi'
		EXEC usp_SelectFromViewVizitatoriGhizi
	ELSE
		THROW 50003, '[X]Nu exista niciun view cu numele dat!', 1
	*/
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DeleteFromGivenTable')
	DROP PROCEDURE usp_DeleteFromGivenTable

GO

CREATE PROCEDURE usp_DeleteFromGivenTable(@nameTable NVARCHAR(50))
AS
BEGIN
	IF @nameTable = ''
		THROW 50002, '[X]Nume de tabel invalid!', 1

	IF (SELECT COUNT(*) FROM [sys].[tables] WHERE sys.tables.name = @nameTable) = 0
		THROW 50003, '[X]Nu exista niciun tabel cu numele dat!', 1

	DECLARE @queryDeleteFromTable NVARCHAR(MAX)
	SET @queryDeleteFromTable = 'DELETE FROM [dbo].[' + @nameTable + ']'

	EXEC sp_executesql @queryDeleteFromTable
	
	/*
	IF @nameTable = 'Ghizi'
		--DELETE FROM [dbo].[Ghizi]
		EXEC usp_DeleteFromGhizi
	ELSE IF @nameTable = 'FosileDinozauri'
		--DELETE FROM [dbo].[FosileDinozauri]
		EXEC usp_DeleteFromFosileDinozauri
	ELSE IF @nameTable = 'VizitatoriGhizi'
		--DELETE FROM [dbo].[VizitatoriGhizi]
		EXEC usp_DeleteFromVizitatoriGhizi
	ELSE
		THROW 50003, '[X]Nu exista niciun tabel cu numele dat!', 1
	*/
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_InsertIntoGivenTable')
	DROP PROCEDURE usp_InsertIntoGivenTable

GO

CREATE PROCEDURE usp_InsertIntoGivenTable(@nameTable NVARCHAR(50), @noOfRows SMALLINT)
AS
BEGIN
	DECLARE @err VARCHAR(50) = ''
	
	IF @nameTable = ''
		SET @err = '[X]Nume de tabel invalid!' + CHAR(13)
	
	IF @noOfRows <= 0
		SET @err = @err + '[X]Numar de inregistrari invalid!' + CHAR(13)

	IF LEN(@err) <> 0
		THROW 50002, @err, 1

	IF @nameTable = 'Ghizi'
		EXEC usp_InsertIntoGhizi @noOfRows
	ELSE IF @nameTable = 'FosileDinozauri'
		EXEC usp_InsertIntoFosileDinozauri @noOfRows
	ELSE IF @nameTable = 'VizitatoriGhizi'
		EXEC usp_InsertIntoVizitatoriGhizi @noOfRows
	ELSE
		THROW 50003, '[X]Nu exista niciun tabel cu numele dat!', 1
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ExecuteViewTests')
	DROP PROCEDURE usp_ExecuteViewTests

GO

CREATE PROCEDURE usp_ExecuteViewTests(@testID INT)
AS
BEGIN
	EXEC usp_ValidateTestID @testID

	PRINT '~~~View test(s)~~~' + CHAR(13)

	DECLARE @nameView NVARCHAR(50)
		
	DECLARE cursorTestViews CURSOR FAST_FORWARD FOR
	SELECT V.Name FROM [dbo].[Tests] T INNER JOIN [dbo].[TestViews] TV ON T.TestID = TV.TestID INNER JOIN [dbo].[Views] V ON TV.ViewID = V.ViewID
	WHERE T.TestID = @testID

	OPEN cursorTestViews
		
	FETCH NEXT FROM cursorTestViews INTO @nameView

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT '[?]Select from ' + @nameView + ' view!'

		EXEC usp_SelectFromGivenView @nameView
		
		FETCH NEXT FROM cursorTestViews INTO @nameView
	END

	CLOSE cursorTestViews
	DEALLOCATE cursorTestViews
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ExecuteDeleteTests')
	DROP PROCEDURE usp_ExecuteDeleteTests

GO

CREATE PROCEDURE usp_ExecuteDeleteTests(@testID INT)
AS
BEGIN
	EXEC usp_ValidateTestID @testID

	DECLARE @nameTable NVARCHAR(50)
	
	DECLARE cursorTestTables CURSOR FAST_FORWARD FOR
	SELECT TA.[Name] FROM [dbo].[Tests] AS T INNER JOIN [dbo].[TestTables] AS TT ON T.TestID = TT.TestID INNER JOIN [dbo].[Tables] AS TA ON TT.TableID = TA.TableID
	WHERE T.TestID = @testID
	ORDER BY TT.Position ASC

	OPEN cursorTestTables

	FETCH NEXT FROM cursorTestTables INTO @nameTable

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT '[-]Delete from ' + @nameTable + ' table!'

		EXEC usp_DeleteFromGivenTable @nameTable
			
		FETCH NEXT FROM cursorTestTables INTO @nameTable
	END

	CLOSE cursorTestTables
	DEALLOCATE cursorTestTables
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ExecuteInsertTests')
	DROP PROCEDURE usp_ExecuteInsertTests

GO

CREATE PROCEDURE usp_ExecuteInsertTests(@testID INT)
AS
BEGIN
	EXEC usp_ValidateTestID @testID

	DECLARE @nameTable NVARCHAR(50)
	DECLARE @noOfRows INT

	DECLARE cursorTestTables CURSOR FAST_FORWARD FOR
	SELECT TA.[Name], TT.[NoOfRows] FROM [dbo].[Tests] AS T INNER JOIN [dbo].[TestTables] AS TT ON T.TestID = TT.TestID INNER JOIN [dbo].[Tables] AS TA ON TT.TableID = TA.TableID
	WHERE T.TestID = @testID
	ORDER BY TT.Position DESC

	OPEN cursorTestTables

	FETCH NEXT FROM cursorTestTables INTO @nameTable, @noOfRows

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT '[+]Insert ' + CONVERT(VARCHAR(4), @noOfRows) + ' records into ' + @nameTable + ' table!'

		EXEC usp_InsertIntoGivenTable @nameTable, @noOfRows
			
		FETCH NEXT FROM cursorTestTables INTO @nameTable, @noOfRows
	END

	CLOSE cursorTestTables
	DEALLOCATE cursorTestTables
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ExecuteOneTest')
	DROP PROCEDURE usp_ExecuteOneTest

GO

CREATE PROCEDURE usp_ExecuteOneTest(@testID INT)
AS
BEGIN
	EXEC usp_ValidateTestID @testID

	IF (SELECT COUNT(*) FROM [dbo].[Tests] T INNER JOIN [dbo].[TestViews] TV ON T.TestID = TV.TestID INNER JOIN [dbo].[Views] V ON TV.ViewID = V.ViewID WHERE T.TestID = @testID) <> 0
		EXECUTE usp_ExecuteViewTests @testID
	ELSE
	BEGIN
		PRINT '~~~Insert/Delete test(s)~~~' + CHAR(13)

		DECLARE @nameTest NVARCHAR(50)
		SET @nameTest = (SELECT T.Name FROM [dbo].[Tests] T WHERE T.TestID = @testID)

		IF @nameTest = 'DeleteFromTables'
			EXEC usp_ExecuteDeleteTests @testID
		ELSE
			EXEC usp_ExecuteInsertTests @testID
	END
END

GO

IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ExecuteAllTests')
	DROP PROCEDURE usp_ExecuteAllTests

GO

CREATE PROCEDURE usp_ExecuteAllTests
AS
BEGIN
	DECLARE @testID INT
	DECLARE @name NVARCHAR(50)
	
	DECLARE cursorTests CURSOR FAST_FORWARD FOR
	SELECT * FROM Tests
	
	OPEN cursorTests

	FETCH NEXT FROM cursorTests INTO @testID, @name

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT CONVERT(CHAR(1), @testID) + ' - ' + @name
		EXEC usp_ExecuteOneTest @testID

		FETCH NEXT FROM cursorTests INTO @testID, @name
	END

	CLOSE cursorTests
	DEALLOCATE cursorTests
END

GO

--EXEC usp_ExecuteAllTests

--EXEC usp_ExecuteOneTest 1 -- delete
--EXEC usp_ExecuteOneTest 2 -- insert 100
--EXEC usp_ExecuteOneTest 3 -- insert 500
--EXEC usp_ExecuteOneTest 4 -- insert 1000
--EXEC usp_ExecuteOneTest 5 -- view

/*
DECLARE @deleteTestID INT = (SELECT MIN(TestID) FROM Tests)
DECLARE @insert100TestID INT = @deleteTestID + 1
DECLARE @insert500TestID INT = @insert100TestID + 1
DECLARE @insert1000TestID INT = @insert500TestID + 1
DECLARE @viewTestID INT = (SELECT MAX(TestID) FROM Tests)

--EXEC usp_ExecuteOneTest @deleteTestID     -- delete
--EXEC usp_ExecuteOneTest @insert100TestID  -- insert 100
--EXEC usp_ExecuteOneTest @insert500TestID  -- insert 500
--EXEC usp_ExecuteOneTest @insert1000TestID -- insert 1000
--EXEC usp_ExecuteOneTest @viewTestID       -- view
*/