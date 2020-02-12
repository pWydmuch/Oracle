DROP TABLE Incydenty2;
DROP TABLE Elita2;
DROP TABLE Plebs2;
DROP TABLE Konta2;

CREATE TABLE Plebs2
(
    nr_plebsu NUMBER
        CONSTRAINT pl2_pk PRIMARY KEY,
    kotek     VARCHAR2(15)
        CONSTRAINT pl24_fk REFERENCES KOCURY(PSEUDO)
);


CREATE TABLE Elita2
(
    nr_elity NUMBER
        CONSTRAINT e2_pk PRIMARY KEY,
    kotek    VARCHAR2(15)
        CONSTRAINT e2_fk REFERENCES KOCURY (PSEUDO),
    sluga    NUMBER
        CONSTRAINT e2_sl REFERENCES Plebs2 (nr_plebsu)
);

CREATE TABLE Incydenty2
(
    nr_incydentu   NUMBER
        CONSTRAINT in2_pk PRIMARY KEY,
    kotek          VARCHAR2(15)
        CONSTRAINT in2_fk REFERENCES KOCURY (PSEUDO),
    imie_wroga     VARCHAR2(15),
    data_incydentu DATE,
    opis_incydentu VARCHAR2(50)
);

CREATE TABLE Konta2
(
    nr_myszy          NUMBER
        CONSTRAINT k2_pk PRIMARY KEY,
    wlasciciel        NUMBER
        CONSTRAINT k2_fk REFERENCES Elita2(nr_elity),
    data_wprowadzenia DATE
        CONSTRAINT k2_dw_nn NOT NULL,
    data_usuniecia    DATE,
    CONSTRAINT k2_ch_dates CHECK (data_usuniecia > data_wprowadzenia)
);

drop table Konta2;

INSERT INTO Plebs2 (nr_plebsu, kotek)
VALUES (1, 'ZERO');
INSERT INTO Plebs2 (nr_plebsu, kotek)
VALUES (2, 'KURKA');
INSERT INTO Plebs2 (nr_plebsu, kotek)
VALUES (3, 'PUSZYSTA');
INSERT INTO Plebs2 (nr_plebsu, kotek)
VALUES (4, 'MAN');
INSERT INTO Plebs2 (nr_plebsu, kotek)
VALUES (5, 'MALY');
INSERT INTO Plebs2 (nr_plebsu, kotek)
VALUES (6, 'UCHO');
INSERT INTO Plebs2 (nr_plebsu, kotek)
VALUES (7, 'DAMA');
INSERT INTO Plebs2 (nr_plebsu, kotek)
VALUES (8, 'LASKA');
INSERT INTO Plebs2 (nr_plebsu, kotek)
VALUES (9, 'SZYBKA');
INSERT INTO Plebs2 (nr_plebsu, kotek)
VALUES (10, 'RURA');
INSERT INTO Plebs2 (nr_plebsu, kotek)
VALUES (11, 'PLACEK');

INSERT INTO Elita2(nr_elity, kotek, sluga)
VALUES (1, 'TYGRYS', 10);
INSERT INTO Elita2(nr_elity, kotek, sluga)
VALUES (2, 'LOLA', 10);--Dwoch maja tego samego
INSERT INTO Elita2(nr_elity, kotek, sluga)
VALUES (3, 'BOLEK', 11);
INSERT INTO Elita2(nr_elity, kotek, sluga)
VALUES (4, 'ZOMBI', 1);
INSERT INTO Elita2(nr_elity, kotek, sluga)
VALUES (5, 'LYSY', 3);
INSERT INTO Elita2(nr_elity, kotek, sluga)
VALUES (6, 'MALA', 5);
INSERT INTO Elita2(nr_elity, kotek, sluga)
VALUES (7, 'RAFA', 7);

INSERT INTO Konta2(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia)
VALUES (1, 1, '2020-01-01', NULL);
INSERT INTO Konta2(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia)
VALUES (2, 1, '2019-01-01', '2019-09-02');
INSERT INTO Konta2(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia)
VALUES (3, 1, '2015-11-06', '2017-09-11');
INSERT INTO Konta2(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia)
VALUES (4, 2, '2012-10-02', NULL);
INSERT INTO Konta2(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia)
VALUES (5, 2, '2018-05-08', '2019-02-12');
INSERT INTO Konta2(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia)
VALUES (6, 3, '2015-05-23', '2019-10-04');
INSERT INTO Konta2(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia)
VALUES (7, 4, '2011-11-23', NULL);
INSERT INTO Konta2(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia)
VALUES (8, 5, '2014-05-12', '2016-10-02');
INSERT INTO Konta2(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia)
VALUES (9, 6, '2013-09-11', '2019-09-15');
INSERT INTO Konta2(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia)
VALUES (10, 6, '2017-10-12', '2018-11-01');

INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (1, 'TYGRYS', 'KAZIO', '2004-10-13', 'USILOWAL NABIC NA WIDLY');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (2, 'ZOMBI', 'SWAWOLNY DYZIO', '2005-03-07', 'WYBIL OKO Z PROCY');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (3, 'BOLEK', 'KAZIO', '2005-03-29', 'POSZCZUL BURKIEM');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (4, 'SZYBKA', 'GLUPIA ZOSKA', '2006-09-12', 'UZYLA KOTA JAKO SCIERKI');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (5, 'MALA', 'CHYTRUSEK', '2007-03-07', 'ZALECAL SIE');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (6, 'TYGRYS', 'DZIKI BILL', '2007-06-12', 'USILOWAL POZBAWIC ZYCIA');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (7, 'BOLEK', 'DZIKI BILL', '2007-11-10', 'ODGRYZL UCHO');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (8, 'LASKA', 'DZIKI BILL', '2008-12-12', 'POGRYZL ZE LEDWO SIE WYLIZALA');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (9, 'LASKA', 'KAZIO', '2009-01-07', 'ZLAPAL ZA OGON I ZROBIL WIATRAK');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (10, 'DAMA', 'KAZIO', '2009-02-07', 'CHCIAL OBEDRZEC ZE SKORY');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (11, 'MAN', 'REKSIO', '2009-04-14', 'WYJATKOWO NIEGRZECZNIE OBSZCZEKAL');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (12, 'LYSY', 'BETHOVEN', '2009-05-11', 'NIE PODZIELIL SIE SWOJA KASZA');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (13, 'RURA', 'DZIKI BILL', '2009-09-03', 'ODGRYZL OGON');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (14, 'PLACEK', 'BAZYLI', '2010-07-12', 'DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (15, 'PUSZYSTA', 'SMUKLA', '2010-11-19', 'OBRZUCILA SZYSZKAMI');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (16, 'KURKA', 'BUREK', '2010-12-14', 'POGONIL');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (17, 'MALY', 'CHYTRUSEK', '2011-07-13', 'PODEBRAL PODEBRANE JAJKA');
INSERT INTO Incydenty2 (nr_incydentu, kotek, imie_wroga, data_incydentu, opis_incydentu)
VALUES (18, 'UCHO', 'SWAWOLNY DYZIO', '2011-07-14', 'OBRZUCIL KAMIENIAMI');

CREATE OR REPLACE FORCE VIEW  KotyV
            OF KOT
                WITH OBJECT IDENTIFIER (pseudo)
AS
SELECT PSEUDO,
       IMIE,
       PLEC,
       FUNKCJA,
       MAKE_REF(KotyV, PSEUDO) SZEF,
       W_STADKU_OD,
       PRZYDZIAL_MYSZY,
       MYSZY_EXTRA,
       NR_BANDY
FROM KOCURY;

CREATE OR REPLACE VIEW PlebsV
            OF Plebs
                WITH OBJECT IDENTIFIER (nr_plebsu)
AS
SELECT nr_plebsu,
       MAKE_REF(KotyV, kotek) kotek
FROM Plebs2;

CREATE OR REPLACE VIEW ElitaV OF Elita
WITH OBJECT IDENTIFIER (nr_elity) AS
SELECT  nr_elity,
        MAKE_REF(KotyV, kotek) kotek,
        MAKE_REF(PlebsV, sluga) sluga
FROM Elita2;


--

CREATE OR REPLACE VIEW KontaV OF Konto
WITH OBJECT IDENTIFIER (nr_myszy) AS
SELECT  nr_myszy,
        MAKE_REF(ElitaV, wlasciciel) wlasciciel,
        data_wprowadzenia,
        data_usuniecia
FROM Konta2;


CREATE OR REPLACE VIEW IncydentyV OF Incydent
WITH OBJECT IDENTIFIER (nr_incydentu) AS
SELECT  nr_incydentu,
        MAKE_REF(KotyV, kotek) kotek,
        imie_wroga,
        data_incydentu,
        opis_incydentu
FROM Incydenty2;


--zlaczenie
SELECT inc.kotek.PSEUDO, inc.IMIE_WROGA, inc.DATA_INCYDENTU, inc.OPIS_INCYDENTU
FROM IncydentyV inc JOIN KotyV k On KOTEK= REF(k)
WHERE inc.kotek.PSEUDO = 'TYGRYS';


--grupowanie
SELECT kn.WLASCICIEL.KOTEK.DAJPSEUDO() "Pseudo", COUNT(*) "Ile myszy na koncie"
FROM KontaV kn
GROUP BY kn.WLASCICIEL.KOTEK.DAJPSEUDO()
ORDER BY "Ile myszy na koncie" DESC;

--podzapytanie
SELECT k.PSEUDO
FROM kotyV k
WHERE k.W_stadku_od < (SELECT min(inc.data_incydentu) from IncydentyR inc);


--lista2

--zad.23

SELECT k.IMIE, k.dajPelnyPrzydzial() * 12 "DAWKA ROCZNA", 'powyzej 864' "DAWKA"
FROM KotyV k
WHERE k.MYSZY_EXTRA IS NOT NULL
  AND k.dajPelnyPrzydzial() * 12 > 864
UNION
SELECT k.IMIE, k.dajPelnyPrzydzial() * 12 "DAWKA ROCZNA", '        864' "DAWKA"
FROM KotyR k
WHERE k.MYSZY_EXTRA IS NOT NULL
  AND k.dajPelnyPrzydzial() * 12 = 864
UNION
SELECT k.IMIE, k.dajPelnyPrzydzial() * 12 "DAWKA ROCZNA", 'ponizej 864' "DAWKA"
FROM KotyR k
WHERE k.MYSZY_EXTRA IS NOT NULL
  AND k.dajPelnyPrzydzial() * 12 < 864
ORDER BY "DAWKA ROCZNA";

--zad.26
SELECT k.FUNKCJA, ROUND(AVG(k.dajPelnyPrzydzial())) "Srednio najw. i najm. myszy"
FROM kotyR k
GROUP BY k.FUNKCJA
HAVING AVG((k.dajPelnyPrzydzial())) IN (
                                                      (SELECT MAX(AVG(k2.dajPelnyPrzydzial()))
                                                       FROM KotyR k2
                                                       WHERE k2.FUNKCJA != 'SZEFUNIO'
                                                       GROUP BY k2.FUNKCJA),
                                                      (SELECT MIN(AVG(k3.dajPelnyPrzydzial()))
                                                       FROM KotyR k3
                                                       GROUP BY k3.FUNKCJA));

--lista 3


--zad.35
DECLARE
    pseudo_kota      KotyV.pseudo%TYPE := &pseudo;
    przydzial        KotyV.PRZYDZIAL_MYSZY%TYPE;
    data_wystapienia KotyV.w_stadku_od%TYPE;
    imie_kota        KotyV.imie%TYPE;
BEGIN
    SELECT k.dajPelnyPrzydzial(), k.W_STADKU_OD, k.IMIE
    INTO przydzial,data_wystapienia, imie_kota
    FROM KotyV k
    WHERE k.PSEUDO = UPPER(pseudo_kota);
    IF przydzial > 700 OR imie_kota LIKE '%A%' OR EXTRACT(MONTH from data_wystapienia) = 1 THEN
        IF przydzial > 700 THEN
            DBMS_OUTPUT.PUT_LINE(imie_kota || '- calkowity roczny przydzial myszy >700');
        END IF;
        IF imie_kota LIKE '%A%' THEN
            DBMS_OUTPUT.PUT_LINE(imie_kota || '- imię zawiera litere A');
        END IF;
        IF EXTRACT(MONTH from data_wystapienia) = 1 THEN
            DBMS_OUTPUT.PUT_LINE(imie_kota || '- styczeń jest miesiacem przystapienia do stada');
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE(imie_kota || '- nie odpowiada kryteriom');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line(SQLERRM);
END;

--zad.37

DECLARE
    i NUMBER := 1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Nr    Pseudonim    Zjada');
    DBMS_OUTPUT.PUT_LINE('------------------------ ');
    FOR kot IN (SELECT k.PSEUDO, k.dajPelnyPrzydzial() "Zjada"
    FROM KotyV k ORDER BY k.dajPelnyPrzydzial() DESC)
        LOOP
            EXIT WHEN i > 5;
            DBMS_OUTPUT.PUT_LINE(i || ' ' || LPAD(kot.PSEUDO, 11) || '' ||
                                 LPAD((kot."Zjada"), 10));
            i := i + 1;
        END LOOP;
END;