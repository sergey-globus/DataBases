-- Таблица пользователей
CREATE TABLE Users (
    user_id SERIAL,
    username VARCHAR(50),
    email VARCHAR(100),
    country VARCHAR(50),
    subscription_type VARCHAR(10) --  free, если нет платной подписки ни в одном кинотеатре; paid - иначе
);

-- Таблица фильмов
CREATE TABLE Movies (
    movie_id SERIAL,
    title VARCHAR(100),
    genre VARCHAR(20),
    release_year INT,
    duration INT -- в минутах
);

-- Таблица кинотеатров
CREATE TABLE Cinemas (
    cinema_id SERIAL,
    name VARCHAR(100),
    subscription_type VARCHAR(10),
    qty_movies INT,
    qty_users INT
);

-- Таблица просмотров
CREATE TABLE Viewings (
    viewing_id SERIAL,
    user_id INT,
    movie_id INT,
    cinema_id INT,
    view_date DATE,
    view_time TIME,
    rating INT -- Рейтинг от 1 до 10
);