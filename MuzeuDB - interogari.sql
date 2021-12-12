-- ne conectam la baza de date MuzeuDB
USE MuzeuDB
GO





/*
DELETE FROM [dbo].[VizitatoriGhizi]
DELETE FROM [dbo].[StanduriDinozauri]
DELETE FROM [dbo].[FosileDinozauri]
DELETE FROM [dbo].[Ghizi]
DELETE FROM [dbo].[VizitatoriVase]
DELETE FROM [dbo].[Vase]
DELETE FROM [dbo].[Vitrine]
DELETE FROM [dbo].[VizitatoriBijuterii]
DELETE FROM [dbo].[Vizitatori]
DELETE FROM [dbo].[Bijuterii]
DELETE FROM [dbo].[Paznici]
*/





------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PARTEA DE INSERARI IN TABELE
------------------------------------------------------------------------------------------------------------------------------------------------------------

-- populam tabela (tabelul/entitatea) Vitrine cu 10 inregistrari de date
-- acest tabel contine cheia primara VitrinaID referita de cheia straina VasID din tabelul Vase
-- prin urmare, tabelul Vitrine va fi populat inaintea tabelului Vase
-- inseram 10 inregistrari
INSERT INTO Vitrine(Lungime, Latime, Inaltime) VALUES
(10, 10, 10),
(15, 10, 5 ),
(30, 15, 10),
(20, 25, 15),
(45, 10, 5 ),
(35, 25, 10),
(15, 20, 5 ),
(20, 25, 15),
(20, 10, 15),
(40, 35, 10)

SELECT * FROM Vitrine -- afisam toate inregistrarile din tabelul Vitrine





-- populam tabela (tabelul/entitatea) Vase cu 10 inregistrari de date
-- inseram 14 inregistrari
INSERT INTO Vase(VasID, Culoare, Material, Vechime, VitrinaID) VALUES
(4 , 'Negru'   , 'Ceramica', 527 , 5 ),
(7 , 'Castaniu', 'Lut'     , 1274, 3 ),
(11, 'Negru'   , 'Ceramica', 781 , 7 ),
(12, 'Maro'    , 'Lut'     , 2037, 3 ),
(18, 'Maro'    , 'Ceramica', 837 , 1 ),
(22, 'Castaniu', 'Ceramica', 1735, 9 ),
(25, 'Negru'   , 'Argila'  , 1940, 4 ),
(26, 'Gri'     , 'Lut'     , 2047, 5 ),
(27, 'Rosu'    , 'Ceramica', 941 , 8 ),
(31, 'Negru'   , 'Ceramica', 1845, 2 ),
(44, 'Bej'     , 'Lut'     , 837 , 10),
(48, 'Castaniu', 'Ceramica', 781 , 1 ),
(63, 'Castaniu', 'Argila'  , 837 , 6 ),
(72, 'Gri'     , 'Lut'     , 2684, 3 )
-- inseram inca o inregistrare care va avea coloana (campul/atributul) Culoare setat ca si textul 'Maro' by default (prin constrangerea de consistenta)
INSERT INTO Vase(VasID, Material, Vechime, VitrinaID) VALUES
(91, 'Argila', 2741, 4)

SELECT * FROM Vase -- afisam toate inregistrarile din tabelul Vase





-- populam tabela (tabelul/entitatea) Vizitatori cu 15 inregistrari de date
-- cheia primara NrLegitimatie din acest tabel va fi preluata de tabelele VizitatoriVase, VizitatoriBijuterii si VizitatoriGhizi
-- prin urmare, acest tabel va trebui populat inaintea tabelelor mentionate anterior care vor avea cheie straina/externa care sa pointeze (refere) la cheia primara din acest tabel
-- inseram 15 inregistrari
INSERT INTO Vizitatori(Prenume, Nume, Varsta) VALUES
('Terry'   , 'Alvarado', 41),
('John'    , 'Robinson', 22),
('Roy'     , 'Blake'   , 27),
('Wallace' , 'Nunez'   , 34),
('John'    , 'Curry'   , 19),
('Marty'   , 'White'   , 63),
('Amy'     , 'Curry'   , 18),
('Jessica' , 'Alvarado', 37),
('Pablo'   , 'Alvarado', 9 ),
('Malcolm' , 'Wade'    , 52),
('Betty'   , 'Alvarado', 5 ),
('Bernice' , 'Smith'   , 21),
('John'    , 'Hart'    , 55),
('Roy'     , 'Smith'   , 27),
('Michael' , 'Smith'   , 3 )

SELECT * FROM Vizitatori -- afisam toate inregistrarile din tabelul Vizitatori





-- populam tabela (tabelul/entitatea) VizitatoriVase cu 15 inregistrari de date
-- se presupune ca tabelele Vizitatori si Vase sunt populate in acest punct
-- inseram 15 inregistrari
INSERT INTO VizitatoriVase(NrLegitimatie, VasID) VALUES
(3 , 22),
(5 , 44),
(10, 27),
(3 , 91),
(6 , 44),
(1 , 44),
(4 , 7 ),
(4 , 25),
(9 , 22),
(4 , 91),
(10, 48),
(7 , 31),
(10, 63),
(7 , 91),
(1 , 7 )

SELECT * FROM VizitatoriVase -- afisam toate inregistrarile din tabelul VizitatoriVase





