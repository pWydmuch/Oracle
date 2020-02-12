DROP TYPE KOT FORCE;
DROP TYPE Elita FORCE;
DROP TYPE PLebs FORCE;
DROP TYPE KONTO FORCE;
DROP TYPE INCYDENT FORCE;

DROP TABLE IncydentyR;
DROP TABLE ElitaR;
DROP TABLE PlebsR;
DROP TABLE KontaR;
DROP TABLE KotyR;

CREATE OR REPLACE TYPE Kot AS OBJECT
(   pseudo VARCHAR2(15) ,
    imie VARCHAR2(15) ,
    plec VARCHAR2(1) ,
    funkcja VARCHAR2(10),
    szef REF KOT,
    w_stadku_od DATE,
    przydzial_myszy NUMBER(3),
    myszy_extra NUMBER(3),
    nr_bandy NUMBER(2),
    MAP MEMBER FUNCTION dajPseudo RETURN VARCHAR2,
    MEMBER FUNCTION dajPelnyPrzydzial RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY kot AS
MAP MEMBER FUNCTION dajPseudo RETURN VARCHAR2 IS
    BEGIN
        RETURN pseudo;
    end;
MEMBER FUNCTION dajPelnyPrzydzial RETURN NUMBER IS
    BEGIN
        RETURN przydzial_myszy + NVL(MYSZY_EXTRA,0);
    end;
end;

CREATE TABLE KotyR OF KOT(
    pseudo  CONSTRAINT ktr_pk PRIMARY KEY,
    imie    NOT NULL,
    plec  CONSTRAINT ktr_pl_ch CHECK(plec IN('M','D')),
    szef  SCOPE IS KotyR,
    w_stadku_od DEFAULT SYSDATE
);


CREATE OR REPLACE TYPE Plebs IS OBJECT(
    nr_plebsu NUMBER,
    kotek REF kot,
  MEMBER FUNCTION ZwrocDaneKota RETURN VARCHAR2
                                      );

CREATE OR REPLACE TYPE BODY PLEBS AS
MEMBER FUNCTION ZwrocDaneKota RETURN VARCHAR2 IS
    K KOT;
    BEGIN
        SELECT DEREF(kotek) INTO K FROM DUAL;
        RETURN K.IMIE || ', ' || K.PLEC || ', ' || K.PSEUDO || ', ' || K.FUNKCJA ||  ', ' ||K.W_STADKU_OD || ', ' || K.NR_BANDY ||', ' || K.DAJPELNYPRZYDZIAL();
    END;
END;

CREATE TABLE PlebsR OF Plebs(
    nr_plebsu CONSTRAINT pl_pk PRIMARY KEY,
    kotek SCOPE IS KotyR
);

CREATE OR REPLACE TYPE Elita IS OBJECT(
    nr_elity NUMBER,
    kotek REF kot,
    sluga REF Plebs,
    MEMBER FUNCTION dajPsuedoSlugi RETURN VARCHAR2,
    MAP MEMBER FUNCTION odwzoruj RETURN VARCHAR2
                                      );

CREATE OR REPLACE TYPE BODY Elita AS
    MEMBER FUNCTION dajPsuedoSlugi RETURN VARCHAR2 AS
        kot_sl Kot;
        BEGIN
            SELECT DEREF(DEREF(sluga).kotek) INTO kot_sl FROM DUAL;
            RETURN kot_sl.pseudo;
        END;
     MAP MEMBER FUNCTION odwzoruj RETURN VARCHAR2 AS
         kot_ek Kot;
         BEGIN
             SELECT DEREF(kotek) INTO kot_ek FROM DUAL;
             RETURN kot_ek.PSEUDO;
         END;
END;

CREATE TABLE ElitaR OF Elita(
    nr_elity CONSTRAINT el_pk PRIMARY KEY,
    sluga SCOPE IS PlebsR,
    kotek SCOPE IS KotyR
);


CREATE OR REPLACE TYPE Konto IS OBJECT -- Wpis lepiej opisywaloby ten obiekt
(
    nr_myszy          NUMBER,
    wlasciciel        REF Elita,
    data_wprowadzenia DATE,
    data_usuniecia    DATE,
    MEMBER FUNCTION dajPseudoWlasciciela RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY Konto AS
    MEMBER FUNCTION dajPseudoWlasciciela RETURN VARCHAR2 AS
        kot_wl KOT;
        BEGIN
            SELECT DEREF(DEREF(wlasciciel).kotek) INTO kot_wl FROM DUAL;
            RETURN kot_wl.PSEUDO;
        END;
END;

CREATE TABLE KontaR OF KONTO(
    CONSTRAINT kor_pk PRIMARY KEY(nr_myszy) ,
    wlasciciel SCOPE IS ELitaR,
    data_wprowadzenia  not null,
    CONSTRAINT ch_dates  CHECK (data_usuniecia> data_wprowadzenia)
);

CREATE OR REPLACE TYPE INCYDENT IS OBJECT
(
    nr_incydentu NUMBER,
    kotek REF KOT,
    imie_wroga VARCHAR2(15),
    data_incydentu DATE,
    opis_incydentu VARCHAR2(50),
    MEMBER FUNCTION czyIncydentPrzed(d DATE) RETURN BOOLEAN
);

CREATE OR REPLACE TYPE BODY INCYDENT AS
MEMBER FUNCTION czyIncydentPrzed(d DATE) RETURN BOOLEAN AS
    BEGIN
         IF data_incydentu < D THEN
          RETURN TRUE;
          END IF;
        RETURN FALSE;
    end;
END;

CREATE TABLE IncydentyR OF INCYDENT(
	CONSTRAINT inc_pk PRIMARY KEY(nr_incydentu),
    kotek SCOPE IS  KotyR
);

-- DROP TABLE IncydentyR;


CREATE OR REPLACE TRIGGER pl_nie_el
    BEFORE INSERT ON PlebsR
    FOR EACH ROW
DECLARE
    liczba NUMBER;
BEGIN
    SELECT COUNT(*) INTO liczba FROM ElitaR e WHERE DEREF(e.KOTEK).PSEUDO = DEREF(:NEW.kotek).pseudo;
    IF liczba > 0 THEN
         raise_application_error(-20001, 'Ten kot jest już w elicie.');
    end if;
end;


drop trigger el_nie_pl;

CREATE OR REPLACE TRIGGER el_nie_pl
    BEFORE INSERT ON ElitaR
    FOR EACH ROW
DECLARE
    liczba NUMBER;
BEGIN
    SELECT COUNT(*) INTO liczba FROM PlebsR p WHERE DEREF(p.KOTEK).PSEUDO = DEREF(:NEW.kotek).pseudo;
    IF liczba > 0 THEN
         raise_application_error(-20001, 'Ten kot jest już w plebsie.');
    end if;
end;

CREATE OR REPLACE TRIGGER spr_inc
    BEFORE INSERT ON IncydentyR
    FOR EACH ROW
DECLARE
liczba NUMBER;
BEGIN
    SELECT COUNT(*) INTO liczba FROM IncydentyR p WHERE  DEREF(:NEW.kotek).pseudo = DEREF(p.KOTEK).pseudo AND :NEW.imie_wroga = p.IMIE_WROGA;
    IF liczba > 0 THEN
         raise_application_error(-20001, 'Ten kot jest już w plebsie.');
    end if;
end;

INSERT INTO PlebsR(nr_plebsu, kotek ) VALUES (1, (SELECT REF(K) FROM KotyR k WHERE k.pseudo='TYGRYS'));


INSERT INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('MRUCZEK','M','TYGRYS','SZEFUNIO',NULL,'2002-01-01',103,33,1);
INSERT INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('MICKA','D','LOLA','MILUSIA',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='TYGRYS'),'2009-10-14',25,47,1);
INSERT INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('CHYTRY','M','BOLEK','DZIELCZY',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='TYGRYS'),'2002-05-05',50,NULL,1);
INSERT INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('KOREK','M','ZOMBI','BANDZIOR',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='TYGRYS'),'2004-03-16',75,13,3);
INSERT INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('BOLEK','M','LYSY','BANDZIOR',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='TYGRYS'),'2006-08-15',72,21,2);
INSERT  INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('RUDA','D','MALA','MILUSIA',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='TYGRYS'),'2006-09-17',22,42,1);
INSERT  INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('PUCEK','M','RAFA','LOWCZY',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='TYGRYS'),'2006-10-15',65,NULL,4);
INSERT  INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('JACEK','M','PLACEK','LOWCZY',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='LYSY'),'2008-12-01',67,NULL,2);
INSERT  INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('BARI','M','RURA','LAPACZ',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='LYSY'),'2009-09-01',56,NULL,2);
INSERT  INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('ZUZIA','D','SZYBKA','LOWCZY',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='LYSY'),'2006-07-21',65,NULL,2);
INSERT  INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('BELA','D','LASKA','MILUSIA',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='LYSY'),'2008-02-01',24,28,2);
INSERT  INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('MELA','D','DAMA','LAPACZ',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='RAFA'),'2008-11-01',51,NULL,4);
INSERT  INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('LATKA','D','UCHO','KOT',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='RAFA'),'2011-01-01',40,NULL,4);
INSERT  INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('DUDEK','M','MALY','KOT',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='RAFA'),'2011-05-15',40,NULL,4);
INSERT  INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('KSAWERY','M','MAN','LAPACZ',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='RAFA'),'2008-07-12',51,NULL,4);
INSERT  INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('SONIA','D','PUSZYSTA','MILUSIA',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='ZOMBI'),'2010-11-18',20,35,3);
INSERT  INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('PUNIA','D','KURKA','LOWCZY',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='ZOMBI'),'2008-01-01',61,NULL,3);
INSERT  INTO KotyR (imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('LUCEK','M','ZERO','KOT',(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO='KURKA'),'2010-03-01',43,NULL,3);

INSERT INTO PlebsR (nr_plebsu,kotek) VALUES (1,(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO ='ZERO' ));
INSERT INTO PlebsR (nr_plebsu,kotek) VALUES (2,(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO ='KURKA' ));
INSERT INTO PlebsR (nr_plebsu,kotek) VALUES (3,(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO ='PUSZYSTA' ));
INSERT INTO PlebsR (nr_plebsu,kotek) VALUES (4,(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO ='MAN' ));
INSERT INTO PlebsR (nr_plebsu,kotek) VALUES (5,(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO ='MALY' ));
INSERT INTO PlebsR (nr_plebsu,kotek) VALUES (6,(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO ='UCHO' ));
INSERT INTO PlebsR (nr_plebsu,kotek) VALUES (7,(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO ='DAMA' ));
INSERT INTO PlebsR (nr_plebsu,kotek) VALUES (8,(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO ='LASKA' ));
INSERT INTO PlebsR (nr_plebsu,kotek) VALUES (9,(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO ='SZYBKA' ));
INSERT INTO PlebsR (nr_plebsu,kotek) VALUES (10,(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO ='RURA' ));
INSERT INTO PlebsR (nr_plebsu,kotek) VALUES (11,(SELECT REF(k) FROM KotyR k WHERE k.PSEUDO ='PLACEK' ));

INSERT INTO ElitaR(nr_elity, kotek, sluga) VALUES (1, (SELECT REF(K) FROM KotyR k WHERE k.pseudo='TYGRYS'), (SELECT REF(S) FROM PlebsR s WHERE s.nr_plebsu=10));
INSERT INTO ElitaR(nr_elity, kotek, sluga) VALUES (2, (SELECT REF(K) FROM KotyR k WHERE k.pseudo='LOLA'), (SELECT REF(S) FROM PlebsR s WHERE s.nr_plebsu=10));--Dwoch maja tego samego
INSERT INTO ElitaR(nr_elity, kotek, sluga) VALUES (3, (SELECT REF(K) FROM KotyR k WHERE k.pseudo='BOLEK'), (SELECT REF(S) FROM PlebsR s WHERE s.nr_plebsu=11));
INSERT INTO ElitaR(nr_elity, kotek, sluga) VALUES (4, (SELECT REF(K) FROM KotyR k WHERE k.pseudo='ZOMBI'), (SELECT REF(S) FROM PlebsR s WHERE s.nr_plebsu=1));
INSERT INTO ElitaR(nr_elity, kotek, sluga) VALUES (5, (SELECT REF(K) FROM KotyR k WHERE k.pseudo='LYSY'), (SELECT REF(S) FROM PlebsR s WHERE s.nr_plebsu=3));
INSERT INTO ElitaR(nr_elity, kotek, sluga) VALUES (6, (SELECT REF(K) FROM KotyR k WHERE k.pseudo='MALA'), (SELECT REF(S) FROM PlebsR s WHERE s.nr_plebsu=5));
INSERT INTO ElitaR(nr_elity, kotek, sluga) VALUES (7, (SELECT REF(K) FROM KotyR k WHERE k.pseudo='RAFA'), (SELECT REF(S) FROM PlebsR s WHERE s.nr_plebsu=7));

INSERT INTO KontaR(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia) VALUES(1,(SELECT REF(k) FROM ElitaR k WHERE k.nr_elity=1),'2020-01-01',NULL);
INSERT INTO KontaR(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia) VALUES(2,(SELECT REF(k) FROM ElitaR k WHERE k.nr_elity=1),'2019-01-01','2019-09-02');
INSERT INTO KontaR(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia) VALUES(3,(SELECT REF(k) FROM ElitaR k WHERE k.nr_elity=1),'2015-11-06','2017-09-11');
INSERT INTO KontaR(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia) VALUES(4,(SELECT REF(k) FROM ElitaR k WHERE k.nr_elity=2),'2012-10-02',NULL);
INSERT INTO KontaR(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia) VALUES(5,(SELECT REF(k) FROM ElitaR k WHERE k.nr_elity=2),'2018-05-08','2019-02-12');
INSERT INTO KontaR(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia) VALUES(6,(SELECT REF(k) FROM ElitaR k WHERE k.nr_elity=3),'2015-05-23','2019-10-04');
INSERT INTO KontaR(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia) VALUES(7,(SELECT REF(k) FROM ElitaR k WHERE k.nr_elity=4),'2011-11-23',NULL);
INSERT INTO KontaR(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia) VALUES(8,(SELECT REF(k) FROM ElitaR k WHERE k.nr_elity=5),'2014-05-12','2016-10-02');
INSERT INTO KontaR(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia) VALUES(9,(SELECT REF(k) FROM ElitaR k WHERE k.nr_elity=6),'2013-09-11','2019-09-15');
INSERT INTO KontaR(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia) VALUES(10,(SELECT REF(k) FROM ElitaR k WHERE k.nr_elity=6),'2017-10-12','2018-11-01');
INSERT INTO KontaR(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia) VALUES(12,(SELECT REF(k) FROM ElitaR k WHERE k.nr_elity=7),'2017-10-12',Null);
INSERT INTO KontaR(nr_myszy, wlasciciel, data_wprowadzenia, data_usuniecia) VALUES(13,(SELECT REF(k) FROM ElitaR k WHERE k.nr_elity=7),'2017-10-12',Null);

INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (1,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='TYGRYS'),'KAZIO','2004-10-13','USILOWAL NABIC NA WIDLY');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (2,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='ZOMBI'),'SWAWOLNY DYZIO','2005-03-07','WYBIL OKO Z PROCY');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (3,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='BOLEK'),'KAZIO','2005-03-29','POSZCZUL BURKIEM');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (4,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='SZYBKA'),'GLUPIA ZOSKA','2006-09-12','UZYLA KOTA JAKO SCIERKI');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (5,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='MALA'),'CHYTRUSEK','2007-03-07','ZALECAL SIE');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (6,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='TYGRYS'),'DZIKI BILL','2007-06-12','USILOWAL POZBAWIC ZYCIA');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (7,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='BOLEK'),'DZIKI BILL','2007-11-10','ODGRYZL UCHO');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (8,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='LASKA'),'DZIKI BILL','2008-12-12','POGRYZL ZE LEDWO SIE WYLIZALA');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (9,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='LASKA'),'KAZIO','2009-01-07','ZLAPAL ZA OGON I ZROBIL WIATRAK');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (10,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='DAMA'),'KAZIO','2009-02-07','CHCIAL OBEDRZEC ZE SKORY');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (11,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='MAN'),'REKSIO','2009-04-14','WYJATKOWO NIEGRZECZNIE OBSZCZEKAL');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (12,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='LYSY'),'BETHOVEN','2009-05-11','NIE PODZIELIL SIE SWOJA KASZA');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (13,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='RURA'),'DZIKI BILL','2009-09-03','ODGRYZL OGON');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (14,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='PLACEK'),'BAZYLI','2010-07-12','DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (15,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='PUSZYSTA'),'SMUKLA','2010-11-19','OBRZUCILA SZYSZKAMI');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (16,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='KURKA'),'BUREK','2010-12-14','POGONIL');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (17,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='MALY'),'CHYTRUSEK','2011-07-13','PODEBRAL PODEBRANE JAJKA');
INSERT INTO IncydentyR (nr_incydentu,kotek,imie_wroga,data_incydentu,opis_incydentu)
    VALUES (18,(SELECT REF(K) FROM KotyR k WHERE k.pseudo='UCHO'),'SWAWOLNY DYZIO','2011-07-14','OBRZUCIL KAMIENIAMI');


