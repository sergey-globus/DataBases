-- 1. Инструкция SELECT, использующая предикат сравнения. 
-- Выведем пары (имя, тип подписки) пользователей из России
SELECT DISTINCT username, subscription_type 
FROM Users
WHERE country = 'Russia'
ORDER BY subscription_type, username;

-- 2. Инструкция SELECT, использующая предикат BETWEEN.
-- Получим список фильмов, снятых между 2015 и 2020 годом
SELECT m.title, m.release_year 
FROM movies m
WHERE m.release_year BETWEEN 2015 AND 2020
ORDER BY release_year, title;

-- 3. Инструкция SELECT, использующая предикат LIKE.
-- Получим список фильмов, являющихся третьей частью (то есть '...III')
SELECT m.title 
FROM movies m
WHERE m.title LIKE '%III';

-- 4. Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
-- Получим список пользователей с бесплатной подпиской, смотревших фильмы в хеллоуин
SELECT username
FROM users
WHERE user_id IN (
	SELECT user_id
	FROM viewings
	WHERE view_date = '31-10-2024'
	)
	AND subscription_type = 'free';

-- 20. Простая инструкция DELETE.
-- удалим из просмотров фильм с индексом 52 (Mysterious Journey I)
DELETE FROM viewings
WHERE movie_id = 52;

-- 5. Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
-- найдем фильмы, которые никто еще не успел посмотреть
SELECT title
FROM movies AS m
WHERE NOT EXISTS (
    SELECT 1
    FROM viewings AS v
    WHERE m.movie_id = v.movie_id
    );

-- 6. Инструкция SELECT, использующая предикат сравнения с квантором.
-- получим список дней, где все оценки фильмов были выше 7
SELECT DISTINCT view_date
FROM Viewings AS v1
WHERE 7 < ALL (
    SELECT rating
    FROM Viewings AS v2
    WHERE v2.view_date = v1.view_date
);

-- 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
-- выведем среднюю оценку в странах, где больше 75 пользователей
SELECT country, AVG(v.rating) AS AvgRating
FROM users u JOIN viewings v ON u.user_id = v.user_id 
GROUP BY country
HAVING COUNT(distinct u.user_id) > 75
ORDER BY AvgRating;

-- 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
-- у каждого пользователя выведем количество просмотренных фильмов и среднюю оценку
SELECT username, 
       (SELECT COUNT(*) 
        FROM viewings 
        WHERE user_id = u.user_id) AS movie_count,
       (SELECT AVG(rating)
        FROM viewings
        WHERE user_id = u.user_id)
FROM users u;

-- 9. Инструкция SELECT, использующая простое выражение CASE.
-- выведем пользователей с типами подписки
SELECT username,
	CASE subscription_type
		WHEN 'free' THEN 'free in all cinemas'
		WHEN 'paid' THEN 'at least one paid'
		ELSE 'who are you warrior'
	END AS subscription
FROM users;

-- 10. Инструкция SELECT, использующая поисковое выражение CASE.
-- выведем старые-новые фильмы
SELECT title,
	CASE
		WHEN release_year < 1990 THEN 'very old'
		WHEN release_year < 2012 THEN 'old'
		WHEN release_year < 2024 THEN 'new'
		ELSE 'mega new'
	END AS type
FROM movies;

-- 11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT.
-- создадим временную таблицу с типом подписки пользователя и возможной подпиской в кинотеатре, где он смотрит фильм
CREATE TABLE tmp AS
SELECT v.viewing_id, u.subscription_type AS user_sub,
	c.subscription_type AS cinema_sub
FROM (viewings v JOIN users u ON v.user_id = u.user_id)
	JOIN cinemas c ON v.cinema_id = c.cinema_id;

-- уберем "бесплатных" польpователей из платных кинотеатров
DELETE
FROM viewings
WHERE viewing_id IN (SELECT viewing_id 
				  FROM tmp
				  WHERE user_sub = 'free' AND cinema_sub = 'paid');
