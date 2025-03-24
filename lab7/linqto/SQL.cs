using Microsoft.EntityFrameworkCore;
using Npgsql.EntityFrameworkCore.PostgreSQL;

namespace SQL
{
    class User
    {
        public required int user_id { get; set; }
        public required string username { get; set; }
        public required string email { get; set; }
        public required string country { get; set; }
        public required string subscription_type { get; set; }

        // Навигационное свойство для просмотров
        public ICollection<Viewing> Viewings { get; set; } = new List<Viewing>();
    }

    class Viewing
    {
        public required int viewing_id { get; set; }
        public required int user_id { get; set; }
        public required int movie_id { get; set; }
        public required int cinema_id { get; set; }
        public required DateTime view_date { get; set; }
        public required TimeSpan view_time { get; set; }
        public required int rating { get; set; }

        // Навигационное свойство для пользователя
        public User User { get; set; } = null!;
    }

    class CinemaContext : DbContext
    {
        public DbSet<User> users { get; set; }
        public DbSet<Viewing> viewings { get; set; }

        // Конфигурация подключения к PostgreSQL
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseNpgsql("Host=localhost;Port=5432;Database=online_cinema;Username=postgres;Password=sergej19");
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Конфигурация Users
            modelBuilder.Entity<User>()
                .HasKey(u => u.user_id); // Указываем первичный ключ

            // Конфигурация Viewings
            modelBuilder.Entity<Viewing>()
                .HasKey(v => v.viewing_id); // Указываем первичный ключ

            // Связь Viewing -> User
            modelBuilder.Entity<Viewing>()
                .HasOne(v => v.User) // Указываем связь Viewing -> User
                .WithMany(u => u.Viewings) // Пользователь может быть связан с несколькими просмотрами
                .HasForeignKey(v => v.user_id) // Внешний ключ
                .OnDelete(DeleteBehavior.Cascade); // Указываем поведение при удалении
        }
    }

    class LinqToSql
    {
        public static void singleTableQuery()
        {
            using (var context = new CinemaContext())
            {
                var result = context.users
                                    .Where(u => u.country == "Russia" && u.user_id % 13 == 1)
                                    .ToList();

                Console.WriteLine("\nОднотабличный запрос, получающий пользователей из России, чьи id кратны 13");
                foreach (var user in result)
                {
                    Console.WriteLine($"  {user.user_id}, {user.username}, {user.email}, {user.country}, {user.subscription_type}");
                }
            }
        }

        public static void multyTableQuery()
        {
            using (var context = new CinemaContext())
            {
                var result = (from viewing in context.viewings
                             join user in context.users on viewing.user_id equals user.user_id
                             group viewing by user into userGroup
                             orderby userGroup.Count() descending
                             select new { Name = userGroup.Key.username, cntViewings = userGroup.Count() }).Take(10)
                             .ToList();

                Console.WriteLine("\nМноготабличный запрос, получающий 10 самых активных пользователей");
                foreach (var item in result)
                {
                    Console.WriteLine($"  Имя: {item.Name}, Количество просмотров: {item.cntViewings}");
                }
            }
        }

        public static void addUser()
        {
            using (var context = new CinemaContext())
            {
                var maxUserId = context.users
                                    .OrderByDescending(u => u.user_id)
                                    .Select(u => u.user_id)
                                    .FirstOrDefault();

                var newUserId = maxUserId + 1;

                var newUser = new User
                {
                    user_id = newUserId,
                    username = $"User_{newUserId}",
                    email = $"user{newUserId}@example.com",
                    country = "Russia",
                    subscription_type = "free"
                };

                Console.WriteLine("\nДобавление пользователя в таблицу users...");
                context.users.Add(newUser); // Исправлено Users на users
                context.SaveChanges();
            }
        }


        public static void updateUser()
        {
            using (var context = new CinemaContext())
            {
                Console.WriteLine("\nОбновление подписки первым 10 пользователям...");
                var users = context.users
                                   .Where(u => u.user_id <= 10)
                                   .ToList();

                foreach (var user in users)
                {
                    if (user.subscription_type == "free")
                    {
                        user.subscription_type = "paid";
                    }
                    else
                    {
                        user.subscription_type = "free";
                    }
                    context.SaveChanges();
                }
            }
        }

        public static void deleteViewing()
        {
            using (var context = new CinemaContext())
            {
                var maxViewingId = context.viewings
                                          .OrderByDescending(v => v.viewing_id)
                                          .Select(v => v.viewing_id)
                                          .First();

                var viewingToDelete = context.viewings.First(v => v.viewing_id == maxViewingId);

                Console.WriteLine("\nУдаление последней записи в таблице viewings...");
                context.viewings.Remove(viewingToDelete);
                context.SaveChanges();
            }
        }

        public static void executeStoredProcedure()
        {
            using (var context = new CinemaContext())
            {
                var result = context.Set<User>()
                                    .FromSqlRaw("SELECT * FROM UsersForCinema(2)")
                                    .ToList();

                Console.WriteLine("\nРезультат хранимой процедуры UsersForCinema");
                foreach (var user in result)
                {
                    Console.WriteLine($"  {user.user_id}, {user.username}, {user.email}, {user.country}, {user.subscription_type}");
                }
            }
        }
    }
}