-- populam tabela (tabelul/entitatea) Paznici cu 10 inregistrari de date
-- cheia primara CNPPaznic din acest tabel (partea 1 a relatiei) va fi cheie straina/externa in tabelul Bijuterii (partea n a relatiei) cu care se afla in relatie 1:n
-- prin urmare tabelul Paznici trebuie populat inaintea tabelului Bijuterii
-- inseram 10 inregistrari
INSERT INTO Paznici(Tura, Salariu, Inaltime, Greutate, Prenume, Nume, DataNasterii, CNPPaznic) VALUES
('Zi'    , 2520, 1.76, 79, 'Russell'    , 'Moore'  , '1977-12-01', 1771201606485),
('Noapte', NULL, 1.80, 91, 'Clarence'   , 'Adams'  , '1980-04-07', 1800407860583),
('Zi'    , 2305, 1.84, 86, 'Terry'      , 'Carter' , '1981-06-12', 1810612579069),
('Zi'    , 2050, 1.79, 91, 'William'    , 'Edwards', '1993-07-09', 1930709813451),
('Noapte', 2100, 1.83, 84, 'Ryan'       , 'Clark'  , '1998-03-10', 1980310453073),
('Zi'    , NULL, 1.80, 85, 'Daniel'     , 'Howard' , '1961-10-20', 1611020336821),
('Noapte', 2305, 1.70, 78, 'Roger'      , 'Allen'  , '1963-08-28', 1630828627656),
('Noapte', 2575, 1.73, 86, 'Arthur'     , 'Scott'  , '1967-06-28', 1670628732875),
('Noapte', NULL, 1.84, 89, 'Donald'     , 'Rogers' , '1976-07-23', 1760723499402),
('Zi'    , NULL, 1.79, 86, 'Christopher', 'Price'  , '1981-02-03', 1810203847149)

SELECT * FROM Paznici -- afisam toate inregistrarile din tabelul Paznici





-- populam tabela (tabelul/entitatea) Bijuterii cu 10 inregistrari de date
-- cheia externa CNPPaznic din acest tabel refera (pointeaza/puncteaza) cheia primara cu acelasi nume din tabelul Paznici
-- de aceea, tabelul Paznici trebuie populat primul si doar apoi se pot adauga inregistrari si in tabelul Bijuterii
-- consideram ca tabelul Paznici a fost populat cu inregistrari
-- inseram 15 inregistrari
INSERT INTO Bijuterii(Material, Valoare, CNPPaznic) VALUES
('Argint'      , 175250 , 1810612579069),
('Bronz'       , 25000  , 1630828627656),
('Aur'         , 1000000, 1930709813451),
('Bronz'       , 45000  , 1670628732875),
('Aur'         , 800000 , 1771201606485),
('Argint'      , 500000 , 1760723499402),
('Alt material', 4500   , 1930709813451),
('Alt material', 1500   , 1670628732875),
('Bronz'       , 10000  , 1611020336821),
('Alt material', 3750   , 1930709813451),
('Alt material', 2900   , 1771201606485),
('Argint'      , 450000 , 1810612579069),
('Argint'      , 875000 , 1771201606485),
('Aur'         , 999999 , 1930709813451),
('Bronz'       , 35750  , 1810612579069),
('Aur'         , 500000 , 1771201606485),
('Aur'         , 800000 , 1930709813451),
('Bronz'       , 4500   , 1930709813451),
('Alt material', 1500   , 1810612579069),
('Aur'         , 1000000, 1670628732875)

SELECT * FROM Bijuterii -- afisam toate inregistrarile din tabelul Bijuterii





-- populam tabela (tabelul/entitatea) VizitatoriBijuterii cu 10 inregistrari de date
-- se presupune ca tabelele Vizitatori si Bijuterii sunt populate in acest punct
-- inseram 10 inregistrari
INSERT INTO VizitatoriBijuterii(NrLegitimatie, BijuterieID) VALUES
(8 , 4 ),
(3 , 7 ),
(1 , 10),
(8 , 1 ),
(9 , 3 ),
(4 , 10),
(9 , 6 ),
(1 , 7 ),
(15, 9 ),
(8 , 7 )

SELECT * FROM VizitatoriBijuterii -- afisam toate inregistrarile din tabelul VizitatoriBijuterii





-- populam tabela (tabelul/entitatea) Ghizi cu 10 inregistrari de date
-- acest tabel trebuie populat (la fel ca si tabelul Vizitatori) pentru a putea ulterior sa populam tabelul VizitatoriGhizi
-- tabelul intermediar VizitatoriGhizi care realizeaza relatia m-n intre tabelele Vizitatori si Ghizi preia cheile primare din aceste doua tabele si le seteaza ca si chei straine/externe
-- inseram 10 inregistrari
INSERT INTO Ghizi(Prenume, Nume, Inaltime, DataNasterii, CNPGhid) VALUES
('Mike'   , 'Hodges'   , 1.68, '1977-05-26', '1770526943430'),
('Camille', 'Stephens' , 1.64, '1978-04-27', '2780527677048'),
('Armando', 'Buchanan' , 1.82, '1988-01-25', '1880125500490'),
('Lori'   , 'Frank'    , 1.75, '1989-11-23', '2891123639402'),
('Ramona' , 'Kennedy'  , 1.81, '1994-09-01', '2940901934219'),
('Mike'   , 'Miles'    , 1.69, '1972-01-11', '1720111529156'),
('Simone' , 'Lindsey'  , 1.77, '1981-03-24', '2810324212265'),
('Amber'  , 'Curry'    , 1.75, '1982-09-10', '2820910183623'),
('Scott'  , 'Mccormick', 1.64, '1988-06-17', '1880617551906'),
('Felix'  , 'Kennedy'  , 1.69, '1993-08-05', '1930805613765')

SELECT * FROM Ghizi -- afisam toate inregistrarile din tabelul Ghizi





-- populam tabela (tabelul/entitatea) VizitatoriGhizi cu 15 inregistrari de date
-- se presupune ca tabelele Vizitatori si Ghizi sunt populate in acest punct
-- inseram 17 inregistrari
INSERT INTO VizitatoriGhizi(NrLegitimatie, CNPGhid) VALUES
(9 , '1880125500490'),
(2 , '2810324212265'),
(2 , '2780527677048'),
(10, '1770526943430'),
(14, '2820910183623'),
(2 , '2940901934219'),
(6 , '2810324212265'),
(8 , '2810324212265'),
(6 , '1880125500490'),
(11, '1770526943430'),
(9 , '2810324212265'),
(11, '2780527677048'),
(11, '2810324212265'),
(15, '1770526943430'),
(1 , '2810324212265'),
(8 , '1880125500490'),
(1 , '2780527677048')

