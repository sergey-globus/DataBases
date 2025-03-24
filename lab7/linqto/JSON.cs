using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace JSON
{
    class Movie
    {
        public required int movie_id { get; set; }
        public required string title { get; set; }
        public required string genre { get; set; }
        public required int release_year { get; set; }
        public required int duration { get; set; }
    }

    class LinqToJson
    {
        private static string JsonFile = "../movies.json";
        public static void Read()
        {
            if (!File.Exists(JsonFile))
            {
                Console.WriteLine("\nJSON файл не найден!");
                return;
            }

            string JsonContent = File.ReadAllText(JsonFile);
            var movies = JsonConvert.DeserializeObject<List<Movie>>(JsonContent);
            Console.WriteLine("\nТаблица фильмов:");
            foreach (var movie in movies)
            {
                Console.WriteLine($"  {movie.movie_id}, {movie.title}, {movie.genre}, {movie.release_year}, {movie.duration}");
            }
        }

        public static void Update()
        {
            if (!File.Exists(JsonFile))
            {
                Console.WriteLine("\nJSON файл не найден!");
                return;
            }

            string JsonContent = File.ReadAllText(JsonFile);
            JArray JsonArray = JArray.Parse(JsonContent);

            Console.Write("  Номер строки для обновления: ");
            if (int.TryParse(Console.ReadLine(), out int index) && index > 0 && index <= JsonArray.Count)
            {
                index -= 1;
                JObject movieObject = (JObject)JsonArray[index];
                Console.Write("  Имя поля (movie_id, title, genre, release_year, duration): ");
                string field = Console.ReadLine();
                if (movieObject.ContainsKey(field))
                {
                    Console.Write("  Новое значение поля: ");
                    string inputStr = Console.ReadLine();
                    if (field == "movie_id" || field == "release_year" || field == "duration")
                    {
                        if (int.TryParse(inputStr, out int meaning))
                        {
                            movieObject[field] = meaning;
                        }
                        else
                        {
                            Console.WriteLine("\nОшибка: введенное значение не соответствует типу");
                        }
                    }
                    else
                    {
                        movieObject[field] = inputStr;
                    }
                    // Сохранение значения
                    File.WriteAllText(JsonFile, JsonArray.ToString());
                }
                else
                {
                    Console.WriteLine("\nОшибка: такого поля не существует");
                }
            }
            else
            {
                Console.WriteLine("\nОшибка: такой строки не существует");
            }
        }

        public static void Insert()
        {
            if (!File.Exists(JsonFile))
            {
                Console.WriteLine("\nJSON файл не найден!");
                return;
            }

            string JsonContent = File.ReadAllText(JsonFile);
            JArray JsonArray = JArray.Parse(JsonContent);

            Console.WriteLine("  Ввод новой строки");
            Console.Write("  movie_id: ");
            if (!int.TryParse(Console.ReadLine(), out int movie_id))
            {
                Console.WriteLine("\nОшибка: введенное значение не соответствует типу");
                return;
            }
            Console.Write("  title: ");
            string title = Console.ReadLine();
            Console.Write("  genre: ");
            string genre = Console.ReadLine();
            Console.Write("  release_year: ");
            if (!int.TryParse(Console.ReadLine(), out int release_year))
            {
                Console.WriteLine("\nОшибка: введенное значение не соответствует типу");
                return;
            }
            Console.Write("  duration: ");
            if (!int.TryParse(Console.ReadLine(), out int duration))
            {
                Console.WriteLine("\nОшибка: введенное значение не соответствует типу");
                return;
            }

            JsonArray.Add(new JObject
            {
                ["movie_id"] = movie_id,
                ["title"] = title,
                ["genre"] = genre,
                ["release_year"] = release_year,
                ["duration"] = duration
            });

            File.WriteAllText(JsonFile, JsonArray.ToString());
        }
    }
}