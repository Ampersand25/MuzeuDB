USE MuzeuDB
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateReadForVitrine', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateReadForVitrine]

GO

CREATE FUNCTION uf_ValidateReadForVitrine(@minArea NVARCHAR(MAX), @maxArea NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX)
	SET @errors = ''

	IF dbo.uf_ValidateNumber(@minArea) = 0
		SET @errors = @errors + '[X]Primul argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@minArea) = 0
		SET @errors = @errors + '[X]Primul argument nu este un numar intreg!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@maxArea) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@maxArea) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este un numar intreg!' + CHAR(13) + CHAR(10)

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.uf_ReadForVitrine', N'IF') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ReadForVitrine]

GO

CREATE FUNCTION uf_ReadForVitrine(@minArea INT, @maxArea INT)
RETURNS TABLE
AS
RETURN
(
	SELECT VitrinaID AS 'ID vitrina', Lungime, Latime, Inaltime, [Perimetru vitrina] = (Lungime + Latime + Inaltime), (Lungime * Latime * Inaltime) AS [Suprafata totala vitrina], ((Lungime + Latime + Inaltime) / 3) AS 'Medie aritmetica dimensiuni vitrina'
	FROM Vitrine
	WHERE (Lungime * Latime * Inaltime) BETWEEN @minArea AND @maxArea
	ORDER BY [Suprafata totala vitrina] DESC OFFSET 0 ROWS
)

GO





IF OBJECT_ID(N'dbo.usp_ReadForVitrine', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_ReadForVitrine]

GO

CREATE PROCEDURE usp_ReadForVitrine(@minArea NVARCHAR(MAX), @maxArea NVARCHAR(MAX))
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX) = dbo.uf_ValidateReadForVitrine(@minArea, @maxArea)
	
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @minAreaToINT INT = CONVERT(INT, @minArea)
	DECLARE @maxAreaToINT INT = CONVERT(INT, @maxArea)
	
	IF @minAreaToINT <= @maxAreaToINT
	BEGIN
		SELECT * FROM dbo.uf_ReadForVitrine(@minAreaToINT, @maxAreaToINT)
		PRINT CONVERT(NVARCHAR(MAX), @@ROWCOUNT) + N' vitrine din muzeu au aria cuprinsa intre ' + @minArea + N' si ' + @maxArea + CHAR(13) + CHAR(10)
	END
	ELSE
	BEGIN
		SELECT * FROM dbo.uf_ReadForVitrine(@maxAreaToINT, @minAreaToINT)
		PRINT CONVERT(NVARCHAR(MAX), @@ROWCOUNT) + N' vitrine din muzeu au aria cuprinsa intre ' + @maxArea + N' si ' + @minArea + CHAR(13) + CHAR(10)
	END
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ReadForVase', N'IF') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ReadForVase]

GO

CREATE FUNCTION uf_ReadForVase()
RETURNS TABLE
AS
RETURN
(
	SELECT V.Culoare AS [Culoare vas], COUNT(*) AS 'Numar total vase de culoarea indicata', [Vechimea totala a veselor de aceasta culoare] = SUM(V.Vechime)
	FROM Vase AS V
	WHERE V.Culoare IS NOT NULL AND V.Culoare <> 'Maro'
	GROUP BY V.Culoare
	HAVING COUNT(*) > 1
	ORDER BY COUNT(*) ASC, SUM(V.Vechime) DESC OFFSET 0 ROWS
)

GO





IF OBJECT_ID(N'dbo.usp_ReadForVase', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_ReadForVase]

GO

CREATE PROCEDURE usp_ReadForVase
AS
	SELECT * FROM dbo.uf_ReadForVase()

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateReadForVizitatoriVase', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateReadForVizitatoriVase]

GO

