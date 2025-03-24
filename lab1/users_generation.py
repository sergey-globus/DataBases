import random

# Примеры имен, фамилий, доменов и стран для генерации
first_names = ["john", "jane", "alex", "emily", "mike", "sara", "chris", "kate", "luke", "anna"]
last_names = ["smith", "johnson", "williams", "brown", "jones", "garcia", "martinez", "lee", "walker", "young"]
domains = ["example.com", "mail.ru", "webmail.ru", "internet.com", "email.ru"]
countries = [
    "United States", "Canada", "Mexico", "Brazil", "Argentina", "France", "Germany", "Italy",
    "Spain", "Russia", "China", "Japan", "South Korea", "India", "Australia", "South Africa"
]
subscription_type = ["free", "paid"]

# Множества для проверки уникальности
emails = set()

# Функция генерации уникальных username и email
def generate_unique_email_username():
    while True:
        first_name = random.choice(first_names)
        last_name = random.choice(last_names)
        number = random.randint(1, 999)
        domain = random.choice(domains)

        username = f"{first_name}_{last_name}_{number}"
        email = f"{first_name}.{last_name}{number}@{domain}"

        # Проверка уникальности
        if email not in emails:
            emails.add(email)
            return username, email


# Генерация 1200 уникальных пар username и email
data = [generate_unique_email_username() for _ in range(1200)]

# Сохранение результатов в файл
with open(r"C:\Users\podko\Desktop\myPrograms\БД\lab1\users.txt", "w") as file:
    for username, email in data:
        country = random.choice(countries)
        subscription = random.choice(subscription_type)
        if (username, email) == data[-1]:
            file.write(f"{username},{email},{country},{subscription}")
        else:
            file.write(f"{username},{email},{country},{subscription}\n")
