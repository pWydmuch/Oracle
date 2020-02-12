-- blok jest jednostka transakcji, commitowane jest dopiero po zatwierdzeniu,
-- czyli jak cos usuniesz to mozesz sie do tego odwolac w tym samym bloku? chyba ze jawnie zrobisz Commit

-- w pl sql nie można chyba używać podzapytań do przypisywania


-- zad.34
DECLARE
    fun    Kocury.funkcja%TYPE := &funkcja;
    liczba NUMBER;
BEGIN
    SELECT count(*) INTO liczba FROM KOCURY WHERE FUNKCJA = UPPER(fun);
    IF liczba > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Znaleziono kota o funkcji ' || fun);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nie naleziono kota o tej funkcji');
    END IF;
END;

--zad.35
DECLARE
    pseudo_kota      Kocury.pseudo%TYPE := &pseudo;
    przydzial        Kocury.PRZYDZIAL_MYSZY%TYPE;
    data_wystapienia Kocury.w_stadku_od%TYPE;
    imie_kota        Kocury.imie%TYPE;
BEGIN
    SELECT PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0), W_STADKU_OD, IMIE
    INTO przydzial,data_wystapienia, imie_kota
    FROM Kocury
    WHERE PSEUDO = UPPER(pseudo_kota);
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


--zad.36

DECLARE
    zmian         NUMBER := 0;
    sum_przydzial NUMBER;
BEGIN
    SELECT sum(PRZYDZIAL_MYSZY) INTO sum_przydzial from KOCURY;
    <<loop_zew>>
    LOOP
        FOR kot IN (SELECT *
                    FROM KOCURY
                             JOIN FUNKCJE F on KOCURY.FUNKCJA = F.FUNKCJA
                    ORDER BY PRZYDZIAL_MYSZY)
            LOOP
                IF 1.1 * kot.PRZYDZIAL_MYSZY <= kot.MAX_MYSZY THEN
                    UPDATE KOCURY
                    SET PRZYDZIAL_MYSZY=PRZYDZIAL_MYSZY + ROUND(0.1 * PRZYDZIAL_MYSZY)
                    WHERE PSEUDO = kot.PSEUDO;
                    zmian := zmian + 1;
                    sum_przydzial := sum_przydzial + ROUND(0.1 * kot.PRZYDZIAL_MYSZY);
                ELSIF 1.1 * kot.PRZYDZIAL_MYSZY > kot.MAX_MYSZY THEN
                    UPDATE KOCURY
                    SET PRZYDZIAL_MYSZY=kot.MAX_MYSZY
                    WHERE PSEUDO = kot.PSEUDO;
                    zmian := zmian + 1;
                    sum_przydzial := sum_przydzial + (kot.MAX_MYSZY - kot.PRZYDZIAL_MYSZY);
                END IF;
                EXIT loop_zew WHEN sum_przydzial > 1050;
            END LOOP;
    END LOOP loop_zew;
    DBMS_OUTPUT.put_line('Calk. przydzial w stadku ' || sum_przydzial || ' Zmian ' || zmian);
END;


SELECT imie, PRZYDZIAL_MYSZY "Myszki po podwyżce"
FROM KOCURY;

ROLLBACK;


select *
from FUNKCJE;

--zad.37
DECLARE
    i NUMBER := 1;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Nr    Pseudonim    Zjada');
    DBMS_OUTPUT.PUT_LINE('------------------------ ');
    FOR kot IN (SELECT * FROM KOCURY ORDER BY PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0) DESC)
        LOOP
            EXIT WHEN i > 5;
            DBMS_OUTPUT.PUT_LINE(i || ' ' || LPAD(kot.PSEUDO, 11) || '' ||
                                 LPAD((kot.PRZYDZIAL_MYSZY + NVL(kot.MYSZY_EXTRA, 0)), 10));
            i := i + 1;
        END LOOP;
END;

--zad.38

DECLARE
    ile       NUMBER        := &ile;
    heading   VARCHAR2(100) := 'Imie';
    szefowie  VARCHAR2(100);
    separator VARCHAR2(100);
    szefu     Kocury%ROWTYPE;
