USE MuzeuDB
GO

CREATE OR ALTER PROCEDURE dbo.NonRepeatableReads2
AS
BEGIN
	-- PROBLEM:
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	-- SOLUTION:
	--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	
	BEGIN TRAN -- BEGIN TRANSATION
	SELECT * FROM [MuzeuDB].[dbo].[Vase]
	WAITFOR DELAY '00:00:10'
	SELECT * FROM [MuzeuDB].[dbo].[Vase]
	COMMIT TRAN -- COMMIT TRANSACTION
END

GO

EXEC dbo.NonRepeatableReads2

SELECT * FROM [MuzeuDB].[dbo].[Vase]
DELETE FROM [MuzeuDB].[dbo].[Vase] WHERE VasID = 200
SELECT * FROM [MuzeuDB].[dbo].[Vase]