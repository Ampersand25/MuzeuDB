USE MuzeuDB
GO

CREATE OR ALTER PROCEDURE dbo.DirtyReads1
AS
BEGIN
	BEGIN TRAN -- BEGIN TRANSATION
	UPDATE [MuzeuDB].[dbo].[Vase] SET Culoare = 'Alb' WHERE VasID = 100
	WAITFOR DELAY '00:00:05'
	ROLLBACK TRAN -- ROLLBACK TRANSATION
END

GO

EXEC dbo.DirtyReads1