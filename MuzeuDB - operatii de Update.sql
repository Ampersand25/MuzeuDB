USE MuzeuDB
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateUpdateForVitrine', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateUpdateForVitrine]

GO

CREATE FUNCTION uf_ValidateUpdateForVitrine(@oldLen NVARCHAR(MAX), @newLen NVARCHAR(MAX), @typeLungimeLatimeInaltime NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX)
	SET @errors = ''

	IF dbo.uf_ValidateNumber(@oldLen) = 0
		SET @errors = @errors + '[X]Primul argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@oldLen) = 0
		SET @errors = @errors + '[X]Primul argument nu este un numar intreg!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@newLen) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@newLen) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(INT, @newLen) !> 0
		SET @errors = @errors + '[X]Al doilea argument nu este valid (trebuie > 0)!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@typeLungimeLatimeInaltime) = 0
		SET @errors = @errors + '[X]Al treilea argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@typeLungimeLatimeInaltime) = 0
		SET @errors = @errors + '[X]Al treilea argument nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(INT, @typeLungimeLatimeInaltime) NOT IN (0, 1, 2)
		SET @errors = @errors + '[X]Al treilea argument nu este valid (0, 1 sau 2)!' + CHAR(13) + CHAR(10)

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.usp_UpdateForVitrine', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_UpdateForVitrine]

GO

CREATE PROCEDURE usp_UpdateForVitrine(@oldLen NVARCHAR(MAX), @newLen NVARCHAR(MAX), @typeLungimeLatimeInaltime NVARCHAR(MAX))
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX) = dbo.uf_ValidateUpdateForVitrine(@oldLen, @newLen, @typeLungimeLatimeInaltime)
	
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @oldLenToINT INT = CONVERT(INT, @oldLen)
	DECLARE @newLenToINT INT = CONVERT(INT, @newLen)
	DECLARE @typeLungimeLatimeInaltimeToTINYINT TINYINT = CONVERT(TINYINT, @typeLungimeLatimeInaltime)
	
	IF @typeLungimeLatimeInaltimeToTINYINT = 0
		UPDATE Vitrine SET Lungime = @newLenToINT
		WHERE Lungime = @oldLenToINT
	ELSE IF @typeLungimeLatimeInaltimeToTINYINT = 1
		UPDATE Vitrine SET Latime = @newLenToINT
		WHERE Latime = @oldLenToINT
	ELSE
		UPDATE Vitrine SET Inaltime = @newLenToINT
		WHERE Inaltime = @oldLenToINT
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateUpdateForVase', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateUpdateForVase]

GO

CREATE FUNCTION uf_ValidateUpdateForVase(@culoare NVARCHAR(MAX), @newMaterial NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX)
	SET @errors = ''

	IF LEN(@culoare) = 0
		SET @errors = @errors + '[X]Primul argument are lungime invalida (trebuie sa contina cel putin un caracter)!' + CHAR(13) + CHAR(10)
	ELSE IF TRY_CONVERT(VARCHAR(MAX), @culoare) IS NULL
		SET @errors = @errors + '[X]Primul argument este invalid ca si continut (contine si caractere speciale)!' + CHAR(13) + CHAR(10)

	IF LEN(@newMaterial) = 0 OR LEN(@newMaterial) > 50
		SET @errors = @errors + '[X]Al doilea argument are lungime invalida (trebuie sa contina cel putin un caracter si cel mult 50)!' + CHAR(13) + CHAR(10)
	ELSE IF TRY_CONVERT(VARCHAR(50), @newMaterial) IS NULL
		SET @errors = @errors + '[X]Al doilea argument este invalid ca si continut (contine si caractere speciale)!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(VARCHAR(50), @newMaterial) NOT IN ('Ceramica', 'Argila', 'Lut')
		SET @errors = @errors + '[X]Al doilea argument nu este valid (material indisponibil)!' + CHAR(13) + CHAR(10)

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.usp_UpdateForVase', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_UpdateForVase]

GO

CREATE PROCEDURE usp_UpdateForVase(@culoare NVARCHAR(MAX), @newMaterial NVARCHAR(MAX))
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX) = dbo.uf_ValidateUpdateForVase(@culoare, @newMaterial)
	
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @culoareToVARCHARMAX VARCHAR(MAX) = CONVERT(VARCHAR(MAX), @culoare)
	DECLARE @newMaterialToVARCHAR50 VARCHAR(50) = CONVERT(VARCHAR(50), @newMaterial)
	
	UPDATE Vase SET Material = @newMaterialToVARCHAR50
	WHERE Culoare = @culoareToVARCHARMAX
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.usp_UpdateForVizitatoriVase', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_UpdateForVizitatoriVase]

GO

CREATE PROCEDURE usp_UpdateForVizitatoriVase
AS
	PRINT '[!]Nu se poate face update pe tabelul/tabela VizitatoriVase (tabela intermediara, adica de legatura)' + CHAR(13) + CHAR(10)

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateUpdateForVizitatori', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateUpdateForVizitatori]

