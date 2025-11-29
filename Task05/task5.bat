#!/bin/bash
chcp 65001

# Создание базы данных из старой структуры (из lab2)
sqlite3 movies_rating.db < ../Task02/db_init.sql

echo "1. Для каждого фильма выведите его название, год выпуска и средний рейтинг. Дополнительно добавьте столбец rank_by_avg_rating, в котором укажите ранг фильма среди всех фильмов по убыванию среднего рейтинга. В результирующем наборе данных оставить 10 фильмов с наибольшим рангом."
echo --------------------------------------------------
sqlite3 movies_rating.db -box "WITH movie_ratings AS ( SELECT m.id, m.title, m.year, AVG(r.rating) as avg_rating, DENSE_RANK() OVER (ORDER BY AVG(r.rating) DESC) as rank_by_avg_rating FROM movies m JOIN ratings r ON m.id = r.movie_id GROUP BY m.id, m.title, m.year ) SELECT title, year, ROUND(avg_rating, 2) as avg_rating, rank_by_avg_rating FROM movie_ratings ORDER BY rank_by_avg_rating, year DESC LIMIT 10;"
echo " "

echo "2. С помощью рекурсивного CTE выделить все жанры фильмов, имеющиеся в таблице movies. Для каждого жанра рассчитать средний рейтинг avg_rating фильмов в этом жанре. Выведите genre, avg_rating и ранг жанра по убыванию среднего рейтинга, используя оконную функцию RANK()."
echo --------------------------------------------------
sqlite3 movies_rating.db -box "WITH RECURSIVE split_genres(genre, remaining, movie_id) AS ( SELECT CASE WHEN INSTR(genres, '|') > 0 THEN SUBSTR(genres, 1, INSTR(genres, '|') - 1) ELSE genres END as genre, CASE WHEN INSTR(genres, '|') > 0 THEN SUBSTR(genres, INSTR(genres, '|') + 1) ELSE '' END as remaining, id as movie_id FROM movies UNION ALL SELECT CASE WHEN INSTR(remaining, '|') > 0 THEN SUBSTR(remaining, 1, INSTR(remaining, '|') - 1) ELSE remaining END as genre, CASE WHEN INSTR(remaining, '|') > 0 THEN SUBSTR(remaining, INSTR(remaining, '|') + 1) ELSE '' END as remaining, movie_id FROM split_genres WHERE remaining != '' ), genre_stats AS ( SELECT DISTINCT trim(sg.genre) as genre, AVG(r.rating) as avg_rating FROM split_genres sg JOIN ratings r ON sg.movie_id = r.movie_id WHERE sg.genre != '' GROUP BY sg.genre ) SELECT genre, ROUND(avg_rating, 2) as avg_rating, RANK() OVER (ORDER BY avg_rating DESC) as rating_rank FROM genre_stats ORDER BY rating_rank;"
echo " "

echo "3. Посчитайте количество фильмов в каждом жанре. Выведите два столбца: genre и movie_count, отсортировав результат по убыванию количества фильмов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box "WITH RECURSIVE split_genres(genre, remaining, movie_id) AS ( SELECT CASE WHEN INSTR(genres, '|') > 0 THEN SUBSTR(genres, 1, INSTR(genres, '|') - 1) ELSE genres END as genre, CASE WHEN INSTR(genres, '|') > 0 THEN SUBSTR(genres, INSTR(genres, '|') + 1) ELSE '' END as remaining, id as movie_id FROM movies UNION ALL SELECT CASE WHEN INSTR(remaining, '|') > 0 THEN SUBSTR(remaining, 1, INSTR(remaining, '|') - 1) ELSE remaining END as genre, CASE WHEN INSTR(remaining, '|') > 0 THEN SUBSTR(remaining, INSTR(remaining, '|') + 1) ELSE '' END as remaining, movie_id FROM split_genres WHERE remaining != '' ) SELECT trim(genre) as genre, COUNT(DISTINCT movie_id) as movie_count FROM split_genres WHERE genre != '' GROUP BY genre ORDER BY movie_count DESC;"
echo " "

