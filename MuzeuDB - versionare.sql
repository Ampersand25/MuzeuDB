-- Ne conectam la baza de date master (default)
USE master
GO

-- Ne conectam la baza de date MuzeuDB
USE MuzeuDB
GO

-- Stergem tabelul/tabela Versiune (in caz aceasta exista)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Versiune]') AND type in (N'U'))
DROP TABLE Versiune

-- Cream tabelul/tabela Versiune (acesta va fi un tabel izolat in cadrul structurii bazei de date, adica nu se va lega de un alt tabel)
-- Acest tabel va contine versiunea curenta a bazei de date precum si versiunea anterioara, dar si data ultimei modificari/actualizari a structurii bazei de date
-- Vom folosi tabelul pentru a extrage versiunea curenta in procesul de actualizare a versiunii, iar dupa vom actualiza noua versiune precum si celelalte coloane din tabel
-- Aceasta tabela va fi de tip singleton (in sensul ca va contine constant o singura inregistrare)
CREATE TABLE Versiune
(
	-- TINYINT  - intreg fara semn (unsigned) reprezentat pe 1 byte/octet (cu valori de la 0 la 255)
	-- DATETIME - data (zi, luna, an) si ora (ora, minut, milisecunda)
	NrVersiuneCurenta TINYINT PRIMARY KEY DEFAULT 0, -- Versiunea curenta a bazei de date (initial este 0 - versiunea initiala/incipienta)
	NrVersiunePrecedenta TINYINT DEFAULT NULL,       -- Versiunea precedenta/anterioara a bazei de date (initial este NULL deoarece baza de date nu si-a schimbat structura)
	DataUltimeiModificari DATETIME                   -- Data si ora ultimei actualizari/modificari a versiunii structurii bazei de date
)

-- Versiunea initiala este versiunea 0
-- Versiunea precedenta este setata ca fiind NULL (nu s-a facut modificare asupra versiunii bazei de date <=> structura a ramas neschimbata)
-- Data (si ora) ultimei modificari/actualizari o setam ca fiind data (si ora) curenta
-- GETDATE() - apel sistem care returneaza/furnizeaza data si ora curenta
-- Inseram valori in coloanele NrVersiuneCurenta si DataUltimeiModificari din tabelul/tabela Versiune (coloana NrVersiunePrecedenta va avea valoarea implicita (default) specificata la definirea constrangerii)
INSERT INTO Versiune(NrVersiuneCurenta, DataUltimeiModificari) VALUES (0, GETDATE())

-- Afisam coloanele NrVersiuneCurenta si DataUltimeiModificari din tabelul Versiune
-- Vom folosi un alias pentru aceste campuri/atribute ale tabelei
SELECT NrVersiuneCurenta AS [Versiune initiala], DataUltimeiModificari AS 'Data ultimei actualizari de versiune' FROM Versiune

GO

-- Stergem procedura stocata cu numele usp_ModifyVersionDB (daca aceasta exista)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_ModifyVersionDB')
DROP PROCEDURE usp_ModifyVersionDB

GO

-- Cream procedura stocata cu numele usp_ModifyVersionDB
-- Procedura stocata de tip utilizator care modifica tabelul/tabela Versiune (nu actualizeaza structura bazei de date, ci doar semnaleaza ca aceasta a fost schimbata)
-- Aceasta procedura va modifica valorile tuturor atributelor (coloanelor) din tabelul Versiune (in acest tabel vom avea constant o singura inregistrare (record/row/line))
-- Preconditii (conditii impuse asupra datelor de intrare)                : @NrVersiuneNoua trebuie sa fie un intreg cuprins in intervalul [0, 5] (adica sa indice o versiune existenta in care poate trece baza de date)
-- Postconditii (descrierea rezultatelor procedurii, a efectului acesteia): daca versiunea curenta a bazei de date este diferita de versiunea @NrVersiuneNoua atunci se actualizeaza tabelul/tabela Versiune ca sa indice versiunea curenta a bazei de date (versiunea curenta va fi @NrVersiuneNoua)
-- Procedura stocata nu arunca/ridica exceptii, ci doar afiseaza mesaje corespunzatoare validarii parametrului de intrare @NrVersiuneNoua (se verifica preconditiile) precum si feedback cu privire la efectul apelului procedurii (daca nu s-a modificat versiunea curenta, daca baza de date si-a facut update la o versiune superioara, respectiv daca baza de date si-a facut downgrade la o versiune inferioara)
-- Procedura nu modifica structura bazei de date, ci doar ii actualizeaza versiunea in tabelul Versiune (modifica continutul acestui tabel)
CREATE PROCEDURE usp_ModifyVersionDB
-- @NrVersiuneNoua - paremetru de intrare al procedurii (parametru simbolic/formal)
-- @NrVersiuneNoua indica versiunea in care a trecut baza de date (vrem sa actualizam aceasta versiune si in tabela Versiune)
-- @NrVersiuneNoua este de tipul INT (integer = intreg), adica o valoare numerica intreaga cu semn (signed) reprezentata pe 4 bytes/octeti (32 de biti)
(@NrVersiuneNoua INT)
AS
BEGIN
	-- Declaram variabila locala @Ver de tip TINYINT
	DECLARE @Ver TINYINT
	-- Stocam in aceasta variabila valoarea din coloana NrVersiuneCurenta a singurei (unicei) inregistrari din tabelul/tabela Versiune
	-- @Ver va fi versiunea curenta a bazei de date conform tabelei Versiune
	SET @Ver = (SELECT NrVersiuneCurenta FROM Versiune)

	-- Baza de date se afla deja in versiunea @NrVersiuneNoua (nu se modifica versiunea curenta => structura ramane aceeasi)
	IF @NrVersiuneNoua = @Ver
	BEGIN
		-- Tiparim un mesaj in consola si nu modificam tabelul/tabela Versiune
		PRINT '[=]Baza de date este deja in versiunea ' + CONVERT(VARCHAR(1), @Ver) + '!'
	END
	-- Argumentul procedurii @NrVersiuneNoua nu reprezinta o versiune valida (nu sunt respectate preconditiile)
	ELSE IF @NrVersiuneNoua < 0 OR @NrVersiuneNoua > 5
	BEGIN
		-- Tiparim un mesaj in consola prin care sa semnalam invaliditatea parametrului @NrVersiuneNoua si totodata incalcarea preconditiilor procedurii
		-- Tabelul Versiune ramane neschimbat/nemodificat
		PRINT '[X]Versiunea ' + STR(@NrVersiuneNoua) + ' este invalida!'
	END
	-- Parametrul de intrare @NrVersiuneNoua reprezinta o versiune disponibila a bazei de date si baza de date nu se afla la momentul actual in versiunea respectiva
	-- Se va face tranzitia din versiunea curenta a bazei de date in versiunea indicata de variabila @NrVersiuneNoua
	ELSE
	BEGIN
		-- Stergem toate inregistrarile din tabelul Versiune (adica singura inregistrare existenta)
		DELETE FROM Versiune
		-- Adaugam o inregistrare noua in tabelul Versiune
		-- Se insereaza valorile @NrVersiuneNoua, @Ver, GETDATE() in coloanele NrVersiuneCurenta, NrVersiunePrecedenta, DataUltimeiModificari corespunzatoare acestei inregistrari
		-- @NrVersiuneNoua - versiunea noua a bazei de date
		-- @Ver            - versiunea veche a bazei de date
		-- GETDATE()       - apel sistem care intoarce data si ora curenta
		INSERT INTO Versiune(NrVersiuneCurenta, NrVersiunePrecedenta, DataUltimeiModificari) VALUES(@NrVersiuneNoua, @Ver, GETDATE())

		-- Baza de date a trecut intr-o versiune superioara (update)
		IF @NrVersiuneNoua > @Ver
		BEGIN
			-- Afisam un mesaj corespunzator pentru user/utilizator care sa precizeze ca structura bazei de date este acum una superioara
			PRINT '[!]Baza de date si-a facut update de la versiunea ' + CONVERT(VARCHAR(1), @Ver) + ' la versiunea ' + CONVERT(VARCHAR(1), @NrVersiuneNoua)
		END
		-- Baza de date a trecut intr-o versiune inferioara (downgrade)
		ELSE -- ELSE IF @NrVersiuneNoua < @Ver
		BEGIN
			-- Afisam un mesaj corespunzator pentru user/utilizator care sa precizeze ca structura bazei de date este acum una inferioara
			PRINT '[!]Baza de date si-a facut downgrade de la versiunea ' + CONVERT(VARCHAR(1), @Ver) + ' la versiunea ' + CONVERT(VARCHAR(1), @NrVersiuneNoua)
		END
	END
END

GO

-- Stergem procedura stocata cu numele usp_UpdateVersionDB1 (in cazul in care aceasta exista deja)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_UpdateVersionDB1')
BEGIN
	DROP PROCEDURE usp_UpdateVersionDB1
END

GO

