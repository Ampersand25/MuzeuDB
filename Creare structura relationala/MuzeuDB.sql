USE master
GO

DROP DATABASE MuzeuDB
GO

CREATE DATABASE MuzeuDB
GO
USE MuzeuDB
GO

CREATE TABLE Vizitatori
(
	NrLegitimatie INT CONSTRAINT pk_Vizitatori_NrLegitimatie PRIMARY KEY IDENTITY,
	Nume VARCHAR(50) CONSTRAINT nn_Vizitatori_Nume NOT NULL,
	Prenume VARCHAR(50) CONSTRAINT nn_Vizitatori_Prenume NOT NULL,
	Varsta INT,
	CONSTRAINT uq_Vizitatori_Nume_Prenume UNIQUE (Nume, Prenume)
)

CREATE TABLE Vitrine
(
	VitrinaID INT CONSTRAINT pk_Vitrine_VitrinaID PRIMARY KEY IDENTITY(1, 1),
	Lungime INT CONSTRAINT nn_Vitrine_Lungime NOT NULL,
	Latime INT CONSTRAINT nn_Vitrine_Latime NOT NULL,
	Inaltime INT CONSTRAINT nn_Vitrine_Inaltime NOT NULL,
	CONSTRAINT ck_Vitrine_Lungime_Latime_Inaltime CHECK (Lungime > 0 AND Latime > 0 AND Inaltime > 0)
)

-- Un vas se afla intr-o singura vitrina     => 1:1
-- O vitrina poate sa contina mai multe vase => 1:n
-- Asadar exista o relatie 1:n (one to many) intre tabelele/entitatile Vitrine (partea 1 a relatiei care se va crea prima) si Vase (partea n a relatiei)
CREATE TABLE Vase
(
	VasID INT CONSTRAINT pk_Vase_VasID PRIMARY KEY,
	Culoare VARCHAR(50) CONSTRAINT df_Vase_Culoare DEFAULT 'Maro',
	Material VARCHAR(50) CONSTRAINT ck_Vase_Material CHECK (Material IN ('Ceramica', 'Argila', 'Lut')),
	Vechime INT,
	VitrinaID INT CONSTRAINT fk_Vase_VitrinaID FOREIGN KEY(VitrinaID) REFERENCES Vitrine(VitrinaID)
	ON UPDATE SET NULL
	ON DELETE SET NULL
)

CREATE TABLE Ghizi
(
	CNPGhid VARCHAR(50) CONSTRAINT pk_Ghizi_CNPGhid PRIMARY KEY CONSTRAINT ck_Ghizi_CNPGhid CHECK (LEN(CNPGhid) = 13),
	Nume VARCHAR(50) CONSTRAINT nn_Ghizi_Nume NOT NULL,
	Prenume VARCHAR(50) CONSTRAINT nn_Ghizi_Prenume NOT NULL,
	Inaltime FLOAT,
	DataNasterii DATE CONSTRAINT nn_Ghizi_DataNasterii NOT NULL
)

-- Un vizitator interactioneaza cu mai multi ghizi => 1:n
-- Un ghid interactioneaza cu mai multi vizitatori => 1:n
-- Asadar exista o relatie m:n (many to many) intre tabelele/entitatile Vizitatori si Ghizi
CREATE TABLE VizitatoriGhizi
(
	NrLegitimatie INT CONSTRAINT fk_VizitatoriGhizi_NrLegitimatie FOREIGN KEY REFERENCES Vizitatori(NrLegitimatie)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	CNPGhid VARCHAR(50) CONSTRAINT fk_VizitatoriGhizi_CNPGhid FOREIGN KEY REFERENCES Ghizi(CNPGhid)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	CONSTRAINT pk_VizitatoriGhizi_NrLegitimatie_CNPGhid PRIMARY KEY (NrLegitimatie, CNPGhid)
)

