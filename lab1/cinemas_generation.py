import random

# Списки для генерации данных
cinema_first_names = [
    "Movie", "Film", "Mega", "Grand", "Groove", "Star", "Prime", "Galaxy",
    "Vista", "Brave", "Silver", "Metro", "Epic", "Nova", "Dream",
    "Royal", "Imperial", "Cine", "Lux", "Cosmos", "Sunset", "Regal", "Crown",
    "Flash", "Starlight", "Majestic", "Odyssey", "Aurora", "XXX"
]
cinema_second_names = [
    "", "Plus", "Time", "House", "World", "Screen", "Nation", "Cinema",
    "Theater", "Cine", "Zone", "Realm", "Spot", "Hub", "Place",
    "Empire", "Sphere", "Galaxy", "Experience", "Arena", "Palace"
]
cinema_third_names = [
    "", "City", "Central", "Plaza", "Park", "Mall", "Village", "Center",
    "District", "Heights", "Square", "Lane", "Terrace", "Boulevard",
    "Avenue", "Hall", "Quarter", "Station", "Tower", "Arcade", "Harbor"
]
cinema_names = set()

subscription_types = ["free", "paid", "mixed"]

# Функция для генерации случайного кинотеатра
def generate_cinema():
    while True:
        name = random.choice(cinema_first_names) + \
            random.choice(cinema_second_names) + " " + random.choice(cinema_third_names)
        if name not in cinema_names:
            cinema_names.add(name)
        return name


# Генерация данных для 1200 записей
cinema_data = [generate_cinema() for _ in range(1200)]

with open(r"C:\Users\podko\Desktop\myPrograms\БД\lab1\cinemas.txt", "w") as file:
    for name in cinema_data:
        subscription = random.choice(subscription_types)
        qty_movies = random.randint(100, 100000)
        qty_users = random.randint(1, 10000)
        if name == cinema_data[-1]:
            file.write(f"{name},{subscription},{qty_movies},{qty_users}")
        else:
            file.write(f"{name},{subscription},{qty_movies},{qty_users}\n")