-- Cream procedura stocata cu numele usp_UpdateVersionDB1
-- Aceasta procedura stocata va realiza prima operatie directa (tranzitia de la versiunea 0 (initiala) a bazei de date la versiunea 1)
-- Procedura stocata modifica tipul unor coloane din anumite tabele/tabeluri existente in baza de date
-- Preconditii : baza de date trebuie sa se afle in versiunea 0 (versiunea initiala)
-- Postconditii: se trece baza de date din versiunea inferioara 0 in versiunea superioara 1 (update)
--               se schimba tipul coloanei Valoare din tabela Bijuterii din INT in BIGINT
--               se schimba tipul coloanei Greutate din tabela Paznici din INT in FLOAT
--               se schimba tipul coloanei Material din tabela StanduriDinozauri din VARCHAR(50) in VARCHAR(7)
--               se schimba tipul coloanei NrOase din tabela FosileDinozauri din INT in TINYINT
--               se schimba tipul coloanei Vechime din tabela Vase din INT in SMALLINT
--               se schimba tipul coloanei Varsta din tabela Vizitatori din INT in TINYINT
--               se schimba tipul coloanei Nume din tabela Ghizi din VARCHAR(50) in NVARCHAR(40)
--               se schimba tipul coloanei Prenume din tabela Ghizi din VARCHAR(50) in NVARCHAR(45)
--               se actualizeaza tabela Versiune prin apelul procedurii stocate usp_ModifyVersionDB cu argumentul 1
CREATE PROCEDURE usp_UpdateVersionDB1
AS
BEGIN
	--PRINT ''
	PRINT CHAR(13) + '~~UPDATE VERSION 1~~'

	-- Modificam direct coloana Valoare din tabelul/tabela Bijuterii
	-- Schimbam tipul de data al coloanei din INT in BIGINT
	ALTER TABLE Bijuterii
	ALTER COLUMN Valoare BIGINT
	PRINT 'Modificare directa tip'
	PRINT '[>]S-a modificat cu succes tipul atributului ''Valoare'' (din tabela ''Bijuterii'') din INT in BIGINT'

	-- Modificam direct coloana Greutate din tabelul/tabela Paznici
	-- Schimbam tipul de data al coloanei din INT in FLOAT
	ALTER TABLE Paznici
	ALTER COLUMN Greutate FLOAT
	PRINT 'Modificare directa tip'
	PRINT '[>]S-a modificat cu succes tipul atributului ''Greutate'' (din tabela ''Paznici'') din INT in FLOAT'

	-- Modificam direct coloana Material din tabelul/tabela StanduriDinozauri
	-- Schimbam tipul de data al coloanei din VARCHAR(50) in VARCHAR(7)
	ALTER TABLE StanduriDinozauri
	ALTER COLUMN Material VARCHAR(7)
	PRINT 'Modificare directa tip'
	PRINT '[>]S-a modificat cu succes tipul atributului ''Material'' (din tabela ''StanduriDinozauri'') din VARCHAR(50) in VARCHAR(7)'

	-- Modificam direct coloana NrOase din tabelul/tabela FosileDinozauri
	-- Schimbam tipul de data al coloanei din INT in TINYINT
	ALTER TABLE FosileDinozauri
	ALTER COLUMN NrOase TINYINT
	PRINT 'Modificare directa tip'
	PRINT '[>]S-a modificat cu succes tipul atributului ''NrOase'' (din tabela ''FosileDinozauri'') din INT in TINYINT'

	-- Modificam direct coloana Vechime din tabelul/tabela Vase
	-- Schimbam tipul de data al coloanei din INT in SMALLINT
	ALTER TABLE Vase
	ALTER COLUMN Vechime SMALLINT
	PRINT 'Modificare directa tip'
	PRINT '[>]S-a modificat cu succes tipul atributului ''Vechime'' (din tabela ''Vase'') din INT in SMALLINT'

	-- Modificam direct coloana Varsta din tabelul/tabela Vizitatori
	-- Schimbam tipul de data al coloanei din INT in TINYINT
	ALTER TABLE Vizitatori
	ALTER COLUMN Varsta TINYINT
	PRINT 'Modificare directa tip'
	PRINT '[>]S-a modificat cu succes tipul atributului ''Varsta'' (din tabela ''Vizitatori'') din INT in TINYINT'

	-- Modificam direct coloana Nume din tabelul/tabela Ghizi
	-- Schimbam tipul de data al coloanei din VARCHAR(50) in NVARCHAR(40)
	ALTER TABLE Ghizi
	ALTER COLUMN Nume NVARCHAR(40)
	PRINT 'Modificare directa tip'
	PRINT '[>]S-a modificat cu succes tipul atributului ''Nume'' (din tabela ''Ghizi'') din VARCHAR(50) in NVARCHAR(40)'

	-- Modificam direct coloana Prenume din tabelul/tabela Ghizi
	-- Schimbam tipul de data al coloanei din VARCHAR(50) in NVARCHAR(45)
	ALTER TABLE Ghizi
	ALTER COLUMN Prenume NVARCHAR(45)
	PRINT 'Modificare directa tip'
	PRINT '[>]S-a modificat cu succes tipul atributului ''Prenume'' (din tabela ''Ghizi'') din VARCHAR(50) in NVARCHAR(45)'

	-- Apelam procedura stocata usp_ModifyVersionDB cu parametrul de intrare actual/efectiv 1
	-- Marcam in tabelul/tabela versiune tranzitia in versiunea 1 a bazei de date
	EXEC usp_ModifyVersionDB 1
END

GO

-- Stergem procedura stocata cu numele usp_DowngradeVersionDB1 (in cazul in care aceasta exista deja)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DowngradeVersionDB1')
BEGIN
	DROP PROCEDURE usp_DowngradeVersionDB1
END

GO

-- Cream procedura stocata cu numele usp_DowngradeVersionDB1
-- Aceasta procedura stocata va realiza prima operatie inversa (tranzitia de la versiunea 1 a bazei de date la versiunea 0 (initiala))
-- Procedura stocata modifica tipul unor coloane din anumite tabele/tabeluri existente in baza de date (se fac modificarile inverse/complementare fata de cele din procedura stocata usp_UpdateVersionDB1)
-- Preconditii : baza de date trebuie sa se afle in versiunea 1
-- Postconditii: se trece baza de date din versiunea superioara 1 in versiunea inferioara 0 (downgrade)
--               se schimba tipul coloanei Valoare din tabela Bijuterii din BIGINT inapoi la INT
--               se schimba tipul coloanei Greutate din tabela Paznici din FLOAT inapoi la INT
--               se schimba tipul coloanei Material din tabela StanduriDinozauri din VARCHAR(7) inapoi la VARCHAR(50)
--               se schimba tipul coloanei NrOase din tabela FosileDinozauri din TINYINT inapoi la INT
--               se schimba tipul coloanei Vechime din tabela Vase din SMALLINT inapoi la INT
--               se schimba tipul coloanei Varsta din tabela Vizitatori din TINYINT inapoi la INT
--               se schimba tipul coloanei Nume din tabela Ghizi din NVARCHAR(40) inapoi la VARCHAR(50)
--               se schimba tipul coloanei Prenume din tabela Ghizi din NVARCHAR(45) inapoi la VARCHAR(50)

--               se actualizeaza tabela Versiune prin apelul procedurii stocate usp_ModifyVersionDB cu argumentul 0
CREATE PROCEDURE usp_DowngradeVersionDB1
AS
BEGIN
	--PRINT ''
	PRINT CHAR(13) + '~~DOWNGRADE VERSION 0~~'

	-- Modificam invers coloana Valoare din tabelul/tabela Bijuterii
	-- Schimbam tipul de data al coloanei din BIGINT in INT
	ALTER TABLE Bijuterii
	ALTER COLUMN Valoare INT
	PRINT 'Modificare inversa tip'
	PRINT '[<]S-a modificat cu succes tipul atributului ''Valoare'' (din tabela ''Bijuterii'') din BIGINT in INT'

	-- Modificam invers coloana Greutate din tabelul/tabela Paznici
	-- Schimbam tipul de data al coloanei din FLOAT in INT
	ALTER TABLE Paznici
	ALTER COLUMN Greutate INT
	PRINT 'Modificare inversa tip'
	PRINT '[<]S-a modificat cu succes tipul atributului ''Greutate'' (din tabela ''Paznici'') din FLOAT in INT'

	-- Modificam invers coloana Material din tabelul/tabela StanduriDinozauri
	-- Schimbam tipul de data al coloanei din VARCHAR(7) in VARCHAR(50)
	ALTER TABLE StanduriDinozauri
	ALTER COLUMN Material VARCHAR(50)
	PRINT 'Modificare inversa tip'
	PRINT '[<]S-a modificat cu succes tipul atributului ''Material'' (din tabela ''StanduriDinozauri'') din VARCHAR(7) in VARCHAR(50)'

	-- Modificam invers coloana NrOase din tabelul/tabela FosileDinozauri
	-- Schimbam tipul de data al coloanei din TINYINT in INT
	ALTER TABLE FosileDinozauri
	ALTER COLUMN NrOase INT
	PRINT 'Modificare inversa tip'
	PRINT '[<]S-a modificat cu succes tipul atributului ''NrOase'' (din tabela ''FosileDinozauri'') din TINYINT in INT'

	-- Modificam invers coloana Vechime din tabelul/tabela Vase
	-- Schimbam tipul de data al coloanei din SMALLINT in INT
	ALTER TABLE Vase
	ALTER COLUMN Vechime INT
	PRINT 'Modificare inversa tip'
	PRINT '[<]S-a modificat cu succes tipul atributului ''Vechime'' (din tabela ''Vase'') din SMALLINT in INT'

	-- Modificam invers coloana Varsta din tabelul/tabela Vizitatori
	-- Schimbam tipul de data al coloanei din TINYINT in INT
	ALTER TABLE Vizitatori
	ALTER COLUMN Varsta INT
	PRINT 'Modificare inversa tip'
	PRINT '[<]S-a modificat cu succes tipul atributului ''Varsta'' (din tabela ''Vizitatori'') din TINYINT in INT'

	-- Modificam invers coloana Nume din tabelul/tabela Ghizi
	-- Schimbam tipul de data al coloanei din NVARCHAR(40) in VARCHAR(50)
	ALTER TABLE Ghizi
	ALTER COLUMN Nume VARCHAR(50)
	PRINT 'Modificare inversa tip'
	PRINT '[>]S-a modificat cu succes tipul atributului ''Nume'' (din tabela ''Ghizi'') din NVARCHAR(40) in VARCHAR(50)'

	-- Modificam invers coloana Prenume din tabelul/tabela Ghizi
	-- Schimbam tipul de data al coloanei din NVARCHAR(45) in VARCHAR(50)
	ALTER TABLE Ghizi
	ALTER COLUMN Prenume VARCHAR(50)
	PRINT 'Modificare inversa tip'
	PRINT '[>]S-a modificat cu succes tipul atributului ''Prenume'' (din tabela ''Ghizi'') din NVARCHAR(45) in VARCHAR(50)'

	-- Apelam procedura stocata usp_ModifyVersionDB cu parametrul de intrare actual/efectiv 0
	-- Marcam in tabelul/tabela versiune tranzitia in versiunea 0 (initiala) a bazei de date
	EXEC usp_ModifyVersionDB 0
END

GO

-- Stergem procedura stocata cu numele usp_UpdateVersionDB2 (in cazul in care aceasta exista deja)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_UpdateVersionDB2')
BEGIN
	DROP PROCEDURE usp_UpdateVersionDB2