echo "4. Найдите жанры, в которых чаще всего оставляют теги (комментарии). Для этого подсчитайте общее количество записей в таблице tags для фильмов каждого жанра. Выведите genre, tag_count и долю этого жанра в общем числе тегов (tag_share), выраженную в процентах."
echo --------------------------------------------------
sqlite3 movies_rating.db -box "WITH RECURSIVE split_genres(genre, remaining, movie_id) AS ( SELECT CASE WHEN INSTR(genres, '|') > 0 THEN SUBSTR(genres, 1, INSTR(genres, '|') - 1) ELSE genres END as genre, CASE WHEN INSTR(genres, '|') > 0 THEN SUBSTR(genres, INSTR(genres, '|') + 1) ELSE '' END as remaining, id as movie_id FROM movies UNION ALL SELECT CASE WHEN INSTR(remaining, '|') > 0 THEN SUBSTR(remaining, 1, INSTR(remaining, '|') - 1) ELSE remaining END as genre, CASE WHEN INSTR(remaining, '|') > 0 THEN SUBSTR(remaining, INSTR(remaining, '|') + 1) ELSE '' END as remaining, movie_id FROM split_genres WHERE remaining != '' ), genre_tags AS ( SELECT trim(sg.genre) as genre, COUNT(t.id) as tag_count FROM split_genres sg JOIN tags t ON sg.movie_id = t.movie_id WHERE sg.genre != '' GROUP BY sg.genre ) SELECT genre, tag_count, ROUND((tag_count * 100.0 / (SELECT COUNT(*) FROM tags)), 2) as tag_share FROM genre_tags ORDER BY tag_count DESC;"
echo " "

echo "5. Для каждого пользователя рассчитайте: общее количество выставленных оценок, средний выставленный рейтинг, дату первой и последней оценки. Выведите user_id, rating_count, avg_rating, first_rating_date, last_rating_date. Отсортируйте результат по убыванию количества оценок и выведите только 10 первых строк."
echo --------------------------------------------------
sqlite3 movies_rating.db -box "SELECT user_id, COUNT(*) as rating_count, ROUND(AVG(rating), 2) as avg_rating, datetime(MIN(timestamp), 'unixepoch') as first_rating_date, datetime(MAX(timestamp), 'unixepoch') as last_rating_date FROM ratings GROUP BY user_id ORDER BY rating_count DESC LIMIT 10;"
echo " "

echo "6. Сегментируйте пользователей по типу поведения:"
echo "   • «Комментаторы» — пользователи, у которых количество тегов (tags) больше количества оценок (ratings),"
echo "   • «Оценщики» — наоборот, оценок больше, чем тегов,"
echo "   • «Активные» — и оценок, и тегов ≥ 10,"
echo "   • «Пассивные» — и оценок, и тегов < 5."
echo "Выведите user_id, общее число оценок, общее число тегов и категорию поведения."
echo --------------------------------------------------
sqlite3 movies_rating.db -box "WITH user_stats AS ( SELECT u.id as user_id, COUNT(DISTINCT r.id) as rating_count, COUNT(DISTINCT t.id) as tag_count FROM users u LEFT JOIN ratings r ON u.id = r.user_id LEFT JOIN tags t ON u.id = t.user_id GROUP BY u.id ) SELECT user_id, rating_count, tag_count, CASE WHEN rating_count >= 10 AND tag_count >= 10 THEN 'Активные' WHEN rating_count < 5 AND tag_count < 5 THEN 'Пассивные' WHEN tag_count > rating_count THEN 'Комментаторы' WHEN rating_count > tag_count THEN 'Оценщики' ELSE 'Сбалансированные' END as category FROM user_stats ORDER BY user_id;"
echo " "

echo "7. Для каждого пользователя выведите его имя и последний фильм, который он оценил (по времени из ratings.timestamp). Если пользователь не оценивал ни одного фильма, он всё равно должен быть в результате (с NULL в полях фильма)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box "WITH last_ratings AS ( SELECT user_id, movie_id, timestamp, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp DESC) as rn FROM ratings ) SELECT u.id as user_id, u.name, m.title as last_rated_movie_title, datetime(lr.timestamp, 'unixepoch') as last_rating_timestamp FROM users u LEFT JOIN last_ratings lr ON u.id = lr.user_id AND lr.rn = 1 LEFT JOIN movies m ON lr.movie_id = m.id ORDER BY u.id;"
echo " "