-- удалим временную таблицу
DROP TABLE tmp;

-- 12. Инструкция SELECT, использующая вложенные коррелированные
-- подзапросы в качестве производных таблиц в предложении FROM. 
-- выведем топ пользователей по просмотрам и по рейтингу
SELECT 'By view count' AS Criteria, u.username AS Top_User
FROM Users u JOIN  (SELECT user_id, COUNT(*) AS view_count
				    FROM Viewings
				    GROUP BY user_id
				    ORDER BY view_count DESC
				    LIMIT 1
					) AS V ON V.user_id = u.user_id
UNION
SELECT 'By average rating' AS Criteria, u.username AS Top_User
FROM Users u JOIN  (SELECT user_id, AVG(rating) AS avg_rating
				    FROM Viewings
				    GROUP BY user_id
				    ORDER BY avg_rating DESC
				    LIMIT 1
					) AS R ON R.user_id = u.user_id;

-- 13. Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3. 
-- список пользователей, ставивших плохие оценки, в кинотеатрах со средним рейтингом фильмов, выпущенных в этом году, меньше 3
SELECT u.username 
FROM viewings v JOIN users u ON v.user_id = u.user_id
WHERE cinema_id IN (SELECT cinema_id
					FROM (SELECT cinema_id, AVG(rating) AS avg_rating
						  FROM viewings
						  WHERE movie_id IN (SELECT movie_id
						  					 FROM movies
						  					 WHERE release_year = 2024)
						  GROUP BY cinema_id)
					WHERE avg_rating < 3)
	AND v.rating < 3;

-- 14. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING. 	
-- выведем для пользователей кинотеатра 8 тип подписки и количество просмотренных фильмов
SELECT u.username, 
       u.subscription_type, 
       COUNT(*) AS MoviesWatched
FROM users u LEFT JOIN viewings v ON u.user_id = v.user_id
WHERE cinema_id = 8
GROUP BY u.username, u.subscription_type;

-- 15. Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
-- Получим пользователей, средняя оценка которых больше общей средней оценки фильмов
SELECT u.username, AVG(rating) AS average_rating
FROM viewings v JOIN users u ON v.user_id = u.user_id
GROUP BY u.username
HAVING AVG(rating) > (SELECT AVG(rating)
 					  FROM viewings);
	
-- 16. Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.
INSERT INTO movies (title, genre, release_year, duration)
VALUES ('Форсаж 10', 'Adventure', 2023, 141);

-- 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса. 
-- пользователи, давно не смотревшие фильмы, смотрят форсаж
INSERT INTO viewings (user_id, movie_id, cinema_id, view_date, view_time, rating)
SELECT u.user_id, m.movie_id, 1, CURRENT_DATE, CURRENT_TIME, 10
FROM (SELECT user_id
      FROM viewings
      GROUP BY user_id
      HAVING MAX(view_date) < '2023-01-01') AS u
      										JOIN movies m ON m.title = 'Форсаж 10';

-- 18. Простая инструкция UPDATE.
UPDATE viewings
SET rating = 9
WHERE viewing_id IN (SELECT viewing_id
					 FROM viewings v JOIN movies m ON m.title = 'Форсаж 10'
					 WHERE v.movie_id = m.movie_id);
	
-- 19. Инструкция UPDATE со скалярным подзапросом в предложении SET.
-- поставим правдоподобное количество фильмов и пользователей для каждого кинотеатра
UPDATE cinemas c
SET qty_movies = (SELECT COUNT(distinct movie_id)
				 FROM viewings
				 WHERE cinema_id = c.cinema_id),
	qty_users = (SELECT COUNT(distinct user_id)
				 FROM viewings
				 WHERE cinema_id = c.cinema_id);
	