END

GO

-- Cream procedura stocata cu numele usp_UpdateVersionDB2
-- Aceasta procedura stocata va realiza a doua operatie directa (tranzitia de la versiunea 1 a bazei de date la versiunea 2)
-- Procedura stocata adauga constrangeri de integritate de tipul default (valori implicite) pentru unele coloane (campuri/atribute) din anumite tabele
-- Fiecare constrangere trebuie sa aiba un nume pentru a se putea realiza operatia inversa (de stergere a constrangerii de pe coloana pe care aceasta s-a adaugat)
-- Preconditii : baza de date trebuie sa se afle in versiunea 1
-- Postconditii: se trece baza de date din versiunea inferioara 1 in versiunea superioara 2 (update)
--               se adauga constrangerea default (de valoare initiala) cu numele df_Bijuterii_Material pe coloana Material din tabela Bijuterii
--               se adauga constrangerea default (de valoare initiala) cu numele df_Pazinici_Salariu pe coloana Salariu din tabela Paznici
--               se adauga constrangerea default (de valoare initiala) cu numele df_Vase_Vechime pe coloana Vechime din tabela Vase
--               se actualizeaza tabela Versiune prin apelul procedurii stocate usp_ModifyVersionDB cu argumentul 2
CREATE PROCEDURE usp_UpdateVersionDB2
AS
BEGIN
	--PRINT ''
	PRINT CHAR(13) + '~~UPDATE VERSION 2~~'

	-- Adaugam constrangere de valoare implicita (default) in coloana (campul) Material din tabelul/tabela Bijuterii
	-- Nume constrangere: df_Bijuterii_Material
	-- Valoare implicita: 'Alt material' (de tip VARCHAR(50))
	ALTER TABLE Bijuterii
	ADD CONSTRAINT df_Bijuterii_Material DEFAULT 'Alt material' FOR Material
	PRINT '[+]S-a adaugat cu succes constrangerea de tip default (valoare implicita) pentru coloana/campul ''Material'' din tabela ''Bijuterii'''

	-- Adaugam constrangere de valoare implicita (default) in coloana (campul) Salariu din tabelul/tabela Paznici
	-- Nume constrangere: df_Pazinici_Salariu
	-- Valoare implicita: 3000 (de tip INT)
	ALTER TABLE Paznici
	ADD CONSTRAINT df_Pazinici_Salariu DEFAULT 3000 FOR Salariu
	PRINT '[+]S-a adaugat cu succes constrangerea de tip default (valoare implicita) pentru coloana/campul ''Salariu'' din tabela ''Paznici'''

	-- Adaugam constrangere de valoare implicita (default) in coloana (campul) Vechime din tabelul/tabela Vase
	-- Nume constrangere: df_Vase_Vechime
	-- Valoare implicita: 50000 (de tip INT)
	ALTER TABLE Vase
	ADD CONSTRAINT df_Vase_Vechime DEFAULT 5000 FOR Vechime
	PRINT '[+]S-a adaugat cu succes constrangerea de tip default (valoare implicita) pentru coloana/campul ''Vechime'' din tabela ''Vase'''

	-- Apelam procedura stocata usp_ModifyVersionDB cu parametrul de intrare actual/efectiv 2
	-- Marcam in tabelul/tabela versiune tranzitia in versiunea 2 a bazei de date
	EXEC usp_ModifyVersionDB 2
END

GO

-- Stergem procedura stocata cu numele usp_DowngradeVersionDB2 (in cazul in care aceasta exista deja)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DowngradeVersionDB2')
BEGIN
	DROP PROCEDURE usp_DowngradeVersionDB2
END

GO

-- Cream procedura stocata cu numele usp_DowngradeVersionDB2
-- Aceasta procedura stocata va realiza a doua operatie inversa (tranzitia de la versiunea 2 a bazei de date la versiunea 1)
-- Procedura stocata sterge constrangerile de valoare implicita adaugate in urma apelului procedurii stocate usp_UpdateVersionDB2
-- Preconditii : baza de date trebuie sa se afle in versiunea 2
-- Postconditii: se trece baza de date din versiunea superioara 2 in versiunea inferioara 1 (downgrade)
--               se sterge/elimina constrangerea de integritate de tip default (de valoare initiala) cu numele df_Bijuterii_Material de pe coloana Material din tabelul Bijuterii
--               se sterge/elimina constrangerea de integritate de tip default (de valoare initiala) cu numele df_Pazinici_Salariu de pe coloana Salariu din tabelul Paznici
--               se sterge/elimina constrangerea de integritate de tip default (de valoare initiala) cu numele df_Vase_Vechime de pe coloana Vechime din tabelul Vase
--               se actualizeaza tabela Versiune prin apelul procedurii stocate usp_ModifyVersionDB cu argumentul 1
CREATE PROCEDURE usp_DowngradeVersionDB2
AS
BEGIN
	--PRINT ''
	PRINT CHAR(13) + '~~DOWNGRADE VERSION 1~~'

	-- Stergem/Eliminam constrangerea de valoare implicita (default) din coloana (campul) Material din tabelul/tabela Bijuterii
	-- Nume constrangere: df_Bijuterii_Material
	ALTER TABLE Bijuterii
	DROP CONSTRAINT df_Bijuterii_Material
	PRINT '[-]S-a sters cu succes constrangerea de tip default (valoare implicita) din tabela ''Bijuterii'''

	-- Stergem/Eliminam constrangerea de valoare implicita (default) din coloana (campul) Salariu din tabelul/tabela Paznici
	-- Nume constrangere: df_Pazinici_Salariu
	ALTER TABLE Paznici
	DROP CONSTRAINT df_Pazinici_Salariu
	PRINT '[-]S-a sters cu succes constrangerea de tip default (valoare implicita) din tabela ''Paznici'''

	-- Stergem/Eliminam constrangerea de valoare implicita (default) din coloana (campul) Vechime din tabelul/tabela Vase
	-- Nume constrangere: df_Vase_Vechime
	ALTER TABLE Vase
	DROP CONSTRAINT df_Vase_Vechime
	PRINT '[-]S-a sters cu succes constrangerea de tip default (valoare implicita) din tabela ''Vase'''

	-- Apelam procedura stocata usp_ModifyVersionDB cu parametrul de intrare actual/efectiv 1
	-- Marcam in tabelul/tabela versiune tranzitia in versiunea 1 a bazei de date
	EXEC usp_ModifyVersionDB 1
END

GO

-- Stergem procedura stocata cu numele usp_UpdateVersionDB3 (in cazul in care aceasta exista deja)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_UpdateVersionDB3')
BEGIN
	DROP PROCEDURE usp_UpdateVersionDB3
END

GO

-- Cream procedura stocata cu numele usp_UpdateVersionDB1
-- Aceasta procedura stocata va realiza a treia operatie directa (tranzitia de la versiunea 2 a bazei de date la versiunea 3)
-- Procedura stocata creaza mai multe tabele/tabeluri in baza de date, modificand astfel structura acesteia
-- Fiecare tabel nou creat va fi independent (nu va fi legat de alt tabel existent in baza de date)
-- Astfel, nu avem relatii intre tabelele nou create si cele deja existente
-- Tabelele nou create nu se vor afla nici in relatii unele cu altele
-- Preconditii : baza de date trebuie sa se afle in versiunea 2 (versiunea curenta trebuie sa fie 2 pentru a se putea face update la versiunea 3)
-- Postconditii: se trece baza de date din versiunea inferioara 2 in versiunea superioara 3 (update)
--               se adauga (introduce/creaza) tabelul/tabela Adrese (8 coloane)
--               se adauga (introduce/creaza) tabelul/tabela Telefoane (4 coloane)
--               se adauga (introduce/creaza) tabelul/tabela Fluturi (5 coloane)
--               se adauga (introduce/creaza) tabelul/tabela Ingrijitori (5 coloane)
--               se adauga (introduce/creaza) tabelul/tabela GhiziFluturi (2 coloane), tabela intermediara ce contine doar doua chei straine care sunt o pereche de chei primare (pentru realizarea relatiei m:n (many to many) intre tabelele Ghizi si Fluturi intr-o versiune superioara)
--               se actualizeaza tabela Versiune prin apelul procedurii stocate usp_ModifyVersionDB cu argumentul 3
CREATE PROCEDURE usp_UpdateVersionDB3
AS
BEGIN
	--PRINT ''
	PRINT CHAR(13) + '~~UPDATE VERSION 3~~'

	-- Crearea tabelului/tabelei Adrese
	CREATE TABLE Adrese
	(
		AdresaID INT CONSTRAINT pk_Adrese_AdresaID PRIMARY KEY,
		Oras NVARCHAR(50) NOT NULL,
		Strada NVARCHAR(50),
		Numar TINYINT,
		Etaj TINYINT CONSTRAINT df_Adrese_Etaj DEFAULT 0,
		Scara TINYINT CONSTRAINT ck_Adrese_Scara CHECK (Scara >= 1),
		CodPostal CHAR(6),
		Tara VARCHAR(50) DEFAULT 'Romania',
		CONSTRAINT ck_Adrese_Numar CHECK (Numar != 0)
	);
	PRINT '[+]S-a creat cu succes tabelul ''Adrese'''

	-- Crearea tabelului/tabelei Telefoane
	CREATE TABLE Telefoane
	(
		NumarMobil CHAR(12) NOT NULL CONSTRAINT ck_Telefoane_NumarMobil CHECK (LEN(NumarMobil) != 0 AND NumarMobil LIKE '+%') CONSTRAINT uq_Telefoane_NumarMobil UNIQUE,
		NumarFix VARCHAR(12),
		Fax VARCHAR(50),
		CNPPaznic VARCHAR(50) NOT NULL,
		CONSTRAINT pk_Telefon_NumarMobil PRIMARY KEY(NumarMobil)
	);
	PRINT '[+]S-a creat cu succes tabelul ''Telefoane'''

	-- Crearea tabelului/tabelei Fluturi
	CREATE TABLE Fluturi
	(
		FlutureID INT CONSTRAINT pk_Fluturi_FlutureID PRIMARY KEY IDENTITY(1, 1),
		Nume VARCHAR(50) CONSTRAINT df_Fluturi_Nume DEFAULT 'Coada randunicii',
		Familie VARCHAR(50) CONSTRAINT ck_Fluturi_Familie CHECK (Familie IN ('Papilionidae', 'Pieridae', 'Lycaenidae', 'Riodinidae', 'Nymphalidae')),
		Regiune VARCHAR(50) CONSTRAINT df_Fluturi_Regiune DEFAULT 'Romania',
		CuloarePredominanta VARCHAR(50)
	);
	PRINT '[+]S-a creat cu succes tabelul ''Fluturi'''

	-- Crearea tabelului/tabelei Ingrijitori
	CREATE TABLE Ingrijitori
	(
		CNPIngrijitor CHAR(13) CONSTRAINT pk_Ingrijitori_CNPIngrijitor PRIMARY KEY(CNPIngrijitor),
		Nume NCHAR(50) NOT NULL,
		Prenume NCHAR(50) NOT NULL,
		Varsta TINYINT CONSTRAINT ck_Ingrijitori_Varsta CHECK (Varsta BETWEEN 18 AND 55),
		Experienta TINYINT CONSTRAINT df_Ingrijitori_Experienta DEFAULT 0,
		CONSTRAINT uq_Ingrijitor_Nume_Prenume UNIQUE (Nume, Prenume)
	);
	PRINT '[+]S-a creat cu succes tabelul ''Ingrijitori'''

	-- Crearea tabelului/tabelei GhiziFluturi
	CREATE TABLE GhiziFluturi
	(
		CNPGhid VARCHAR(50) NOT NULL,
		FlutureID INT NOT NULL,
		CONSTRAINT pk_GhiziFluturi_CNPGhid_FlutureID PRIMARY KEY (CNPGhid, FlutureID)
	);
	PRINT '[+]S-a creat cu succes tabelul ''GhiziFluturi'''

	-- Apelam procedura stocata usp_ModifyVersionDB cu parametrul de intrare actual/efectiv 3
	-- Marcam in tabelul/tabela versiune tranzitia in versiunea 3 a bazei de date
	EXEC usp_ModifyVersionDB 3
