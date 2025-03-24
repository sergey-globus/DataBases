-- Заполнение таблицы Users данными из файла users.txt
COPY Users (username, email, country, subscription_type) FROM '/var/lib/postgresql/data/users.txt'  DELIMITER ',' CSV;

-- Заполнение таблицы Movies данными из файла movies.txt
COPY Movies (title, genre, release_year, duration) FROM '/var/lib/postgresql/data/movies.txt' DELIMITER ',' CSV;

-- Заполнение таблицы Cinemas данными из файла cinemas.txt
COPY Cinemas (name, subscription_type, qty_movies, qty_users) FROM '/var/lib/postgresql/data/cinemas.txt' DELIMITER ',' CSV;

-- Заполнение таблицы viewings данными из файла viewings.txt
COPY Viewings (user_id, movie_id, cinema_id, view_date, view_time, rating) FROM '/var/lib/postgresql/data/viewings.txt' DELIMITER ',' CSV;