SELECT * FROM VizitatoriGhizi -- afisam toate inregistrarile din tabelul VizitatoriGhizi





-- populam tabela (tabelul/entitatea) FosileDinozauri cu 18 inregistrari de date
-- acest tabel are cheia straina/externa CNPGhid care este cheie primara in tabelul Ghizi,
-- deci tabelul Ghizi trebuie sa fie populat inainte sa adaugam inregistrari in tabelul FosileDinozauri (pentru a completa coloana CNPGhid cu una din valorile din tabela Ghizi de pe coloana CNPGhid)
-- inseram 18 inregistrari
INSERT INTO FosileDinozauri(FosilaDinozaurID, TipDinozaur, FamilieDinozaur, Epoca, NrOase, CNPGhid) VALUES
(184 , 'Tyrannosaurus'  , 'Tyrannosauridae'  , 'Cretacicului superior' , 211, '1770526943430'),
(294 , 'Tylosaurus'     , 'Mosasauridae'     , 'Cretacicului superior' , 173, '1880617551906'),
(382 , 'Mosasaurus'     , 'Mosasauridae'     , 'Cretacicului superior' , 188, '1880125500490'),
(391 , 'Wuerhosaurus'   , 'Stegosauridae'    , 'Cretacicului superior' , 198, '1720111529156'),
(420 , 'Leptoceratops ' , 'Leptoceratopsidae', 'Cretacicului superior' , 200, '2820910183623'),
(475 , 'Rhamphorhynchus', 'Rhamphorhynchidae', 'Jurasicul tarziu'      , 166, '1770526943430'),
(497 , 'Emausaurus'     , NULL               , 'Jurasicul timpuriu'    , 205, '1880617551906'),
(801 , 'Spinosaurus'    , 'Spinosauridae'    , 'Cretacicului superior' , 208, '2780527677048'),
(887 , 'Arrhinoceratops', 'Ceratopsidae'     , 'Cretacicului superior' , 205, '1930805613765'),
(915 , 'Pterodactylus'  , NULL               , 'Jurasicul tarziu'      , 171, '1720111529156'),
(935 , 'Torosaurus'     , 'Ceratopsidae'     , 'Maastrichtiana'        , 200, '2940901934219'),
(937 , 'Stenopelix'     , NULL               , 'Cretaceul timpuriu'    , 152, '1720111529156'),
(1056, 'Triceratops'    , 'Ceratopsidae'     , 'Cretacicului superior' , 199, '1880125500490'),
(1358, 'Styracosaurus'  , 'Ceratopsidae'     , 'Cretacicului superior' , 201, '1930805613765'),
(1563, 'Psittacosaurus' , 'Psittacosauridae' , NULL                    , 197, '1720111529156'),
(2462, 'Herrerasaurus'  , 'Herrerasauridae'  , 'Triassicul tarziu'     , 190, '1880125500490'),
(3713, 'Edmontosaurus'  , 'Hadrosauridae'    , 'Cretacicu'             , 169, '2780527677048'),
(3810, 'Shantungosaurus', 'Hadrosauridae'    , 'Cretacicului superior' , 195, '2820910183623')

SELECT * FROM FosileDinozauri -- afisam toate inregistrarile din tabelul FosileDinozauri





-- populam tabela (tabelul/entitatea) StanduriDinozauri cu 10 inregistrari de date
-- acest tabel se afla in relatie 1:1 (one to one) cu tabelul FosileDinozauri si cum tabelul FosileDinozauri a fost primul creat
-- inseamna ca tot tabelul FosileDinozauri va fi primul populat dintre tabelele FosileDinozauri si StanduriDinozauri (cel de al doilea are cheia straina setata si ca cheie primara)
-- inseram 10 inregistrari
INSERT INTO StanduriDinozauri(StandDinozaurID, Material, Lungime, Latime, Inaltime) VALUES
(382 , 'Sticla' , 50, 25, 5 ),
(391 , 'Sticla' , 50, 15, 5 ),
(420 , 'Plastic', 40, 30, 10),
(497 , 'Lemn'   , 45, 15, 5 ),
(801 , 'Plastic', 35, 10, 5 ),
(935 , 'Lemn'   , 45, 25, 10),
(937 , 'Sticla' , 50, 25, 10),
(1056, 'Plastic', 35, 35, 5 ),
(1358, 'Plastic', 25, 5 , 5 ),
(1563, 'Sticla' , 30, 25, 10)

SELECT * FROM StanduriDinozauri -- afisam toate inregistrarile din tabelul StanduriDinozauri





------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PARTEA DE VIZUALIZARE A CONTINUTULUI (INREGISTRARILOR) TABELELOR/ENTITATILOR BAZEI DE DATE
------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT * FROM Vitrine
SELECT * FROM Vase
SELECT * FROM Vizitatori
SELECT * FROM VizitatoriVase

SELECT * FROM Paznici
SELECT * FROM Bijuterii
SELECT * FROM VizitatoriBijuterii

SELECT * FROM Ghizi
SELECT * FROM VizitatoriGhizi

SELECT * FROM FosileDinozauri
SELECT * FROM StanduriDinozauri





