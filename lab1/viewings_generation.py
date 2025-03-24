import random
from datetime import datetime, timedelta

num_viewings = 30000
N = 1200
start_date = datetime(2017, 1, 1)
end_date = datetime(2024, 12, 31)

# Функция для генерации случайной даты и времени
def random_date(start, end):
    delta = end - start
    random_days = random.randint(0, delta.days)
    random_time = timedelta(
        hours=random.randint(0, 23),
        minutes=random.randint(0, 59),
        seconds=random.randint(0, 59)
    )
    dt = start + timedelta(days=random_days) + random_time
    return dt.date(), dt.time()


with open(r"C:\Users\podko\Desktop\myPrograms\БД\lab1\viewings.txt", "w") as file:
    user_id = random.randint(1, N)
    movie_id = random.randint(1, N)
    cinema_id = random.randint(1, N)
    view_date, view_time = random_date(start_date, end_date)
    rating = random.randint(1, 10)
    file.write(f"{user_id},{movie_id},{cinema_id},{view_date},{view_time},{rating}")            # без \n
    for _ in range(num_viewings - 1):
        user_id = random.randint(1, N)
        movie_id = random.randint(1, N)
        cinema_id = random.randint(1, N)
        view_date, view_time = random_date(start_date, end_date)
        rating = random.randint(1, 10)
        file.write(f"\n{user_id},{movie_id},{cinema_id},{view_date},{view_time},{rating}")      # c \n