GO

CREATE FUNCTION uf_ValidateUpdateForVizitatori(@nrLegitimatie NVARCHAR(MAX), @newNume NVARCHAR(MAX), @newVarstaUnit NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX)
	SET @errors = ''

	IF dbo.uf_ValidateNumber(@nrLegitimatie) = 0
		SET @errors = @errors + '[X]Primul argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@nrLegitimatie) = 0
		SET @errors = @errors + '[X]Primul argument nu este un numar intreg!' + CHAR(13) + CHAR(10)

	IF LEN(@newNume) < 3
		SET @errors = @errors + '[X]Al doilea argument are lungime invalida (trebuie sa contina cel putin 3 caractere)!' + CHAR(13) + CHAR(10)
	ELSE IF TRY_CONVERT(VARCHAR(MAX), @newNume) IS NULL
		SET @errors = @errors + '[X]Al doilea argument este invalid ca si continut (contine si caractere speciale)!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@newVarstaUnit) = 0
		SET @errors = @errors + '[X]Al treilea argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@newVarstaUnit) = 0
		SET @errors = @errors + '[X]Al treilea argument nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(INT, @newVarstaUnit) NOT IN (0, 1)
		SET @errors = @errors + '[X]Al treilea argument nu este valid (0 sau 1)!' + CHAR(13) + CHAR(10)

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.usp_UpdateForVizitatori', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_UpdateForVizitatori]

GO

CREATE PROCEDURE usp_UpdateForVizitatori(@nrLegitimatie NVARCHAR(MAX), @newNume NVARCHAR(MAX), @newVarstaUnit NVARCHAR(MAX))
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX) = dbo.uf_ValidateUpdateForVizitatori(@nrLegitimatie, @newNume, @newVarstaUnit)
	
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @nrLegitimatieToINT INT = CONVERT(INT, @nrLegitimatie)
	DECLARE @newNumeToVARCHAR50 VARCHAR(50) = CONVERT(VARCHAR(50), @newNume)
	DECLARE @newVarstaUnitToBIT BIT = CONVERT(BIT, @newVarstaUnit)
	
	UPDATE Vizitatori SET Nume = @newNumeToVARCHAR50, Varsta = Varsta + @newVarstaUnitToBIT
	WHERE NrLegitimatie = @nrLegitimatieToINT
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateUpdateForStanduriDinozauri', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateUpdateForStanduriDinozauri]

GO

CREATE FUNCTION uf_ValidateUpdateForStanduriDinozauri(@newMaterial NVARCHAR(MAX), @lungime NVARCHAR(MAX), @latime NVARCHAR(MAX), @inaltime NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX)
	SET @errors = ''

	IF LEN(@newMaterial) = 0 OR LEN(@newMaterial) > 50
		SET @errors = @errors + '[X]Primul argument are lungime invalida (trebuie sa contina cel putin un caracter si cel mult 50)!' + CHAR(13) + CHAR(10)
	ELSE IF TRY_CONVERT(VARCHAR(MAX), @newMaterial) IS NULL
		SET @errors = @errors + '[X]Primul argument este invalid ca si continut (contine si caractere speciale)!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(VARCHAR(50), @newMaterial) NOT IN ('Sticla', 'Lemn', 'Plastic')
		SET @errors = @errors + '[X]Primul argument nu este valid (material indisponibil)!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@lungime) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@lungime) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este un numar intreg!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@latime) = 0
		SET @errors = @errors + '[X]Al treilea argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@latime) = 0
		SET @errors = @errors + '[X]Al treilea argument nu este un numar intreg!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@inaltime) = 0
		SET @errors = @errors + '[X]Al patrulea argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@inaltime) = 0
		SET @errors = @errors + '[X]Al patrulea argument nu este un numar intreg!' + CHAR(13) + CHAR(10)

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.usp_UpdateForStanduriDinozauri', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_UpdateForStanduriDinozauri]

GO

CREATE PROCEDURE usp_UpdateForStanduriDinozauri(@newMaterial NVARCHAR(MAX), @lungime NVARCHAR(MAX), @latime NVARCHAR(MAX), @inaltime NVARCHAR(MAX))
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX) = dbo.uf_ValidateUpdateForStanduriDinozauri(@newMaterial, @lungime, @latime, @inaltime)
	
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @newMaterialToVARCHAR50 VARCHAR(50) = CONVERT(VARCHAR(50), @newMaterial)
	DECLARE @lungimeToINT INT = CONVERT(INT, @lungime)
	DECLARE @latimeToINT INT = CONVERT(INT, @latime)
	DECLARE @inaltimeToINT INT = CONVERT(INT, @inaltime)
	
	UPDATE StanduriDinozauri SET Material = @newMaterialToVARCHAR50
	WHERE (Lungime = @lungimeToINT) AND (Latime = @latimeToINT) AND (Inaltime = @inaltimeToINT)
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------