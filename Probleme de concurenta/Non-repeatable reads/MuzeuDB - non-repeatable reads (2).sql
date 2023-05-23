USE MuzeuDB
GO

CREATE OR ALTER PROCEDURE dbo.NonRepeatableReads2
@solve BIT
AS
BEGIN
	IF (@solve = 0)
		-- PROBLEM:
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	ELSE
		-- SOLUTION:
		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	
	BEGIN TRAN -- BEGIN TRANSATION
	SELECT * FROM [MuzeuDB].[dbo].[Vase]
	WAITFOR DELAY '00:00:10'
	SELECT * FROM [MuzeuDB].[dbo].[Vase]
	COMMIT TRAN -- COMMIT TRANSACTION
END

GO

-- CALL FOR PROBLEM
EXEC dbo.NonRepeatableReads2 0

-- CALL FOR SOLUTION
EXEC dbo.NonRepeatableReads2 1

SELECT * FROM [MuzeuDB].[dbo].[Vase]
DELETE FROM [MuzeuDB].[dbo].[Vase] WHERE VasID = 200
SELECT * FROM [MuzeuDB].[dbo].[Vase]