BEGIN
    FOR i IN 1 .. ile
        LOOP
            heading := heading || LPAD('| Szef ' || i, 15);
        end loop;
    DBMS_OUTPUT.PUT_LINE(heading);
    FOR i IN 0 .. ile
        LOOP
            separator := separator || '------------ ';
        end loop;
    DBMS_OUTPUT.PUT_LINE(separator);
    FOR kot IN (SELECT *
                FROM KOCURY
                WHERE FUNKCJA in ('MILUSIA', 'KOT') )
        LOOP
            szefu := kot;
            szefowie := kot.imie;
            FOR i IN 1 .. ile
                LOOP
                    IF szefu.SZEF is null THEN
                        szefowie := szefowie || '    ';
                    ELSE
                        SELECT * INTO szefu FROM KOCURY WHERE PSEUDO = szefu.SZEF;
                        szefowie := szefowie || LPAD(szefu.IMIE, 15);
                    END IF;
                END LOOP;
            DBMS_OUTPUT.PUT_LINE(szefowie);
        END LOOP;
END;

--zad.39

DECLARE
    nr_b      BANDY.nr_bandy%TYPE := &nr;
    nazwa_b   BANDY.nazwa%TYPE    := &nazwa;
    teren_b   BANDY.teren%TYPE    := &teren;
    minus_number EXCEPTION;
    same_data EXCEPTION;
    czyBlad   BOOLEAN             := FALSE;
    komunikat varchar2(256)       := '';
BEGIN
    IF nr_b <= 0 THEN
        RAISE minus_number;
    END IF;
    FOR banda IN (SELECT * FROM BANDY)
        LOOP
            IF nr_b = banda.NR_BANDY OR nazwa_b = banda.NAZWA OR teren_b = banda.TEREN THEN
                czyBlad := TRUE;
            end if;
            IF nr_b = banda.NR_BANDY THEN
                komunikat := komunikat || ' ' || TO_CHAR(nr_b);
            end if;
            IF nazwa_b = banda.NAZWA THEN
                komunikat := komunikat || ' ' || nazwa_b;
            end if;
            IF teren_b = banda.TEREN THEN
                komunikat := komunikat || ' ' || teren_b;
            end if;
        END LOOP;
    IF czyBlad THEN
        RAISE same_data;
    END IF;
    INSERT INTO BANDY(nr_bandy, nazwa, teren) VALUES (nr_b, nazwa_b, teren_b);
EXCEPTION
    WHEN
        minus_number THEN DBMS_OUTPUT.PUT_LINE('Ujemny numer');
    WHEN
        same_data THEN DBMS_OUTPUT.PUT_LINE(komunikat || ' juz istnieje');
END;

SELECT *
FROM BANDY;


ROLLBACK;

--zad.40

CREATE OR REPLACE PROCEDURE dodaj_bande(nr_b BANDY.nr_bandy%TYPE,
                                        nazwa_b BANDY.nazwa%TYPE,
                                        teren_b BANDY.teren%TYPE)
AS
    minus_number EXCEPTION;
    same_data EXCEPTION;
    czyBlad   BOOLEAN       := FALSE;
    komunikat varchar2(256) := '';
BEGIN
    IF nr_b <= 0 THEN
        RAISE minus_number;
    END IF;
    FOR banda IN (SELECT * FROM BANDY)
        LOOP
            IF nr_b = banda.NR_BANDY OR nazwa_b = banda.NAZWA OR teren_b = banda.TEREN THEN
                czyBlad := TRUE;
            end if;
            IF nr_b = banda.NR_BANDY THEN
                komunikat := komunikat || ' ' || TO_CHAR(nr_b);
            end if;
            IF nazwa_b = banda.NAZWA THEN
                komunikat := komunikat || ' ' || nazwa_b;
            end if;
            IF teren_b = banda.TEREN THEN
                komunikat := komunikat || ' ' || teren_b;
            end if;
        END LOOP;
    IF czyBlad THEN
        RAISE same_data;

    END IF;
    INSERT INTO BANDY(nr_bandy, nazwa, teren) VALUES (nr_b, nazwa_b, teren_b);
EXCEPTION
    WHEN
        minus_number THEN DBMS_OUTPUT.PUT_LINE('Ujemny numer');
    WHEN
        same_data THEN DBMS_OUTPUT.PUT_LINE(komunikat || ' juz istnieje');
END;

begin
    dodaj_bande(33, 'd', 'SasdAD');
