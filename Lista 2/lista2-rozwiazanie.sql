--zad.17
SELECT pseudo, przydzial_myszy, nazwa banda
FROM kocury kc
         JOIN bandy bn ON kc.nr_bandy = bn.nr_bandy
WHERE teren IN ('POLE', 'CALOSC')
  AND przydzial_myszy > 50
ORDER BY przydzial_myszy DESC;

--zad.18
SELECT kc.imie, TO_CHAR(kc.w_stadku_od, 'YYYY-MM-DD') "POLUJE OD"
FROM kocury kc,
     kocury kc2
WHERE kc2.IMIE = 'JACEK'
  AND kc.W_STADKU_OD < kc2.W_STADKU_OD
ORDER BY kc.W_STADKU_OD DESC;


--zad.19
--a
SELECT K1.IMIE,
       K1.FUNKCJA,
       NVL(K2.IMIE, ' ') "Szef 1",
       NVL(K3.IMIE, ' ') "Szef 2",
       NVL(K4.IMIE, ' ') "Szef 3" ---Musi byc k2.imie a nie k1.szef, bo szef jest dołaczony do pseuda
FROM KOCURY K1
         LEFT JOIN KOCURY K2 ON K1.SZEF = K2.PSEUDO
         LEFT JOIN KOCURY K3 ON K2.SZEF = K3.PSEUDO
         LEFT JOIN KOCURY K4 ON K3.SZEF = K4.PSEUDO
WHERE K1.FUNKCJA IN ('MILUSIA', 'KOT');

--b
SELECT Imi "IMIE", Funkcja, NVL(szef1, ' ') "Szef 1", NVL(szef2, ' ') "Szef 2", NVL(szef3, ' ') "Szef 3"
FROM (SELECT CONNECT_BY_ROOT imie Imi, CONNECT_BY_ROOT funkcja Funkcja, level lev, imie
      FROM Kocury
      CONNECT BY PRIOR szef = pseudo
      START WITH funkcja IN ('KOT', 'MILUSIA'))
    PIVOT (MIN(imie) FOR lev IN (2 szef1, 3 szef2, 4 szef3));
--c

SELECT CONNECT_BY_ROOT K1.IMIE               "Imie",
       CONNECT_BY_ROOT K1.FUNKCJA            "Funkcja",
       SYS_CONNECT_BY_PATH(K2.IMIE, '   | ') "Imiona kolejnych szefow"
FROM Kocury K1
         JOIN Kocury K2 ON K1.SZEF = K2.PSEUDO
WHERE K2.SZEF IS NULL
CONNECT BY PRIOR K1.szef = K1.pseudo
START WITH K1.funkcja IN ('KOT', 'MILUSIA');

--zad.20
SELECT IMIE             "Imie kotki",
       NAZWA            "Nazwa bandy",
       WK.IMIE_WROGA    "Imie wroga",
       STOPIEN_WROGOSCI "Ocena wroga",
       DATA_INCYDENTU   "Data inc."
FROM KOCURY K
         JOIN BANDY B on K.NR_BANDY = B.NR_BANDY
         JOIN WROGOWIE_KOCUROW WK on K.PSEUDO = WK.PSEUDO
         JOIN WROGOWIE W on WK.IMIE_WROGA = W.IMIE_WROGA
WHERE DATA_INCYDENTU > TO_DATE('01.01.2007', 'DD.MM.YYYY')
  AND PLEC = 'D'
ORDER BY "Imie kotki";

--zad.21

SELECT NAZWA, COUNT(DISTINCT K.PSEUDO) "Liczba wrogow"
FROM BANDY B
         JOIN KOCURY K on B.NR_BANDY = K.NR_BANDY
         JOIN WROGOWIE_KOCUROW WK on K.PSEUDO = WK.PSEUDO
GROUP BY NAZWA;

--zad.22
SELECT K.FUNKCJA, K.PSEUDO "Pseudonim kota", COUNT(*)
FROM KOCURY K
         JOIN FUNKCJE F on K.FUNKCJA = F.FUNKCJA
         JOIN WROGOWIE_KOCUROW WK on K.PSEUDO = WK.PSEUDO
HAVING COUNT(*) > 1
GROUP BY K.FUNKCJA, K.PSEUDO;

--zad.23

