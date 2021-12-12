USE MuzeuDB
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateDeleteForVitrine', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateDeleteForVitrine]

GO

CREATE FUNCTION uf_ValidateDeleteForVitrine(@leftID NVARCHAR(MAX), @rightID NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX) = ''

	IF dbo.uf_ValidateNumber(@leftID) = 0
		SET @errors = @errors + '[X]Primul argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@leftID) = 0
		SET @errors = @errors + '[X]Primul argument nu este un numar intreg!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@rightID) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@rightID) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este un numar intreg!' + CHAR(13) + CHAR(10)

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.usp_DeleteForVitrine', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_DeleteForVitrine]

GO

CREATE PROCEDURE usp_DeleteForVitrine
(
	@noOfDeletedRecords INT OUTPUT,
	@leftID NVARCHAR(MAX),
	@rightID NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX) = dbo.uf_ValidateDeleteForVitrine(@leftID, @rightID)
	
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @leftIDToINT INT = CONVERT(INT, @leftID)
	DECLARE @rightIDToINT INT = CONVERT(INT, @rightID)
	
	DELETE FROM Vitrine WHERE (VitrinaID BETWEEN @leftIDToINT AND @rightIDToINT) OR (VitrinaID BETWEEN @rightIDToINT AND @leftIDToINT)

	SET @noOfDeletedRecords = @@ROWCOUNT
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateDeleteForVase', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateDeleteForVase]

GO

CREATE FUNCTION uf_ValidateDeleteForVase(@str NVARCHAR(MAX), @culoareMaterial NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX) = ''

	IF LEN(@str) = 0
		SET @errors = @errors + '[X]Primul argument are lungime invalida (trebuie sa contina cel putin un caracter)!' + CHAR(13) + CHAR(10)
	ELSE IF TRY_CONVERT(VARCHAR(MAX), @str) IS NULL
		SET @errors = @errors + '[X]Primul argument este invalid ca si continut (contine si caractere speciale)!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@culoareMaterial) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@culoareMaterial) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(INT, @culoareMaterial) NOT IN (0, 1)
		SET @errors = @errors + '[X]Al doilea argument nu este valid (0 sau 1)!' + CHAR(13) + CHAR(10)

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.usp_DeleteForVase', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_DeleteForVase]

GO

CREATE PROCEDURE usp_DeleteForVase
(
	@noOfDeletedRecords INT OUTPUT,
	@str NVARCHAR(MAX),
	@culoareMaterial NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX) = dbo.uf_ValidateDeleteForVase(@str, @culoareMaterial)
	
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @strToVARCHARMAX VARCHAR(MAX) = CONVERT(VARCHAR(MAX), @str)
	DECLARE @culoareMaterialToBIT BIT = CONVERT(BIT, @culoareMaterial)
	
	DELETE FROM Vase WHERE (Culoare = @str AND @culoareMaterialToBIT = 0) OR (Material = @str AND @culoareMaterialToBIT = 1)

	SET @noOfDeletedRecords = @@ROWCOUNT
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateDeleteForVizitatoriVase', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateDeleteForVizitatoriVase]

GO

CREATE FUNCTION uf_ValidateDeleteForVizitatoriVase(@nrLegitimatie NVARCHAR(MAX), @vasID NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX) = ''

	IF dbo.uf_ValidateNumber(@nrLegitimatie) = 0
		SET @errors = @errors + '[X]Primul argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@nrLegitimatie) = 0
		SET @errors = @errors + '[X]Primul argument nu este un numar intreg!' + CHAR(13) + CHAR(10)

	IF dbo.uf_ValidateNumber(@vasID) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@vasID) = 0
		SET @errors = @errors + '[X]Al doilea argument nu este un numar intreg!' + CHAR(13) + CHAR(10)

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.usp_DeleteForVizitatoriVase', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_DeleteForVizitatoriVase]

GO

