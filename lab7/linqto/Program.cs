using System;
using System.Collections.Generic;
using Object;
using JSON;
using SQL;

class Program
{
    static void Main()
    {
        while (true)
        {
            Console.WriteLine("\n1. LINQ to Object");
            Console.WriteLine("2. LINQ to JSON");
            Console.WriteLine("3. LINQ to SQL");
            Console.WriteLine("0. Выход");
            Console.Write("Выберите действие: ");

            var choice = Console.ReadLine();
            switch (choice)
            {
                case "1":
                    LinqToObject.Execute();
                    break;
                case "2":
                    Console.WriteLine("  1. Чтение из JSON документа");
                    Console.WriteLine("  2. Обновление JSON документа");
                    Console.WriteLine("  3. Запись (Добавление) в JSON документ");
                    Console.Write("  Выберите действие: ");
                    var subchoice = Console.ReadLine();
                    switch (subchoice)
                    {
                        case "1":
                            LinqToJson.Read();
                            break;
                         case "2":
                             LinqToJson.Update();
                             break;
                         case "3":
                             LinqToJson.Insert();
                             break;
                    }
                    break;
                case "3":
                    LinqToSql.singleTableQuery();
                    LinqToSql.multyTableQuery();
                    LinqToSql.addUser();
                    LinqToSql.updateUser();
                    LinqToSql.deleteViewing();
                    LinqToSql.executeStoredProcedure();
                    break;
                case "0":
                   return;
                default:
                    Console.WriteLine("Неверный выбор, попробуйте еще раз.");
                    break;
            }
        }
    }
}