-- Un vizitator admira mai multe vase          => 1:n
-- Un vas este admirat de mai multi vizitatori => 1:n
-- Asadar exista o relatie m:n (many to many) intre tabelele/entitatile Vizitatori si Vase
CREATE TABLE VizitatoriVase
(
	NrLegitimatie INT CONSTRAINT fk_VizitatoriVase_NrLegitimatie FOREIGN KEY(NrLegitimatie) REFERENCES Vizitatori(NrLegitimatie)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	VasID INT CONSTRAINT fk_VizitatoriVase_VasID FOREIGN KEY(VasID) REFERENCES Vase(VasID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	CONSTRAINT pk_VzitatoriVase_NrLegitimatie_VasID PRIMARY KEY (NrLegitimatie, VasID)
)

-- Un ghid prezinta mai multe fosile          => 1:n
-- O fosila este prezentata de un singur ghid => 1:n
-- Asadar exista o relatie 1:n (one to many) intre tabelele/entitatile Ghizi (partea 1 a relatiei care se va crea prima) si FosileDinozauri (partea n a relatiei)
CREATE TABLE FosileDinozauri
(
	FosilaDinozaurID INT CONSTRAINT pk_FosileDinozauri_FosilaDinozaurID PRIMARY KEY,
	TipDinozaur VARCHAR(50) CONSTRAINT df_FosileDinozauri_TipDinozaur DEFAULT 'Tyrannosaurus',
	FamilieDinozaur VARCHAR(50) CONSTRAINT df_FosileDinozauri_FamilieDinozaur DEFAULT 'Tyrannosauridae',
	Epoca VARCHAR(50) CONSTRAINT df_FosileDinozauri_Epoca DEFAULT 'Cretacicului superior',
	NrOase INT,
	CNPGhid VARCHAR(50) CONSTRAINT fk_FosileDinozauri_CNPGhid FOREIGN KEY REFERENCES Ghizi(CNPGhid)
	ON UPDATE CASCADE
	ON DELETE SET NULL
)

-- Pe un stand se afla un singur dinozaur => 1:1
-- Un dinozaur se afla pe un singur stand => 1:1
-- Asadar exista o relatie 1:1 (one to one) intre tabelele/entitatile FosileDinozauri si StanduriDinozauri
CREATE TABLE StanduriDinozauri
(
	StandDinozaurID INT CONSTRAINT fk_StanduriDinozauri_StandDinozaurID FOREIGN KEY REFERENCES FosileDinozauri(FosilaDinozaurID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	Material VARCHAR(50),
	Lungime INT,
	Latime INT,
	Inaltime INT,
	CONSTRAINT pk_StanduriDinozaururi_StandDinozaurID PRIMARY KEY (StandDinozaurID),
	CONSTRAINT ck_StanduriDinozauri_Material CHECK (Material = 'Sticla' OR Material = 'Lemn' OR Material = 'Plastic'),
	CONSTRAINT ck_StanduriDinozauri_Lungime_Latime_Inaltime CHECK (Lungime > 0 AND Latime > 0 AND Inaltime > 0)
)

CREATE TABLE Paznici
(
	CNPPaznic VARCHAR(50) CONSTRAINT pk_Paznici_CNPPaznic PRIMARY KEY CONSTRAINT ck_Paznici_CNPPaznic CHECK (LEN(CNPPaznic) = 13),
	Nume VARCHAR(50) CONSTRAINT nn_Paznici_Nume NOT NULL,
	Prenume VARCHAR(50) CONSTRAINT nn_Paznici_Prenume NOT NULL,
	Inaltime FLOAT CONSTRAINT ck_Paznici_Inaltime CHECK (Inaltime > 0),
	Greutate INT,
	DataNasterii DATE CONSTRAINT nn_Paznici_DataNasterii NOT NULL,
	Tura VARCHAR(50) CONSTRAINT ck_Paznici_Tura CHECK (Tura = 'Zi' OR Tura = 'Noapte'),
	Salariu INT
)

-- O bijuterie este pazita de un singur paznic => 1:1
-- Un paznic pazeste mai multe bijuterii       => 1:n
-- Asadar exista o relatie 1:n (one to many) intre tabelele/entitatile Paznici (partea 1 a relatiei care se va crea prima) si Bijuterii (partea n a relatiei)
CREATE TABLE Bijuterii
(
	BijuterieID INT CONSTRAINT pk_Bijuterii_BijuterieID PRIMARY KEY IDENTITY(1, 1),
	Material VARCHAR(50),
	Valoare INT,
	CNPPaznic VARCHAR(50) CONSTRAINT fk_Bijuterii_CNPPaznic FOREIGN KEY(CNPPaznic) REFERENCES Paznici(CNPPaznic)
	ON UPDATE CASCADE
	ON DELETE SET NULL,
	CONSTRAINT ck_Bijuterii_Material CHECK (Material IN ('Aur', 'Argint', 'Bronz', 'Alt material'))
)

-- Un vizitator se uita la mai multe bijuterii => 1:n
-- La o bijuterie se uita mai multi vizitatori => 1:n
-- Asadar exista o relatie m:n (many to many) intre tabelele/entitatile Vizitatori si Bijuterii
CREATE TABLE VizitatoriBijuterii
(
	NrLegitimatie INT CONSTRAINT fk_VizitatoriBijuterii_NrLegitimatie FOREIGN KEY REFERENCES Vizitatori(NrLegitimatie)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	BijuterieID INT CONSTRAINT fk_VizitatoriBijuterii_BijuterieID FOREIGN KEY REFERENCES Bijuterii(BijuterieID)
	ON UPDATE CASCADE
	ON DELETE CASCADE,
	CONSTRAINT pk_VzitatoriBijuterii_NrLegitimatie_BijuterieID PRIMARY KEY (NrLegitimatie, BijuterieID)
)