CREATE PROCEDURE usp_DeleteForVizitatoriVase
(
	@noOfDeletedRecords INT OUTPUT,
	@nrLegitimatie NVARCHAR(MAX),
	@vasID NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX) = dbo.uf_ValidateDeleteForVizitatoriVase(@nrLegitimatie, @vasID)
	
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @nrLegitimatieToINT INT = CONVERT(INT, @nrLegitimatie)
	DECLARE @vasIDToINT BIT = CONVERT(INT, @vasID)
	
	DELETE FROM VizitatoriVase WHERE NrLegitimatie = @nrLegitimatieToINT AND VasID = @vasIDToINT

	SET @noOfDeletedRecords = @@ROWCOUNT
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateDeleteForVizitatori', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateDeleteForVizitatori]

GO

CREATE FUNCTION uf_ValidateDeleteForVizitatori(@varsta NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX) = ''

	IF dbo.uf_ValidateNumber(@varsta) = 0
		SET @errors = @errors + '[X]Parametrul de intrare nu este o valoare numerica!' + CHAR(13) + CHAR(10)
	ELSE IF dbo.uf_ValidateInteger(@varsta) = 0
		SET @errors = @errors + '[X]Parametrul de intrare nu este un numar intreg!' + CHAR(13) + CHAR(10)
	ELSE IF CONVERT(INT, @varsta) NOT BETWEEN 0 AND 100
		SET @errors = @errors + '[X]Parametrul de intrare nu este un numar natural mai mic sau egal cu 100!' + CHAR(13) + CHAR(10)

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.usp_DeleteForVizitatori', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_DeleteForVizitatori]

GO

CREATE PROCEDURE usp_DeleteForVizitatori
(
	@noOfDeletedRecords INT OUTPUT,
	@varsta NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX) = dbo.uf_ValidateDeleteForVizitatori(@varsta)
	
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @varstaToTINYINT TINYINT = CONVERT(TINYINT, @varsta)
	
	DELETE FROM Vizitatori WHERE Varsta = @varstaToTINYINT

	SET @noOfDeletedRecords = @@ROWCOUNT
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.uf_ValidateDeleteForStanduriDinozauri', N'FN') IS NOT NULL
	DROP FUNCTION [dbo].[uf_ValidateDeleteForStanduriDinozauri]

GO

CREATE FUNCTION uf_ValidateDeleteForStanduriDinozauri(@material NVARCHAR(MAX))
RETURNS VARCHAR(MAX) AS
BEGIN
	DECLARE @errors VARCHAR(MAX) = ''

	IF LEN(@material) = 0
		SET @errors = @errors + '[X]Parametrul de intrare are lungime invalida (trebuie sa contina cel putin un caracter)!' + CHAR(13) + CHAR(10)
	ELSE IF TRY_CONVERT(VARCHAR(MAX), @material) IS NULL
		SET @errors = @errors + '[X]Parametrul de intrare este invalid ca si continut (contine si caractere speciale)!' + CHAR(13) + CHAR(10)

	RETURN @errors
END

GO





IF OBJECT_ID(N'dbo.usp_DeleteForStanduriDinozauri', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[usp_DeleteForStanduriDinozauri]

GO

CREATE PROCEDURE usp_DeleteForStanduriDinozauri
(
	@noOfDeletedRecords INT OUTPUT,
	@material NVARCHAR(MAX)
)
AS
BEGIN
	DECLARE @validMsg VARCHAR(MAX) = dbo.uf_ValidateDeleteForStanduriDinozauri(@material)
	
	IF LEN(@validMsg) <> 0
		THROW 50002, @validMsg, 1

	DECLARE @materialToVARCHARMAX VARCHAR(MAX) = CONVERT(VARCHAR(MAX), @material)
	
	DELETE FROM StanduriDinozauri WHERE Material = @materialToVARCHARMAX

	SET @noOfDeletedRecords = @@ROWCOUNT
END

GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------