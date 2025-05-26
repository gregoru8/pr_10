--1. Создать материализованное представление для таблицы customer_sales:
CREATE MATERIALIZED VIEW customer_search AS (
select
	customer_json -> 'customer_id' AS customer_id, customer_json,
	to_tsvector('english', customer_json) AS search_vector
FROM customer_sales
);

--2. Создать индекс GIN в представлении:
CREATE INDEX customer_search_gin_idx ON customer_search USING GIN(search_vector);

--3. Выполнить запрос, используя новую базу данных с возможностью поиска:
SELECT
customer_id,
customer_json
FROM customer_search
WHERE search_vector @@ plainto_tsquery('english', 'Danny Bat');

--4. Вывести уникальный список скутеров и автомобилей (и удаление ограниченных выпусков) с помощью DISTINCT:
SELECT DISTINCT
p1.model,
p2.model
FROM products p1
LEFT JOIN products p2 ON TRUE
WHERE p1.product_type = 'scooter'
AND p2.product_type = 'automobile'
AND p1.model NOT ILIKE '%Limited
Edition%';

--5. Преобразование вывода в запрос:
SELECT DISTINCT
plainto_tsquery('english', p1.model) &&
plainto_tsquery('english', p2.model)
FROM products p1
LEFT JOIN products p2 ON TRUE
WHERE p1.product_type = 'scooter'
AND p2.product_type = 'automobile'
AND p1.model NOT ILIKE '%Limited Edition%';	

--6. Запрос базы данных, используя каждый из объектов tsquery, и подсчитать вхождения для каждого объекта:
SELECT
sub.query,
(
SELECT COUNT(1)
FROM customer_search
WHERE customer_search.search_vector @@ sub.query) FROM (
SELECT DISTINCT
plainto_tsquery('english', p1.model) &&
plainto_tsquery('english', p2.model) AS query
FROM products p1
LEFT JOIN products p2 ON TRUE
WHERE p1.product_type = 'scooter'
AND p2.product_type = 'automobile'
AND p1.model NOT ILIKE '%Limited Edition%'
) sub
ORDER BY 2 DESC;