------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PARTEA DE INTEROGARI
------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 0. interogare care extrage informatia din doua tabele: FosileDinozauri si StanduriDinozauri (relatie 1:1 <=> one to one)
-- interogare care afiseaza, sub forma tabelara, volumul si aria suportului (platformei) sub forma de paralelipiped pe care sunt pozitionate fosilele de dinozauri din cadrul unui muzeu
-- se afiseaza aria (suprafata) si volumul platformelor corespunzatoare dinozaurilor care au trait in epoca Cretacicului superior (criteriul de selectie/filtrare)
-- de asemenea, se mai afiseaza si informatii cu privire la id-ul fosilei de dinozaur, tipul dinozaurului caruia ii apartine precum si familiei din care acesta se trage
-- inregistrarile din tabelul rezultat vor fi in ordine crescatoare a coloanelor corespunzatoare volumului si ariei (aria este criteriu secundar de sortare/ordonare in caz de volum egal intre doua inregistrari)
SELECT * FROM FosileDinozauri
SELECT * FROM StanduriDinozauri

SELECT f.FosilaDinozaurID, f.TipDinozaur, f.FamilieDinozaur, Volum_platforma = s.Lungime * s.Latime * s.Inaltime, Arie_platforma = 2 * (s.Lungime * s.Latime + s.Lungime * s.Inaltime + s.Latime * s.Inaltime)
FROM FosileDinozauri f INNER JOIN StanduriDinozauri s ON f.FosilaDinozaurID = s.StandDinozaurID
WHERE f.Epoca = 'Cretacicului superior'
ORDER BY Volum_platforma ASC, Arie_platforma ASC





-- 1. interogare care extrage informatia din doua tabele: Vitrine si Vase (relatie 1:n <=> one to many)
-- interogare care afiseaza, sub forma tabelara, pentru fiecare vitrina, id-ul vitrinei (VitrinaID)
-- si vechimea totala a vaselor din aceasta care sunt fie din lut, fie din ceramica (din punct de vedere al materialului)
-- si au o vechime de cel putin 1000 de ani (suma vechimilor vaselor de lut si ceramica din vitrina trebuie sa fie mai mare sau egala cu 1000 <=> minim 1000)
-- daca o vitrina (inregistrare din tabela Vitrine) nu are corespondent in tabela Vase (cu alte cuvinte, nu exista un vas in vitrina respectiva) atunci nu se va lua in considerare la selectie (nu va fi selectata)
-- tabelul rezultat in urma interogarii va avea inregistrarile sortate/ordonate in mod crescator dupa vechimea calculata in coloana Vechime_totala_vase
SELECT * FROM Vitrine
SELECT * FROM Vase

SELECT vi.VitrinaID AS 'Numar vitrina', SUM(va.Vechime) AS Vechime_totala_vase
FROM Vitrine vi INNER JOIN Vase va ON vi.VitrinaID = va.VitrinaID
WHERE va.Material = 'Ceramica' OR va.Material = 'Lut'
GROUP BY vi.VitrinaID
HAVING SUM(va.Vechime) >= 1000
ORDER BY SUM(va.Vechime) -- ORDER BY SUM(va.Vechime) ASC





-- 2. interogare care extrage informatia din doua tabele: Paznici si Bijuterii (relatie 1:n <=> one to many)
-- interogare care afiseaza, sub forma tabelara, pentru fiecare paznic care lucreaza in tura de zi, CNP-ul acestuia,
-- dar si valoarea medie a bijuteriilor (daca aceasta este mai mare strict decat 10000 de unitati monetare) pe care acesta le pazeste in muzeu
-- daca media aritmetica a valorilor bijuteriilor (preturilor la care sunt estimate bijuteriile) este mai mica sau egala cu 10000 atunci inregistrarea cu acea valoare nu va mai fi inclusa in tabelul final
-- tabelul rezultat va fi sortat/ordonat descrescator dupa aceasta medie a valorilor (adica dupa coloana in care se calculeaza media aritmetica a valorilor bijuteriilor)
SELECT * FROM Paznici
SELECT * FROM Bijuterii

SELECT p.CNPPaznic, AVG(b.Valoare) AS 'Valoare totala bijuterii'
FROM Paznici p INNER JOIN Bijuterii b ON p.CNPPaznic = b.CNPPaznic
WHERE p.Tura = 'Zi'
GROUP BY p.CNPPaznic
HAVING AVG(b.Valoare) > 10000
ORDER BY AVG(b.Valoare) DESC





-- 3. interogare care extrage informatia din doua tabele: Ghizi si FosileDinozauri (relatie 1:n <=> one to many)
-- interogare care afiseaza, sub forma tabelara, numele unui ghid, prenumele aceluiasi ghid,
-- suma oaselor fosilelor de dinozaur, numarul minim de oase dintr-o fosila precum si numarul maxim dintr-o fosila
-- pentru fiecare ghid care prezinta fosile de dinozaur pentru care se cunoaste familia careia ii apartine dinozaurul prezentat de catre ghid,
-- cu conditia ca suma oaselor fosilelor pe care ghidul le prezinta vizitatorilor muzeului sa fie mai mica strict decat 400
-- tabelul rezultat va fi sortat/ordonat descrescator dupa 3 criterii:
-- crescator dupa suma oaselor fosilelor (criteriul principal de sortare)
-- crescator dupa numarul minim de oase a unei fosile (in caz de inregistrari cu aceeasi valoare in coloana corespunzatoare numarului de oase a fosilelor)
-- crescator dupa numarul maxim de oase a unui fosile (in caz de inregistrari cu aceeasi valoare in coloana corespunzatoare numarului minim de oase dintr-o fosila)
SELECT * FROM Ghizi
SELECT * FROM FosileDinozauri

SELECT g.Nume, g.Prenume, Suma_oase_fosile = SUM(f.NrOase), Numar_minim_oase_fosila = MIN(f.NrOase), Numar_maxim_oase_fosila = MAX(f.NrOase)
FROM Ghizi g INNER JOIN FosileDinozauri f ON g.CNPGhid = f.CNPGhid
WHERE f.FamilieDinozaur IS NOT NULL
GROUP BY g.Nume, g.Prenume
HAVING SUM(f.NrOase) < 400
ORDER BY Suma_oase_fosile, Numar_minim_oase_fosila, Numar_maxim_oase_fosila