--zlaczenie
SELECT inc.kotek.PSEUDO, inc.IMIE_WROGA, inc.DATA_INCYDENTU, inc.OPIS_INCYDENTU
FROM IncydentyR inc
WHERE inc.kotek.PSEUDO = 'TYGRYS';


--grupowanie
SELECT kn.WLASCICIEL.KOTEK.DAJPSEUDO() "Pseudo", COUNT(*) "Ile myszy na koncie"
FROM KontaR kn
GROUP BY kn.WLASCICIEL.KOTEK.DAJPSEUDO()
ORDER BY "Ile myszy na koncie" DESC;

--podzapytanie
SELECT k.PSEUDO
FROM kotyR k
WHERE k.W_stadku_od < (SELECT min(inc.data_incydentu) from IncydentyR inc);


--lista2

--zad.23

SELECT k.IMIE, k.dajPelnyPrzydzial() * 12 "DAWKA ROCZNA", 'powyzej 864' "DAWKA"
FROM KotyR k
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
    pseudo_kota      KotyR.pseudo%TYPE := &pseudo;
    przydzial        KotyR.PRZYDZIAL_MYSZY%TYPE;
    data_wystapienia KotyR.w_stadku_od%TYPE;
    imie_kota        KotyR.imie%TYPE;
BEGIN
    SELECT k.dajPelnyPrzydzial(), k.W_STADKU_OD, k.IMIE
    INTO przydzial,data_wystapienia, imie_kota
    FROM KotyR k
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
    FOR kot IN (SELECT k.PSEUDO, k.dajPelnyPrzydzial() "Zjada" FROM KotyR k ORDER BY k.dajPelnyPrzydzial() DESC)
        LOOP
            EXIT WHEN i > 5;
            DBMS_OUTPUT.PUT_LINE(i || ' ' || LPAD(kot.PSEUDO, 11) || '' ||
                                 LPAD((kot."Zjada"), 10));
            i := i + 1;
        END LOOP;