SELECT IMIE, (przydzial_myszy + NVL(myszy_extra, 0)) * 12 "DAWKA ROCZNA", 'powyzej 864' "DAWKA"
FROM KOCURY
WHERE MYSZY_EXTRA IS NOT NULL
  AND (przydzial_myszy + NVL(myszy_extra, 0)) * 12 > 864
UNION
SELECT IMIE, (przydzial_myszy + NVL(myszy_extra, 0)) * 12 "DAWKA ROCZNA", '        864' "DAWKA"
FROM KOCURY
WHERE MYSZY_EXTRA IS NOT NULL
  AND (przydzial_myszy + NVL(myszy_extra, 0)) * 12 = 864
UNION
SELECT IMIE, (przydzial_myszy + NVL(myszy_extra, 0)) * 12 "DAWKA ROCZNA", 'ponizej 864' "DAWKA"
FROM KOCURY
WHERE MYSZY_EXTRA IS NOT NULL
  AND (przydzial_myszy + NVL(myszy_extra, 0)) * 12 < 864
ORDER BY "DAWKA ROCZNA";

--zad.24
SELECT B.NR_BANDY, NAZWA, TEREN
FROM BANDY B
         LEFT JOIN KOCURY K on B.NR_BANDY = K.NR_BANDY
WHERE K.PSEUDO IS NULL;

SELECT B.NR_BANDY, NAZWA, TEREN
FROM BANDY B
         LEFT JOIN KOCURY K on B.NR_BANDY = K.NR_BANDY
MINUS
SELECT B.NR_BANDY, NAZWA, TEREN
FROM BANDY B
         JOIN KOCURY K on B.NR_BANDY = K.NR_BANDY;

--zad.25 Drugie zapytanie zwroci najwieksze bo jest wieksze lub rowne wszystkim innym
SELECT IMIE, FUNKCJA, PRZYDZIAL_MYSZY
FROM KOCURY
WHERE PRZYDZIAL_MYSZY >=
      3 * (SELECT PRZYDZIAL_MYSZY
           FROM KOCURY
                    JOIN BANDY USING (NR_BANDY)
           WHERE FUNKCJA = 'MILUSIA'
             AND TEREN IN ('SAD', 'CALOSC')
             AND PRZYDZIAL_MYSZY >= ALL (
               SELECT PRZYDZIAL_MYSZY
               FROM KOCURY
                        JOIN BANDY USING (NR_BANDY)
               WHERE FUNKCJA = 'MILUSIA'
                 AND TEREN IN ('SAD', 'CALOSC'))
      );

--zad.26
SELECT FUNKCJA, ROUND(AVG(NVL(MYSZY_EXTRA, 0) + PRZYDZIAL_MYSZY)) "Srednio najw. i najm. myszy"
FROM KOCURY
GROUP BY FUNKCJA
HAVING AVG(NVL(MYSZY_EXTRA, 0) + PRZYDZIAL_MYSZY) IN (
                                                      (SELECT MAX(AVG(NVL(MYSZY_EXTRA, 0) + PRZYDZIAL_MYSZY))
                                                       FROM KOCURY
                                                       WHERE FUNKCJA != 'SZEFUNIO'
                                                       GROUP BY FUNKCJA),
                                                      (SELECT MIN(AVG(NVL(MYSZY_EXTRA, 0) + PRZYDZIAL_MYSZY))
                                                       FROM KOCURY
                                                       GROUP BY FUNKCJA)
    );

--zad.27
--a
SELECT PSEUDO, NVL(MYSZY_EXTRA, 0) + PRZYDZIAL_MYSZY Zjada
FROM KOCURY K
WHERE &n > (SELECT COUNT(DISTINCT PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0))
            FROM KOCURY
            WHERE (K.PRZYDZIAL_MYSZY + NVL(K.MYSZY_EXTRA, 0) <
                   PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0)))
ORDER BY Zjada DESC;

--b

SELECT PSEUDO, NVL(MYSZY_EXTRA, 0) + PRZYDZIAL_MYSZY Zjada
FROM KOCURY
WHERE (PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0)) IN
      (SELECT *
       FROM (SELECT DISTINCT (PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0)) przydzial
             FROM KOCURY
             ORDER BY przydzial DESC)
       WHERE ROWNUM <= &n);

