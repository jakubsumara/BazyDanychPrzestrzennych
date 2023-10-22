--3
CREATE EXTENSION postgis;

--2
CREATE DATABASE cw2;
CREATE SCHEMA cw2;

--4
CREATE TABLE budynki (id int primary key not null, geom GEOMETRY, name varchar(15));
CREATE TABLE drogi (id int primary key not null, geom GEOMETRY, name varchar(15));
CREATE TABLE punkty_informacyjne (id int primary key not null, geom GEOMETRY, name varchar(15));

--5
INSERT INTO budynki VALUES (1, ST_GeomFromText('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))'), 'BuildingA');
INSERT INTO budynki VALUES (2, ST_GeomFromText('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7 ))'), 'BuildingB');
INSERT INTO budynki VALUES (3, ST_GeomFromText('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))'), 'BuildingC');
INSERT INTO budynki VALUES (4, ST_GeomFromText('POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))'), 'BuildingD');
INSERT INTO budynki VALUES (5, ST_GeomFromText('POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))'), 'BuildingF');

INSERT INTO drogi VALUES (1, ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)'), 'RoadX');
INSERT INTO drogi VALUES (2, ST_GeomFromText('LINESTRING(7.5 0, 7.5 10.5)'), 'RoadY');

INSERT INTO punkty_informacyjne VALUES (1, ST_GeomFromText('POINT(1 3.5)'), 'G');
INSERT INTO punkty_informacyjne VALUES (2, ST_GeomFromText('POINT(5.5 1.5)'), 'H');
INSERT INTO punkty_informacyjne VALUES (3, ST_GeomFromText('POINT(9.5 6)'), 'I');
INSERT INTO punkty_informacyjne VALUES (4, ST_GeomFromText('POINT(6.5 6)'), 'J');
INSERT INTO punkty_informacyjne VALUES (5, ST_GeomFromText('POINT(6 9.5)'), 'K');

--6
--a
SELECT SUM(ST_Length(geom)) FROM drogi;
--b
SELECT
	ST_AsText(geom) AS "Geometria (WKT)",
	St_Area(geom) AS "Powierzchnia",
	St_Perimeter(geom) AS "Obwód"
FROM budynki WHERE name = 'BuildingA';
--c
SELECT name, ST_Area(geom) AS Powierzchnia FROM budynki ORDER BY budynki.name;
--d
SELECT name, St_Perimeter(geom) As Obwód FROM budynki
ORDER BY ST_Area(geom) desc limit 2;
--e
SELECT ST_Distance(budynek.geom, punkt.geom) AS "Najkrótsza odległość" FROM budynki AS budynek, punkty_informacyjne AS punkt
WHERE budynek.name = 'BuildingC' AND punkt.name = 'G';
--f
SELECT ST_Area(ST_Difference((SELECT budynki.geom FROM budynki
WHERE budynki.name='BuildingC'), 
ST_buffer((SELECT budynki.geom FROM budynki
WHERE budynki.name='BuildingB'),0.5))) AS Powierzchnia;
--g
SELECT budynki.name FROM budynki, drogi
WHERE ST_Y(ST_Centroid(budynki.geom)) > ST_Y(ST_Centroid(drogi.geom)) AND drogi.name='RoadX';
--h
SELECT ST_Area(ST_Symdifference((SELECT budynki.geom FROM budynki
WHERE budynki.name='BuildingC'),ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))',0))) AS Powierzchnia;





