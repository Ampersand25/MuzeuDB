USE MuzeuDB
GO

CREATE OR ALTER PROCEDURE dbo.Deadlock2
AS
BEGIN
	SET DEADLOCK_PRIORITY LOW
	--SET DEADLOCK_PRIORITY HIGH

	BEGIN TRAN -- BEGIN TRANSACTION
	UPDATE [MuzeuDB].[dbo].[Vizitatori] SET Nume = 'Oprea', Prenume = 'Marius' WHERE NrLegitimatie = (SELECT TOP 1 NrLegitimatie FROM [MuzeuDB].[dbo].[Vizitatori] ORDER BY NrLegitimatie DESC)
	WAITFOR DELAY '00:00:05'
	UPDATE [MuzeuDB].[dbo].[Bijuterii] SET Material = 'Bronz' WHERE BijuterieID = (SELECT TOP 1 BijuterieID FROM [MuzeuDB].[dbo].[Bijuterii] ORDER BY BijuterieID DESC)
	COMMIT TRAN -- COMMIT TRANSACTION
END

GO

EXEC dbo.Deadlock2

SELECT * FROM [MuzeuDB].[dbo].[Bijuterii]
SELECT * FROM [MuzeuDB].[dbo].[Vizitatori]