#!/usr/bin/env python3
import csv
import sqlite3
from datetime import datetime

def create_sql_script():
    """Создает SQL-скрипт для инициализации базы данных"""
    
    sql_content = []
    
    # Удаление существующих таблиц
    sql_content.append("-- Удаление существующих таблиц")
    sql_content.append("DROP TABLE IF EXISTS movies;")
    sql_content.append("DROP TABLE IF EXISTS ratings;")
    sql_content.append("DROP TABLE IF EXISTS tags;")
    sql_content.append("DROP TABLE IF EXISTS users;")
    sql_content.append("")
    
    # Создание таблиц
    sql_content.append("-- Создание таблиц")
    sql_content.append("""
CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    year INTEGER,
    genres TEXT
);
""")
    
    sql_content.append("""
CREATE TABLE ratings (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    rating REAL NOT NULL,
    timestamp INTEGER NOT NULL
);
""")
    
    sql_content.append("""
CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    tag TEXT NOT NULL,
    timestamp INTEGER NOT NULL
);
""")
    
    sql_content.append("""
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    gender TEXT NOT NULL,
    register_date TEXT NOT NULL,
    occupation TEXT NOT NULL
);
""")
    
    sql_content.append("")
    
    # Загрузка данных в таблицу movies
    sql_content.append("-- Загрузка данных в таблицу movies")
    with open('movies.csv', 'r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Пропускаем заголовок
        
        for row in reader:
            if len(row) >= 3:
                movie_id = row[0]
                title = row[1].replace("'", "''")
                genres = row[2].replace("'", "''")
                
                # Извлекаем год из названия
                year = None
                if title.endswith(')'):
                    start = title.rfind('(')
                    if start != -1:
                        year_str = title[start+1:-1]
                        if year_str.isdigit() and len(year_str) == 4:
                            year = int(year_str)
                
                if year:
                    sql_content.append(f"INSERT INTO movies (id, title, year, genres) VALUES ({movie_id}, '{title}', {year}, '{genres}');")
                else:
                    sql_content.append(f"INSERT INTO movies (id, title, year, genres) VALUES ({movie_id}, '{title}', NULL, '{genres}');")
    
    sql_content.append("")
    
    # Загрузка данных в таблицу ratings
    sql_content.append("-- Загрузка данных в таблицу ratings")
    with open('ratings.csv', 'r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Пропускаем заголовок
        
        for idx, row in enumerate(reader, 1):
            if len(row) >= 4:
                user_id = row[0]
                movie_id = row[1]
                rating = row[2]
                timestamp = row[3]
                sql_content.append(f"INSERT INTO ratings (id, user_id, movie_id, rating, timestamp) VALUES ({idx}, {user_id}, {movie_id}, {rating}, {timestamp});")
    
    sql_content.append("")
    
    # Загрузка данных в таблицу tags
    sql_content.append("-- Загрузка данных в таблицу tags")
    with open('tags.csv', 'r', encoding='utf-8') as file:
        reader = csv.reader(file)
        next(reader)  # Пропускаем заголовок
        
        for idx, row in enumerate(reader, 1):
            if len(row) >= 4:
                user_id = row[0]
                movie_id = row[1]
                tag = row[2].replace("'", "''")
                timestamp = row[3]
                sql_content.append(f"INSERT INTO tags (id, user_id, movie_id, tag, timestamp) VALUES ({idx}, {user_id}, {movie_id}, '{tag}', {timestamp});")
    
    sql_content.append("")
    
    # Загрузка данных в таблицу users
    sql_content.append("-- Загрузка данных в таблицу users")
    with open('users.txt', 'r', encoding='utf-8') as file:
        for idx, line in enumerate(file, 1):
            parts = line.strip().split('|')
            if len(parts) >= 6:
                user_id = parts[0]
                name = parts[1].replace("'", "''")
                email = parts[2].replace("'", "''")
                gender = parts[3]
                register_date = parts[4]
                occupation = parts[5].replace("'", "''")
                
                sql_content.append(f"INSERT INTO users (id, name, email, gender, register_date, occupation) VALUES ({user_id}, '{name}', '{email}', '{gender}', '{register_date}', '{occupation}');")
    
    # Записываем SQL-скрипт в файл
    with open('db_init.sql', 'w', encoding='utf-8') as sql_file:
        sql_file.write('\n'.join(sql_content))
    
    print("SQL-скрипт db_init.sql успешно создан!")

if __name__ == "__main__":
    create_sql_script()