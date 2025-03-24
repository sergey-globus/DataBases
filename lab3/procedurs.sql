-- процедура, меняющая тип подписки у пользователя на противоположный
CREATE OR REPLACE PROCEDURE SwapSubscriptionType(userid INT)
AS $$
BEGIN
    UPDATE users
    SET subscription_type = CASE
        WHEN subscription_type = 'free' THEN 'paid'
        WHEN subscription_type = 'paid' THEN 'free'
        ELSE subscription_type -- Для других значений подписки (если такие будут), оставляем как есть
    END
    WHERE user_id = userid;
END
$$ LANGUAGE plpgsql;

CALL SwapSubscriptionType(5);
SELECT *
FROM users
WHERE user_id = 5;


-- рекурсивная процедура, меняющая в заданном кинотеатре тип подписки всем пользователям
CREATE OR REPLACE PROCEDURE RecursiveSwap(cinema INT, userid INT DEFAULT NULL)
AS $$
DECLARE
    next_user_id INT;
BEGIN
    -- Инициализируем рекурсию с первого пользователя, если user_id еще не задан
    IF userid IS NULL THEN
        -- Начинаем с первого пользователя в кинотеатре
        SELECT user_id INTO next_user_id
        FROM viewings
        WHERE cinema_id = cinema
        ORDER BY user_id
        LIMIT 1;
        
        -- Рекурсивный вызов для первого пользователя
        CALL RecursiveSwap(cinema, next_user_id);
    ELSE
        -- Изменяем подписку для текущего пользователя
        CALL SwapSubscriptionType(userid);
        
        -- Находим следующего пользователя в том же кинотеатре
        SELECT user_id INTO next_user_id
        FROM viewings
        WHERE cinema_id = cinema
          AND user_id > userid
        ORDER BY user_id
        LIMIT 1;
        
        -- Если найден следующий пользователь, продолжаем рекурсию
        IF next_user_id IS NOT NULL THEN
            CALL RecursiveSwap(cinema, next_user_id);
        END IF;
    END IF;
END
$$ LANGUAGE plpgsql;

CALL RecursiveSwap(1);
SELECT *
FROM users
WHERE user_id IN (SELECT user_id
		          FROM viewings
		          WHERE cinema_id = 1);


-- та же процедура, но с курсором
CREATE OR REPLACE PROCEDURE CursorSwap(cinema INT)
AS $$
DECLARE
    -- Курсор для выборки всех пользователей, которые посетили данный кинотеатр
    user_cursor CURSOR FOR
        SELECT user_id
        FROM viewings
        WHERE cinema_id = cinema;
    
    current_user_id INT;
BEGIN
    OPEN user_cursor;
    
    -- Обрабатываем строки из курсора построчно
    LOOP
        -- Получаем данные из текущей строки
        FETCH user_cursor INTO current_user_id;
        -- Если строк нет, завершаем цикл
        EXIT WHEN NOT FOUND;
        -- Изменяем подписку для текущего пользователя
        CALL SwapSubscriptionType(current_user_id);
    END LOOP;

    CLOSE user_cursor;
END
$$ LANGUAGE plpgsql;

CALL CursorSwap(1);
SELECT *
FROM users
WHERE user_id IN (SELECT user_id
		          FROM viewings
		          WHERE cinema_id = 1);

		         
 -- процедура доступа к метаданным
CREATE OR REPLACE PROCEDURE GetMetadata()
AS $$
DECLARE
    table_cursor CURSOR FOR 
        SELECT table_name
        FROM information_schema.tables t
        WHERE table_schema = 'public'  -- Ограничиваем только таблицами в схеме public
          AND table_type = 'BASE TABLE'  -- Отбираем только базовые таблицы
		  AND (
              SELECT COUNT(*)
              FROM information_schema.columns c
              WHERE c.table_schema = t.table_schema
                AND c.table_name = t.table_name
          ) > 4;  -- Условие на количество столбцов

    table_record RECORD;
    column_record RECORD;
    current_table VARCHAR(255);
BEGIN
    OPEN table_cursor;
    LOOP
        FETCH table_cursor INTO table_record;
        EXIT WHEN NOT FOUND;
        -- Выводим информацию о текущей таблице
        RAISE NOTICE 'Table: %', table_record.table_name;
        
        current_table := table_record.table_name;

        -- Открываем динамический курсор для столбцов текущей таблицы
        FOR column_record IN EXECUTE
            'SELECT column_name, data_type 
             FROM information_schema.columns 
             WHERE table_name = $1' USING current_table
        LOOP
            -- Выводим информацию о столбце
            RAISE NOTICE '  Column: %, Type: %', column_record.column_name, column_record.data_type;
        END LOOP;

    END LOOP;
    CLOSE table_cursor;
END
$$ LANGUAGE plpgsql;

CALL GetMetadata();
