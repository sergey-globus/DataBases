CREATE OR REPLACE EXTENSION plpython3u;


-- 1) Определяемая пользователем скалярная функция CLR,
-- рассчитываем для фильма разницу его рейтигнга с общим рейтингом
CREATE OR REPLACE FUNCTION movieavgrating(movie_id integer)
RETURNS double precision
AS $$
import plpy
# Получаем среднюю оценку конкретного фильма
movie_avg_result = plpy.execute(f"""
    SELECT AVG(rating) AS avg_rating
    FROM Viewings
    WHERE movie_id = {movie_id}
""")

# Проверяем, есть ли результат для конкретного фильма
if not movie_avg_result or movie_avg_result[0]["avg_rating"] is None:
    return None  # Если данных нет, возвращаем NULL

movie_avg_rating = movie_avg_result[0]["avg_rating"]

# Получаем среднюю оценку всех фильмов
all_movies_avg_result = plpy.execute("""
    SELECT AVG(rating) AS avg_rating
    FROM Viewings
""")

all_movies_avg_rating = all_movies_avg_result[0]["avg_rating"]

# Рассчитываем разницу
return movie_avg_rating - all_movies_avg_rating
$$ LANGUAGE plpython3u;

select movieavgrating(1200);


-- 2) Пользовательская агрегатная функцая CLR
-- вспомогательные функции умножения чисел и извлечения корня
CREATE OR REPLACE FUNCTION MulFunc(state FLOAT[], value FLOAT)
RETURNS FLOAT[] AS $$
    state[0] *= value
    state[1] += 1
    return state;
$$ LANGUAGE plpython3u;

CREATE OR REPLACE FUNCTION RootFunc(state FLOAT[])
RETURNS FLOAT AS $$
    return state[0] ** (1.0 / state[1]);
$$ LANGUAGE plpython3u;

-- агрегатная функция, возвращающая среднее геометрическое
CREATE OR REPLACE AGGREGATE GAVG(FLOAT) (
    SFUNC = MulFunc,  		-- функция накопления, которая вызывается для каждой строки и накапливает результат
    STYPE = FLOAT[], 		-- тип для хранения промежуточных результатов
    INITCOND = '{1, 0}', 	-- начальное состояние: {произведение = 1, счетчик = 0}
    FINALFUNC = RootFunc 	-- функция, вызываемая после обработки всех строк
);

SELECT GAVG(rating)
FROM viewings
where viewing_id < 500;


-- 3) Определяемая пользователем табличная функция CLR
-- возвращаем таблицу сгенерированных пользователей
CREATE OR REPLACE FUNCTION GenerateViewings(num INT)
RETURNS TABLE(user_id INT, movie_id INT, cinema_id INT, view_date DATE, view_time TIME, rating INT)
AS $$
    result = []
    import random
    from datetime import datetime, timedelta

    N = 1200
    start_date = datetime(2017, 1, 1)
    end_date = datetime(2024, 12, 31)

    for _ in range(num):
        delta = end_date - start_date
        random_days = random.randint(0, delta.days)
        random_time = timedelta(
            hours=random.randint(0, 23),
            minutes=random.randint(0, 59),
            seconds=random.randint(0, 59)
        )
        dt = start_date + timedelta(days=random_days) + random_time
        result.append((
            random.randint(1, N),
            random.randint(1, N),
            random.randint(1, N),
            dt.date(),
            dt.time(),
            random.randint(1, 10)
        ))

    return result
$$ LANGUAGE plpython3u;

select *
from GenerateViewings(100);


-- 4) Хранимая процедура CLR
-- выводим в notice процентаж просмотров по дням недели
CREATE OR REPLACE PROCEDURE WeeklyViewingsPercentage()
LANGUAGE plpython3u
AS $$
    import datetime

    # Список дней недели и словарь для подсчета просмотров по дням
    days = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    day_counts = {i: 0 for i in range(7)}  # 0: понедельник, 6: воскресенье

    # Выполняем SQL-запрос для выборки всех дат просмотров
    result = plpy.execute("SELECT view_date FROM viewings;")
    total_viewings = len(result)

    # Подсчет просмотров по дням недели
    for row in result:
        # Преобразование строки даты в объект datetime.date
        view_date = datetime.datetime.strptime(row["view_date"], "%Y-%m-%d").date()
        day_of_week = view_date.weekday()  # 0: понедельник, 6: воскресенье
        day_counts[day_of_week] += 1

    # Вывод отчета
    plpy.notice("Процент просмотров по дням недели:")
    for i in range(7):
        percentage = (day_counts[i] / total_viewings) * 100
        plpy.notice(f"{days[i]}: {percentage:.2f}%")
$$;

call WeeklyViewingsPercentage();


-- 5) Триггер CLR
-- вывод информации в notice после добавления в таблицу просмотров
CREATE OR REPLACE FUNCTION public.log_timestamp()
RETURNS trigger
AS $$
    import datetime
    current_date = datetime.datetime.now().date()
    current_time = datetime.datetime.now().time()

    plpy.notice(f"Дата: {current_date}, Время: {current_time}, Операция: добавление записи")
$$ LANGUAGE plpython3u;

CREATE OR REPLACE TRIGGER log_update
AFTER INSERT ON viewings
FOR EACH ROW
EXECUTE FUNCTION log_timestamp();

INSERT INTO viewings (user_id, movie_id, cinema_id, view_date, view_time, rating)
VALUES (1, 1201, 2, CURRENT_DATE, CURRENT_TIME, 5);


-- 6) Определяемый пользователем тип данных CLR
-- тип данных для фильма
CREATE TYPE MOVIE AS (
    title TEXT,
    release_year INT,
    duration INT
);

CREATE OR REPLACE PROCEDURE MovieInfo(cur_movie MOVIE)
AS $$
    plpy.notice(f"Фильм: {cur_movie['title']}, год выхода: {cur_movie['release_year']}, продолжительность: {cur_movie['duration']}")
$$ LANGUAGE plpython3u;


CALL MovieInfo(('title', 1997, 111)::MOVIE);