--c

SELECT K1.PSEUDO, MAX(K1.PRZYDZIAL_MYSZY + NVL(K1.MYSZY_EXTRA, 0)) "Przydzial myszy"
FROM KOCURY K1,
     KOCURY K2
WHERE (K1.PRZYDZIAL_MYSZY + NVL(K1.MYSZY_EXTRA, 0)) <= (K2.PRZYDZIAL_MYSZY + NVL(K2.MYSZY_EXTRA, 0))
GROUP BY K1.PSEUDO
HAVING COUNT(DISTINCT K2.PRZYDZIAL_MYSZY + NVL(K2.MYSZY_EXTRA, 0)) <= &n
ORDER BY "Przydzial myszy" desc;


--d
SELECT PSEUDO, Zjada
FROM (SELECT PSEUDO,
             NVL(MYSZY_EXTRA, 0) + PRZYDZIAL_MYSZY                                   Zjada,
             DENSE_RANK() over (ORDER BY NVL(MYSZY_EXTRA, 0) + PRZYDZIAL_MYSZY DESC) pozycja
      FROM KOCURY)
WHERE pozycja <= &n;

--Zad.28

SELECT TO_CHAR(EXTRACT(YEAR FROM W_STADKU_OD)) "ROK", COUNT(*) "LICZBA WSTAPIEN"
FROM KOCURY
GROUP BY EXTRACT(YEAR FROM W_STADKU_OD)
HAVING COUNT(*) IN (
                    (SELECT *
                     FROM (SELECT DISTINCT COUNT(pseudo)
                           FROM Kocury
                           GROUP BY EXTRACT(YEAR from w_stadku_od)
                           HAVING COUNT(pseudo) > (
                               SELECT ROUND(AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od))), 7)
                               FROM Kocury
                               GROUP BY EXTRACT(YEAR FROM w_stadku_od))
                           ORDER BY COUNT(pseudo))
                     WHERE ROWNUM = 1
                    ),
                    (SELECT *
                     FROM (SELECT DISTINCT COUNT(pseudo)
                           FROM Kocury
                           GROUP BY EXTRACT(YEAR from w_stadku_od)
                           HAVING COUNT(pseudo) < (
                               SELECT ROUND(AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od))), 7)
                               FROM Kocury
                               GROUP BY EXTRACT(YEAR FROM w_stadku_od))
                           ORDER BY COUNT(pseudo) DESC)
                     WHERE ROWNUM = 1
                    ))
UNION
SELECT 'Srednia', ROUND(AVG(COUNT(*)), 7)
FROM Kocury
GROUP BY EXTRACT(YEAR FROM w_stadku_od)
ORDER BY "LICZBA WSTAPIEN";

--Zad.29
--a

SELECT K.IMIE,
       NVL(K.MYSZY_EXTRA, 0) + K.PRZYDZIAL_MYSZY        Zjada,
       K.NR_BANDY,
       AVG(NVL(K2.MYSZY_EXTRA, 0) + K2.PRZYDZIAL_MYSZY) "SREDNIA BANDY"
FROM KOCURY K
         JOIN KOCURY K2 ON K.NR_BANDY = K2.NR_BANDY
WHERE K.PLEC = 'M'
GROUP BY K.IMIE, NVL(K.MYSZY_EXTRA, 0) + K.PRZYDZIAL_MYSZY, K.NR_BANDY
HAVING NVL(K.MYSZY_EXTRA, 0) + K.PRZYDZIAL_MYSZY <= AVG(NVL(K2.MYSZY_EXTRA, 0) + K2.PRZYDZIAL_MYSZY)
ORDER BY "SREDNIA BANDY";

--b

SELECT IMIE, NVL(MYSZY_EXTRA, 0) + PRZYDZIAL_MYSZY Zjada, NR_BANDY, SREDNIA "SREDNIA BANDY"
FROM (SELECT NR_BANDY, AVG(NVL(MYSZY_EXTRA, 0) + PRZYDZIAL_MYSZY) SREDNIA FROM KOCURY GROUP BY NR_BANDY)
         JOIN KOCURY USING (NR_BANDY)
WHERE PLEC = 'M'
  AND NVL(MYSZY_EXTRA, 0) + PRZYDZIAL_MYSZY <= SREDNIA