END

GO

-- Stergem procedura stocata cu numele usp_DowngradeVersionDB3 (in cazul in care aceasta exista deja)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DowngradeVersionDB3')
BEGIN
	DROP PROCEDURE usp_DowngradeVersionDB3
END

GO

-- Cream procedura stocata cu numele usp_DowngradeVersionDB3
-- Aceasta procedura stocata va realiza a treia operatie inversa (tranzitia de la versiunea 3 a bazei de date la versiunea 2)
-- Procedura stocata sterge/elimina din baza de date tabelele create in urma apelului procedurii stocate usp_UpdateVersionDB3 (procedura stocata de tip utilizator care realizeaza operatia complementara procedurii stocate in cauza)
-- Preconditii : baza de date trebuie sa se afle in versiunea 3 (versiunea curenta trebuie sa fie 3 pentru a se putea face downgrade la versiunea 2)
-- Postconditii: se trece baza de date din versiunea superioara 3 in versiunea inferioara 2 (downgrade)
--               se sterge tabelul Adrese din baza de date MuzeuDB
--               se sterge tabelul Telefoane din baza de date MuzeuDB
--               se sterge tabelul Fluturi din baza de date MuzeuDB
--               se sterge tabelul Ingrijitori din baza de date MuzeuDB
--               se sterge tabelul GhiziFluturi din baza de date MuzeuDB
--               se actualizeaza tabela Versiune prin apelul procedurii stocate usp_ModifyVersionDB cu argumentul 2
CREATE PROCEDURE usp_DowngradeVersionDB3
AS
BEGIN
	--PRINT ''
	PRINT CHAR(13) + '~~DOWNGRADE VERSION 2~~'

	-- Stergerea tabelului/tabelei Adrese
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Adrese]') AND type in (N'U'))
	BEGIN
		DROP TABLE Adrese
		PRINT '[-]S-a sters cu succes tabela ''Adrese'''
	END
	
	-- Stergerea tabelului/tabelei Telefoane
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Telefoane]') AND type in (N'U'))
	BEGIN
		DROP TABLE Telefoane
		PRINT '[-]S-a sters cu succes tabela ''Telefoane'''
	END

	-- Stergerea tabelului/tabelei Telefoane
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Fluturi]') AND type in (N'U'))
	BEGIN
		DROP TABLE Fluturi
		PRINT '[-]S-a sters cu succes tabela ''Fluturi'''
	END

	-- Stergerea tabelului/tabelei Ingrijitori
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Ingrijitori]') AND type in (N'U'))
	BEGIN
		DROP TABLE Ingrijitori
		PRINT '[-]S-a sters cu succes tabela ''Ingrijitori'''
	END
	
	-- Stergerea tabelului/tabelei GhiziFluturi
	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GhiziFluturi]') AND type in (N'U'))
	BEGIN
		DROP TABLE GhiziFluturi
		PRINT '[-]S-a sters cu succes tabela ''GhiziFluturi'''
	END

	-- Apelam procedura stocata usp_ModifyVersionDB cu parametrul de intrare actual/efectiv 2
	-- Marcam in tabelul/tabela versiune tranzitia in versiunea 2 a bazei de date
	EXEC usp_ModifyVersionDB 2
END

GO

-- Stergem procedura stocata cu numele usp_UpdateVersionDB4 (in cazul in care aceasta exista deja)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_UpdateVersionDB4')
BEGIN
	DROP PROCEDURE usp_UpdateVersionDB4
END

GO

