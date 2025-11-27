BEGIN TRANSACTION;

-- Добавление 5 новых пользователей (себя и 4 соседей по группе)
INSERT INTO users (name, email, gender_id, register_date, occupation_id) VALUES 
('Сеничев Алексей', 'senichev.alexey@example.com', 1, datetime('now'), 19),
('Иванов Петр', 'ivanov.petr@example.com', 1, datetime('now'), 19),
('Петрова Мария', 'petrova.maria@example.com', 2, datetime('now'), 19),
('Сидоров Дмитрий', 'sidorov.dmitry@example.com', 1, datetime('now'), 19),
('Козлова Анна', 'kozlova.anna@example.com', 2, datetime('now'), 19);

-- Добавление 3 новых фильмов разных жанров
INSERT INTO movies (title, year) VALUES 
('Довод', 2020),
('Оппенгеймер', 2023),
('Барби', 2023);

-- Получение ID добавленных фильмов для дальнейшего использования
WITH new_movies AS (
    SELECT id, title FROM movies 
    WHERE title IN ('Довод', 'Оппенгеймер', 'Барби')
)
-- Добавление жанров для новых фильмов
INSERT INTO movies_genres (movie_id, genre_id)
SELECT 
    nm.id,
    g.id
FROM new_movies nm
CROSS JOIN genres g
WHERE 
    (nm.title = 'Довод' AND g.genre_name IN ('Sci-Fi', 'Action', 'Thriller')) OR
    (nm.title = 'Оппенгеймер' AND g.genre_name IN ('Drama', 'History', 'Biography')) OR
    (nm.title = 'Барби' AND g.genre_name IN ('Comedy', 'Adventure', 'Fantasy'));

-- Добавление 3 отзывов от себя (Сеничев Алексей)
INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT 
    (SELECT id FROM users WHERE name = 'Сеничев Алексей'),
    m.id,
    CASE 
        WHEN m.title = 'Довод' THEN 4.5
        WHEN m.title = 'Оппенгеймер' THEN 5.0
        WHEN m.title = 'Барби' THEN 4.0
    END,
    strftime('%s', 'now')
FROM movies m
WHERE m.title IN ('Довод', 'Оппенгеймер', 'Барби');

COMMIT;