ORDER BY "SREDNIA BANDY";

--c

SELECT IMIE,
       PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0) Zjada,
       NR_BANDY,
       (SELECT AVG(PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0)) --srednia przydzialu z odpowiadajacej kotu bandy
        FROM KOCURY K2
        WHERE K1.NR_BANDY = K2.NR_BANDY)     "srednia bandy"
FROM KOCURY K1
WHERE PLEC = 'M'
  AND PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0) <=
      (SELECT AVG(PRZYDZIAL_MYSZY + NVL(MYSZY_EXTRA, 0)) "srednia bandy" --przydzial<srednia
       FROM KOCURY K2
       WHERE K1.NR_BANDY = K2.NR_BANDY)
ORDER BY "srednia bandy";

--zad.30

SELECT IMIE,
       TO_CHAR(W_STADKU_OD, 'YYYY-MM-DD') || ' <---' "WSTAPIL DO STADKA",
       'NAJSTARSZY STAZEM W BANDZIE ' || NAZWA       " "
FROM KOCURY K1
         JOIN BANDY B on K1.NR_BANDY = B.NR_BANDY
WHERE W_STADKU_OD = (SELECT MIN(W_STADKU_OD)
                     FROM KOCURY K2
                     WHERE K1.NR_BANDY = K2.NR_BANDY
                     GROUP BY K1.NR_BANDY)
UNION
SELECT IMIE,
       TO_CHAR(W_STADKU_OD, 'YYYY-MM-DD') || ' <---' "WSTAPIL DO STADKA",
       'NAJMLODSZY STAZEM W BANDZIE ' || NAZWA       " "
FROM KOCURY K1
         JOIN BANDY B on K1.NR_BANDY = B.NR_BANDY
WHERE W_STADKU_OD = (SELECT MAX(W_STADKU_OD)
                     FROM KOCURY K2
                     WHERE K1.NR_BANDY = K2.NR_BANDY
                     GROUP BY K1.NR_BANDY)
UNION
SELECT IMIE, TO_CHAR(W_STADKU_OD, 'YYYY-MM-DD') || ' <---' "WSTAPIL DO STADKA", ' '
FROM KOCURY K1
         JOIN BANDY B on K1.NR_BANDY = B.NR_BANDY
WHERE W_STADKU_OD NOT IN ((SELECT MAX(W_STADKU_OD)
                           FROM KOCURY K2
                           WHERE K1.NR_BANDY = K2.NR_BANDY
                           GROUP BY K1.NR_BANDY),
                          (SELECT MIN(W_STADKU_OD)
                           FROM KOCURY K2
                           WHERE K1.NR_BANDY = K2.NR_BANDY
                           GROUP BY K1.NR_BANDY)
    );

--zad.31

CREATE OR REPLACE VIEW Bandy_Info (NAZWA_BANDY, SRE_SPOZ, MAX_SPOZ, MIN_SPOZ, KOTY, KOTY_Z_DOD)
AS
SELECT NAZWA "nazwa",
       AVG(PRZYDZIAL_MYSZY),
       MAX(PRZYDZIAL_MYSZY),
       MIN(PRZYDZIAL_MYSZY),
       COUNT(*),
       COUNT(MYSZY_EXTRA)
FROM BANDY
         JOIN KOCURY K on BANDY.NR_BANDY = K.NR_BANDY
GROUP BY NAZWA;

SELECT *
FROM BANDY_INFO;

SELECT PSEUDO,
       IMIE,
       FUNKCJA,
       PRZYDZIAL_MYSZY                         Zjada,
       'OD ' || MIN_SPOZ || ' DO ' || MAX_SPOZ "Granice spozycia",
       W_STADKU_OD                             "LOWI OD"
FROM KOCURY
         JOIN BANDY B on KOCURY.NR_BANDY = B.NR_BANDY
         JOIN BANDY_INFO BI ON BI.NAZWA_BANDY = B.NAZWA
WHERE PSEUDO = &pseudo;

--zad.32

SELECT PSEUDO, PLEC, "Myszy przed podw.", "Extra przed podw"
FROM (SELECT PSEUDO,
             PLEC,
             PRZYDZIAL_MYSZY            "Myszy przed podw.",
             NVL(MYSZY_EXTRA, 0)        "Extra przed podw",
             DENSE_RANK() over (
                 ORDER BY W_STADKU_OD ) pozycja
      FROM KOCURY
               JOIN BANDY B on KOCURY.NR_BANDY = B.NR_BANDY
      WHERE NAZWA = 'CZARNI RYCERZE'
     )