-- Cream procedura stocata cu numele usp_UpdateVersionDB4
-- Aceasta procedura stocata va realiza a 4-a (si penultima) operatie directa (tranzitia de la versiunea 3 a bazei de date la versiunea 4)
-- Procedura stocata adauga coloane (campuri/atribute) noi unor tabele deja existente in structura bazei de date
-- Nu se pot adauga constrangeri pe tabelele existente inca din versiunea 0 (versiunea initiala) deoarece acestea sunt populate cu inregistrari
-- Pe tabelele create in urma apelului procedurii stocate usp_UpdateVersionDB3 (care a adus baza de date in versiunea 3) se poate adauga doar constrangere NOT NULL (pentru ca aceste tabele nu contin date, adica sunt goale)
-- Daca adaugam alte constrangeri de integritate (diferite de NOT NULL) pe coloanele nou introduse in urma tranzitiei de la versiunea 2 la versiunea 3 atunci nu vom putea sterge aceste coloane ulterior (adica sa revenim de la versiunea 4 la versiunea 3)
-- Preconditii : baza de date trebuie sa se afle in versiunea 3 (versiunea curenta trebuie sa fie 3 pentru a se putea face update la versiunea 4
-- Postconditii: se trece baza de date din versiunea inferioara 3 in versiunea superioara 4 (update)
--               se adauga coloana/campul Clasa de tipul VARCHAR(50) si cu constrangere DEFAULT (de valoare implicita) in tabelul FosileDinozauri
--               se adauga coloana/campul DataImportMuzeu de tipul DATETIME si cu constragerea DEFAULT (de valoare implicita) in tabelul Fluturi
--               se adauga coloana/campul Judet de tipul NVARCHAR(50) si cu constrangerea NOT NULL in tabelul Adrese
--               se adauga coloana/campul Salariu de tipul TINYINT si cu constrangerea CHECK in tabelul Ingrijitori
--               se adauga coloana/campul Casatorit de tipul BIT in tabelul Vizitatori
--               se actualizeaza tabela Versiune prin apelul procedurii stocate usp_ModifyVersionDB cu argumentul 4
CREATE PROCEDURE usp_UpdateVersionDB4
AS
BEGIN
	--PRINT ''
	PRINT CHAR(13) + '~~UPDATE VERSION 4~~'

	-- Adaugam/Inseram coloana Clasa in tabelul/tabela FosileDinozauri
	-- Coloana (atributul/campul) nou introdusa va avea constrangerea DEFAULT (de valoare implicita) cu numele df_FosileDinozauri_Clasa
	-- Coloana (atributul/campul) nou introdusa va avea constrangerea CHECK cu numele ck_FosileDinozauri_Clasa
	-- Tipul acesteia este un VARCHAR(50) (sir de caractere variabil (ca si dimensiune = numar de caractere) de lungime maxim 50)
	-- Pentru a elimina/sterge aceasta coloana din tabela trebuie sa stergem mai intai constrangerile de integritate asociate: default (df_FosileDinozauri_Clasa) si check (ck_FosileDinozauri_Clasa)
	ALTER TABLE FosileDinozauri
	ADD Clasa VARCHAR(50) CONSTRAINT df_FosileDinozauri_Clasa DEFAULT 'Reptilia' CONSTRAINT ck_FosileDinozauri_Clasa CHECK (Clasa <> '')
	--ADD Clasa VARCHAR(50)
	PRINT '[+]S-a adaugat cu succes coloana ''Clasa'' cu constrangerile ''df_FosileDinozauri_Clasa'' (DEFAULT) si ''ck_FosileDinozauri_Clasa'' (CHECK) in tabelul ''FosileDinozauri'''

	-- Adaugam/Inseram coloana DataImportMuzeu in tabelul/tabela Fluturi
	-- Coloana (atributul/campul) nou introdusa va avea constrangerea DEFAULT (de valoare implicita) cu numele df_Fluturi_DataImportMuzeu
	-- Tipul acesteia este un DATETIME (data si ora)
	-- GETDATE() - apel sistem care returneaza/furnizeaza data si ora curenta
	-- Pentru a elimina/sterge aceasta coloana din tabela trebuie sa stergem mai intai constrangerea de integritate default asociata (df_Fluturi_DataImportMuzeu)
	ALTER TABLE Fluturi
	ADD DataImportMuzeu DATETIME CONSTRAINT df_Fluturi_DataImportMuzeu DEFAULT GETDATE()
	--ADD DataImportMuzeu DATETIME
	PRINT '[+]S-a adaugat cu succes coloana ''DataImportMuzeu'' cu constrangerea ''df_Fluturi_DataImportMuzeu'' (DEFAULT) in tabelul ''Fluturi'''

	-- Adaugam/Inseram coloana Judet in tabelul/tabela Adrese
	-- Coloana (atributul/campul) nou introdusa va avea constrangerea NOT NULL (fiecare inregistrare/linie va trebui sa aiba neaparat o valoare in aceasta coloana)
	-- Tipul acesteia este un NVARCHAR(50) (sir de caractere UNICODE de maxim 50 de caractere)
	ALTER TABLE Adrese
	ADD Judet NVARCHAR(50) NOT NULL
	PRINT '[+]S-a adaugat cu succes coloana ''Judet'' cu constrangerea NOT NULL in tabelul ''Adrese'''

	-- Adaugam/Inseram coloana Salariu in tabelul/tabela Ingrijitori
	-- Coloana (atributul/campul) nou introdusa va avea constrangerile NOT NULL si CHECK (trebuie ca valorile introduse in aceasta coloana sa fie cel putin egale cu 1000 pentru fiecare inregistrare din acest tabel) cu numele ck_Ingrijitori_Salariu
	-- Tipul acesteia este un TINYINT (intreg fara semn (unsigned) reprezentat pe 1 byte/octet)
	-- Pentru a elimina/sterge aceasta coloana din tabela trebuie sa stergem mai intai constrangerea de integritate check asociata (ck_Ingrijitori_Salariu)
	ALTER TABLE Ingrijitori
	ADD Salariu TINYINT NOT NULL CONSTRAINT ck_Ingrijitori_Salariu CHECK (Salariu >= 1000)
	--ADD Salariu TINYINT
	PRINT '[+]S-a adaugat cu succes coloana ''Salariu'' cu constrangerea ''ck_Ingrijitori_Salariu'' (CHECK) in tabelul ''Ingrijitori'''

	-- Adaugam/Inseram coloana Casatorit in tabelul/tabela Vizitatori
	-- Coloana (atributul/campul) nou introdusa va avea constrangerea DEFAULT cu numele df_Vizitatori_Casatorit
	-- Tipul acesteia este un BIT (poate lua una din valorile 0, 1 si NULL)
	-- Pentru a elimina/sterge aceasta coloana din tabela trebuie sa stergem mai intai constrangerea de integritate default asociata (df_Vizitatori_Casatorit)
	ALTER TABLE Vizitatori
	ADD Casatorit BIT CONSTRAINT df_Vizitatori_Casatorit DEFAULT NULL
	PRINT '[+]S-a adaugat cu succes coloana ''Casatorit'' cu constrangerea ''df_Vizitatori_Casatorit'' (DEFAULT) in tabelul ''Vizitatori'''

	-- Adaugam/Inseram coloana Detinator in tabelul/tabela Bijuterii
	-- Coloana (atributul/campul) nou introdusa va avea constrangerea UNIQUE (nu pot exista doua inregistrari in tabela care sa aiba aceleasi valori in aceasta coloana, cu alte cuvinte valorile din coloana data vor fi unice pe inregistrare)
	-- Tipul acesteia este un NVARCHAR(50) (sir de caractere UNICODE de maxim 50 de caractere)
	--ALTER TABLE Bijuterii
	--ADD Detinator NVARCHAR(50) UNIQUE
	--PRINT '[+]S-a adaugat cu succes coloana ''Detinator'' in tabelul ''Bijuterii'''

	-- Apelam procedura stocata usp_ModifyVersionDB cu parametrul de intrare actual/efectiv 4
	-- Marcam in tabelul/tabela versiune tranzitia in versiunea 4 a bazei de date
	EXEC usp_ModifyVersionDB 4
END

GO

-- Stergem procedura stocata cu numele usp_DowngradeVersionDB4 (in cazul in care aceasta exista deja)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DowngradeVersionDB4')
BEGIN
	DROP PROCEDURE usp_DowngradeVersionDB4
END

GO

-- Cream procedura stocata cu numele usp_DowngradeVersionDB4
-- Aceasta procedura stocata va realiza a 4-a (si penultima) operatie inversa (tranzitia de la versiunea 4 a bazei de date la versiunea 3)
-- Procedura stocata sterge/elimina coloanele (campurile/atributele) create in urma apelului procedurii stocate usp_UpdateVersionDB4 (procedura stocata de tip utilizator care realizeaza operatia complementara procedurii stocate in cauza)
-- Preconditii : baza de date trebuie sa se afle in versiunea 4 (versiunea curenta trebuie sa fie 4 pentru a se putea face downgrade la versiunea 3)
-- Postconditii: se trece baza de date din versiunea superioara 4 in versiunea inferioara 3 (downgrade)
--               se elimina constrangerea de tip DEFAULT cu numele df_FosileDinozauri_Clasa de pe coloana Clasa din tabela FosileDinozauri a bazei de date
--               se sterge coloana (atributul) Clasa din tabela FosileDinozauri a bazei de date
--               se elimina constrangerea de tip DEFAULT cu numele df_Fluturi_DataImportMuzeu de pe coloana DataImportMuzeu din tabela Fluturi a bazei de date
--               se sterge coloana (atributul) DataImportMuzeu din tabela Fluturi a bazei de date
--               se sterge coloana (atributul) Judet din tabela Adrese a bazei de date
--               se elimina constrangerea de tip CHECK cu numele ck_Ingrijitori_Salariu de pe coloana Salariu din tabela Ingrijitori a bazei de date
--               se sterge coloana (atributul) Salariu din tabela Ingrijitori a bazei de date
--               se sterge coloana (atributul) Casatorit din tabela Vizitatori a bazei de date
--               se actualizeaza tabela Versiune prin apelul procedurii stocate usp_ModifyVersionDB cu argumentul 3
CREATE PROCEDURE usp_DowngradeVersionDB4
AS
BEGIN
	--PRINT ''
	PRINT CHAR(13) + '~~DOWNGRADE VERSION 3~~'

	-- Eliminam constrangerile de tip DEFAULT cu numele df_FosileDinozauri_Clasa si CHECK cu numele ck_FosileDinozauri_Clasa de pe coloana Clasa din tabela FosileDinozauri
	-- Prima oara trebuie sterse constrangerile de integritate ascociate si dupa se poate sterge si coloana care le continea (le avea setate)
	ALTER TABLE FosileDinozauri
	DROP CONSTRAINT df_FosileDinozauri_Clasa, ck_FosileDinozauri_Clasa
	PRINT 'S-au sters cu succes constrangerile ''df_FosileDinozauri_Clasa'' (DEFAULT) si ''ck_FosileDinozauri_Clasa'' (CHECK) din tabela ''FosileDinozauri'''

	-- Stergem/Eliminam coloana Clasa din tabelul/tabela FosileDinozauri
	ALTER TABLE FosileDinozauri
	DROP COLUMN Clasa
	PRINT '[-]S-a sters/eliminat cu succes coloana ''Clasa'' din tabela ''FosileDinozauri'''

	-- Eliminam constrangerea de tip DEFAULT cu numele df_Fluturi_DataImportMuzeu de pe coloana DataImportMuzeu din tabela Fluturi
	-- Prima oara trebuie stearsa constrangerea si dupa se poate sterge si coloana
	ALTER TABLE Fluturi
	DROP CONSTRAINT df_Fluturi_DataImportMuzeu
	PRINT 'S-a sters cu succes constrangerea ''df_Fluturi_DataImportMuzeu'' (DEFAULT) din tabela ''Fluturi'''

	-- Stergem/Eliminam coloana DataImportMuzeu din tabelul/tabela Fluturi
	ALTER TABLE Fluturi
	DROP COLUMN DataImportMuzeu
	PRINT '[-]S-a sters/eliminat cu succes coloana ''DataImportMuzeu'' din tabela ''Fluturi'''

	-- Stergem/Eliminam coloana Judet din tabelul/tabela Adrese
	ALTER TABLE Adrese
	DROP COLUMN Judet
	PRINT '[-]S-a sters/eliminat cu succes coloana ''Judet'' din tabela ''Adrese'''

	-- Eliminam constrangerea de tip CHECK cu numele ck_Ingrijitori_Salariu de pe coloana Salariu din tabela Ingrijitori
	-- Prima oara trebuie stearsa constrangerea si dupa se poate sterge si coloana
	ALTER TABLE Ingrijitori
	DROP CONSTRAINT ck_Ingrijitori_Salariu
	PRINT 'S-a sters cu succes constrangerea ''ck_Ingrijitori_Salariu'' (CHECK) din tabela ''Ingrijitori'''

	-- Stergem/Eliminam coloana Salariu din tabelul/tabela Ingrijitori
	ALTER TABLE Ingrijitori
	DROP COLUMN Salariu
	PRINT '[-]S-a sters/eliminat cu succes coloana ''Salariu'' din tabela ''Ingrijitori'''

	-- Eliminam constrangerea de tip DEFAULT cu numele df_Vizitatori_Casatorit de pe coloana Casatorit din tabela Vizitatori
	-- Prima oara trebuie stearsa constrangerea si dupa se poate sterge si coloana
	ALTER TABLE Vizitatori
	DROP CONSTRAINT df_Vizitatori_Casatorit
	PRINT 'S-a sters cu succes constrangerea ''df_Vizitatori_Casatorit'' (DEFAULT) din tabela ''Vizitatori'''

	-- Stergem/Eliminam coloana Casatorit din tabelul/tabela Vizitatori
	ALTER TABLE Vizitatori
	DROP COLUMN Casatorit
	PRINT '[-]S-a sters/eliminat cu succes coloana ''Casatorit'' din tabela ''Vizitatori'''

	-- Stergem/Eliminam coloana Detinator din tabelul/tabela Bijuterii
	--ALTER TABLE Bijuterii
	--DROP COLUMN Detinator
	--PRINT '[-]S-a sters/eliminat cu succes coloana ''Detinator'' din tabela ''Bijuterii'''

	-- Apelam procedura stocata usp_ModifyVersionDB cu parametrul de intrare actual/efectiv 3
	-- Marcam in tabelul/tabela versiune tranzitia in versiunea 3 a bazei de date
	EXEC usp_ModifyVersionDB 3
END

GO

-- Stergem procedura stocata cu numele usp_UpdateVersionDB5 (in cazul in care aceasta exista deja)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_UpdateVersionDB5')
BEGIN
	DROP PROCEDURE usp_UpdateVersionDB5
END

GO

-- Cream procedura stocata cu numele usp_UpdateVersionDB5
-- Aceasta procedura stocata va realiza a 5-a (si ultima) operatie directa (tranzitia de la versiunea 4 a bazei de date la versiunea 5 (finala))
-- Procedura stocata adauga constrangeri de integritate de tipul foreign key (cheie straina) pe unele coloane din tabelele bazei de date
-- Daca vrem sa adaugam o constrangere de tipul cheie straina (externa) pe o coloana inexistenta dintr-o tabela atunci vom crea mai intai coloana (campul/atributul) respectiv caruia sa ii setam constrangerea de foreing key
-- In urma executiei procedurii, toate tabelele nou create in versiunea 3 a bazei de date se vor afla in relatii cu alte tabele din baza de date (nu vor mai exista tabeluri izolate in structura bazei de date, cu exceptia tabelei Versiune care este o tabela pur informativa)
-- Preconditii : baza de date trebuie sa se afle in versiunea 4 (versiunea curenta trebuie sa fie 4 pentru a se putea face update la versiunea 5)
-- Postconditii: se trece baza de date din versiunea inferioara 4 in versiunea superioara 5 (finala) (update)
--               se adauga coloana/campul CNPIngrijitor de tipul CHAR(13) in tabelul Vitrine
--               se seteaza constrangerea de FOREIGN KEY cu numele fk_Vitrine_CNPIngrijitor pe coloana CNPIngrijitor din tabelul Vitrine (aceasta va pointa la cheia primara (PRIMARY KEY) CNPIngrijitor din tabelul Ingrijitori)
--               se seteaza constrangerea de FOREIGN KEY cu numele fk_Telefoane_CNPPaznic pe coloana CNPPaznic din tabelul Telefoane (aceasta va pointa la cheia primara (PRIMARY KEY) CNPPaznic din tabelul Paznici)
--               se seteaza constrangerea de FOREIGN KEY cu numele fk_Adrese_AdresaID pe coloana AdresaID din tabelul Adrese (aceasta va pointa la cheia primara (PRIMARY KEY) NrLegitimatie din tabelul Vizitatori)
--               se seteaza constrangerea de FOREIGN KEY cu numele fk_GhiziFluturi_CNPGhid pe coloana CNPGhid din tabelul GhiziFluturi (aceasta va pointa la cheia primara (PRIMARY KEY) CNPGhid din tabelul Ghizi)
--               se seteaza constrangerea de FOREIGN KEY cu numele fk_GhiziFluturi_FlutureID pe coloana FlutureID din tabelul GhiziFluturi (aceasta va pointa la cheia primara (PRIMARY KEY) FlutureID din tabelul Fluturi)
--               se actualizeaza tabela Versiune prin apelul procedurii stocate usp_ModifyVersionDB cu argumentul 5
CREATE PROCEDURE usp_UpdateVersionDB5
AS
BEGIN
	--PRINT ''
	PRINT CHAR(13) + '~~UPDATE VERSION 5~~'

	-- Adaugam coloana CNPIngrijitor in tabela Vitrine
	-- Ii atribuim tipul de data CHAR(13) (sir de caractere de lungime fixa, adica cu exact 13 caractere)
	-- Nu ii setam nicio constrangere acestei coloane noi adaugate/inserate
	ALTER TABLE Vitrine
	ADD CNPIngrijitor CHAR(13)
	PRINT '[+]S-a adaugat cu succes coloana ''CNPIngrijitor'' in tabela ''Vitrine'''

	-- Adaugam constrangerea cu numele fk_Vitrine_CNPIngrijitor pe coloana CNPIngrijitor din tabela Vitrine
	-- Coloana CNPIngrijitor va fi acum o cheie straina (externa) ce va pointa la cheia primara CNPInjrijitor din tabela Ingrijitori
	-- Cele doua tabele (Ingrijitori si Vitrine) se vor afla in relatie 1:n (tabela Ingrijitori este partea 1 a relatiei, iar tabela Vitrine este partea n a relatiei)
	-- O vitrina este spalata de un singur ingrijitor => 1:1
	-- Un ingrijitor spala mai multe vitrine          => 1:n
	-- => relatie 1:n (one to many)
	ALTER TABLE Vitrine
	ADD CONSTRAINT fk_Vitrine_CNPIngrijitor FOREIGN KEY(CNPIngrijitor) REFERENCES Ingrijitori(CNPIngrijitor)
	ON UPDATE SET NULL
	ON DELETE SET NULL
	PRINT '[+]S-a adaugat cu succes constrangerea de cheie straina (externa) cu numele ''fk_Vitrine_CNPIngrijitor'' pe coloana ''CNPIngrijitor'' din tabela ''Vitrine'''

	-- Adaugam constrangerea cu numele fk_Telefoane_CNPPaznic pe coloana CNPPaznic din tabela Telefoane
	-- Coloana CNPPaznic va fi acum o cheie straina (externa) ce va pointa la cheia primara CNPPaznic din tabela Paznici
	-- Cele doua tabele (Paznici si Telefoane) se vor afla in relatie 1:n (tabela Paznici este partea 1 a relatiei, iar tabela Telefoane este partea n a relatiei)
	-- Un telefon ii apartine unui singur paznic   => 1:1
	-- Un paznic poate sa aiba mai multe telefoane => 1:n
	-- => relatie 1:n (one to many)
	ALTER TABLE Telefoane
	ADD CONSTRAINT fk_Telefoane_CNPPaznic FOREIGN KEY(CNPPaznic) REFERENCES Paznici(CNPPaznic)
	ON UPDATE CASCADE
	ON DELETE CASCADE
	PRINT '[+]S-a adaugat cu succes constrangerea de cheie straina (externa) cu numele ''fk_Telefoane_CNPPaznic'' pe coloana ''CNPPaznic'' din tabela ''Telefoane'''

	-- Adaugam constrangerea cu numele fk_Adrese_AdresaID pe coloana AdresaID din tabela Adrese
	-- Coloana AdresaID va fi acum o cheie straina (externa) ce va pointa la cheia primara NrLegitimatie din tabela Vizitatori
	-- AdresaID este atat cheie primara (PRIMARY KEY) cat si cheie straina (FOREIGN KEY) in tabela Adrese
	-- Cele doua tabele (Adrese si Vizitatori) se vor afla in relatie 1:1
	-- Cum tabela Vizitatori este prima creata, inseamna ca tabela Adrese va avea cheia primara setata ca si cheie straina
	-- La o adresa locuieste un singur vizitator           => 1:1
	-- Un vizitator isi are domiciliul la o singura adresa => 1:1
	-- => relatie 1:1 (one to one)
	ALTER TABLE Adrese
	ADD CONSTRAINT fk_Adrese_AdresaID FOREIGN KEY(AdresaID) REFERENCES Vizitatori(NrLegitimatie)
	ON UPDATE CASCADE
	ON DELETE CASCADE
	PRINT '[+]S-a adaugat cu succes constrangerea de cheie straina (externa) cu numele ''fk_Adrese_AdresaID'' pe coloana ''AdresaID'' din tabela ''Adrese'''

	-- Adaugam constrangerea cu numele fk_GhiziFluturi_CNPGhid pe coloana CNPGhid din tabela GhiziFluturi
	-- Coloana CNPGhid va fi acum o cheie straina (externa) ce va pointa la cheia primara CNPGhid din tabela Ghizi
	-- Cele doua tabele (Fluturi si Ghizi) se vor afla in relatie m:n
	-- Un fluture este prezentat de mai multi ghizi turistici    => 1:n
	-- Un ghid turistic prezinta vizitatorilor mai multi fluturi => 1:n
	-- => relatie m:n (many to many)
	ALTER TABLE GhiziFluturi
	ADD CONSTRAINT fk_GhiziFluturi_CNPGhid FOREIGN KEY(CNPGhid) REFERENCES Ghizi(CNPGhid)
	ON UPDATE CASCADE
	ON DELETE CASCADE
	PRINT '[+]S-a adaugat cu succes constrangerea de cheie straina (externa) cu numele ''fk_GhiziFluturi_CNPGhid'' pe coloana ''CNPGhid'' din tabela ''GhiziFluturi'''

	-- Adaugam constrangerea cu numele fk_GhiziFluturi_FlutureID pe coloana FlutureID din tabela GhiziFluturi
	-- Coloana FlutureID va fi acum o cheie straina (externa) ce va pointa la cheia primara FlutureID din tabela Fluturi
	ALTER TABLE GhiziFluturi
	ADD CONSTRAINT fk_GhiziFluturi_FlutureID FOREIGN KEY(FlutureID) REFERENCES Fluturi(FlutureID)
	ON UPDATE CASCADE
	ON DELETE CASCADE
	PRINT '[+]S-a adaugat cu succes constrangerea de cheie straina (externa) cu numele ''fk_GhiziFluturi_FlutureID'' pe coloana ''FlutureID'' din tabela ''GhiziFluturi'''

	-- Apelam procedura stocata usp_ModifyVersionDB cu parametrul de intrare actual/efectiv 5
	-- Marcam in tabelul/tabela versiune tranzitia in versiunea 5 (finala) a bazei de date
	EXEC usp_ModifyVersionDB 5
END

GO

-- Stergem procedura stocata cu numele usp_DowngradeVersionDB5 (in cazul in care aceasta exista deja)
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_DowngradeVersionDB5')
BEGIN
	DROP PROCEDURE usp_DowngradeVersionDB5
END

GO

-- Cream procedura stocata cu numele usp_DowngradeVersionDB5
-- Aceasta procedura stocata va realiza a 5-a (si ultima) operatie inversa (tranzitia de la versiunea 5 (finala) a bazei de date la versiunea 4)
-- Procedura va sterge constrangerile de integritate de tipul foreign key adaugate pe unele coloane din tabelele bazei de date in urma apelului procedurii stocate usp_UpdateVersionDB5 (care face tranzitia versiunii bazei de date din 4 in 5)
-- Preconditii : baza de date trebuie sa se afle in versiunea 5 (versiunea curenta trebuie sa fie 5 pentru a se putea face downgrade la versiunea 4)
-- Postconditii: se trece baza de date din versiunea superioara 5 (finala) in versiunea inferioara 4 (downgrade)
--               se sterge constrangerea de FOREING KEY (cheie straina/externa) cu numele fk_Vitrine_CNPIngrijitor din tabela Vitrine (de pe coloana CNPIngrijitor)
--               se elimina coloana CNPIngrijitor din tabela Vitrine
--               se sterge constrangerea de FOREING KEY (cheie straina/externa) cu numele fk_Telefoane_CNPPaznic din tabela Telefoane (de pe coloana CNPPaznic)
--               se sterge constrangerea de FOREING KEY (cheie straina/externa) cu numele fk_Adrese_AdresaID din tabela Adrese (de pe coloana AdresaID)
--               se sterge constrangerea de FOREING KEY (cheie straina/externa) cu numele fk_GhiziFluturi_CNPGhid din tabela GhiziFluturi (de pe coloana CNPGhid)
--               se sterge constrangerea de FOREING KEY (cheie straina/externa) cu numele fk_GhiziFluturi_FlutureID din tabela GhiziFluturi (de pe coloana FlutureID)
--               se actualizeaza tabela Versiune prin apelul procedurii stocate usp_ModifyVersionDB cu argumentul 4
CREATE PROCEDURE usp_DowngradeVersionDB5
AS
BEGIN
	--PRINT ''
	PRINT CHAR(13) + '~~DOWNGRADE VERSION 4~~'

	-- Eliminam constrangerea de integritate, de tipul cheie straina, asociata coloanei CNPIngrijitor din tabela Vitrine
	-- Pentru ca aceasta coloana sa poata fi stearsa/eliminata din tabela in care se afla, ea trebuie sa nu mai refere o cheie primara (adica sa isi piarda constrangerea de integritate de tipul cheie straina)
	ALTER TABLE Vitrine
	DROP CONSTRAINT fk_Vitrine_CNPIngrijitor
	PRINT '[-]S-a sters cu succes constrangerea de FOREIGN KEY cu numele ''fk_Vitrine_CNPIngrijitor'' din tabelul ''Vitrine'''

	-- Stergem coloana (campul/atributul) CNPIngrijitor din tabela Vitrine
	ALTER TABLE Vitrine
	DROP COLUMN CNPIngrijitor
	PRINT '[-]S-a sters cu succes coloana ''CNPIngrijitor'' din tabelul ''Vitrine'''

	-- Eliminam constrangerea de integritate, de tipul cheie straina, asociata coloanei CNPPaznic din tabela Telefoane
	ALTER TABLE Telefoane
	DROP CONSTRAINT fk_Telefoane_CNPPaznic
	PRINT '[-]S-a sters cu succes constrangerea de FOREIGN KEY cu numele ''fk_Telefoane_CNPPaznic'' din tabelul ''Telefoane'''

	-- Eliminam constrangerea de integritate, de tipul cheie straina, asociata coloanei AdresaID din tabela Adrese
	ALTER TABLE Adrese
	DROP CONSTRAINT fk_Adrese_AdresaID
	PRINT '[-]S-a sters cu succes constrangerea de FOREIGN KEY cu numele ''fk_Adrese_AdresaID'' din tabelul ''Adrese'''

	-- Eliminam constrangerea de integritate, de tipul cheie straina, asociata coloanei CNPGhid din tabela GhiziFluturi
	ALTER TABLE GhiziFluturi
	DROP CONSTRAINT fk_GhiziFluturi_CNPGhid
	PRINT '[-]S-a sters cu succes constrangerea de FOREIGN KEY cu numele ''fk_GhiziFluturi_CNPGhid'' din tabelul ''GhiziFluturi'''

	-- Eliminam constrangerea de integritate, de tipul cheie straina, asociata coloanei FlutureID din tabela GhiziFluturi
	ALTER TABLE GhiziFluturi
	DROP CONSTRAINT fk_GhiziFluturi_FlutureID
	PRINT '[-]S-a sters cu succes constrangerea de FOREIGN KEY cu numele ''fk_GhiziFluturi_FlutureID'' din tabelul ''GhiziFluturi'''

	-- Apelam procedura stocata usp_ModifyVersionDB cu parametrul de intrare actual/efectiv 4
	-- Marcam in tabelul/tabela versiune tranzitia in versiunea 4 a bazei de date
	EXEC usp_ModifyVersionDB 4
END

GO

-- Stergem procedura stocata cu numele usp_VersionControl
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'usp_VersionControl')
BEGIN
	DROP PROCEDURE usp_VersionControl
