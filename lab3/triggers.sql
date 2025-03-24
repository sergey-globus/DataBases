-- Триггер AFTER
-- Функция, выполняющая проверку и изменение типа подписки пользователя
CREATE OR REPLACE FUNCTION CheckUserSubscription()
RETURNS TRIGGER AS
$$
BEGIN
    -- Проверяем, является ли подписка кинотеатра платной
    IF (SELECT subscription_type FROM Cinemas WHERE cinema_id = NEW.cinema_id) = 'paid' THEN
        -- Если подписка платная, обновляем тип подписки пользователя на 'paid'
        UPDATE Users
        SET subscription_type = 'paid'
        WHERE user_id = NEW.user_id;
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

-- Создание триггера, который срабатывает после вставки в таблицу Viewings
CREATE TRIGGER AfterViewingInsert
AFTER INSERT ON Viewings
FOR EACH ROW
EXECUTE FUNCTION CheckUserSubscription();

-- теперь, если "бесплатный" пользователь смотрит фильм в платном кинотеатре, у него автоматически меняется тип подписки
INSERT INTO viewings (user_id, movie_id, cinema_id, view_date, view_time, rating)
VALUES ((SELECT user_id FROM users WHERE subscription_type = 'free' LIMIT 1), 1201, 2, CURRENT_DATE, CURRENT_TIME, 5)


-- Триггер INSTEAD OF
-- Функция, которая срабатывает вместо обновления в таблице Viewings
CREATE OR REPLACE FUNCTION BlockViewingUpdate()
RETURNS TRIGGER AS 
$$
BEGIN
    -- Выдаем исключение, чтобы заблокировать обновление и показать сообщение
    RAISE EXCEPTION 'Таблица Viewings не предназначена для обновления значений';
END
$$ LANGUAGE plpgsql;

-- создадим представление на основе таблицы viewings
CREATE VIEW tmp_viewings
AS SELECT * FROM viewings;

-- Создаем триггер INSTEAD OF, который срабатывает вместо UPDATE в этом представлении
CREATE TRIGGER InsteadOfViewingUpdate
INSTEAD OF UPDATE ON tmp_viewings
FOR EACH ROW
EXECUTE FUNCTION BlockViewingUpdate();

-- пробуем обновить знаяение в таблице viewing
UPDATE tmp_viewings
SET rating = 7
WHERE user_id = 1;
