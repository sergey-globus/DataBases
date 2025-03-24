import psycopg2


def execute_query(query, params=None):
    try:
        conn = psycopg2.connect(
            dbname="online_cinema",
            user="postgres",
            password="sergej19",
            host="localhost",
            port="5432"
        )
        cursor = conn.cursor()
        cursor.execute(query, params)
        if conn.notices:
            for notice in conn.notices:
                print(notice.strip())
        if cursor.description:
            results = cursor.fetchall()
            for row in results:
                print(row)
        else:
            conn.commit()
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Error: {e}")


def main():
    while True:
        print("""
        1. Скалярный запрос (количество просмотренных фильмов у каждого пользователя)
        2. Запрос с JOIN (средняя оценка в странах, где больше 75 пользователей)
        3. Запрос с CTE и оконными функциями (Для каждого фильма в таблице просмотров среднее значение рейтинга)
        4. Запрос к метаданным (таблицы в бд и их столбцы)
        5. Вызов скалярной функции (считающей среднюю оценку фильму)
        6. Вызов табличной функции (возвращаюящей кинотеатра список его пользователей)
        7. Вызов хранимой процедуры (выводящей процентаж просмотров по дням недели)
        8. Вызов системной функции (с текущей версией postgres)
        9. Создание таблицы (Reviews)
        10. Вставка данных
        11. Удаление таблицы (Reviews)
        0. Выход
        """)
        choice = input("Выберите действие: ")
        if choice == "1":
            execute_query("""
                 SELECT username, 
                       (SELECT COUNT(*) 
                        FROM viewings 
                        WHERE user_id = u.user_id) AS movie_count
                 FROM users u""")
        elif choice == "2":
            execute_query("""
                SELECT country, AVG(v.rating) AS AvgRating
                FROM users u JOIN viewings v ON u.user_id = v.user_id 
                GROUP BY country
                HAVING COUNT(distinct u.user_id) > 75
                ORDER BY AvgRating
            """)
        elif choice == "3":
            execute_query("""
                SELECT 
                    v.viewing_id,
                    v.user_id,
                    v.movie_id,
                    v.rating,
                    m.title,
                    AVG(v.rating) OVER(PARTITION BY v.movie_id) AS AvgRating
                FROM viewings v JOIN movies m ON v.movie_id = m.movie_id
            """)
        elif choice == "4":
            execute_query("CALL GetMetadata();")
        elif choice == "5":
            movie_id = int(input("Введите ID фильма: "))
            execute_query("SELECT GetAvgRatingForMovie(%s);", (movie_id,))
        elif choice == "6":
            cinema_id = int(input("Введите ID кинотеатра: "))
            execute_query("SELECT * FROM UsersForCinema(%s);", (cinema_id,))
        elif choice == "7":
            execute_query("CALL WeeklyViewingsPercentage();")
        elif choice == "8":
            execute_query("SELECT version();")
        elif choice == "9":
            execute_query("""
                CREATE TABLE IF NOT EXISTS Reviews (
                    review_id SERIAL PRIMARY KEY,
                    user_id INT REFERENCES Users(user_id),
                    movie_id INT REFERENCES Movies(movie_id),
                    review_text TEXT,
                    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );
            """)
        elif choice == "10":
            user_id = input("Введите ID пользователя: ")
            movie_id = input("Введите ID фильма: ")
            review_text = input("Введите текст отзыва: ")
            execute_query("""
                INSERT INTO Reviews (user_id, movie_id, review_text) 
                VALUES (%s, %s, %s);
            """, (user_id, movie_id, review_text))
        elif choice == "11":
            execute_query("""
                DROP TABLE Reviews CASCADE;
            """)
        elif choice == "0":
            print("Выход из программы.")
            break
        else:
            print("Неверный выбор. Попробуйте снова.")


if __name__ == "__main__":
    main()
