USE MuzeuDB
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.usp_AddConstraintVase', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_AddConstraintVase]

GO

CREATE PROCEDURE usp_AddConstraintVase
AS
BEGIN
	IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS WHERE CONSTRAINT_NAME = 'ck_Vase_Culoare') <> 0
		ALTER TABLE Vase
		DROP CONSTRAINT ck_Vase_Culoare

	ALTER TABLE Vase
	ADD CONSTRAINT ck_Vase_Culoare CHECK (LEN(Culoare) > 0)

	IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS WHERE CONSTRAINT_NAME = 'ck_Vase_Vechime') <> 0
		ALTER TABLE Vase
		DROP CONSTRAINT ck_Vase_Vechime

	ALTER TABLE Vase
	ADD CONSTRAINT ck_Vase_Vechime CHECK (Vechime >= 500)

	IF OBJECT_ID(N'dbo.df_Vase_Vechime', N'D') IS NOT NULL 
		ALTER TABLE Vase
		DROP CONSTRAINT df_Vase_Vechime

	ALTER TABLE Vase
	ADD CONSTRAINT df_Vase_Vechime DEFAULT 500 FOR Vechime
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.usp_AddConstraintVizitatori', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_AddConstraintVizitatori]

GO

CREATE PROCEDURE usp_AddConstraintVizitatori
AS
BEGIN
	IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS WHERE CONSTRAINT_NAME = 'ck_Vizitatori_Nume') <> 0
		ALTER TABLE Vizitatori
		DROP CONSTRAINT ck_Vizitatori_Nume

	ALTER TABLE Vizitatori
	ADD CONSTRAINT ck_Vizitatori_Nume CHECK ((LOWER(Nume) NOT LIKE ('%[^abcdefghijklmnopqrstuvwxyz]%')) AND (Nume LIKE ('[ABCDEFGHIJKLMNOPQRSTUVWXYZ]__%')))

	IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS WHERE CONSTRAINT_NAME = 'ck_Vizitatori_Prenume') <> 0
		ALTER TABLE Vizitatori
		DROP CONSTRAINT ck_Vizitatori_Prenume

	ALTER TABLE Vizitatori
	ADD CONSTRAINT ck_Vizitatori_Prenume CHECK ((LOWER(Prenume) NOT LIKE ('%[^abcdefghijklmnopqrstuvwxyz]%')) AND (Prenume LIKE ('[ABCDEFGHIJKLMNOPQRSTUVWXYZ]__%')))

	IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS WHERE CONSTRAINT_NAME = 'ck_Vizitatori_Varsta') <> 0
		ALTER TABLE Vizitatori
		DROP CONSTRAINT ck_Vizitatori_Varsta

	ALTER TABLE Vizitatori
	ADD CONSTRAINT ck_Vizitatori_Varsta CHECK (Varsta BETWEEN 3 AND 100)

	IF OBJECT_ID(N'dbo.df_Vizitatori_Nume', N'D') IS NOT NULL 
		ALTER TABLE Vizitatori
		DROP CONSTRAINT df_Vizitatori_Nume

	ALTER TABLE Vizitatori
	ADD CONSTRAINT df_Vizitatori_Nume DEFAULT 'John' FOR Nume

	IF OBJECT_ID(N'dbo.df_Vizitatori_Prenume', N'D') IS NOT NULL 
		ALTER TABLE Vizitatori
		DROP CONSTRAINT df_Vizitatori_Prenume

	ALTER TABLE Vizitatori
	ADD CONSTRAINT df_Vizitatori_Prenume DEFAULT 'Smith' FOR Prenume

	IF OBJECT_ID(N'dbo.df_Vizitatori_Varsta', N'D') IS NOT NULL 
		ALTER TABLE Vizitatori
		DROP CONSTRAINT df_Vizitatori_Varsta

	ALTER TABLE Vizitatori
	ADD CONSTRAINT df_Vizitatori_Varsta DEFAULT 18 FOR Varsta
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.usp_AddConstraintsTables', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_AddConstraintsTables]

GO

CREATE PROCEDURE usp_AddConstraintsTables
AS
BEGIN
	EXEC usp_AddConstraintVase
	EXEC usp_AddConstraintVizitatori
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

--EXEC usp_AddConstraintVase
--EXEC usp_AddConstraintVizitatori
--EXEC usp_AddConstraintsTables