USE MuzeuDB
GO

CREATE OR ALTER PROCEDURE dbo.PhantomReads1
AS
BEGIN
	BEGIN TRAN -- BEGIN TRANSACTION
	WAITFOR DELAY '00:00:05'
	INSERT INTO Vase VALUES (400, 'Galben', 'Ceramica', 777, 1)
	COMMIT TRAN -- COMMIT TRANSACTION
END

GO

EXEC dbo.PhantomReads1