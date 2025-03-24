using System;
using System.Collections.Generic;
using System.Linq;

namespace Object
{
    // Класс для представления пользователя
    class User
    {
    private int check_id;  
    public required int id   
    {   
        get => check_id;   
        // Введем ограничение на неотрицательное id
        set  
        {  
            if (value < 0)  
                throw new ArgumentException("ID cannot be less than zero.");  
            check_id = value;  
        }  
    }  
        public required string name { get; set; }
        public required string email { get; set; }
        public required string country { get; set; } 
        public required string subscription_type { get; set; } 
    }

    class LinqToObject
    {
        public static void Execute()
        {
            // Список пользователей  
            List<User> users = new List<User>();  
            var userData = new List<(int id, string name, string email, string country, string subscriptionType)>  
            {  
                (-1, "Alice", "alice@mail.com", "USA", "paid"),  
                (2, "Bob", "bob@mail.com", "Russia", "free"),  
                (3, "Charlie", "charlie@mail.com", "Canada", "paid"),  
                (4, "Diana", "diana@mail.com", "France", "free"),  
                (5, "Eve", "eve@mail.com", "Germany", "paid"),  
                (6, "Frank", "frank@mail.com", "USA", "free"),  
                (7, "Grace", "grace@mail.com", "Russia", "paid"),  
                (8, "Hank", "hank@mail.com", "Canada", "free"),  
                (9, "Ivy", "ivy@mail.com", "France", "paid"),  
                (10, "Jack", "jack@mail.com", "Germany", "free"),  
                (11, "Karen", "karen@mail.com", "USA", "paid"),  
                (12, "Leo", "leo@mail.com", "Russia", "free"),  
                (13, "Mona", "mona@mail.com", "Canada", "paid"),  
                (14, "Nina", "nina@mail.com", "France", "free"),  
                (15, "Oscar", "oscar@mail.com", "Germany", "paid"),  
                (16, "Paul", "paul@mail.com", "USA", "free"),  
                (17, "Quinn", "quinn@mail.com", "Russia", "paid"),  
                (18, "Rachel", "rachel@mail.com", "Canada", "free"),  
                (19, "Steve", "steve@mail.com", "France", "paid"),  
                (20, "Tina", "tina@mail.com", "Germany", "free")  
            };  

            // Adding users and handling ID validation  
            foreach (var (id, name, email, country, subscriptionType) in userData)  
            {  
                try  
                {  
                    User user = new User  
                    {  
                        id = id,  
                        name = name,  
                        email = email,  
                        country = country,  
                        subscription_type = subscriptionType  
                    };  
                    users.Add(user);  
                }  
                catch (ArgumentException ex)  
                {  
                    Console.WriteLine($"Warning: {ex.Message} for user {name}. User not added.");  
                }  
            } 
            

            Console.WriteLine("1) Пользователи, отсортированные по алфавиту, с 6 по 10: ");
            var sortUsers = (from user in users
                            orderby user.name
                            select user).Skip(5).Take(5);

            foreach (var user in sortUsers)
            {
                Console.WriteLine($"  {user.id} {user.name} {user.email} {user.country} {user.subscription_type}");
            }

            Console.WriteLine("\n2) Количество в разных странах пользователей с платной подпиской: ");
            var cntUsersByCountry = from user in users
                                    where user.subscription_type == "paid"
                                    group user by user.country into countryGroup
                                    select new { Country = countryGroup.Key, cntPaidUsers = countryGroup.Count() };

            foreach (var group in cntUsersByCountry)
            {
                Console.WriteLine($"{group.Country}: {group.cntPaidUsers}");
            }

            Console.WriteLine("\n3) Пользователи из одной страны, разбитые по парам: ");
            var pairUsersByCountry = from userFirst in users
                                    join userSecond in users on userFirst.country equals userSecond.country
                                    where userFirst.id < userSecond.id
                                    let Country = userFirst.country
                                    select new { Country, First = userFirst.name, Second = userSecond.name };

            foreach (var pair in pairUsersByCountry)
            {
                Console.WriteLine($"  {pair.Country} {pair.First} {pair.Second}");
            }

            Console.WriteLine("\n4) Проверим, есть ли пользователи в таких странах, как Россия, Италия и Казахстан: ");
            var countries = new List<string> {"Russia", "Italy", "Kazakhstan"}; 
            var availabilityForContries = from Country in countries
                                        let Exist = users.Any(u => u.country == Country)
                                        //let Exist = users.Select(u => u.country).Contains(Country);
                                        select new { Country, Exist };

            foreach (var elem in availabilityForContries)
            {
                Console.WriteLine($"  {elem.Country}: {elem.Exist}");
            }

            Console.WriteLine("\n5) Выведем первую попавшуюся страну с минимальным количеством платных пользователей: ");
            
            var countryWithMinUsers = (from grp in cntUsersByCountry
                                    where grp.cntPaidUsers == cntUsersByCountry.Min(u => u.cntPaidUsers)
                                    select grp.Country).First();

            Console.WriteLine($"{countryWithMinUsers}");
        }
    }
}