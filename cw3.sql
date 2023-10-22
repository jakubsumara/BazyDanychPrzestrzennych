 CREATE EXTENSION Postgis;
 
 --3
 SELECT * FROM alaska;
 
 --4
SELECT count(popp.f_codedesc) AS "ilość budynków" FROM popp, rivers
WHERE popp.f_codedesc = 'Building' AND ST_DWithin(popp.geom, rivers.geom, 1000) = TRUE;

SELECT popp.f_codedesc, popp.gid  AS "budynek" INTO tableB FROM popp, rivers
WHERE popp.f_codedesc = 'Building' AND ST_DWithin(popp.geom, rivers.geom, 1000) = TRUE;
SELECT * FROM tableB;

--5
CREATE TABLE airportsNew AS SELECT name, geom, elev FROM airports;
SELECT * FROM airportsNew;
--a
SELECT name AS zachód FROM airportsNew 
ORDER BY ST_Y(geom) DESC LIMIT 1;
SELECT name AS wschód FROM airportsNew
ORDER BY ST_Y(geom) ASC LIMIT 1;
--b
INSERT INTO airportsNew VALUES(
	'airportB',
	(SELECT ST_Centroid(
	ST_MakeLine((SELECT geom FROM airportsNew WHERE name = 'NOATAK'), (SELECT geom FROM airportsNew WHERE name = 'NIKOLSKI AS'))
	)), 50
);

SELECT*FROM airportsNew WHERE name = 'airportB';

--6
SELECT ST_Area(ST_Buffer(ST_ShortestLine(airports.geom, lakes.geom), 1000))
FROM lakes, airports
WHERE airports.name='AMBLER' AND lakes.names='Iliamna Lake';

--7
SELECT trees.vegdesc, SUM(ST_Area(trees.geom)) FROM trees, tundra, swamp
WHERE ST_Within(trees.geom,tundra.geom) OR ST_Within(trees.geom,swamp.geom)
GROUP BY trees.vegdesc;