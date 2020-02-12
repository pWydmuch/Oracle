--zad.1
SELECT imie_wroga Wrog, opis_incydentu Przewina
FROM wrogowie_kocurow
WHERE EXTRACT( YEAR FROM data_incydentu) = 2009;

--zad.2
SELECT imie, funkcja, TO_CHAR(w_stadku_od,'YYYY-MM-DD') "Z NAMI OD"
FROM kocury
WHERE w_stadku_od   BETWEEN TO_DATE('01/09/2005','DD/MM/YYYY') AND TO_DATE('31/07/2007','DD/MM/YYYY') AND plec='D';

--zad.3
SELECT imie_wroga, gatunek, stopien_wrogosci "STOPIEN WROGOSCI"
FROM wrogowie
WHERE lapowka IS NULL
ORDER BY stopien_wrogosci;

--zad.4
SELECT imie || ' zwany ' || pseudo ||' (fun. ' ||funkcja || ') lowi myszki w bandzie ' || nr_bandy || ' od ' || w_stadku_od "WSZYSTKO O KOCURACH"
FROM kocury
WHERE plec='M'
ORDER BY w_stadku_od DESC, pseudo;

--zad.5
SELECT pseudo, REGEXP_REPLACE(REGEXP_REPLACE(pseudo,'A','#',1,1),'L','%',1,1) "Po wymianie A na # oraz L na %"
FROM kocury
WHERE pseudo LIKE '%A%' AND pseudo LIKE '%L%';

--zad.6
SELECT imie, TO_CHAR(w_stadku_od,'YYYY-MM-DD') "W stadku", FLOOR((przydzial_myszy/11)*10) "Zjadal", TO_CHAR(ADD_MONTHS(w_stadku_od,6),'YYYY-MM-DD') Podwyzka, przydzial_myszy Zjada
FROM kocury
WHERE FLOOR(MONTHS_BETWEEN(TO_DATE('03/07/2019','DD-MM-YYYY'),w_stadku_od)/12) >= 10 
       AND EXTRACT(MONTH FROM w_stadku_od) BETWEEN 3 AND 9 
ORDER BY Zjada DESC;

--zad.7       
SELECT imie, przydzial_myszy*3 "MYSZY KWARTALNE", NVL(myszy_extra*3,0) "KWARTALNE_DODATKI"
FROM kocury
WHERE przydzial_myszy >= 55 AND przydzial_myszy > NVL(myszy_extra*2,0)
ORDER BY "MYSZY KWARTALNE" DESC;

--zad.8
SELECT imie,
        CASE 
            WHEN (przydzial_myszy + NVL(myszy_extra,0))*12 > 660 THEN TO_CHAR((przydzial_myszy + NVL(myszy_extra,0))*12)
            WHEN (przydzial_myszy + NVL(myszy_extra,0))*12=660 THEN 'Limit'
            ELSE  'Ponizej 660' 
        END "Zjada rocznie"
FROM kocury
ORDER BY imie;

--zad.9    
SELECT pseudo, TO_CHAR(w_stadku_od,'YYYY-MM-DD'), 
                            CASE
                                WHEN EXTRACT(day from w_stadku_od) <= 15 THEN 
                                    CASE
                                        WHEN EXTRACT(DAY FROM NEXT_DAY(LAST_DAY( TO_DATE('24/09/2019','DD/MM/YYYY')) - INTERVAL '7' DAY,3)) >= EXTRACT(DAY FROM TO_DATE('24/09/2019','DD/MM/YYYY'))  
                                             THEN TO_CHAR(NEXT_DAY(LAST_DAY( TO_DATE('24/09/2019','DD/MM/YYYY')) - INTERVAL '7' DAY,3),'YYYY-MM-DD')
                                        ELSE  TO_CHAR(NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('24/09/2019','DD/MM/YYYY'),1)) - INTERVAL '7' DAY,3),'YYYY-MM-DD')
                                    END
                                ELSE TO_CHAR(NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('24/09/2019','DD/MM/YYYY'),1)) - INTERVAL '7' DAY,3),'YYYY-MM-DD')
                            END wyplata