end;
ROLLBACK;
Select *
from bandy;
SELECT *
from USER_OBJECTS;
DROP procedure dodaj_bande;


--zad.41

CREATE OR REPLACE TRIGGER insert_banda
    BEFORE INSERT
    ON BANDY
    FOR EACH ROW
BEGIN
    SELECT max(NR_BANDY) + 1 INTO :NEW.nr_bandy FROM BANDY;
END;

begin
    dodaj_bande(10, 'dfs', 'xz');
end;

select *
from bandy;
rollback;
delete BANDY
where NR_BANDY = 10;


--zad.42
--a
CREATE OR REPLACE PACKAGE virus AS
    tygrys_10p NUMBER;
    tygrys_przy NUMBER;
    strata NUMBER;
    nagroda NUMBER;
END;

CREATE OR REPLACE PACKAGE BODY virus AS
    BEGIN
    virus.strata := 0;
    virus.nagroda := 0;
end;

CREATE OR REPLACE TRIGGER set_tygrys_10_p
    BEFORE UPDATE
    ON KOCURY
BEGIN
    SELECT FLOOR(0.1 * PRZYDZIAL_MYSZY),PRZYDZIAL_MYSZY INTO virus.tygrys_10p,virus.tygrys_przy FROM KOCURY WHERE PSEUDO = 'TYGRYS';
END;

CREATE OR REPLACE TRIGGER podwyzka_milus
    BEFORE UPDATE
    ON KOCURY
    FOR EACH ROW
DECLARE
    roznica NUMBER;
BEGIN
    IF :OLD.FUNKCJA = 'MILUSIA' THEN
        roznica := :NEW.PRZYDZIAL_MYSZY - :OLD.PRZYDZIAL_MYSZY;
        IF roznica < 0 THEN
            :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
        ELSIF roznica < virus.tygrys_10p THEN
            :NEW.MYSZY_EXTRA := :NEW.MYSZY_EXTRA + 5; --NIE ROBISZ UPDATE TYLKO ZMIENIASZ WARTOSCI KTORA DO NIEGO IDZIE
            :NEW.PRZYDZIAL_MYSZY := (:NEW.PRZYDZIAL_MYSZY + virus.tygrys_10p);
            virus.strata := virus.strata + 1;
        ELSE
            virus.nagroda := virus.nagroda + 1;
        END IF;
    END IF;
END;

CREATE OR REPLACE TRIGGER tygrys_zmiana
    AFTER UPDATE
    ON KOCURY
DECLARE
    roznica_mysz_ex NUMBER;
    roznica_przydz  NUMBER;
BEGIN
    IF virus.nagroda > 0 THEN
        roznica_mysz_ex := 5 * virus.nagroda;
        virus.nagroda := 0;
        UPDATE KOCURY
        SET MYSZY_EXTRA=MYSZY_EXTRA + roznica_mysz_ex
        WHERE PSEUDO = 'TYGRYS';
    end if;
    IF virus.strata > 0 THEN
        roznica_przydz := FLOOR(0.1*virus.tygrys_przy*virus.strata);
        virus.strata := 0;
        UPDATE KOCURY
        SET PRZYDZIAL_MYSZY=PRZYDZIAL_MYSZY - roznica_przydz
        WHERE PSEUDO = 'TYGRYS';
    end if;
    virus.tygrys_przy := 0;
    virus.tygrys_10p := 0;
END;


select *
from KOCURY;
update KOCURY
set PRZYDZIAL_MYSZY = (PRZYDZIAL_MYSZY + 15)
where FUNKCJA = 'MILUSIA';
rollback;

drop trigger set_tygrys_10_p;
drop trigger podwyzka_milus;
drop trigger tygrys_zmiana;
drop package virus;

--b

CREATE OR REPLACE TRIGGER comp_tr
    FOR UPDATE
    ON KOCURY
    COMPOUND TRIGGER
    tygrys_10p NUMBER;
    tygrys_przy NUMBER;
    strata NUMBER := 0;
    nagroda NUMBER := 0;
BEFORE STATEMENT IS
BEGIN
    SELECT PRZYDZIAL_MYSZY, FLOOR(0.1 * PRZYDZIAL_MYSZY)
    INTO tygrys_przy, tygrys_10p
    FROM KOCURY
    WHERE PSEUDO = 'TYGRYS';