-- 4. interogare care extrage informatia din 3 tabele (2 tabele aflate in relatie m-n si unul intermediar): Vizitatori, VizitatoriVase (tabel intermediar), Vase
-- interogare care afiseaza, sub forma tabelara, numele si prenumele unui vizitator; id-ul, materialul si culoarea tuturor vaselor
-- care sunt admirate de catre vizitatorul respectiv cu conditia ca culoarea vasului sa fie negru, castaniu sau maro
-- cu alte cuvinte, pentru fiecare vizitator al muzeului se vor afisa informatii despre vasele de culoare negru, castaniu sau maro pe care acesta le-a vazut
-- tabelul rezultat va fi afisat in ordine crescatoare dupa valorile din coloana corespunzatoare id-ului vasului admirat de catre vizitator (vas care are una dintre culorile specificate anterior/precedent)
SELECT * FROM Vizitatori
SELECT * FROM VizitatoriVase
SELECT * FROM Vase

SELECT vi.Nume, vi.Prenume, va.VasID, va.Material, va.Culoare
FROM Vizitatori vi INNER JOIN VizitatoriVase vv ON vi.NrLegitimatie = vv.NrLegitimatie INNER JOIN Vase va ON vv.VasID = va.VasID
WHERE va.Culoare IN ('Negru', 'Castaniu', 'Maro')
ORDER BY va.VasID





-- 5. interogare care extrage informatia din 3 tabele (2 tabele aflate in relatie m-n si unul intermediar): Vizitatori, VizitatoriVase (tabel intermediar), Vase
-- interogare care afiseaza, sub forma tabelara, numarul legitimatiei, numele si prenumele unui vizitator precum si numarul de vase pe care acesta le-a admirat in cadrul vizitei la muzeu
-- astfel, pentru fiecare vizitator, vom cunoaste numarul de vase pe care acesta le-a vazut
-- tabelul rezultat va fi sortat/ordonat descrescator dupa 3 criterii:
-- descrescator dupa numarul de vase admirate (criteriul principal de sortare)
-- crescator dupa numele vizitatorului (lexicografic/alfabetic), asta daca exista doua inregistrari de vizitatori care sa fi vizitat acelasi numar de vase
-- crescator dupa prenumele vizitatorului (lexicografic/alfabetic), asta daca exista doua inregistrari de vizitatori care sa fi vizitat acelasi numar de vase si sa aiba acelasi nume de familie
SELECT * FROM Vizitatori
SELECT * FROM VizitatoriVase
SELECT * FROM Vase

SELECT vi.NrLegitimatie, vi.Nume, vi.Prenume, Numar_vase_admirate = COUNT(va.VasID)
FROM Vizitatori vi INNER JOIN VizitatoriVase vv ON vi.NrLegitimatie = vv.NrLegitimatie INNER JOIN Vase va ON vv.VasID = va.VasID
GROUP BY vi.NrLegitimatie, vi.Nume, vi.Prenume
ORDER BY Numar_vase_admirate DESC, vi.Nume ASC, vi.Prenume ASC





-- 6. interogare care extrage informatia din 3 tabele (2 tabele aflate in relatie m-n si unul intermediar): Vizitatori, VizitatoriGhizi (tabel intermediar), Ghizi
-- interogare care afiseaza, sub forma de tabel, pentru fiecare vizitator (numarul de legitimatie primit la intrarea in muzeu, numele de familie si prenumele) major (cu varsta peste 18 ani),
-- CNP-ul, numele si prenumele fiecarui ghid care ii prezinta exponatele din cadrul muzeului
-- astfel, pentru fiecare vizitator cu varsta de minim 18 ani, vom cunoaste toti ghizii din muzeu cu care acesta a interactionat pe parcursul vizitei la muzeu
-- tabelul rezultat va fi sortat/ordonat descrescator dupa 4 criterii:
-- criteriu principal: crescator dupa numele vizitatorului
-- criterii secundare (in caz de egalitate): crescator dupa prenumele vizitatorului, crescator dupa numele ghidului, crescator dupa prenumele ghidului
SELECT * FROM Vizitatori
SELECT * FROM VizitatoriGhizi
SELECT * FROM Ghizi

SELECT v.NrLegitimatie, v.Nume, v.Prenume, g.CNPGhid, g.Nume, g.Prenume
FROM Vizitatori v INNER JOIN VizitatoriGhizi vg ON v.NrLegitimatie = vg.NrLegitimatie INNER JOIN Ghizi g ON vg.CNPGhid = g.CNPGhid
WHERE v.Varsta >= 18
GROUP BY v.NrLegitimatie, v.Nume, v.Prenume, g.CNPGhid, g.Nume, g.Prenume
ORDER BY v.Nume, v.Prenume, g.Nume, g.Prenume





-- 7. interogare care extrage informatia din 3 tabele (2 tabele aflate in relatie m-n si unul intermediar): Vizitatori, VizitatoriBijuterii (tabel intermediar), Bijuterii
-- interogare care afiseaza, sub forma de tabel, pentru fiecare vizitator (numele si prenumele acestuia),
-- valoarea celei mai pretioase bijuterii care nu este din materialul definit ca si "Alt material" (adica bijuteria este din aur, argint sau bronz) pe care acesta a admirat-o
-- astfel, pentru fiecare vizitator din muzeu vom cunoaste care este cea mai valoroasa bijuterie dintr-un material pretios (aur/argint/bronz) la care acesta s-a uitat
-- tabelul rezultat va fi sortat/ordonat descrescator dupa valoarea maxima calculata prin functia de agregare (in functie de valorile corespunzatoare coloanei in care este stocat apelul functiei MAX)
SELECT * FROM Vizitatori
SELECT * FROM VizitatoriBijuterii
SELECT * FROM Bijuterii