CREATE FUNCTION uf_ValidateReadForVizitatoriVase(@varsta NVARCHAR(MAX), @sign NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX)
	SET @errors = ''

	IF dbo.uf_ValidateNumber(@varsta) = 0
		SET @errors = @errors + '[X]Primul argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@varsta) = 0
		SET @errors = @errors + '[X]Primul argument nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(INT, @varsta) NOT BETWEEN 0 AND 100
		SET @errors = @errors + '[X]Primul argument nu este valid (trebuie sa fie >= 0 si <= 100)!' + CHAR(13) + CHAR(10)

	IF LEN(@sign) <> 1
		SET @errors = @errors + '[X]Al doilea argument are lungime invalida (trebuie sa contina un singur caracter)!' + CHAR(13) + CHAR(10)
	ELSE IF @sign NOT IN ('<', '=', '>')
		SET @errors = @errors + '[X]Al doilea argument nu este valid (trebuie sa fie un simbol de inegalitate stricta sau de egalitate)!' + CHAR(13) + CHAR(10)

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.uf_ReadForVizitatoriVase', N'IF') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ReadForVizitatoriVase]

GO

CREATE FUNCTION uf_ReadForVizitatoriVase(@varsta TINYINT, @sign CHAR(1))
RETURNS TABLE
AS
RETURN
(
	SELECT [Numar de legitimatie vizitator] = V.NrLegitimatie, V.Nume + ' ' + V.Prenume AS 'Nume complet vizitator', V.Varsta AS 'Varsta vizitator', [ID vas] = Vase.VasID, Vase.Material AS [Material vas], Vase.Culoare AS [Culoare vas]
	FROM Vizitatori AS V INNER JOIN VizitatoriVase VV ON V.NrLegitimatie = VV.NrLegitimatie INNER JOIN Vase ON VV.VasID = Vase.VasID
	WHERE (V.Varsta < @varsta AND @sign = '<') OR (V.Varsta = @varsta AND @sign = '=') OR (V.Varsta > @varsta AND @sign = '>')
)

GO





IF OBJECT_ID(N'dbo.usp_ReadForVizitatoriVase', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_ReadForVizitatoriVase]

GO

CREATE PROCEDURE usp_ReadForVizitatoriVase(@varsta NVARCHAR(MAX), @sign NVARCHAR(MAX))
AS
	DECLARE @validMsg VARCHAR(MAX) = dbo.uf_ValidateReadForVizitatoriVase(@varsta, @sign)
	
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @varstaToTINYINT TINYINT = CONVERT(TINYINT, @varsta)
	DECLARE @signToCHAR1 CHAR(1) = CONVERT(CHAR(1), @sign)
	
	SELECT * FROM dbo.uf_ReadForVizitatoriVase(@varstaToTINYINT, @signToCHAR1)
	ORDER BY [Nume complet vizitator]
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateReadForVizitatori', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateReadForVizitatori]

GO

CREATE FUNCTION uf_ValidateReadForVizitatori(@str NVARCHAR(MAX), @typeNumePrenume NVARCHAR(MAX), @typePrefixSufix NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX)
	SET @errors = ''

	IF LEN(@str) = 0
		SET @errors = @errors + '[X]Primul argument are lungime invalida (trebuie sa contina cel putin un caracter)!' + CHAR(13) + CHAR(10)
	ELSE IF TRY_CONVERT(VARCHAR(MAX), @str) IS NULL
		SET @errors = @errors + '[X]Primul argument este invalid ca si continut (contine si caractere speciale)!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@typeNumePrenume) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@typeNumePrenume) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(INT, @typeNumePrenume) NOT IN (0, 1)
		SET @errors = @errors + '[X]Al doilea argument nu este valid (0 sau 1)!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@typePrefixSufix) = 0
		SET @errors = @errors + '[X]Al treilea argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@typePrefixSufix) = 0
		SET @errors = @errors + '[X]Al treilea argument nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(INT, @typePrefixSufix) NOT IN (0, 1)
		SET @errors = @errors + '[X]Al treilea argument nu este valid (0 sau 1)!' + CHAR(13) + CHAR(10)

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.uf_ReadForVizitatori', N'IF') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ReadForVizitatori]

GO

