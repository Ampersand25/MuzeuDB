USE MuzeuDB
GO

CREATE OR ALTER PROCEDURE dbo.PhantomReads2
@solve BIT
AS
BEGIN
	IF @solve = 0
		-- PROBLEM:
		SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	ELSE
		-- SOLUTION:
		SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	
	BEGIN TRAN -- BEGIN TRANSACTION
	SELECT * FROM [MuzeuDB].[dbo].[Vase]
	WAITFOR DELAY '00:00:10'
	SELECT * FROM [MuzeuDB].[dbo].[Vase]
	COMMIT TRAN -- COMMIT TRANSACTION
END

GO

-- CALL FOR PROBLEM
EXEC dbo.PhantomReads2 0

-- CALL FOR SOLUTION
EXEC dbo.PhantomReads2 1

SELECT * FROM [MuzeuDB].[dbo].[Vase]
DELETE FROM [MuzeuDB].[dbo].[Vase] WHERE VasID = 400
select * from [MuzeuDB].[dbo].[Vase]