SELECT v.NrLegitimatie, v.Nume, v.Prenume, Cea_mai_valoroasa_bijuterie_admirata = MAX(b.Valoare)
FROM Vizitatori v INNER JOIN VizitatoriBijuterii vb ON v.NrLegitimatie = vb.NrLegitimatie INNER JOIN Bijuterii b ON vb.BijuterieID = b.BijuterieID
WHERE b.Material <> 'Alt material'
GROUP BY v.NrLegitimatie, v.Nume, v.Prenume
ORDER BY Cea_mai_valoroasa_bijuterie_admirata DESC





-- 8. interogare care extrage informatia din 4 tabele: Vizitatori, VizitatoriGhizi, Ghizi, FosileDinozauri
-- interogare care afiseaza, sub forma de tabel, familia si epoca din care face parte fiecare fosila de dinozaur admirata de cel putin un vizitator in decursul vizitei la muzeu,
-- fosila pentru care numele se termina in "urus" (are sufixul "urus" si oricate caractere (0 sau mai multe) inainte)
-- astfel, vom stii toti dinozaurii admirati de catre vizitatori care se termina in sufixul "urus"
-- inregistrarile (fosilele de dinozauri) din tabelul final (tabelul rezultat) vor fi sortate/ordonate crescator (in ordine lexicografica/alfabetica) dupa epoca (epoca in care au trait dinozaurii corespunzatori fosilelor)
SELECT * FROM Vizitatori
SELECT * FROM VizitatoriGhizi
SELECT * FROM Ghizi
SELECT * FROM FosileDinozauri

SELECT DISTINCT f.FamilieDinozaur, f.Epoca
FROM Vizitatori v INNER JOIN VizitatoriGhizi vg ON v.NrLegitimatie = vg.NrLegitimatie INNER JOIN Ghizi g ON vg.CNPGhid = g.CNPGhid INNER JOIN FosileDinozauri f ON g.CNPGhid = f.CNPGhid
WHERE f.TipDinozaur LIKE '%urus'
ORDER BY f.Epoca





-- 9. interogare care extrage informatia din 5 tabele: Vizitatori, VizitatoriGhizi, Ghizi, FosileDinozauri, StanduriDinozauri
-- interogare care afiseaza, sub forma de tabel, materialul unic al standului (platformei/suportului) pe care se afla plasat/pozitionat un dinozaur
-- al carui nume (tip de dinozazaur) nu contine secventa de litere 'ra' (aceste doua litere nu apar succesiv in numele dinozaurului) si care a fost admirat de cel putin un vizitator
-- se va afisa cel mult un timp de material existent (nu vor exista duplicate/dubluri pe coloana respectiva care este de altfel si singura din tabelul final/rezultat)
-- astfel, vom cunoaste materialele platformelor pe care se afla dinozaurii admirati de catre vizitatori in timpul vizitei la muzeu
-- tabelul final va fi sortat/ordonat descrescator in functie de valorile din coloana/campul/atributul material (aceste valori vor fi recoltate din tabelul StandDinozaur pe baza relatiei indirecte dintre acest tabel si tabelul Vizitatori)
SELECT * FROM Vizitatori
SELECT * FROM VizitatoriGhizi
SELECT * FROM Ghizi
SELECT * FROM FosileDinozauri
SELECT * FROM StanduriDinozauri

SELECT DISTINCT s.Material
FROM Vizitatori v INNER JOIN VizitatoriGhizi vg ON v.NrLegitimatie = vg.NrLegitimatie INNER JOIN Ghizi g ON vg.CNPGhid = g.CNPGhid INNER JOIN FosileDinozauri f ON g.CNPGhid = f.CNPGhid INNER JOIN StanduriDinozauri s ON f.FosilaDinozaurID = s.StandDinozaurID
WHERE f.TipDinozaur NOT LIKE '%ra%'
ORDER BY s.Material DESC





-- 10. interogare care extrage informatia din 4 tabele: Vizitatori, VizitatoriVase, Vase, Vitrine
-- interogare care afiseaza, sub forma de tabel, numele de familie si prenumele unui vizitator cu varsta cuprinsa intre 18 si 35 de ani (interval inchis) care a admirat cel putin o vaza in timpul vizitei la muzeu
-- precum si volumul tuturor vitrinelor corespunzatoare vaselor de lut sau argila pe care acesta le-a admirat in timpul vizitei
-- astfel, pentru fiecare vizitator care are cel putin 18 ani si cel mult 35 de ani (vizitator major pana in varsta de 35 de ani) vom cunoaste volumul vitrinelor in care se afla cel putin un vas de lut sau argila pe care acesta l-a admirat
-- tabelul final/rezultat va fi sortat/ordonat crescator dupa volumul precizata (valoarea din coloana "Volum vitrina" corespunzatoare fiecarei linii/inregistrari din cadrul tabelului)
SELECT * FROM Vizitatori
SELECT * FROM VizitatoriVase
SELECT * FROM Vase
SELECT * FROM Vitrine

SELECT vi.Nume, vi.Prenume, vit.VitrinaID, (vit.Latime * vit.Lungime * vit.Inaltime) AS 'Volum vitrina'
FROM Vizitatori vi INNER JOIN VizitatoriVase vv ON vi.NrLegitimatie = vv.NrLegitimatie INNER JOIN Vase va ON vv.VasID = va.VasID INNER JOIN Vitrine vit ON va.VitrinaID = vit.VitrinaID
WHERE va.Material IN ('Lut', 'Argila') AND vi.Varsta BETWEEN 18 AND 35
ORDER BY vit.VitrinaID ASC





