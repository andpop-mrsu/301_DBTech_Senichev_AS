-- Добавление 5 новых пользователей (себя и 4 соседей по группе)
INSERT INTO users (name, email, gender_id, register_date, occupation_id) VALUES 
('Сеничев Алексей', 'senichev@example.com', 1, date('now'), 19),
('Иванов Иван', 'ivanov@example.com', 1, date('now'), 19),
('Петрова Анна', 'petrova@example.com', 2, date('now'), 19),
('Сидоров Михаил', 'sidorov@example.com', 1, date('now'), 19),
('Козлова Елена', 'kozlova@example.com', 2, date('now'), 19);

-- Добавление 3 новых фильмов разных жанров
INSERT INTO movies (title, year) VALUES 
('Интерстеллар', 2014),
('Начало', 2010),
('Джентльмены', 2019);

-- Добавление жанров для новых фильмов
INSERT INTO genres (genre_name) VALUES 
('Sci-Fi'), ('Adventure'), ('Drama'), ('Action'), ('Thriller'), ('Crime'), ('Comedy')
ON CONFLICT(genre_name) DO NOTHING;

-- Связывание фильмов с жанрами
INSERT INTO movies_genres (movie_id, genre_id) VALUES
((SELECT id FROM movies WHERE title = 'Интерстеллар'), (SELECT id FROM genres WHERE genre_name = 'Sci-Fi')),
((SELECT id FROM movies WHERE title = 'Интерстеллар'), (SELECT id FROM genres WHERE genre_name = 'Adventure')),
((SELECT id FROM movies WHERE title = 'Интерстеллар'), (SELECT id FROM genres WHERE genre_name = 'Drama')),
((SELECT id FROM movies WHERE title = 'Начало'), (SELECT id FROM genres WHERE genre_name = 'Sci-Fi')),
((SELECT id FROM movies WHERE title = 'Начало'), (SELECT id FROM genres WHERE genre_name = 'Action')),
((SELECT id FROM movies WHERE title = 'Начало'), (SELECT id FROM genres WHERE genre_name = 'Thriller')),
((SELECT id FROM movies WHERE title = 'Джентльмены'), (SELECT id FROM genres WHERE genre_name = 'Action')),
((SELECT id FROM movies WHERE title = 'Джентльмены'), (SELECT id FROM genres WHERE genre_name = 'Crime')),
((SELECT id FROM movies WHERE title = 'Джентльмены'), (SELECT id FROM genres WHERE genre_name = 'Comedy'));

-- Добавление 3 отзывов от себя (Сеничев Алексей)
INSERT INTO ratings (user_id, movie_id, rating, timestamp) VALUES
((SELECT id FROM users WHERE name = 'Сеничев Алексей'), (SELECT id FROM movies WHERE title = 'Интерстеллар'), 5.0, strftime('%s','now')),
((SELECT id FROM users WHERE name = 'Сеничев Алексей'), (SELECT id FROM movies WHERE title = 'Начало'), 4.5, strftime('%s','now')),
((SELECT id FROM users WHERE name = 'Сеничев Алексей'), (SELECT id FROM movies WHERE title = 'Джентльмены'), 4.0, strftime('%s','now'));