END

GO

-- Cream o procedura stocata cu numele usp_VersionControl
-- Aceasta procedura stocata va reprezenta mecanismul principal de versionare a bazei de date
-- Ea va facilita tranzitia de la o versiune curenta la orice alta versiune indicata de parametrul formal/simbolic @NrVersiuneNouaStr
-- Se va arunca exceptie in cazul in care acest argument este invalid (nu este o valoare numerica de o singura cifra) si nu reprezinta o versiune valida (numar intreg de la 0 la 5)
-- Prin acest sistem de versionare se poate trece de la o versiune inferioara la una superioara, dar si invers (de la o versiune superioara la una inferioara)
-- Preconditii (restrictii asupra datelor de intrare): @NrVersiuneNouaStr IN ('0', '1', '2', '3', '4', '5'), sir de caractere de lungime 1 (cu un singur caracter) care contine o cifra de la 0 la 5 sub forma de text
-- Postconditii (descrierea rezultatelor)            : se face tranzitia bazei de date din versiunea curenta in versiunea indicata de argumentul @NrVersiuneNouaStr al procedurii stocate si se modifica unica inregistrare din tabelul/tabela Versiune
-- Procedura arunca exceptii cu 3 numere diferite de eroare: 50002 - lungime invalida text
--                                                           50003 - continut invalid text (caracterul nu este cifra, este non-numeric)
--                                                           50004 - versiune inexistenta
CREATE PROCEDURE usp_VersionControl
-- Parametrii de intrare (parametrii formali/simbolici) ai procedurii stocate (argumentele acesteia)
-- @NrVersiuneNouaStr - versiunea noua (reprezentata ca si un sir de caractere) la care vrem sa aducem baza de date
-- Aceasta variabila de tip text poate sa contina MAX caractere (MAX - valoare predefinita (default) de tip constanta)
(@NrVersiuneNouaStr VARCHAR(MAX))
AS
BEGIN
	-- Declaram o variabila de tipul VARCHAR(100) (text cu cel mult 100 de caractere si de lungime variabila) cu numele @MesajEroare
	-- In aceasta variabila vom stoca/retine mesajul de exceptie in cazul in care parametrul de intrare (@NrVersiuneNouaStr) al procedurii stocate este invalid (nu respecta preconditiile, adica restrictiile impuse asupra valorii actuale/efective a acestuia)
	DECLARE @MesajEroare VARCHAR(100)

	-- @NrVersiuneNouaStr trebuie sa contina un singur caracter care sa reprezinte cifra corespunzatoare versiunii in care dorim sa aducem structura bazei de date
	IF (LEN(@NrVersiuneNouaStr) != 1)
	BEGIN
		-- @NrVersiuneNouaStr contine prea putine caractere (adica 0)
		-- @NrVersiuneNouaStr reprezinta un sir de caractere vid (nu contine niciun caracter)
		IF LEN(@NrVersiuneNouaStr) < 1
		BEGIN
			-- Setam in mod corespunzator mesajul de eroare pentru a oferi feedback utilizatorului
			SET @MesajEroare = 'Lungime invalida parametru: au fost introduse prea putine caractere!'
		END
		-- @NrVersiuneNouaStr contine prea multe caractere (adica > 1, respectiv >= 2)
		ELSE
		BEGIN
			-- Setam in mod corespunzator mesajul de eroare pentru a oferi feedback utilizatorului
			SET @MesajEroare = 'Lungime invalida parametru: au fost introduse prea multe caractere!'
		END;

		-- Aruncam exceptie folosind instructiune THROW pentru a semnala o situatie exceptionala (anormala de executie)
		-- error_number - 50002 (numele erorii)
		-- message      - @MesajEroare (mesajul exceptiei/erorii)
		-- state        - 1 (starea)
		THROW 50002, @MesajEroare, 1
	END

	-- @NrVersiuneNouaStr contine un singur caracter, dar acesta nu reprezinta o cifra, deci prin urmare nu este valid
	IF (@NrVersiuneNouaStr NOT BETWEEN '0' AND '9') -- IF (@NrVersiuneNouaStr < '0' OR @NrVersiuneNouaStr > '9')
	BEGIN
		-- Setam in mod corespunzator mesajul de eroare pentru a oferi feedback utilizatorului
		SET @MesajEroare = 'Argument invalid: caracterul introdus nu este o cifra!';
		
		-- Aruncam exceptie folosind instructiune THROW pentru a semnala o situatie exceptionala (anormala de executie)
		-- error_number - 50003 (numele erorii)
		-- message      - @MesajEroare (mesajul exceptiei/erorii)
		-- state        - 1 (starea)
		THROW 50003, @MesajEroare, 1
	END

	-- Declarama o variabila cu numele @NrVersiuneNoua de tipul TINYINT (unsigned char)
	DECLARE @NrVersiuneNoua TINYINT
	-- Setam aceasta variabila nou definita/declarata cu intregul corespunzator variabilei @NrVersiuneNouaStr (variabila de tip sir de caractere)
	-- Astfel, folosind apelul sistem CONVERT, facem conversia explicita a variabilei @NrVersiuneNouaStr de la VARCHAR(MAX) (unde MAX este 1 in acest caz) la TINYINT
	-- Rezultatul conversiei va fi retinut in variabila @NrVersiuneNoua mentionata anterior
	SET @NrVersiuneNoua = CONVERT(TINYINT, @NrVersiuneNouaStr)

	-- Versiunea @NrVersiuneNoua nu este valida
	-- @NrVersiuneNoua este o cifra, dar acesta nu reprezinta o versiune disponibila a bazei de date
	-- Astfel, nu se poate trece de la versiunea curenta a bazei de date la versiunea indicata de @NrVersiuneNoua pentru ca aceasta nu exista la momentul de fata
	IF (@NrVersiuneNoua >= 6) -- IF @NrVersiuneNoua < 0 OR @NrVersiuneNoua > 5
	BEGIN
		-- Setam in mod corespunzator mesajul de eroare pentru a oferi feedback utilizatorului
		SET @MesajEroare = 'Versiune inexistenta: versiunile valabile sunt de la 0 la 5!';
		
		-- Aruncam exceptie folosind instructiune THROW pentru a semnala o situatie exceptionala (anormala de executie)
		-- error_number - 50004 (numele erorii)
		-- message      - @MesajEroare (mesajul exceptiei/erorii)
		-- state        - 1 (starea)
		THROW 50004, @MesajEroare, 1
	END

	-- Declaram variabila @Ver avand tipul de data TINYINT
	DECLARE @Ver TINYINT
	-- Incarcam/Setam variabila @Ver cu versiunea curenta a bazei de date (pe care o extragem din coloana NrVersiuneCurenta a tabelei Versiune)
	SET @Ver = (SELECT NrVersiuneCurenta FROM Versiune)

	-- Baza de date se afla deja in versiunea dorita
	-- In acest caz, structura nu va suferi modificari (baza de date ramane neschimbata)
	IF (@NrVersiuneNoua = @Ver)
	BEGIN
		PRINT '[=]Baza de date se afla deja in versiunea ' + CONVERT(CHAR(1), @Ver)
	END
	ELSE
	BEGIN
		-- Variabila textuala in care vom construi numele procedurii stocate pe care vrem sa o apelam
		-- Aceasta este de tipul VARCHAR(50), adica un sir de caractere cu lungime variabila de maxim 50 de caractere (simboluri)
		DECLARE @NumeComanda VARCHAR(50)

		-- Retinem/Stocam in variabila @NrVersiuneVeche, vechea versiune a bazei de date
		-- @NrVersiuneVeche reprezeinta versiunea curenta de la care facem tranzitia (update sau downgrade) in noua versiune (cea dorita)
		DECLARE @NrVersiuneVeche TINYINT
		SET @NrVersiuneVeche = @Ver

		-- Facem update de la o versiune inferioara la una superioara
		IF (@Ver < @NrVersiuneNoua)
		BEGIN
			PRINT '[!]Update de la versiunea ' + CONVERT(CHAR(1), @Ver) + ' la versiunea ' + CONVERT(CHAR(1), @NrVersiuneNoua)
			
			-- Iteram prin toate starile (versiunile) intermediare de la versiunea curenta si pana la versiunea noua (cea finala)
			-- Ciclarea se face crescator (de la @Ver inclusiv si pana la @NrVersiuneNoua exclusiv)
			-- Pasul (step) este 1
			WHILE (@Ver < @NrVersiuneNoua) -- WHILE @Ver != @NrVersiuneNoua
			BEGIN
				-- Incrementam variabila @Ver
				SET @Ver = @Ver + 1
				
				-- Construim comanda de executat in variabila @NumeComanda
				SET @NumeComanda = 'usp_UpdateVersionDB' + CONVERT(CHAR(1), @Ver)
				-- Executam comanda a carui nume corespunde variabilei @NumeComanda (variabila de tip text (sir de caractere))
				EXEC @NumeComanda
			END
		END
		-- Facem downgrade de la o versiune superioara la una inferioara
		ELSE
		BEGIN
			PRINT '[!]Downgrade de la versiunea ' + CONVERT(CHAR(1), @Ver) + ' la versiunea ' + CONVERT(CHAR(1), @NrVersiuneNoua)

			-- Iteram prin toate starile (versiunile) intermediare de la versiunea curenta si pana la versiunea noua (cea finala)
			-- Ciclarea se face descrescator (de la @Ver inclusiv si pana la @NrVersiuneNoua exclusiv)
			-- Pasul (step) este -1
			WHILE (@Ver > @NrVersiuneNoua) -- WHILE @Ver != @NrVersiuneNoua
			BEGIN
				-- Construim comanda de executat in variabila @NumeComanda
				SET @NumeComanda = 'usp_DowngradeVersionDB' + CONVERT(CHAR(1), @Ver)
				-- Executam comanda a carui nume corespunde variabilei @NumeComanda (variabila de tip text (sir de caractere))
				EXEC @NumeComanda
				
				-- Decrementam variabila @Ver
				SET @Ver = @Ver - 1
			END
		END
		
		PRINT 'Baza de date a trecut cu succes la versiunea ' + CONVERT(CHAR(1), @NrVersiuneNoua)

		-- Actualizam versiunea curenta (precum si versiunea anterioara a bazei de date si data ultimei modificari/actualizari de structura) in tabela Versiune
		DELETE FROM Versiune
		INSERT INTO Versiune(NrVersiuneCurenta, NrVersiunePrecedenta, DataUltimeiModificari) VALUES(@NrVersiuneNoua, @NrVersiuneVeche, GETDATE())

		-- Afisam tabela Versiune
		-- Tiparim versiunea curenta a bazei de date
		SELECT NrVersiuneCurenta AS 'Versiune curenta baza de date', NrVersiunePrecedenta AS 'Versiune anterioara baza de date', DataUltimeiModificari AS 'Data modificarii versiunii bazei de date' FROM Versiune
	END
