-- 1. Из таблиц базы данных, созданной в первой лабораторной работе, извлечь данные в JSON
COPY (Select array_to_json(array_agg(row_to_json(m))) from movies m)  to '/var/lib/postgresql/movies.json';
COPY (Select array_to_json(array_agg(row_to_json(u))) from users u)  to '/var/lib/postgresql/users.json';
COPY (Select array_to_json(array_agg(row_to_json(c))) from cinemas c)  to '/var/lib/postgresql/cinemas.json';
COPY (Select array_to_json(array_agg(row_to_json(v))) from viewings v)  to '/var/lib/postgresql/viewings.json';


-- 2. Выполнить загрузку и сохранение JSON файла в таблицу
--DROP TABLE UsersTMP;
--DROP TABLE JSONTMP;

CREATE TABLE IF NOT EXISTS UsersTMP (
    user_id SERIAL,
    username VARCHAR(50),
    email VARCHAR(100),
    country VARCHAR(50),
    subscription_type VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS JSONTMP
(
    data JSONB
);

COPY JSONTMP(data) from '/var/lib/postgresql/users.json';

SELECT * FROM JSONTMP;

-- Вставка данных из JSON в UsersTMP
INSERT INTO UsersTMP (username, email, country, subscription_type)
SELECT (json_data->>'username')::VARCHAR, 
       (json_data->>'email')::VARCHAR, 
       (json_data->>'country')::VARCHAR, 
       (json_data->>'subscription_type')::VARCHAR
FROM (
    SELECT jsonb_array_elements(data::jsonb) AS json_data
    FROM JSONTMP
) AS json_elements;

SELECT * FROM UsersTMP;


-- 3. добавить атрибут с типом JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT или UPDATE
-- добавим атрибут с типом JSON для списка кинотеатров, в которых у пользователя есть подписка
ALTER TABLE UsersTMP
ADD COLUMN user_data JSONB;

-- заполним атрибут двумя случайными кионтеатрами с их JSON данными
CREATE OR REPLACE FUNCTION RandomCinema()
RETURNS JSONB AS
$$
BEGIN
	RETURN (
    SELECT row_to_json(c) 
	FROM Cinemas c 
	WHERE subscription_type <> 'free' 
	ORDER BY RANDOM() 
	LIMIT 1
	);
END
$$ LANGUAGE plpgsql;

UPDATE UsersTMP
SET user_data = jsonb_build_object(
    'main', RandomCinema(),
    'alternative', RandomCinema()
)
WHERE subscription_type = 'paid';

SELECT *
FROM UsersTMP


-- 4. Выполнить следующие действия:

-- 4. 1. Извлечь XML/JSON фрагмент из XML/JSON документа
SELECT 
    user_id,
    user_data->'main' AS main_cinema,
    user_data->'alternative' AS alternative_cinema
FROM 
    UsersTMP
WHERE 
    subscription_type = 'paid';


-- 4. 2. Извлечь значения конкретных узлов или атрибутов XML/JSON документа
SELECT 
    (user_data->'main'->>'cinema_id')::int AS main_cinema_id,
    user_data->'main'->>'name' AS main_cinema_name,
    user_data->'main'->>'subscription_type' AS main_subscription_type,
    user_data->'main'->>'qty_movies' AS main_qty_movies,
    user_data->'main'->>'qty_users' AS main_qty_users
FROM 
    UsersTMP
WHERE 
    user_id = 9;


-- 4. 4. Изменить XML/JSON документ
UPDATE UsersTMP
SET user_data = jsonb_build_object(
    'main', RandomCinema(),
    'alternative', 'null'::JSONB
)
WHERE user_id = 9;


-- 4. 3. Выполнить проверку (не)существования узла или атрибута
SELECT 
    user_id,
    user_data->'main' AS main_cinema,
    user_data->'alternative' AS alternative_cinema
FROM 
    UsersTMP
WHERE 
    subscription_type = 'paid'
    AND (user_data->'alternative')::jsonb = 'null'::JSONB;


-- 4. 5. Разделить XML/JSON документ на несколько строк по узлам
SELECT jsonb_array_elements(data)
FROM JSONTMP;

-- вложенные JSON
SELECT *
FROM UsersTMP;

COPY (Select array_to_json(array_agg(row_to_json(u))) from UsersTMP u)  to '/var/lib/postgresql/UsersTMP.json';

--DROP TABLE ExtraJSON;
CREATE TABLE IF NOT EXISTS ExtraJSON
(
    data JSONB
);

COPY ExtraJSON(data) from '/var/lib/postgresql/UsersTMP.json';

SELECT jsonb_array_elements(data) FROM ExtraJSON;