FROM kocury
ORDER BY w_stadku_od; 

SELECT pseudo, TO_CHAR(w_stadku_od,'YYYY-MM-DD'), 
                            CASE
                                WHEN EXTRACT(day from w_stadku_od) <= 15 THEN 
                                    CASE
                                        WHEN EXTRACT(day from NEXT_DAY(LAST_DAY( TO_DATE('26/09/2019','DD/MM/YYYY')) - INTERVAL '7' DAY,3)) >= EXTRACT(day from TO_DATE('26/09/2019','DD/MM/YYYY'))  
                                             THEN TO_CHAR(NEXT_DAY(LAST_DAY( TO_DATE('26/09/2019','DD/MM/YYYY')) - INTERVAL '7' DAY,3),'YYYY-MM-DD')
                                        ELSE  TO_CHAR(NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('26/09/2019','DD/MM/YYYY'),1)) - INTERVAL '7' DAY,3),'YYYY-MM-DD')
                                    END
                                ELSE TO_CHAR(NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('26/09/2019','DD/MM/YYYY'),1)) - INTERVAL '7' DAY,3),'YYYY-MM-DD')
                            END wyplata
FROM kocury
ORDER BY w_stadku_od;

--zad.10

SELECT CASE COUNT(pseudo)
           WHEN 1 THEN szef||' - Unikalny'
           ELSE szef||' - nieunikalny'
       END "Unikalnosc atr. szef"
FROM Kocury
    WHERE szef IS NOT NULL
GROUP BY szef
ORDER BY szef;

SELECT CASE COUNT(pseudo)
            WHEN 1 THEN pseudo ||' - Unikalny'
            ELSE pseudo||' - nieunikalny'
       END "Unikalnosc atr. pseudo"
FROM Kocury
GROUP BY pseudo
ORDER BY pseudo;

--zad .11
SELECT  pseudo "Pseudonim", COUNT(*) "Liczba wrogow"
FROM wrogowie_kocurow
GROUP BY pseudo
HAVING COUNT(*)>1;

--zad.12
SELECT 'Liczba kotow= ' || COUNT(*) || ' lowi jako ' || funkcja || ' i zjada max. ' || TO_CHAR(MAX(przydzial_myszy + NVL(myszy_extra,0)),'fm99.00') || ' myszy miesiecznie' "Maksymalny przydzial"
FROM kocury
WHERE plec!='M' AND funkcja!='szefunio'
GROUP BY funkcja
HAVING AVG(przydzial_myszy + NVL(myszy_extra,0)) > 50;

--zad13
SELECT nr_bandy "Nr bandy", plec, MIN(NVL(przydzial_myszy,0)) "Minimalny przydzial"
FROM kocury 
GROUP BY  plec, nr_bandy;

--zad.14
SELECT LEVEL "Poziom", pseudo "Pseudonim", funkcja, nr_bandy "Nr bandy"
FROM kocury
WHERE plec='M'
CONNECT BY PRIOR pseudo=szef
START WITH funkcja='BANDZIOR';

--zad.15
SELECT LPAD((LEVEL-1),(LEVEL-1)*4+1,'===>') ||'            ' || imie "Hierarchia", NVL(szef, 'Sam sobie panem') "Pseudo szefa", funkcja "Funkcja"
FROM kocury
WHERE myszy_extra IS NOT NULL
CONNECT BY PRIOR pseudo = szef
START WITH szef IS NULL;

--zad.16
SELECT LPAD(' ', 4*(LEVEL-1)) || pseudo "Droga sluzbowa"  
FROM Kocury
CONNECT BY pseudo = PRIOR szef AND pseudo != 'TYGRYS'
START WITH plec='M'
    AND MONTHS_BETWEEN(TO_DATE('03/07/2019','DD/MM/YYYY'), w_stadku_od) > 120
    AND myszy_extra IS NULL;