END BEFORE STATEMENT;
    BEFORE EACH ROW IS
        roznica NUMBER;
    BEGIN
        IF :NEW.FUNKCJA = 'MILUSIA' THEN
            roznica := :NEW.PRZYDZIAL_MYSZY - :OLD.PRZYDZIAL_MYSZY;
            IF roznica < 0 THEN
                :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
            ELSIF roznica < tygrys_10p THEN
                :NEW.MYSZY_EXTRA := (:NEW.MYSZY_EXTRA + 5); --NIE ROBISZ UPDATE TYLKO ZMIENIASZ WARTOSCI KTORA DO NIEGO IDZIE
                :NEW.PRZYDZIAL_MYSZY := (:NEW.PRZYDZIAL_MYSZY + tygrys_10p);
                strata := strata + 1;
            ELSE
                nagroda := nagroda + 1;
            END IF;
        END IF;
    END BEFORE EACH ROW ;
    AFTER STATEMENT IS
        p10             NUMBER;
        roznica_mysz_ex NUMBER;
        roznica_przydz  NUMBER;
    BEGIN
        IF nagroda > 0 THEN
            roznica_mysz_ex := 5 * nagroda;
            nagroda := 0;
            UPDATE KOCURY
            SET MYSZY_EXTRA=MYSZY_EXTRA + roznica_mysz_ex
            WHERE PSEUDO = 'TYGRYS';
        end if;
        IF strata > 0 THEN
            FOR i IN 1..strata
                LOOP
                    p10 := FLOOR(tygrys_przy * 0.1);
                    tygrys_przy := tygrys_przy - p10;
                    roznica_przydz := roznica_przydz + p10;
                end loop;
            strata := 0;
            UPDATE KOCURY
            SET PRZYDZIAL_MYSZY=PRZYDZIAL_MYSZY - roznica_przydz
            WHERE PSEUDO = 'TYGRYS';
        end if;
        tygrys_przy := 0;
        tygrys_10p := 0;
    END AFTER STATEMENT ;
    END;

select *
from KOCURY;
update KOCURY
set PRZYDZIAL_MYSZY = (PRZYDZIAL_MYSZY + 19) -- WYCHODZI NULL dla tygrysa przy niedostatku
where FUNKCJA = 'MILUSIA';
rollback;
drop trigger comp_tr;

--zad.43
DECLARE
    naglowek VARCHAR(300);
    myslniki VARCHAR(300);
    cursor funkcje is (SELECT FUNKCJA
                       FROM FUNKCJE);
    ilosc    NUMBER;
BEGIN
    naglowek := RPAD('NAZWA BANDY', 20) || '  PLEC  ' || 'ILE';
    myslniki := RPAD('-----------', 20) || '  ----  ' || '--';
    FOR fun IN funkcje
        LOOP
            naglowek := naglowek || LPAD(fun.funkcja, 20);
            myslniki := myslniki || LPAD('--------------', 20);
        end loop;
    DBMS_OUTPUT.PUT_LINE(naglowek || LPAD('SUMA', 20));
    DBMS_OUTPUT.PUT_LINE(myslniki || LPAD('----', 20));

    FOR banda IN (SELECT NAZWA, NR_BANDY FROM BANDY)
        LOOP
            FOR ple IN (SELECT PLEC FROM KOCURY GROUP BY plec)
                LOOP
                    IF ple.PLEC = 'M' THEN
                        DBMS_OUTPUT.PUT(RPAD(banda.NAZWA, 20));
                        DBMS_OUTPUT.PUT(LPAD('Kocor', 6));

                    ELSE
                        DBMS_OUTPUT.PUT(LPAD(' ', 20));
                        DBMS_OUTPUT.PUT(LPAD('Kotka', 6));
                    END IF;
                    SELECT count(*)
                    INTO ilosc
                    FROM KOCURY
                    where KOCURY.NR_BANDY = banda.NR_BANDY
                      AND KOCURY.PLEC = ple.plec; --ile kotow z dana banda i plcia
                    dbms_output.put(LPAD(ilosc, 4));

                    for fun in funkcje
                        loop
                            SELECT sum(PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0))
                            into ilosc
                            from KOCURY K
                            WHERE K.PLEC = ple.plec
                              AND K.FUNKCJA = fun.FUNKCJA
                              AND K.NR_BANDY = banda.NR_BANDY; --ile kotow z dana banda, plcia i funkcja
                            dbms_output.put(LPAD(NVL(ilosc, 0), 20));
                        end loop;

                    SELECT SUM(PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0))
                    into ilosc
                    FROM KOCURY K
                    where K.NR_BANDY = banda.NR_BANDY
                      AND ple.PLEC = K.PLEC;
                    dbms_output.put(LPAD(NVL(ilosc, 0), 20));
                    dbms_output.new_line();
                end loop;
        end loop;

    DBMS_OUTPUT.PUT_LINE(myslniki || LPAD('----', 20));
    DBMS_OUTPUT.PUT(RPAD('ZJADA', 32));
    for fun in funkcje
        loop
            SELECT SUM(PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0))
            into ilosc
            from Kocury K
            where K.FUNKCJA = fun.FUNKCJA;
            dbms_output.put(LPAD(NVL(ilosc, 0), 20));
        end loop;

    SELECT sum(PRZYDZIAL_MYSZY + nvl(MYSZY_EXTRA, 0)) into ilosc FROM Kocury;
    dbms_output.put(LPAD(ilosc, 20));
    dbms_output.new_line();