WHERE pozycja <= 3
UNION
SELECT PSEUDO, PLEC, "Myszy przed podw.", "Extra przed podw"
FROM (SELECT PSEUDO,
             PLEC,
             PRZYDZIAL_MYSZY            "Myszy przed podw.",
             NVL(MYSZY_EXTRA, 0)        "Extra przed podw",
             DENSE_RANK() over (
                 ORDER BY W_STADKU_OD ) pozycja
      FROM KOCURY
               JOIN BANDY B on KOCURY.NR_BANDY = B.NR_BANDY
      WHERE NAZWA = 'LACIACI MYSLIWI'
     )
WHERE pozycja <= 3;

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = CASE PLEC
                          WHEN 'D' THEN PRZYDZIAL_MYSZY + 0.1 * (SELECT MIN(PRZYDZIAL_MYSZY) FROM KOCURY)
                          ELSE PRZYDZIAL_MYSZY + 10
    END,
    MYSZY_EXTRA     = NVL(MYSZY_EXTRA, 0) + 0.15 * (SELECT AVG(NVL(MYSZY_EXTRA, 0))
                                                    FROM KOCURY
                                                             JOIN BANDY B2 on KOCURY.NR_BANDY = B2.NR_BANDY)
WHERE PSEUDO IN (SELECT PSEUDO
                 FROM (SELECT PSEUDO,
                              DENSE_RANK() over (
                                  ORDER BY W_STADKU_OD ) pozycja1
                       FROM KOCURY
                                JOIN BANDY B on KOCURY.NR_BANDY = B.NR_BANDY
                       WHERE NAZWA = 'CZARNI RYCERZE'
                      )
                 WHERE pozycja1 <= 3
                 UNION
                 SELECT PSEUDO
                 FROM (SELECT PSEUDO,
                              DENSE_RANK() over (
                                  ORDER BY W_STADKU_OD ) pozycja2
                       FROM KOCURY
                                JOIN BANDY B on KOCURY.NR_BANDY = B.NR_BANDY
                       WHERE NAZWA = 'LACIACI MYSLIWI'
                      )
                 WHERE pozycja2 <= 3
);

ROLLBACK;

--zad.33

--a

SELECT DECODE(plec, 'Kotka', ' ', NAZWA) nazwa,
       plec,
       ile,
       szefunio,
       bandzior,
       lowczy,
       lapacz,
       kot,
       milusia,
       dzielczy,
       suma
