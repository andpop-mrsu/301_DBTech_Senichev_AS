-- Удаление существующих таблиц
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS movies_genres;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS occupations;
DROP TABLE IF EXISTS genders;

-- Создание таблицы полов
CREATE TABLE genders (
    id INTEGER PRIMARY KEY,
    gender_name TEXT NOT NULL UNIQUE
);

-- Создание таблицы профессий
CREATE TABLE occupations (
    id INTEGER PRIMARY KEY,
    occupation_name TEXT NOT NULL UNIQUE
);

-- Создание таблицы пользователей
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    gender_id INTEGER NOT NULL,
    register_date TEXT NOT NULL DEFAULT (date('now')),
    occupation_id INTEGER NOT NULL,
    FOREIGN KEY (gender_id) REFERENCES genders (id),
    FOREIGN KEY (occupation_id) REFERENCES occupations (id)
);

-- Создание таблицы фильмов
CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    year INTEGER NOT NULL CHECK (year >= 1800 AND year <= strftime('%Y', 'now'))
);

-- Создание таблицы жанров
CREATE TABLE genres (
    id INTEGER PRIMARY KEY,
    genre_name TEXT NOT NULL UNIQUE
);

-- Создание таблицы связи фильмов и жанров
CREATE TABLE movies_genres (
    movie_id INTEGER NOT NULL,
    genre_id INTEGER NOT NULL,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES movies (id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres (id) ON DELETE CASCADE
);

-- Создание таблицы оценок
CREATE TABLE ratings (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    rating REAL NOT NULL CHECK (rating >= 0 AND rating <= 5),
    timestamp INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies (id) ON DELETE CASCADE
);

-- Создание таблицы тегов
CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    tag TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies (id) ON DELETE CASCADE
);

-- Заполнение справочника полов
INSERT INTO genders (id, gender_name) VALUES 
(1, 'male'),
(2, 'female');

-- Заполнение справочника профессий
INSERT INTO occupations (id, occupation_name) VALUES
(1, 'administrator'),
(2, 'artist'),
(3, 'doctor'),
(4, 'educator'),
(5, 'engineer'),
(6, 'entertainment'),
(7, 'executive'),
(8, 'healthcare'),
(9, 'homemaker'),
(10, 'lawyer'),
(11, 'librarian'),
(12, 'marketing'),
(13, 'none'),
(14, 'other'),
(15, 'programmer'),
(16, 'retired'),
(17, 'salesman'),
(18, 'scientist'),
(19, 'student'),
(20, 'technician'),
(21, 'writer');

-- Создание индексов для ускорения запросов
CREATE INDEX idx_users_name ON users(name);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_movies_title ON movies(title);
CREATE INDEX idx_movies_year ON movies(year);
CREATE INDEX idx_ratings_user_id ON ratings(user_id);
CREATE INDEX idx_ratings_movie_id ON ratings(movie_id);
CREATE INDEX idx_tags_user_id ON tags(user_id);
CREATE INDEX idx_tags_movie_id ON tags(movie_id);