USE MuzeuDB
GO

CREATE OR ALTER PROCEDURE dbo.Deadlock1
AS
BEGIN
	SET DEADLOCK_PRIORITY HIGH
	--SET DEADLOCK_PRIORITY LOW

	BEGIN TRAN -- BEGIN TRANSACTION
	UPDATE [MuzeuDB].[dbo].[Bijuterii] SET Material = 'Aur' WHERE BijuterieID = (SELECT TOP 1 BijuterieID FROM [MuzeuDB].[dbo].[Bijuterii] ORDER BY BijuterieID DESC)
	WAITFOR DELAY '00:00:05'
	UPDATE [MuzeuDB].[dbo].[Vizitatori] SET Nume = 'Plesa', Prenume = 'Raul' WHERE NrLegitimatie = (SELECT TOP 1 NrLegitimatie FROM [MuzeuDB].[dbo].[Vizitatori] ORDER BY NrLegitimatie DESC)
	COMMIT TRAN -- COMMIT TRANSACTION
END

GO

EXEC dbo.Deadlock1

SELECT * FROM [MuzeuDB].[dbo].[Bijuterii]
SELECT * FROM [MuzeuDB].[dbo].[Vizitatori]