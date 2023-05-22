USE MuzeuDB
GO

-- PENTRU DIRTY READS, NON-REPEATABLE READS SI PHANTOM READS
SELECT * FROM [MuzeuDB].[dbo].[Vase]

DELETE FROM [MuzeuDB].[dbo].[Vase] WHERE VasID = 100

INSERT INTO [MuzeuDB].[dbo].[Vase] VALUES (100, 'Albastru', 'Lut', 99999, 5)

SELECT * FROM [MuzeuDB].[dbo].[Vase]

-- PENTRU DEADLOCK
SELECT * FROM [MuzeuDB].[dbo].[Bijuterii]
SELECT * FROM [MuzeuDB].[dbo].[Vizitatori]

DELETE FROM [MuzeuDB].[dbo].[Bijuterii] WHERE BijuterieID = (SELECT TOP 1 BijuterieID FROM [MuzeuDB].[dbo].[Bijuterii] ORDER BY BijuterieID DESC)
DELETE FROM [MuzeuDB].[dbo].[Vizitatori] WHERE NrLegitimatie = (SELECT TOP 1 NrLegitimatie FROM [MuzeuDB].[dbo].[Vizitatori] ORDER BY NrLegitimatie DESC)

INSERT INTO [MuzeuDB].[dbo].[Bijuterii] (Material, Valoare, CNPPaznic) VALUES ('Argint', 95725, 1930709813451)
INSERT INTO [MuzeuDB].[dbo].[Vizitatori] (Nume, Prenume, Varsta) VALUES ('Felecan', 'Mihai', 47)

SELECT * FROM [MuzeuDB].[dbo].[Bijuterii]
SELECT * FROM [MuzeuDB].[dbo].[Vizitatori]