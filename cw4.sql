create extension postgis;

-- 1) Znajdź budynki, które zostały wybudowane lub wyremontowane 
--	  na przestrzeni roku (zmiana pomiędzy 2018 a 2019).
select t2019.* into zmienione from t2019_kar_buildings t2019 
left join t2018_kar_buildings t2018 on t2018.polygon_id = t2019.polygon_id
where t2018.height != t2019.height 
or ST_Equals(t2018.geom, t2019.geom) = FALSE 
or t2018.polygon_id is NULL;

select * from zmienione

--2. Znajdź ile nowych POI pojawiło się w promieniu 500 m od wyremontowanych lub wybudowanych budynków, 
--które znalezione zostały w zadaniu 1. Policz je wg ich kategorii.
select poi2019.* into newPoi from t2019_kar_poi_table poi2019
where not exists (select* from t2018_kar_poi_table poi2018 where poi2018.poi_id = poi2019.poi_id)

select poi2019.type, count(poi2019.type) from t2019_kar_poi_table poi2019, newPoi nP
where ST_Within(poi2019.geom, ST_Buffer(nP.geom, 500))
group by poi2019.type;

--3. Utwórz nową tabelę o nazwie ‘streets_reprojected’, 
--która zawierać będzie dane z tabeli T2019_KAR_STREETS przetransformowane do układu współrzędnych DHDN.Berlin/Cassin
select * into streets_reprojected from T2019_KAR_STREETS
update streets_reprojected
set geom = ST_Transform(ST_SetSRID(geom, 4326), 3068)
-- mozna by to zrobic samym st_transformem gdyby przy zaczytywaniu danych ustawic srid
select ST_SRID(geom) from streets_reprojected;

--4. Stwórz tabelę o nazwie ‘input_points’ i dodaj do niej dwa rekordy o geometrii punktowej. 
--Użyj następujących współrzędnych:

create table input_points(
point_id INT primary key,
geom GEOMETRY );

insert into input_points values
(1, ST_GeomFromText('POINT(8.36093 49.03174)', 4326)),
(2, ST_GeomFromText('POINT(8.39876 49.00644)', 4326));

select * from input_points;

-- 5. Zaktualizuj dane w tabeli ‘input_points’ tak, aby punkty te były w układzie współrzędnych 
-- DHDN.Berlin/Cassini. Wyświetl współrzędne za pomocą funkcji ST_AsText().
update input_points
set geom = ST_Transform(geom, 3068);
select ST_AsText(geom) from input_points

--6. Znajdź wszystkie skrzyżowania, które znajdują się w odległości 200 m od linii
--zbudowanej z punktów w tabeli ‘input_points’. Wykorzystaj tabelę T2019_STREET_NODE. 
--Dokonaj reprojekcji geometrii, aby była zgodna z resztą tabel.
-- update t2019_kar_street_node
-- set geom = ST_Transform(ST_SetSRID(geom, 4326), 4326);

select * from t2019_kar_street_node
where ST_DWithin(geom,(select ST_Transform((ST_MakeLine(geom)), 4326) from input_points),200,false);

--7.Policz jak wiele sklepów sportowych (‘Sporting Goods Store’ - tabela POIs)
--znajduje się w odległości 300 m od parków (LAND_USE_A).
select count (distinct(poi2019.*)) from t2019_kar_poi_table poi2019, t2019_kar_land_use_a park
where poi2019.type = 'Sporting Goods Store'
and park.type = 'Park (City/County)'
and ST_Contains(ST_Buffer(park.geom, 300), poi2019.geom)


-- 8) Znajdź punkty przecięcia torów kolejowych (RAILWAYS) z ciekami (WATER_LINES).
--	  Zapisz znalezioną geometrię do osobnej tabeli o nazwie ‘T2019_KAR_BRIDGES’.
select ST_Intersection(r.geom, w.geom) into T2019_KAR_BRIDGES
from t2019_kar_railways r, t2019_kar_water_lines w;

select* from T2019_KAR_BRIDGES;