-- 11. interogare care extrage informatia din doua tabele: Paznici si Bijuterii (relatie 1:n <=> one to many)
-- interogare care afiseaza, sub forma de tabel, materialele pe care le au bijuteriile pe care le pazesc paznicii care lucreaza in tura de noapte
-- fiecare material se afiseaza o singura data si in ordine descrescatoare din punct de vedere lexicografic/alfabetic al numelui materialului
-- daca un paznic pazeste doua bijuterii care au acelasi material atunci in tabelul final va exista o singura inregistrare care sa aiba materialul respectiv
-- astfel, putem sa stim toate materialele din care sunt facute bijuteriile care sunt pazite noaptea de catre paznici (paznicii care lucreaza in tura de seara)
-- tabelul final/rezultat va fi sortat/ordonat descrescator dupa numele materialului (invers alfabetic/lexicografic)
SELECT * FROM Paznici
SELECT * FROM Bijuterii

SELECT DISTINCT b.Material
FROM Paznici p INNER JOIN Bijuterii b ON p.CNPPaznic = b.CNPPaznic
WHERE p.Tura = 'Noapte'
ORDER BY b.Material DESC





-- 12. interogare care extrage informatia din doua tabele: Paznici si Bijuterii (relatie 1:n <=> one to many)
-- interogare care afiseaza, sub forma de tabel, valorile celor mai putin pretioase 10 bijuterii pazite de catre paznici a caror salariu este cunoscut (nu este NULL)
-- astfel, vom avea un raport cu cele mai mici 10 preturi unice (diferite) de bijuterii (cota de piata la care au fost estimate de catre specialistii in domeniu)
-- care sunt pazite de catre angajati care au salariul anuntat (adica se cunoaste)
-- tabelul final/rezultat va fi sortat/ordonat crescator dupa valoarea bijuteriilor
SELECT * FROM Paznici
SELECT * FROM Bijuterii

SELECT DISTINCT TOP(10) b.Valoare
FROM Paznici p INNER JOIN Bijuterii b ON p.CNPPaznic = b.CNPPaznic
WHERE p.Salariu IS NOT NULL 
ORDER BY b.Valoare ASC





-- 13. interogare care extrage informatia din 4 tabele: Vizitatori, VizitatoriBijuterii, Bijuterii, Paznici
-- interogare care afiseaza, sub forma de tabel, numarul de legitimatie, numele precum si prenumele vizitatorilor care au fost la muzeu ziua
-- cu alte cuvinte, este vorba despre vizitatorii care au interactionat in mod indirect cu paznici aflati in tura de zi la muzeu (vizitatorii au admirat bijuterii pazite de paznici care lucrau pe timp de zi)
-- astfel, vom cunoaste toti vizitatorii care au fost la muzeu pe timp de zi
-- tabelul final/rezultat va avea inregistrarile de pe linii in ordine (strict) crescatoare dupa criteriile nume vizitator (criteriu principal de sortare) si prenume vizitator (criteriu secundar de sortare in cazul in care exista doi vizitatori cu acelasi nume)
SELECT * FROM Vizitatori
SELECT * FROM VizitatoriBijuterii
SELECT * FROM Bijuterii
SELECT * FROM Paznici

SELECT DISTINCT v.NrLegitimatie, v.Nume, v.Prenume
FROM Vizitatori v INNER JOIN VizitatoriBijuterii vb ON v.NrLegitimatie = vb.NrLegitimatie INNER JOIN Bijuterii b ON vb.BijuterieID = b.BijuterieID INNER JOIN Paznici p ON b.CNPPaznic = p.CNPPaznic
WHERE p.Tura = 'Zi'
ORDER BY v.Nume, v.Prenume





-- 14. interogare care extrage informatia din 4 tabele: Vizitatori, VizitatoriBijuterii, Bijuterii, Paznici
-- interogare care afiseaza, sub forma de tabel, numele, prenumele si salariul tuturor paznicilor care au interactionat cu vizitatori majori (cu varsta minim 18 ani)
-- astfel, vom avea datele tuturoar paznicilor care au pazit bijuterii pe care le-au admirat vizitatori in varsta de cel putin 18 ani
-- vizitatorii admira bijuterii iar paznicii le pazesc, deci vizitatorii interactioneaza in mod indirect cu paznicii muzeului
-- inregistrarile/liniile din tabelul final/rezultat vor fi afisate in ordine crescatoare a salariului paznicilor (valorile din coloana Salariu a tabelului) care au interactionat in mod indirect cu vizitatori majori prezenti in vizita la muzeu
SELECT * FROM Vizitatori
SELECT * FROM VizitatoriBijuterii
SELECT * FROM Bijuterii
SELECT * FROM Paznici

SELECT DISTINCT p.Nume, p.Prenume, p.Salariu
FROM Vizitatori v INNER JOIN VizitatoriBijuterii vb ON v.NrLegitimatie = vb.NrLegitimatie INNER JOIN Bijuterii b ON vb.BijuterieID = b.BijuterieID INNER JOIN Paznici p ON b.CNPPaznic = p.CNPPaznic
WHERE v.Varsta >= 18
ORDER BY p.Salariu





-- 15. interogare care extrage informatia din 3 tabele (2 tabele aflate in relatie m-n si unul intermediar): Vizitatori, VizitatoriGhizi (tabel intermediar), Ghizi
-- interogare care afiseaza, sub forma de tabel, numele si prenumele vizitatorilor cu varsta mai mica de 18 ani (care sunt deci minori); CNP-ul, numele si prenumele ghizilor care au interactionat cu acesti vizitatori
-- astfel, pentru fiecare vizitator minor (copil) vom cunoaste ghizii din muzeu care le-au prezentat exponatele muzeului (fosilele de dinozauri)
SELECT * FROM Vizitatori
SELECT * FROM VizitatoriGhizi
SELECT * FROM Ghizi