END;

--dla wszystkich kotow plci meskiej ktorzy nie uczestniczyli w zadnym incydencie znalezc liczbe dostepnyhc na koncie myszy,

SELECT K.PSEUDO, K.PLEC, (SELECT COUNT(*) FROM  KontaR K2 WHERE K2.DATA_USUNIECIA IS NULL AND K2.WLASCICIEL.KOTEK.PSEUDO = K.PSEUDO  ) FROM KotyR K
WHERE K.PLEC='M'
MINUS
SELECT I.KOTEK.PSEUDO, I.KOTEK.PLEC, (SELECT COUNT(*) FROM  KontaR K2 WHERE K2.DATA_USUNIECIA IS NULL AND K2.WLASCICIEL.KOTEK.PSEUDO = I.KOTEK.PSEUDO  ) FROM IncydentyR I
;

SELECT E.KOTEK.PSEUDO FROM ElitaR E LEFT JOIN IncydentyR I ON E.KOTEK = I.KOTEK WHERE I.NR_INCYDENTU IS NULL;
SELECT * FROM KotyR K LEFT JOIN IncydentyR I On K.PSEUDO = VALUE(I).KOTEK.PSEUDO WHERE I.NR_INCYDENTU IS NULL;

SELECT DISTINCT I.KOTEK.PSEUDO FROM IncydentyR I;

SELECT COUNT(*) FROM  KontaR K2 WHERE K2.DATA_USUNIECIA IS NULL AND K2.WLASCICIEL.KOTEK.PSEUDO = K.PSEUDO