END;


--zad.44

CREATE
    OR
    REPLACE FUNCTION policz_podatek(pseudo2 KOCURY.pseudo%TYPE)
    RETURN NUMBER AS
    podatek  NUMBER;
    ile_pod  NUMBER;
    od_kiedy DATE;
    ile_wrog NUMBER;
BEGIN
    SELECT CEIL(0.05 * (PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0))) INTO podatek FROM KOCURY WHERE pseudo = pseudo2;
    SELECT count(*) INTO ile_pod FROM KOCURY WHERE szef = pseudo2;
    SELECT count(*) INTO ile_wrog FROM WROGOWIE_KOCUROW WHERE PSEUDO = pseudo2;
    SELECT W_STADKU_OD INTO od_kiedy FROM KOCURY WHERE pseudo2 = PSEUDO;
    IF ile_pod = 0 THEN
        podatek := podatek + 2;
    END IF;
    IF ile_wrog = 0 THEN
        podatek := podatek + 1;
    END IF;
    IF EXTRACT(YEAR FROM od_kiedy) > 2009 THEN
        podatek := podatek + 2;
    END IF;
    return podatek;
end;


CREATE
    OR
    REPLACE PACKAGE podatek AS
    FUNCTION POLICZ_PODATEK(pseudo2 KOCURY.PSEUDO%TYPE)
        RETURN NUMBER;
    PROCEDURE
        dodaj_bande(nr_b BANDY.nr_bandy%TYPE,
                    nazwa_b BANDY.nazwa%TYPE,
                    teren_b BANDY.teren%TYPE);
END;

CREATE OR REPLACE PACKAGE BODY podatek AS
    FUNCTION POLICZ_PODATEK(pseudo2 KOCURY.PSEUDO%TYPE) RETURN NUMBER AS
        podatek  NUMBER;
        ile_pod  NUMBER;
        od_kiedy DATE;
        ile_wrog NUMBER;
    BEGIN
        SELECT CEIL(0.05 * (PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0))) INTO podatek FROM KOCURY WHERE pseudo = pseudo2;
        SELECT count(*) INTO ile_pod FROM KOCURY WHERE szef = pseudo2;
        SELECT count(*) INTO ile_wrog FROM WROGOWIE_KOCUROW WHERE PSEUDO = pseudo2;
        SELECT W_STADKU_OD INTO od_kiedy FROM KOCURY WHERE pseudo2 = PSEUDO;
        IF ile_pod = 0 THEN
            podatek := podatek + 2;
        END IF;
        IF ile_wrog = 0 THEN
            podatek := podatek + 1;
        END IF;
        IF EXTRACT(YEAR FROM od_kiedy) > 2009 THEN
            podatek := podatek + 2;
        END IF;
        return podatek;
    end;

    PROCEDURE dodaj_bande(nr_b BANDY.nr_bandy%TYPE,
                          nazwa_b BANDY.nazwa%TYPE,
                          teren_b BANDY.teren%TYPE)
    AS
        minus_number EXCEPTION;
        same_data EXCEPTION;
    BEGIN
        IF nr_b <= 0 THEN
            RAISE minus_number;
        END IF;
        FOR banda IN (SELECT * FROM BANDY)
            LOOP
                IF nr_b = banda.NR_BANDY OR nazwa_b = banda.NAZWA OR teren_b = banda.TEREN THEN
                    RAISE same_data;
                end if;
            END LOOP;
        INSERT INTO BANDY(nr_bandy, nazwa, teren) VALUES (nr_b, nazwa_b, teren_b);
    EXCEPTION
        WHEN
            minus_number THEN DBMS_OUTPUT.PUT_LINE('Ujemny numer');
        WHEN
            same_data THEN DBMS_OUTPUT.PUT_LINE('juz istnieje');
    END;