CREATE FUNCTION uf_ReadForVizitatori(@str VARCHAR(MAX), @typeNumePrenume BIT, @typePrefixSufix BIT)
RETURNS TABLE
AS
RETURN
(
	SELECT Vizitatori.NrLegitimatie AS [Numar de legitimatie], Vizitatori.Nume AS 'Nume vizitator muzeu', Vizitatori.Prenume AS 'Prenume vizitator muzeu', Vizitatori.Varsta
	FROM Vizitatori
	WHERE (LOWER(Vizitatori.Nume) LIKE (LOWER(@str) + '%') AND @typeNumePrenume = 0 AND @typePrefixSufix = 0) OR (LOWER(Vizitatori.Nume) LIKE ('%' + LOWER(@str)) AND @typeNumePrenume = 0 AND @typePrefixSufix = 1) OR
	(UPPER(Vizitatori.Prenume) LIKE (UPPER(@str) + '%') AND @typeNumePrenume = 1 AND @typePrefixSufix = 0) OR (UPPER(Vizitatori.Prenume) LIKE ('%' + UPPER(@str)) AND @typeNumePrenume = 1 AND @typePrefixSufix = 1)
)

GO





IF OBJECT_ID(N'dbo.usp_ReadForVizitatori', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_ReadForVizitatori]

GO

CREATE PROCEDURE usp_ReadForVizitatori(@str NVARCHAR(MAX), @typeNumePrenume NVARCHAR(MAX), @typePrefixSufix NVARCHAR(MAX))
AS
	DECLARE @validMsg VARCHAR(MAX) = dbo.uf_ValidateReadForVizitatori(@str, @typeNumePrenume, @typePrefixSufix)
	
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @strToVARCHARMAX VARCHAR(MAX) = CONVERT(VARCHAR(MAX), @str)
	DECLARE @typeNumePrenumeToBIT BIT = CONVERT(BIT, @typeNumePrenume)
	DECLARE @typePrefixSufixToBIT BIT = CONVERT(BIT, @typePrefixSufix)
	
	SELECT * FROM dbo.uf_ReadForVizitatori(@strToVARCHARMAX, @typeNumePrenumeToBIT, @typePrefixSufixToBIT)
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateReadForStanduriDinozauri', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateReadForStanduriDinozauri]

GO

CREATE FUNCTION uf_ValidateReadForStanduriDinozauri(@material NVARCHAR(MAX), @type NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX)
	SET @errors = ''

	IF LEN(@material) = 0
		SET @errors = @errors + '[X]Primul argument are lungime invalida (trebuie sa contina cel putin un caracter)!' + CHAR(13) + CHAR(10)
	ELSE IF TRY_CONVERT(VARCHAR(MAX), @material) IS NULL
		SET @errors = @errors + '[X]Primul argument este invalid ca si continut (contine si caractere speciale)!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@type) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@type) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(INT, @type) NOT IN (0, 1)
		SET @errors = @errors + '[X]Al doilea argument nu este valid (0 sau 1)!' + CHAR(13) + CHAR(10)

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.uf_ReadForStanduriDinozauri', N'IF') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ReadForStanduriDinozauri]

GO

CREATE FUNCTION uf_ReadForStanduriDinozauri(@material VARCHAR(MAX), @type BIT)
RETURNS TABLE
AS
RETURN
(
	SELECT SD.StandDinozaurID AS 'ID pentru standul de dinozaur', [Material suport de dinozaur] = SD.Material, SD.Lungime AS [Lungime platforma], SD.Latime AS [Latime platforma], SD.Inaltime AS [Inaltime platforma]
	FROM StanduriDinozauri AS SD
	WHERE (LOWER(SD.Material) LIKE ('_%' + LOWER(@material) + '%_') AND @type = 0) OR (UPPER(SD.Material) LIKE ('%' + UPPER(@material) + '%') AND @type = 1)
)

GO





IF OBJECT_ID(N'dbo.usp_ReadForStanduriDinozauri', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_ReadForStanduriDinozauri]

GO

CREATE PROCEDURE usp_ReadForStanduriDinozauri(@material NVARCHAR(MAX), @type NVARCHAR(MAX))
AS
	DECLARE @validMsg VARCHAR(MAX) = dbo.uf_ValidateReadForStanduriDinozauri(@material, @type)
	
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @materialToVARCHARMAX VARCHAR(MAX) = CONVERT(VARCHAR(MAX), @material)
	DECLARE @typeToBIT BIT = CONVERT(BIT, @type)
	
	SELECT * FROM dbo.uf_ReadForStanduriDinozauri(@materialToVARCHARMAX, @typeToBIT)
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------