FROM (SELECT NAZWA,
             DECODE(PLEC, 'D', 'Kotka', 'Kocur')                                                         plec,
             TO_CHAR(COUNT(pseudo))                                                                      ile,
             TO_CHAR(SUM(DECODE(FUNKCJA, 'SZEFUNIO', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) szefunio,
             TO_CHAR(SUM(DECODE(FUNKCJA, 'BANDZIOR', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) bandzior,
             TO_CHAR(SUM(DECODE(FUNKCJA, 'LOWCZY', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))   lowczy,
             TO_CHAR(SUM(DECODE(FUNKCJA, 'LAPACZ', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))   lapacz,
             TO_CHAR(SUM(DECODE(FUNKCJA, 'KOT', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))      kot,
             TO_CHAR(SUM(DECODE(FUNKCJA, 'MILUSIA', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))  milusia,
             TO_CHAR(SUM(DECODE(FUNKCJA, 'DZIELCZY', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) dzielczy,
             TO_CHAR(SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)))                                 suma
      FROM KOCURY
               NATURAL JOIN BANDY
      GROUP BY NAZWA, PLEC
      UNION
      SELECT 'Z----------------',
             '--------',
             '----------',
             '-----------',
             '-----------',
             '----------',
             '----------',
             '----------',
             '----------',
             '----------',
             '----------'
      FROM dual
      UNION
      SELECT 'ZJADA RAZEM'                                                                               nazwa,
             ' '                                                                                         plec,
             ' '                                                                                         ile,
             TO_CHAR(SUM(DECODE(FUNKCJA, 'SZEFUNIO', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) szefunio,
             TO_CHAR(SUM(DECODE(FUNKCJA, 'BANDZIOR', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) bandzior,
             TO_CHAR(SUM(DECODE(FUNKCJA, 'LOWCZY', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))   lowczy,
             TO_CHAR(SUM(DECODE(FUNKCJA, 'LAPACZ', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))   lapacz,
             TO_CHAR(SUM(DECODE(FUNKCJA, 'KOT', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))      kot,
             TO_CHAR(SUM(DECODE(FUNKCJA, 'MILUSIA', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0)))  milusia,
             TO_CHAR(SUM(DECODE(FUNKCJA, 'DZIELCZY', NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0), 0))) dzielczy,
             TO_CHAR(SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)))                                 suma
      FROM KOCURY
               NATURAL JOIN BANDY
      ORDER BY 1, 2);

--b

SELECT DECODE(plec, 'Kocur', ' ', Nazwa) "NAZWA_BANDY",
       plec,
       ile,
       szefunio,
       bandzior,
       lowczy,
       lapacz,
       kot,
       milusia,
       dzielczy,
       suma
FROM ((
          SELECT Nazwa,
                 decode(Plec, 'M', 'Kocur', 'Kotka') plec,
                 to_char(Ile)                        ile,
                 to_char(NVL(fun1, 0))               szefunio,
                 to_char(NVL(fun2, 0))               bandzior,
                 to_char(NVL(fun3, 0))               lowczy,
                 to_char(NVL(fun4, 0))               lapacz,
                 to_char(NVL(fun5, 0))               kot,
                 to_char(NVL(fun6, 0))               milusia,
                 to_char(NVL(fun7, 0))               dzielczy,
                 to_char(suma)                       suma
          FROM (
              (SELECT nazwa, plec Plec, COUNT(*) Ile
               FROM Kocury
                        NATURAL JOIN Bandy
               GROUP BY nazwa, plec)
                  NATURAL JOIN
                  (SELECT funkcja,
                          nazwa,
                          plec,
                          myszy_extra,
                          przydzial_myszy,
                          (SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0))
                           FROM Kocury K2
                                    NATURAL JOIN Bandy B2
                           WHERE B1.nazwa = B2.nazwa
                             AND K2.plec = K1.plec) "SUMA"
                   FROM Kocury K1
                            NATURAL JOIN Bandy B1)
              )
              PIVOT (SUM(przydzial_myszy + NVL(myszy_extra, 0))
              FOR funkcja IN ('SZEFUNIO' fun1,'BANDZIOR' fun2,'LOWCZY' fun3,'LAPACZ' fun4,'KOT' fun5,'MILUSIA' fun6,'DZIELCZY' fun7))

      UNION
      SELECT 'Z--------------',
              '------',
              '------',
              '-------',
              '-------',
              '-------',
              '-------',
              '-------',
              '-------',
              '-------',
              '-------'
       FROM dual
      UNION
      SELECT Nazwa,
              Plec,
              Ile,
              to_char(NVL(fun1, 0)) szefunio,
              to_char(NVL(fun2, 0)) bandzior,
              to_char(NVL(fun3, 0)) lowczy,
              to_char(NVL(fun4, 0)) lapacz,
              to_char(NVL(fun5, 0)) kot,
              to_char(NVL(fun6, 0)) milusia,
              to_char(NVL(fun7, 0)) dzielczy,
              to_char(suma)
       FROM (SELECT 'Zjada razem '                                                          nazwa,
                     ' '                                                                     plec,
                     ' '                                                                     ile,
                     funkcja,
                     SUM(NVL(przydzial_myszy, 0) + nvl(myszy_extra, 0))                      Suma_funkcji,
                     (SELECT SUM(NVL(przydzial_myszy, 0) + nvl(myszy_extra, 0)) FROM Kocury) "SUMA"
              FROM KOCURY K5
              GROUP BY funkcja
             )
                 PIVOT (MAX(Suma_funkcji) FOR funkcja IN ('SZEFUNIO' fun1,'BANDZIOR' fun2,'LOWCZY' fun3,'LAPACZ' fun4,'KOT' fun5,'MILUSIA' fun6,'DZIELCZY' fun7)))
      ORDER BY 1, 2 DESC);

