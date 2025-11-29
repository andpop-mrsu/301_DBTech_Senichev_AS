PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = -64000; -- 64MB кэша

BEGIN TRANSACTION;

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
    gender_id INTEGER NOT NULL CHECK (gender_id IN (1, 2)),
    register_date TEXT NOT NULL DEFAULT (datetime('now')),
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
    FOREIGN KEY (movie_id) REFERENCES movies (id) ON DELETE RESTRICT,
    FOREIGN KEY (genre_id) REFERENCES genres (id) ON DELETE CASCADE
);

-- Создание таблицы оценок
CREATE TABLE ratings (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    rating REAL NOT NULL CHECK (rating >= 0 AND rating <= 5),
    timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies (id) ON DELETE RESTRICT
);

-- Создание таблицы тегов
CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    movie_id INTEGER NOT NULL,
    tag TEXT NOT NULL,
    timestamp INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies (id) ON DELETE RESTRICT
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

-- ВСТАВКА ДАННЫХ ИЗ ЛАБОРАТОРНОЙ РАБОТЫ 2
-- Вставка пользователей из старой базы
INSERT INTO users (id, name, email, gender_id, register_date, occupation_id)
SELECT 
    u.id, 
    u.name, 
    u.email, 
    CASE WHEN u.gender = 'male' THEN 1 ELSE 2 END,
    u.register_date,
    (SELECT id FROM occupations WHERE occupation_name = u.occupation)
FROM (
    SELECT 1 as id, 'Devonte Stamm' as name, 'marianne.krajcik@bartoletti.com' as email, 'male' as gender, '2010-09-19' as register_date, 'technician' as occupation
    UNION ALL SELECT 2, 'Merritt Grimes', 'rempel.yvette@kertzmann.com', 'male', '2018-06-12', 'other'
    -- Добавь остальных пользователей из users.txt
) AS u;

-- Вставка фильмов из старой базы
INSERT INTO movies (id, title, year)
SELECT 
    movieId,
    title,
    CASE 
        WHEN title LIKE '%(1995)' THEN 1995
        WHEN title LIKE '%(1996)' THEN 1996
        WHEN title LIKE '%(1997)' THEN 1997
        WHEN title LIKE '%(1998)' THEN 1998
        WHEN title LIKE '%(1999)' THEN 1999
        WHEN title LIKE '%(2000)' THEN 2000
        ELSE NULL
    END as year
FROM (
    SELECT 1 as movieId, 'Toy Story (1995)' as title
    UNION ALL SELECT 2, 'Jumanji (1995)'
    -- Добавь остальные фильмы из movies.csv
) AS m WHERE year IS NOT NULL;

-- Вставка жанров и связей
INSERT INTO genres (genre_name) VALUES 
('Adventure'), ('Animation'), ('Children'), ('Comedy'), ('Fantasy'), ('Romance'), ('Drama'), ('Action'), ('Crime'), ('Thriller'), ('Horror'), ('Mystery'), ('Sci-Fi'), ('Documentary'), ('War'), ('Musical'), ('Western'), ('Film-Noir')
ON CONFLICT(genre_name) DO NOTHING;

-- Вставка оценок из старой базы
INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT 
    UserId,
    MovieId, 
    Rating,
    Timestamp
FROM (
    SELECT 1 as UserId, 1 as MovieId, 4.0 as Rating, 964982703 as Timestamp
    UNION ALL SELECT 1, 3, 4.0, 964981247
    -- Добавь остальные оценки из ratings.csv
) AS r;

-- Вставка тегов из старой базы
INSERT INTO tags (user_id, movie_id, tag, timestamp)
SELECT 
    userid,
    movieid,
    tag,
    timestamp
FROM (
    SELECT 2 as userid, 60756 as movieid, 'funny' as tag, 1445714994 as timestamp
    UNION ALL SELECT 3, 26756, 'Highly quotable', 1445714996
    -- Добавь остальные теги из tags.csv
) AS t;

-- СОЗДАНИЕ ИНДЕКСОВ ДЛЯ УСКОРЕНИЯ ЗАПРОСОВ
CREATE INDEX idx_users_name ON users(name);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_register_date ON users(register_date);
CREATE INDEX idx_movies_title ON movies(title);
CREATE INDEX idx_movies_year ON movies(year);
CREATE INDEX idx_ratings_user_id ON ratings(user_id);
CREATE INDEX idx_ratings_movie_id ON ratings(movie_id);
CREATE INDEX idx_ratings_timestamp ON ratings(timestamp);
CREATE INDEX idx_tags_user_id ON tags(user_id);
CREATE INDEX idx_tags_movie_id ON tags(movie_id);
CREATE INDEX idx_movies_genres_movie_id ON movies_genres(movie_id);
CREATE INDEX idx_movies_genres_genre_id ON movies_genres(genre_id);

COMMIT;

-- Анализ базы для оптимизации запросов
ANALYZE;