SELECT v.Nume AS 'Nume vizitator minor', v.Prenume AS 'Prenume vizitator minor', g.CNPGhid AS 'CNP ghid', g.Nume AS 'Nume ghid', g.Prenume AS 'Prenume ghid'
FROM Vizitatori v INNER JOIN VizitatoriGhizi vg ON v.NrLegitimatie = vg.NrLegitimatie INNER JOIN Ghizi g ON vg.CNPGhid = g.CNPGhid
WHERE v.Varsta < 18





-- Interogari cu subinterogari in clauza HAVING
-- 1.
SELECT P.Nume + ' ' + P.Prenume AS [Nume complet], B.Material, SUM(B.Valoare) AS [Valoare totala bijuterie]
FROM Bijuterii B JOIN Paznici P ON B.CNPPaznic = P.CNPPaznic
WHERE P.Nume <> 'Carter'
GROUP By P.Nume, P.Prenume, B.Material
HAVING SUM(B.Valoare) >= ((SELECT SUM(B.Valoare) FROM Bijuterii B) / (SELECT COUNT(B.BijuterieID) FROM Bijuterii AS B))
ORDER BY B.Material ASC, SUM(B.Valoare) DESC

-- 2.
SELECT G.Nume AS 'Nume ghid', G.Prenume AS [Prenume ghid], Dinozaur = FD.TipDinozaur, [Numar oase dinozaur] = FD.NrOase
FROM Ghizi AS G INNER JOIN FosileDinozauri AS FD ON G.CNPGhid = FD.CNPGhid
WHERE FD.FamilieDinozaur IS NOT NULL AND FD.Epoca LIKE 'Cretacicului_%' AND FD.TipDinozaur NOT LIKE '%urus'
GROUP BY G.Nume, G.Prenume, FD.TipDinozaur, FD.NrOase
HAVING SUM(FD.NrOase)
BETWEEN ((SELECT MIN(FosileDinozauri.FosilaDinozaurID) FROM FosileDinozauri) + 10) 
AND ((SELECT MAX(FosileDinozauri.FosilaDinozaurID) FROM FosileDinozauri) - 5)
ORDER BY FD.NrOase ASC

/*
GO
CREATE PROCEDURE Query
(@plus TINYINT, @minus SMALLINT)
AS
BEGIN
	SELECT G.Nume AS 'Nume ghid', G.Prenume AS [Prenume ghid], Dinozaur = FD.TipDinozaur, [Numar oase dinozaur] = FD.NrOase
	FROM Ghizi AS G INNER JOIN FosileDinozauri AS FD ON G.CNPGhid = FD.CNPGhid
	WHERE FD.FamilieDinozaur IS NOT NULL AND FD.Epoca LIKE 'Cretacicului_%' AND FD.TipDinozaur NOT LIKE '%urus'
	GROUP BY G.Nume, G.Prenume, FD.TipDinozaur, FD.NrOase
	HAVING SUM(FD.NrOase)
	BETWEEN ((SELECT MIN(FosileDinozauri.FosilaDinozaurID) FROM FosileDinozauri) + @plus) 
	AND ((SELECT MAX(FosileDinozauri.FosilaDinozaurID) FROM FosileDinozauri) + @minus)
	ORDER BY FD.NrOase ASC
END

DECLARE @foo TINYINT
SET @foo = 10

DECLARE @bar SMALLINT
SET @bar = -5

EXEC Query @foo, @bar
*/

-- 3.
DECLARE @temp TINYINT
SET @temp = 5

SELECT G.Nume + ' ' + G.Prenume AS 'Nume ghid turistic', AVG(V.Varsta) AS [Varsta medie vizitator]
FROM Ghizi G INNER JOIN VizitatoriGhizi ON G.CNPGhid = VizitatoriGhizi.CNPGhid INNER JOIN Vizitatori AS V ON VizitatoriGhizi.NrLegitimatie = V.NrLegitimatie
WHERE V.Nume != 'John'
GROUP BY G.Nume, G.Prenume
HAVING AVG(V.Varsta) < ((SELECT AVG(V.Varsta) FROM Vizitatori V) - (SELECT MIN(V.Varsta) FROM Vizitatori V WHERE V.Varsta >= @temp))
ORDER BY [Varsta medie vizitator], [Nume ghid turistic] DESC

-- 4.
SELECT [Nume complet vizitator] = Vi.Nume + ' ' + Vi.Prenume, Vi.Varsta, COUNT(Va.VasID) AS 'Numar total de vase admirate'
FROM Vizitatori Vi INNER JOIN VizitatoriVase VV ON Vi.NrLegitimatie = VV.NrLegitimatie INNER JOIN Vase Va ON VV.VasID = Va.VasID
GROUP BY Vi.Nume, Vi.Prenume, Vi.Varsta
HAVING COUNT(Va.VasID) >= (SELECT COUNT(Va.VasID) FROM Vase Va) / (SELECT COUNT(VV.NrLegitimatie) FROM Vizitatori Vi JOIN VizitatoriVase VV ON Vi.NrLegitimatie = VV.NrLegitimatie WHERE Vi.Varsta >= 35)
ORDER BY Vi.Nume, Vi.Varsta DESC

-- 5.
SELECT FD.TipDinozaur AS 'Familie dinozaur', FD.Epoca, [Arie platforma] = SUM(SD.Lungime * SD.Latime * SD.Inaltime)
FROM FosileDinozauri FD INNER JOIN StanduriDinozauri SD ON FD.FosilaDinozaurID = SD.StandDinozaurID
WHERE Epoca NOT IN ('Jurasicul tarziu', 'Maastrichtiana')
GROUP BY FD.TipDinozaur, FD.Epoca
HAVING SUM(SD.Lungime * SD.Latime * SD.Inaltime) <= (SELECT SUM(SD.Lungime * SD.Latime * SD.Inaltime) FROM StanduriDinozauri SD WHERE SD.Material != 'Plastic') / (SELECT COUNT(FD.CNPGhid) FROM FosileDinozauri AS FD WHERE FD.NrOase >= 195)
ORDER BY FD.Epoca DESC