END

GO

-- TESTARE PROCEDURI STOCATE PRIN APEL

-- Apeluri pentru procedurile stocate care efectueaza operatiile directe
-- Scripturile corespunzatoare acestor proceduri stocate de tip user (utilizator) efectueaza tranzitia bazei de date de la o versiune inferioara la una superioara
-- Pentru o versiune curenta se poate trece doar la versiunea imediat urmatoare
--EXEC usp_UpdateVersionDB1
--EXEC usp_UpdateVersionDB2
--EXEC usp_UpdateVersionDB3
--EXEC usp_UpdateVersionDB4
--EXEC usp_UpdateVersionDB5

--SELECT * FROM Versiune

-- Apeluri pentru procedurile stocate care efectueaza operatiile inverse/complementare
-- Scripturile corespunzatoare acestor proceduri stocate de tip user (utilizator) efectueaza tranzitia bazei de date de la o versiune superioara la una inferioara
-- Pentru o versiune curenta se poate trece doar la versiunea imediat anterioara/precedenta
--EXEC usp_DowngradeVersionDB5
--EXEC usp_DowngradeVersionDB4
--EXEC usp_DowngradeVersionDB3
--EXEC usp_DowngradeVersionDB2
--EXEC usp_DowngradeVersionDB1

--SELECT * FROM Versiune

