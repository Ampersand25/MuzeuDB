USE MuzeuDB
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateNumber', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateNumber]

GO

CREATE FUNCTION uf_ValidateNumber(@arg NVARCHAR(MAX))
RETURNS BIT AS
BEGIN
	RETURN ISNUMERIC(@arg)
END

GO





IF OBJECT_ID(N'dbo.uf_ValidateInteger', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateInteger]

GO

CREATE FUNCTION uf_ValidateInteger(@arg NVARCHAR(MAX))
RETURNS BIT AS
BEGIN
	IF TRY_CONVERT(INT, @arg) IS NULL
		RETURN 0

	RETURN 1
END

GO





IF OBJECT_ID(N'dbo.uf_ValidateNumberOfRecords', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateNumberOfRecords]

GO

CREATE FUNCTION uf_ValidateNumberOfRecords(@noOfRecords NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	IF dbo.uf_ValidateNumber(@noOfRecords) = 0
		RETURN '[X]Numarul de inregistrari nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@noOfRecords) = 0
		RETURN '[X]Numarul de inregistrari nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(INT, @noOfRecords) <= 0
		RETURN '[X]Numar de inregistrari invalid!' + CHAR(13) + CHAR(10)

	RETURN ''
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateVitrina', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateVitrina]

GO

CREATE FUNCTION uf_ValidateVitrina(@lungime NVARCHAR(MAX), @latime NVARCHAR(MAX), @inaltime NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX) = ''

	IF dbo.uf_ValidateNumber(@lungime) = 0
		SET @errors = @errors + '[X]Lungimea introdusa pentru vitrina nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@lungime) = 0
		SET @errors = @errors + '[X]Lungimea introdusa pentru vitrina nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE
	BEGIN
		DECLARE @lungimeToINT INT = CONVERT(INT, @lungime)

		IF @lungimeToINT !> 0
			SET @errors = '[X]Lungime vitrina invalida (trebuie > 0)!' + CHAR(13) + CHAR(10)
	END

	IF dbo.uf_ValidateNumber(@latime) = 0
		SET @errors = @errors + '[X]Latimea introdusa pentru vitrina nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@latime) = 0
		SET @errors = @errors + '[X]Latimea introdusa pentru vitrina nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE
	BEGIN
		DECLARE @latimeToINT INT = CONVERT(INT, @latime)

		IF @latimeToINT !> 0
			SET @errors = '[X]Latime vitrina invalida (trebuie > 0)!' + CHAR(13) + CHAR(10)
	END

	IF dbo.uf_ValidateNumber(@inaltime) = 0
		SET @errors = @errors + '[X]Inaltimea introdusa pentru vitrina nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@inaltime) = 0
		SET @errors = @errors + '[X]Inaltimea introdusa pentru vitrina nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE
	BEGIN
		DECLARE @inaltimeToINT INT = CONVERT(INT, @inaltime)

		IF @inaltimeToINT !> 0
			SET @errors = '[X]Inaltime vitrina invalida (trebuie > 0)!' + CHAR(13) + CHAR(10)
	END

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.usp_CreateForVitrine', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_CreateForVitrine]

GO

CREATE PROCEDURE usp_CreateForVitrine
(
	@lungime NVARCHAR(MAX),
	@latime NVARCHAR(MAX),
	@inaltime NVARCHAR(MAX),
	@noOfRecords NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX)

	SET @validMsg = dbo.uf_ValidateVitrina(@lungime, @latime, @inaltime)
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	SET @validMsg = dbo.uf_ValidateNumberOfRecords(@noOfRecords)
	IF LEN(@validMsg) <> 0
		THROW 50003, @validMsg, 1
	
	DECLARE @lungimeToINT INT = CONVERT(INT, @lungime)
	DECLARE @latimeToINT INT = CONVERT(INT, @latime)
	DECLARE @inaltimeToINT INT = CONVERT(INT, @inaltime)

	DECLARE @cont INT = 0
	DECLARE @noOfRecordsToINT INT = CONVERT(INT, @noOfRecords)

	WHILE @cont < @noOfRecordsToINT
	BEGIN
		INSERT INTO Vitrine(Lungime, Latime, Inaltime) VALUES
		(@lungimeToINT, @latimeToINT, @inaltimeToINT)

		SET @cont = @cont + 1
	END

	RETURN
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateText', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateText]

GO

CREATE FUNCTION uf_ValidateText(@string NVARCHAR(MAX))
RETURNS BIT AS
BEGIN
	IF LOWER(@string) LIKE '%[^abcdefghijklmnopqrstuvwxyz]%'
		RETURN 0

	RETURN 1
END

GO





IF OBJECT_ID(N'dbo.uf_GetMaterialVas', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_GetMaterialVas]

GO

CREATE FUNCTION uf_GetMaterialVas(@material VARCHAR(50))
RETURNS VARCHAR(50) AS
BEGIN
	DECLARE @materialLwr VARCHAR(MAX)
	SET @materialLwr = LOWER(@material)

	IF @materialLwr = 'ceramica'
		RETURN 'Ceramica'
	ELSE IF @materialLwr = 'argila'
		RETURN 'Argila'
	ELSE IF @materialLwr = 'lut'
		RETURN 'Lut'
	
	RETURN '[X]Material invalid!' + CHAR(13) + CHAR(10)
END

GO





IF OBJECT_ID(N'dbo.uf_ValidateVas', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateVas]

GO

CREATE FUNCTION uf_ValidateVas(@vasID NVARCHAR(MAX), @culoare NVARCHAR(MAX), @material NVARCHAR(MAX), @vechime NVARCHAR(MAX), @vitrinaID NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX)
	SET @errors = ''

	IF dbo.uf_ValidateNumber(@vasID) = 0
		SET @errors = @errors + '[X]ID-ul introdus pentru vas nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@vasID) = 0
		SET @errors = @errors + '[X]ID-ul introdus pentru vas nu este un numar intreg!' + CHAR(13) + CHAR(10)

	IF LEN(@culoare) = 0
		SET @errors = @errors + '[X]Culoarea introdusa pentru vas are lungime invalida (nu contine niciun caracter)!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(VARCHAR(MAX), @culoare) IS NULL
		SET @errors = @errors + '[X]Culoarea introdusa pentru vas este invalida ca si continut (contine si caractere speciale)!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateText(@culoare) = 0
		SET @errors = @errors + '[X]Culoarea introdusa pentru vas este invalida (nu contine doar litere)!' + CHAR(13) + CHAR(10)

	IF LEN(@material) = 0
		SET @errors = @errors + '[X]Materialul introdus pentru vas are lungime invalida (nu contine niciun caracter)!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(VARCHAR(MAX), @material) IS NULL
		SET @errors = @errors + '[X]Materialul introdus pentru vas este invalid ca si continut (contine si caractere speciale)!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateText(@material) = 0
		SET @errors = @errors + '[X]Materialul introdus pentru vas este invalid (nu contine doar litere)!' + CHAR(13) + CHAR(10)
	ELSE IF LOWER(@material) NOT IN (N'ceramica', N'argila', N'lut')
		SET @errors = @errors + '[X]Materialul introdus pentru vas este indisponibil (acesta trebuie sa fie: ceramica, argila sau lut)!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@vechime) = 0
		SET @errors = @errors + '[X]Vechimea introdusa pentru vas nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@vechime) = 0
		SET @errors = @errors + '[X]Vechimea introdusa pentru vas nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE
	BEGIN
		DECLARE @vechimeToINT INT = CONVERT(INT, @vechime)

		IF @vechimeToINT < 500
			SET @errors = '[X]Vechime vas invalida (trebuie >= 500)!' + CHAR(13) + CHAR(10)
	END

	IF dbo.uf_ValidateNumber(@vitrinaID) = 0
		SET @errors = @errors + '[X]ID-ul de vitrina introdus pentru vas nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@vitrinaID) = 0
		SET @errors = @errors + '[X]ID-ul de vitrina introdus pentru vas nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE
	BEGIN
		DECLARE @vitrinaIDToINT INT = CONVERT(INT, @vitrinaID)

		IF @vitrinaIDToINT < 1
			SET @errors = '[X]ID de vitrina pentru vas invalid (trebuie >= 1)!' + CHAR(13) + CHAR(10)
	END

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.usp_CreateForVase', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_CreateForVase]

GO

CREATE PROCEDURE usp_CreateForVase
(
	@vasID NVARCHAR(MAX),
	@culoare NVARCHAR(MAX),
	@material NVARCHAR(MAX),
	@vechime NVARCHAR(MAX),
	@vitrinaID NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX)

	SET @validMsg = dbo.uf_ValidateVas(@vasID, @culoare, @material, @vechime, @vitrinaID)
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @vasIDToINT INT = CONVERT(INT, @vasID)

	IF (SELECT COUNT(*) FROM Vase WHERE VasID = @vasIDToINT) <> 0
	BEGIN
		SET @validMsg = '[X]Exista deja un vas cu ID-ul introdus!' + CHAR(13) + CHAR(10);
		THROW 50003, @validMsg, 1
	END

	DECLARE @vitrinaIDToINT INT = CONVERT(INT, @vitrinaID)

	IF (SELECT COUNT(*) FROM Vitrine WHERE VitrinaID = @vitrinaIDToINT) = 0
	BEGIN
		SET @validMsg = '[X]Nu exista nicio vitrina cu ID-ul introdus!' + CHAR(13) + CHAR(10);
		THROW 50004, @validMsg, 1
	END

	DECLARE @culoareToVARCHAR50 VARCHAR(50) = CONVERT(VARCHAR(50), @culoare)
	DECLARE @materialToVARCHAR50 VARCHAR(50) = CONVERT(VARCHAR(50), @material)
	DECLARE @vechimeToINT INT = CONVERT(INT, @vechime)

	INSERT INTO Vase(VasID, Culoare, Material, Vechime, VitrinaID) VALUES
	(@vasIDToINT, @culoareToVARCHAR50, dbo.uf_getMaterialVas(@materialToVARCHAR50), @vechimeToINT, @vitrinaIDToINT)

	RETURN
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateVizitator', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateVizitator]

GO

CREATE FUNCTION uf_ValidateVizitator(@nume NVARCHAR(MAX), @prenume NVARCHAR(MAX), @varsta NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX) = ''

	IF LEN(@nume) = 0
		SET @errors = @errors + '[X]Numele introdus pentru vizitator are lungime invalida (nu contine niciun caracter)!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(VARCHAR(MAX), @nume) IS NULL
		SET @errors = @errors + '[X]Numele introdus pentru vizitator este invalid ca si continut (contine si caractere speciale)!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateText(@nume) = 0
		SET @errors = @errors + '[X]Numele introdus pentru vizitator este invalid (nu contine doar litere)!' + CHAR(13) + CHAR(10)

	IF LEN(@prenume) = 0
		SET @errors = @errors + '[X]Prenumele introdus pentru vizitator are lungime invalida (nu contine niciun caracter)!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(VARCHAR(MAX), @prenume) IS NULL
		SET @errors = @errors + '[X]Prenumele introdus pentru vizitator este invalid ca si continut (contine si caractere speciale)!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateText(@prenume) = 0
		SET @errors = @errors + '[X]Prenumele introdus pentru vizitator este invalid (nu contine doar litere)!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@varsta) = 0
		SET @errors = @errors + '[X]Varsta introdusa pentru vizitator nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@varsta) = 0
		SET @errors = @errors + '[X]Varsta introdusa pentru vizitator nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE
	BEGIN
		DECLARE @varstaToINT INT = CONVERT(INT, @varsta)

		IF @varstaToINT < 3
			SET @errors = '[X]Varsta vizitator invalida (trebuie >= 3)!' + CHAR(13) + CHAR(10)
	END

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.usp_CreateForVizitatori', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_CreateForVizitatori]

GO

CREATE PROCEDURE usp_CreateForVizitatori
(
	@nume NVARCHAR(MAX),
	@prenume NVARCHAR(MAX),
	@varsta NVARCHAR(MAX),
	@noOfRecords NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX)

	SET @validMsg = dbo.uf_ValidateVizitator(@nume, @prenume, @varsta)
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	SET @validMsg = dbo.uf_ValidateNumberOfRecords(@noOfRecords)
	IF LEN(@validMsg) <> 0
		THROW 50003, @validMsg, 1
	
	DECLARE @numeToVARCHAR50 VARCHAR(50) = CONVERT(VARCHAR(50), @nume)
	DECLARE @prenumeToVARCHAR50 INT = CONVERT(VARCHAR(50), @prenume)
	DECLARE @varstaToINT INT = CONVERT(INT, @varsta)

	DECLARE @cont INT = 0
	DECLARE @noOfRecordsToINT INT = CONVERT(INT, @noOfRecords)

	WHILE @cont < @noOfRecordsToINT
	BEGIN
		INSERT INTO Vizitatori(Nume, Prenume, Varsta) VALUES
		(@numeToVARCHAR50, @prenumeToVARCHAR50, @varstaToINT)

		SET @cont = @cont + 1
	END

	RETURN
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateVizitatorVas', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateVizitatorVas]

GO

CREATE FUNCTION uf_ValidateVizitatorVas(@nrLegitimatie NVARCHAR(MAX), @vasID NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX) = ''

	IF dbo.uf_ValidateNumber(@nrLegitimatie) = 0
		SET @errors = @errors + '[X]Numarul de legitimatie introdus pentru vizitator nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@nrLegitimatie) = 0
		SET @errors = @errors + '[X]Numarul de legitimatie introdus pentru vizitator nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE
	BEGIN
		DECLARE @nrLegitimatieToINT INT = CONVERT(INT, @nrLegitimatie)

		IF @nrLegitimatieToINT < 1
			SET @errors = '[X]Numar de legitimatie vizitator invalid (trebuie >= 1)!' + CHAR(13) + CHAR(10)
	END

	IF dbo.uf_ValidateNumber(@vasID) = 0
		SET @errors = @errors + '[X]ID-ul introdus pentru vas nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@vasID) = 0
		SET @errors = @errors + '[X]ID-ul introdus pentru vas nu este un numar intreg!' + CHAR(13) + CHAR(10)

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.usp_CreateForVizitatoriVase', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_CreateForVizitatoriVase]

GO

CREATE PROCEDURE usp_CreateForVizitatoriVase
(
	@nrLegitimatie NVARCHAR(MAX),
	@vasID NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX)

	SET @validMsg = dbo.uf_ValidateVizitatorVas(@nrLegitimatie, @vasID)
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @nrLegitimatieToINT INT = CONVERT(INT, @nrLegitimatie)
	DECLARE @vasIDToINT INT = CONVERT(INT, @vasID)

	IF (SELECT COUNT(*) FROM VizitatoriVase WHERE (NrLegitimatie = @nrLegitimatieToINT AND VasID = @vasIDToINT)) != 0
	BEGIN
		SET @validMsg = '[X]Exista deja o inregistrare cu acelasi numar de legitimatie pentru vizitator si ID pentru vas!' + CHAR(13) + CHAR(10);
		THROW 50003, @validMsg, 1
	END

	IF (SELECT COUNT(*) FROM Vizitatori WHERE NrLegitimatie = @nrLegitimatieToINT) = 0
	BEGIN
		SET @validMsg = '[X]Nu exista niciun vizitator cu numarul de legitimatie introdus!' + CHAR(13) + CHAR(10);
		THROW 50004, @validMsg, 1
	END

	IF (SELECT COUNT(*) FROM Vase WHERE VasID = @vasIDToINT) = 0
	BEGIN
		SET @validMsg = '[X]Nu exista niciun vas cu ID-ul introdus!' + CHAR(13) + CHAR(10);
		THROW 50005, @validMsg, 1
	END

	INSERT INTO VizitatoriVase(NrLegitimatie, VasID) VALUES
	(@nrLegitimatieToINT, @vasIDToINT)

	RETURN
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateStandDinozaur', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateStandDinozaur]

GO

CREATE FUNCTION uf_ValidateStandDinozaur(@material NVARCHAR(MAX), @lungime NVARCHAR(MAX), @latime NVARCHAR(MAX), @inaltime NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX) = ''

	IF LEN(@material) = 0
		SET @errors = @errors + '[X]Materialul introdus pentru suportul/platforma de dinozaur are lungime invalida (nu contine niciun caracter)!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(VARCHAR(MAX), @material) IS NULL
		SET @errors = @errors + '[X]Materialul introdus pentru suportul/platforma de dinozaur este invalid ca si continut (contine si caractere speciale)!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateText(@material) = 0
		SET @errors = @errors + '[X]Materialul introdus pentru suportul/platforma de dinozaur este invalid (nu contine doar litere)!' + CHAR(13) + CHAR(10)
	ELSE IF LOWER(@material) NOT IN (N'sticla', N'lemn', N'plastic')
		SET @errors = @errors + '[X]Materialul introdus pentru suportul/platforma de dinozaur este indisponibil (acesta trebuie sa fie: sticla, lemn sau plastic)!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@lungime) = 0
		SET @errors = @errors + '[X]Lungimea introdusa pentru suportul/platforma de dinozaur nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@lungime) = 0
		SET @errors = @errors + '[X]Lungimea introdusa pentru suportul/platforma de dinozaur nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE
	BEGIN
		DECLARE @lungimeToINT INT = CONVERT(INT, @lungime)

		IF @lungimeToINT !> 0
			SET @errors = '[X]Lungime stand de dinozaur invalida (trebuie > 0)!' + CHAR(13) + CHAR(10)
	END

	IF dbo.uf_ValidateNumber(@latime) = 0
		SET @errors = @errors + '[X]Latimea introdusa pentru suportul/platforma de dinozaur nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@latime) = 0
		SET @errors = @errors + '[X]Latimea introdusa pentru suportul/platforma de dinozaur nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE
	BEGIN
		DECLARE @latimeToINT INT = CONVERT(INT, @latime)

		IF @latimeToINT !> 0
			SET @errors = '[X]Latime stand de dinozaur invalida (trebuie > 0)!' + CHAR(13) + CHAR(10)
	END

	IF dbo.uf_ValidateNumber(@inaltime) = 0
		SET @errors = @errors + '[X]Inaltimea introdusa pentru suportul/platforma de dinozaur nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@inaltime) = 0
		SET @errors = @errors + '[X]Inaltimea introdusa pentru suportul/platforma de dinozaur nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE
	BEGIN
		DECLARE @inaltimeToINT INT = CONVERT(INT, @inaltime)

		IF @inaltimeToINT !> 0
			SET @errors = '[X]Inaltime stand de dinozaur invalida (trebuie > 0)!' + CHAR(13) + CHAR(10)
	END

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.uf_getMaterialStandDinozaur', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_getMaterialStandDinozaur]

GO

CREATE FUNCTION uf_getMaterialStandDinozaur(@material VARCHAR(50))
RETURNS VARCHAR(50) AS
BEGIN
	DECLARE @materialLwr VARCHAR(MAX)
	SET @materialLwr = LOWER(@material)

	IF @materialLwr = 'sticla'
		RETURN 'Sticla'
	ELSE IF @materialLwr = 'lemn'
		RETURN 'Lemn'
	ELSE IF @materialLwr = 'plastic'
		RETURN 'Plastic'
	
	RETURN '[X]Material invalid!' + CHAR(13) + CHAR(10)
END

GO





IF OBJECT_ID(N'dbo.usp_CreateForStanduriDinozauri', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_CreateForStanduriDinozauri]

GO

CREATE PROCEDURE usp_CreateForStanduriDinozauri
(
	@material NVARCHAR(MAX),
	@lungime NVARCHAR(MAX),
	@latime NVARCHAR(MAX),
	@inaltime NVARCHAR(MAX),
	@noOfRecords NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX)

	SET @validMsg = dbo.uf_ValidateStandDinozaur(@material, @lungime, @latime, @inaltime)
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	SET @validMsg = dbo.uf_ValidateNumberOfRecords(@noOfRecords)
	IF LEN(@validMsg) <> 0
		THROW 50003, @validMsg, 1
	
	DECLARE @materialToVARCHAR50 VARCHAR(50) = CONVERT(VARCHAR(50), @material)
	DECLARE @lungimeToINT INT = CONVERT(INT, @lungime)
	DECLARE @latimeToINT INT = CONVERT(INT, @latime)
	DECLARE @inaltimeToINT INT = CONVERT(INT, @inaltime)

	DECLARE @cont INT = 0
	DECLARE @noOfRecordsToINT INT = CONVERT(INT, @noOfRecords)

	WHILE @cont < @noOfRecordsToINT
	BEGIN
		INSERT INTO StanduriDinozauri(Material, Lungime, Latime, Inaltime) VALUES
		(dbo.uf_getMaterialStandDinozaur(@materialToVARCHAR50), @lungimeToINT, @latimeToINT, @inaltimeToINT)

		SET @cont = @cont + 1
	END

	RETURN
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------