import random

genres = ["Action", "Adventure", "Comedy", "Drama", "Horror", "Thriller", "Science Fiction",
         "Fantasy", "Romance", "Mystery", "Animation", "Documentary", "Family", "Musical",
         "Western", "Historical", "War", "Sport", "Superhero", "Crime", "Biography", "Dance","Noir",
         "Short", "Reality", "Talk Show", "Game Show", "Educational", "Experimental", "Cult", "Silent"]

adjectives = [
    "Mysterious", "Silent", "Brave", "Lost", "Eternal", "Hidden",
    "Forgotten", "Dark", "Shining", "Haunted", "Epic", "Cursed",
    "Ancient", "Fateful", "Dreamy", "Wild", "Secret", "Broken"
]
nouns = [
    "Journey", "Shadow", "World", "Heart", "Night", "Dream",
    "Secret", "Whisper", "Tale", "Legend", "Hero", "Vengeance",
    "Adventure", "Ghost", "Saga", "Future", "Time", "Promise"
]
part = ['I', 'II', 'III', 'IV', 'V']

movies = set()

# Функция для генерации названий фильмов
def generate_movie_title():
    while True:
        adjective = random.choice(adjectives)
        noun = random.choice(nouns)
        movie = adjective + " " + noun + " " + random.choice(part)
        if movie not in movies:
            movies.add(movie)
            return movie


data = [generate_movie_title() for _ in range(1200)]

with open(r"C:\Users\podko\Desktop\myPrograms\БД\lab1\movies.txt", "w") as file:
    for movie in data:
        year = random.randint(1970, 2024)
        genre = random.choice(genres)
        duration = random.randint(1, 450)
        if movie == data[-1]:
            file.write(f"{movie},{genre},{year},{duration}")
        else:
            file.write(f"{movie},{genre},{year},{duration}\n")