end;

begin
    dbms_output.put(RPAD('PSEUDONIM', 10));
    dbms_output.put(LPAD('PODATKEK PODGLOWNY', 20));
    dbms_output.new_line();
    for kocur in (SELECT PSEUDO from Kocury)
        loop
            dbms_output.put_line(RPAD(kocur.pseudo, 10) || LPAD(podatek.policz_podatek(kocur.pseudo), 20));
        end loop;
end;

drop function policz_podatek;
drop package podatek;


--zad.45


create table dodatki_extra
(

    PSEUDO        varchar2(15)
        constraint dod_ps_fk references KOCURY (PSEUDO),
    DODATEK_EXTRA number(2) not null
);
drop table dodatki_extra;



CREATE OR REPLACE TRIGGER kontrola_milus
    AFTER UPDATE OF PRZYDZIAL_MYSZY
    ON KOCURY
    FOR EACH ROW
    WHEN ( old.funkcja = 'MILUSIA') --w when bez :
DECLARE
    pragma autonomous_transaction ;
BEGIN
    IF :new.PRZYDZIAL_MYSZY > :old.PRZYDZIAL_MYSZY AND LOGIN_USER != 'TYGRYS' THEN
        EXECUTE IMMEDIATE '
        BEGIN
            FOR milusia IN (SELECT * FROM KOCURY WHERE FUNKCJA = ''MILUSIA'')
                Loop
                    INSERT INTO dodatki_extra(PSEUDO, DODATEK_EXTRA) VALUES (milusia.PSEUDO, -10);
                    commit;
                end loop;
        end;
        ';
    end if;
end;
UPDATE KOCURY
set PRZYDZIAL_MYSZY = PRZYDZIAL_MYSZY + 1
where FUNKCJA = 'MILUSIA';

select *
from dodatki_extra;
delete dodatki_extra;
rollback;
drop trigger kontrola_milus;
--zad.46

CREATE TABLE
    zdarzenia
(
    uzytkownik VARCHAR2(15),
    data       DATE,
    pseudo     varchar2(15)
        constraint fg_pseudo references KOCURY (PSEUDO),
    polecenie  VARCHAR2(10)
);
drop
    table
    zdarzenia;
CREATE OR
    REPLACE TRIGGER update_przydzial
    BEFORE UPDATE OF przydzial_myszy
    ON KOCURY
    FOR EACH ROW
DECLARE
--     PRAGMA AUTONOMOUS_TRANSACTION;
    maxm NUMBER; minm NUMBER; who varchar2(15) default ' '; what varchar2(15);
    blad EXCEPTION ;
BEGIN
    SELECT MIN_MYSZY, MAX_MYSZY INTO minm, maxm FROM FUNKCJE WHERE FUNKCJA = :NEW.funkcja;

    IF :NEW.przydzial_myszy NOT BETWEEN minm AND maxm THEN
        who := LOGIN_USER; what := 'UPDATE';
        INSERT INTO zdarzenia VALUES (who, SYSDATE, :NEW.pseudo, what);
        RAISE blad;
--         COMMIT;
--         raise_application_error(-20001, 'Wartość jest za duża lub z mała.');
    END IF;
    EXCEPTION
    WHEN blad THEN DBMS_OUTPUT.PUT_LINE('blad');
end;

update KOCURY
set PRZYDZIAL_MYSZY = 452 --za duzo - kot ma max 60
where PSEUDO = 'UCHO';
select *
from zdarzenia;
delete zdarzenia;
rollback;
drop trigger update_przydzial;

select *
from kocury
where PSEUDO = 'UCHO';
select *
from FUNKCJE;


