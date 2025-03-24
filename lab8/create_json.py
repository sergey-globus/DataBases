import json
import time
from datetime import datetime
import os

def generate_json_file(output_dir="./nifi/in_file"):
    """Генерирует JSON-файл с данными о просмотре в указанной директории."""

    # Проверка и создание директории
    os.makedirs(output_dir, exist_ok=True)

    now = datetime.now()
    timestamp_str = now.strftime("%d.%m.%Y_%H:%M:%S")
    datetime_str = now.strftime("%Y-%m-%d")
    time_str = now.strftime("%H:%M:%S.%f")[:-3]

    file_name = os.path.join(output_dir, f"www_viewings_{timestamp_str}.json")

    data = [
        {
            "user_id": 1,
            "movie_id": 2,
            "cinema_id": 3,
            "view_date": datetime_str,
            "view_time": time_str,
            "rating": 5,
        },
        {
            "user_id": 1,
            "movie_id": 2,
            "cinema_id": 3,
            "view_date": datetime_str,
            "view_time": time_str,
            "rating": 4,
        },
        {
            "user_id": 1,
            "movie_id": 2,
            "cinema_id": 3,
            "view_date": datetime_str,
            "view_time": time_str,
            "rating": 3,
        },
    ]

    with open(file_name, "w") as f:
        json.dump(data, f, indent=2)

    print(f"Файл {file_name} создан.")


def main():
    while True:
        generate_json_file()
        time.sleep(300)  # 5 минут


if __name__ == "__main__":
    main()
