-- Ограничения для таблицы Users
ALTER TABLE Users
ADD CONSTRAINT pk_users PRIMARY KEY (user_id),
ADD CONSTRAINT unique_email UNIQUE (email),
ADD CONSTRAINT check_subscription_type_users CHECK (subscription_type IN ('paid', 'free')),
ALTER COLUMN username SET NOT NULL,
ALTER COLUMN email SET NOT NULL;

-- Ограничения для таблицы Movies
ALTER TABLE Movies
ADD CONSTRAINT pk_movies PRIMARY KEY (movie_id),
ADD CONSTRAINT check_release_year CHECK (release_year >= 1888),
ADD CONSTRAINT check_duration CHECK (duration > 0),
ALTER COLUMN title SET NOT NULL;

-- Ограничения для таблицы Cinemas
ALTER TABLE Cinemas
ADD CONSTRAINT pk_cinemas PRIMARY KEY (cinema_id),
ADD CONSTRAINT check_subscription_type_cinemas CHECK (subscription_type IN ('paid', 'free', 'mixed')),
ADD CONSTRAINT check_qty_movies CHECK (qty_movies >= 0),
ADD CONSTRAINT check_qty_users CHECK (qty_users >= 0),
ALTER COLUMN name SET NOT NULL;

-- Ограничения для таблицы Viewings
ALTER TABLE Viewings
ADD CONSTRAINT pk_viewings PRIMARY KEY (viewing_id),
ADD CONSTRAINT check_rating CHECK (rating BETWEEN 1 AND 10),
ADD CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_movie_id FOREIGN KEY (movie_id) REFERENCES Movies(movie_id) ON DELETE CASCADE,
ADD CONSTRAINT fk_cinema_id FOREIGN KEY (cinema_id) REFERENCES Cinemas(cinema_id) ON DELETE CASCADE,
ALTER COLUMN view_date SET NOT NULL,
ALTER COLUMN view_time SET NOT NULL;