-- Apeluri pentru procedura stocata principala (cea care faciliteaza tranzitia de la o versiune a baze de date la alta)
-- Se poate trece de la versiunea curenta la orice alta versiune existenta (disponibila)
-- Apeluri valide
--EXEC usp_VersionControl 4
--EXEC usp_VersionControl 2
--EXEC usp_VersionControl 5
--EXEC usp_VersionControl 1
--EXEC usp_VersionControl 3
--EXEC usp_VersionControl 0

--EXEC usp_VersionControl '2'
--EXEC usp_VersionControl '4'
--EXEC usp_VersionControl '1'
--EXEC usp_VersionControl '3'
--EXEC usp_VersionControl '5'
--EXEC usp_VersionControl '0'

-- Apeluri invalide
--EXEC usp_VersionControl ''
--EXEC usp_VersionControl 'abc'
--EXEC usp_VersionControl '23'
--EXEC usp_VersionControl 'x2yz1'
--EXEC usp_VersionControl 'i'
--EXEC usp_VersionControl '_'
--EXEC usp_VersionControl '9'
--EXEC usp_VersionControl 6
--EXEC usp_VersionControl '+5'
--EXEC usp_VersionControl -3

-- Instructiune SQL (Structured Query Language) de tip DML (Data Manipulation Language) care afiseaza (tipareste) toate inregistrarile din tabelul/tabela Versiune
-- Se vor selecta toate coloanele acestei tabele
--SELECT * FROM Versiune

-- Versiune veche (outdated) pentru procedura stocata principala pentru controlul versionarii bazei de date (facilitarea tranzitiei de la o versiune la alta)
-- Aceasta procedura avea parametrul de intrare de tin intreg (INT)
/*
CREATE PROCEDURE usp_VersionControl
(@NrVersiuneNoua INT)
AS
BEGIN
	IF @NrVersiuneNoua < 0 OR @NrVersiuneNoua > 5
	BEGIN
		DECLARE @MesajEroare VARCHAR(50)
		SET @MesajEroare = 'Versiunea ' + STR(@NrVersiuneNoua) + ' nu este valida!\n'
		
		RAISERROR(@MesajEroare, 11, 1);
	END
	ELSE
	BEGIN
		DECLARE @Ver TINYINT
		SET @Ver = (SELECT NrVersiuneCurenta FROM Versiune)

		IF @NrVersiuneNoua = @Ver
		BEGIN
			PRINT '[=]Baza de date se afla deja in versiunea ' + CONVERT(VARCHAR(1), @Ver)
		END
		ELSE
		BEGIN
			DECLARE @NumeComanda VARCHAR(20)
			
			IF @NrVersiuneNoua < @Ver
			BEGIN
				PRINT '[!]Update de la versiunea ' + CONVERT(VARCHAR(1), @Ver) + ' la versiunea ' + CONVERT(VARCHAR(1), @NrVersiuneNoua)
				
				WHILE @Ver < @NrVersiuneNoua -- WHILE @Ver != @NrVersiuneNoua
				BEGIN
					SET @Ver = @Ver + 1
					
					SET @NumeComanda = 'usp_UpdateVersionDB' + CONVERT(VARCHAR(1), @Ver)
					EXEC @NumeComanda
				END
			END
			ELSE
			BEGIN
				PRINT '[!]Downgrade de la versiunea ' + CONVERT(VARCHAR(1), @Ver) + ' la versiunea ' + CONVERT(VARCHAR(1), @NrVersiuneNoua)

				WHILE @Ver > @NrVersiuneNoua -- WHILE @Ver != @NrVersiuneNoua
				BEGIN
					SET @NumeComanda = 'usp_DowngradeVersionDB' + CONVERT(VARCHAR(1), @Ver)
					EXEC @NumeComanda
					
					SET @Ver = @Ver - 1
				END
			END

			EXEC usp_ModifyVersionDB @NrVersiuneNoua
			PRINT 'Baza de date a trecut cu succes la versiunea ' + CONVERT(VARCHAR(1), @NrVersiuneNoua)
		END
	END
END
*/