-- 21. Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.
-- удалим из просмотров строки, где пользователи смотрели еще не вышедшие фильмы
DELETE FROM viewings v
WHERE EXTRACT(YEAR FROM view_date) < (SELECT release_year
									  FROM movies
									  WHERE movie_id = v.movie_id);

-- 22. Инструкция SELECT, использующая простое обобщенное табличное выражение 
-- выведем пользователей со средним рейтингом больше общего среднего рейтинга
WITH CTE AS (
    SELECT user_id, AVG(rating) AS avg_rating
    FROM viewings
    GROUP BY user_id
)
SELECT *
FROM CTE
WHERE avg_rating > (SELECT AVG(avg_rating) 
					FROM CTE);

-- 23. Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.
WITH RECURSIVE RecursiveViewings (user_id, viewing_id, movie_id, view_date, view_time, previous_movie_id, level) AS (
    -- Начальный запрос: выбирает первый просмотр фильма (например, самый ранний просмотр каждого пользователя)
    SELECT v.user_id, v.viewing_id, v.movie_id, v.view_date, v.view_time, NULL::integer AS previous_movie_id, 1 AS level
    FROM viewings v
    WHERE NOT EXISTS (
        SELECT 1
        FROM viewings v_prev
        WHERE v_prev.user_id = v.user_id
          AND (v_prev.view_date < v.view_date OR (v_prev.view_date = v.view_date AND v_prev.view_time < v.view_time))
    )
    UNION ALL
    -- Рекурсивная часть: находит следующий просмотр для каждого пользователя
    SELECT v_next.user_id, v_next.viewing_id, v_next.movie_id, v_next.view_date, v_next.view_time,
           rv.movie_id AS previous_movie_id, rv.level + 1 AS level
    FROM viewings v_next  JOIN RecursiveViewings rv ON v_next.user_id = rv.user_id
       AND (v_next.view_date > rv.view_date OR (v_next.view_date = rv.view_date AND v_next.view_time > rv.view_time))
    WHERE NOT EXISTS (
        SELECT 1
        FROM viewings v_in_between
        WHERE v_in_between.user_id = v_next.user_id
          AND (v_in_between.view_date > rv.view_date OR (v_in_between.view_date = rv.view_date AND v_in_between.view_time > rv.view_time))
          AND (v_in_between.view_date < v_next.view_date OR (v_in_between.view_date = v_next.view_date AND v_in_between.view_time < v_next.view_time))
    )
)
-- Финальный запрос для вывода цепочки просмотров для каждого пользователя
SELECT *
FROM RecursiveViewings
ORDER BY user_id, level;

-- 24. Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
-- Для каждого фильма в таблице просмотров выведем среднее значение рейтинга
SELECT 
    v.viewing_id,
    v.user_id,
    v.movie_id,
    v.rating,
    m.title,
    AVG(v.rating) OVER(PARTITION BY v.movie_id) AS AvgRating
FROM viewings v JOIN movies m ON v.movie_id = m.movie_id;

-- 25. Оконные фнкции для устранения дублей
-- временная таблица с дублями
CREATE TABLE tmp AS
SELECT * FROM viewings
UNION ALL
SELECT * FROM viewings;
-- Нумеруем все одинаковые строки с помощью ROW_NUMBER
WITH RankedViewings AS (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY user_id, movie_id, cinema_id, view_date, view_time, rating 
                             ORDER BY viewing_id) AS row_num
    FROM tmp
)
-- Выбираем только уникальные строки и сохраняем их в новую таблицу
SELECT * 
INTO tmp_2
FROM RankedViewings
WHERE row_num = 1;

-- Очистка временной таблицы
DROP TABLE tmp;
DROP TABLE tmp_2;

-- отдельное задание
-- выведем в таблице фильмов 10 самых популярных
SELECT title
FROM movies
WHERE movie_id IN ( SELECT movie_id
				    FROM viewings
				    GROUP BY movie_id
				    ORDER BY COUNT(*) DESC
				    LIMIT 10);

				 

