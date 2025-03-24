import psycopg2
import redis
import json
from time import time, sleep
import matplotlib.pyplot as plt
from random import randint
from faker import Faker

N_REPEATS = 10
faker = Faker()

# Подключение к PostgreSQL
def get_postgres_connection():
    return psycopg2.connect(
        dbname="online_cinema",
        user="postgres",
        password="sergej19",
        host="127.0.0.1",
        port="5432"
    )

# Подключение к Redis
def get_redis_connection():
    return redis.StrictRedis(host="127.0.0.1", port=6379, decode_responses=True)

# Выполнение запроса к PostgreSQL
def get_data_postgres(cur):
    cur.execute("""
    SELECT 'By view count' AS Criteria, u.username AS Top_User
    FROM Users u
    JOIN (
        SELECT user_id, COUNT(*) AS view_count
        FROM Viewings
        GROUP BY user_id
        ORDER BY view_count DESC
        LIMIT 10
    ) AS V ON V.user_id = u.user_id
    """)
    return cur.fetchall()

# Выполнение запроса через Redis
def get_data_redis(redis_conn, cur):
    cache_key = "top_users"
    if redis_conn.exists(cache_key):
        return json.loads(redis_conn.get(cache_key))

    # Если данных нет в кэше, загружаем их из PostgreSQL
    data = get_data_postgres(cur)
    redis_conn.set(cache_key, json.dumps(data, default=str), ex=10)  # Кэшируем на 10 секунд
    return data

# Добавление данных в PostgreSQL
def insert_data_postgres(cur, con):
    username = faker.name()
    cur.execute("INSERT INTO Users (username, email, country, subscription_type) VALUES (%s, %s, %s, %s)",
                (username, faker.email(), faker.country(), "free"))
    con.commit()

# Удаление данных из PostgreSQL
def delete_data_postgres(cur, con):
    cur.execute("DELETE FROM Users WHERE user_id IN (SELECT user_id FROM Users LIMIT 1)")
    con.commit()

# Обновление данных в PostgreSQL
def update_data_postgres(cur, con):
    cur.execute("UPDATE Users SET subscription_type = 'paid' WHERE user_id IN (SELECT user_id FROM Users LIMIT 1)")
    con.commit()

# Сравнительный анализ времени выполнения
def analyze_performance():
    con = get_postgres_connection()
    cur = con.cursor()
    redis_conn = get_redis_connection()

    labels = ["Без изменений", "Добавление данных", "Удаление данных", "Обновление данных"]
    times_postgres = []
    times_redis = []

    # Без изменений данных
    t1_postgres = []
    t1_redis = []
    get_data_redis(redis_conn, cur)     # для загрузки в кэш редиса
    for _ in range(N_REPEATS):
        start = time()
        get_data_postgres(cur)
        t1_postgres.append(time() - start)

        start = time()
        get_data_redis(redis_conn, cur)
        t1_redis.append(time() - start)
    times_postgres.append(sum(t1_postgres) / N_REPEATS)
    times_redis.append(sum(t1_redis) / N_REPEATS)

    # Добавление данных
    t2_postgres = []
    t2_redis = []
    sleep(10)
    get_data_redis(redis_conn, cur)  # для загрузки в кэш редиса
    for _ in range(N_REPEATS):
        insert_data_postgres(cur, con)
        start = time()
        get_data_postgres(cur)
        t2_postgres.append(time() - start)

        start = time()
        get_data_redis(redis_conn, cur)
        t2_redis.append(time() - start)
        sleep(5)
    times_postgres.append(sum(t2_postgres) / N_REPEATS)
    times_redis.append(sum(t2_redis) / N_REPEATS)

    # Удаление данных
    t3_postgres = []
    t3_redis = []
    sleep(10)
    get_data_redis(redis_conn, cur)  # для загрузки в кэш редиса
    for _ in range(N_REPEATS):
        delete_data_postgres(cur, con)
        start = time()
        get_data_postgres(cur)
        t3_postgres.append(time() - start)

        start = time()
        get_data_redis(redis_conn, cur)
        t3_redis.append(time() - start)
        sleep(5)
    times_postgres.append(sum(t3_postgres) / N_REPEATS)
    times_redis.append(sum(t3_redis) / N_REPEATS)

    # Обновление данных
    t4_postgres = []
    t4_redis = []
    sleep(10)
    get_data_redis(redis_conn, cur)  # для загрузки в кэш редиса
    for _ in range(N_REPEATS):
        update_data_postgres(cur, con)
        start = time()
        get_data_postgres(cur)
        t4_postgres.append(time() - start)

        start = time()
        get_data_redis(redis_conn, cur)
        t4_redis.append(time() - start)
        sleep(5)
    times_postgres.append(sum(t4_postgres) / N_REPEATS)
    times_redis.append(sum(t4_redis) / N_REPEATS)

    # Построение графиков
    x = range(len(labels))
    plt.figure(figsize=(10, 6))
    plt.plot(x, times_postgres, label="PostgreSQL")
    plt.plot(x, times_redis, label="Redis")
    plt.xticks(x, labels)
    plt.ylabel("Время выполнения (сек)")
    plt.title("Сравнительный анализ времени выполнения запросов")
    plt.legend()
    plt.show()

    cur.close()
    con.close()

# Главный цикл
def main():
    print("Начало анализа производительности")
    analyze_performance()

if __name__ == "__main__":
    main()
