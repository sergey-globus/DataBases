-- скалярная функция, считающая среднюю оценку фильму
CREATE OR REPLACE FUNCTION GetAvgRatingForMovie(movie INT)
RETURNS FLOAT AS
$$
BEGIN
	RETURN COALESCE((SELECT AVG(rating) 
	                 FROM viewings
	                 WHERE movie_id = movie), 0);
END
$$ LANGUAGE plpgsql;

SELECT title, GetAvgRatingForMovie(movie_id)
FROM movies;

-- Подставляемая табличная функцая, возвращаюящая для заданного кинотеатра список его пользователей
CREATE OR REPLACE FUNCTION UsersForCinema(cinema INT)
RETURNS TABLE(user_id INT, username VARCHAR, email VARCHAR, country VARCHAR, subscription_type VARCHAR) AS
$$
BEGIN
    RETURN QUERY
    SELECT u.user_id, u.username, u.email, u.country, u.subscription_type
    FROM users u
    WHERE u.user_id IN (
        SELECT v.user_id
        FROM viewings v
        WHERE v.cinema_id = cinema
    );
END
$$ LANGUAGE plpgsql;

SELECT *
FROM UsersForCinema(1);

-- многооператорная табличная функция, возвращающая несколько функций UsersForCinema
CREATE OR REPLACE FUNCTION SomeUsersForCinema()
RETURNS TABLE(user_id INT, username VARCHAR, email VARCHAR, country VARCHAR, subscription_type VARCHAR) AS
$$
BEGIN
	RETURN QUERY
    SELECT *
	FROM UsersForCinema(1);
	RETURN QUERY
    SELECT *
	FROM UsersForCinema(2);
	RETURN QUERY
    SELECT *
	FROM UsersForCinema(3);
END
$$ LANGUAGE plpgsql;

SELECT *
FROM SomeUsersForCinema();

-- функция с рекурсивным ОТВ
CREATE OR REPLACE FUNCTION ViewsRecursive()
RETURNS TABLE (user_id INT, viewing_id INT, movie_id INT, view_date DATE, view_time TIME, previous_movie_id INT, level INT) AS
$$
BEGIN
	RETURN QUERY
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
END;
$$ LANGUAGE plpgsql;

SELECT *
FROM ViewsRecursive();


-- доп функция: на вход user, на выход список кинотеатров (без повтора), в которых он побывал
CREATE OR REPLACE FUNCTION CinemasForUser(uid INT)
RETURNS TABLE(cinema_id INT, name VARCHAR(100), subscription_type VARCHAR(10), qty_movies INT, qty_users INT) AS
$$
BEGIN
    RETURN QUERY
    SELECT *
    FROM cinemas c
    WHERE c.cinema_id IN (SELECT DISTINCT v.cinema_id
				        FROM viewings v
				        WHERE v.user_id = uid);
END
$$ LANGUAGE plpgsql;

SELECT *
FROM CinemasForUser(1);