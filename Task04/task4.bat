@echo off
chcp 65001 > nul

REM Создание базы данных
sqlite3 movies_rating.db < db_init.sql

echo 1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они оценили. В списке оставить первые 100 записей.
echo --------------------------------------------------
sqlite3 movies_rating.db -box "SELECT DISTINCT u1.name as user1, u2.name as user2, m.title as movie_title FROM ratings r1 JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id JOIN users u1 ON r1.user_id = u1.id JOIN users u2 ON r2.user_id = u2.id JOIN movies m ON r1.movie_id = m.id ORDER BY u1.name, u2.name, m.title LIMIT 100;"
echo.

echo 2. Найти 10 самых свежих оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД.
echo --------------------------------------------------
sqlite3 movies_rating.db -box "SELECT DISTINCT m.title, u.name, r.rating, date(r.timestamp, 'unixepoch') as rating_date FROM ratings r JOIN users u ON r.user_id = u.id JOIN movies m ON r.movie_id = m.id ORDER BY r.timestamp DESC LIMIT 10;"
echo.

echo 3. Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке 'Рекомендуем' для фильмов должно быть написано 'Да' или 'Нет'.
echo --------------------------------------------------
sqlite3 movies_rating.db -box "WITH movie_avg_ratings AS ( SELECT m.id, m.title, m.year, AVG(r.rating) as avg_rating FROM movies m JOIN ratings r ON m.id = r.movie_id GROUP BY m.id, m.title, m.year ), min_max_ratings AS ( SELECT MIN(avg_rating) as min_rating, MAX(avg_rating) as max_rating FROM movie_avg_ratings ) SELECT mar.title, mar.year, mar.avg_rating, CASE WHEN mar.avg_rating = (SELECT max_rating FROM min_max_ratings) THEN 'Да' WHEN mar.avg_rating = (SELECT min_rating FROM min_max_ratings) THEN 'Нет' END as Рекомендуем FROM movie_avg_ratings mar WHERE mar.avg_rating = (SELECT min_rating FROM min_max_ratings) OR mar.avg_rating = (SELECT max_rating FROM min_max_ratings) ORDER BY mar.year, mar.title;"
echo.

echo 4. Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-женщины в период с 2010 по 2012 год.
echo --------------------------------------------------
sqlite3 movies_rating.db -box "SELECT COUNT(*) as ratings_count, ROUND(AVG(r.rating), 2) as avg_rating FROM ratings r JOIN users u ON r.user_id = u.id WHERE u.gender = 'female' AND date(r.timestamp, 'unixepoch') BETWEEN '2010-01-01' AND '2012-12-31';"
echo.

echo 5. Составить список фильмов с указанием их средней оценки и места в рейтинге по средней оценке. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей.
echo --------------------------------------------------
sqlite3 movies_rating.db -box "WITH movie_ratings AS ( SELECT m.id, m.title, m.year, AVG(r.rating) as avg_rating, RANK() OVER (ORDER BY AVG(r.rating) DESC) as rating_rank FROM movies m JOIN ratings r ON m.id = r.movie_id GROUP BY m.id, m.title, m.year ) SELECT title, year, ROUND(avg_rating, 2) as avg_rating, rating_rank FROM movie_ratings ORDER BY year, title LIMIT 20;"
echo.

echo 6. Вывести список из 10 последних зарегистрированных пользователей в формате 'Фамилия Имя^|Дата регистрации' (сначала фамилия, потом имя).
echo --------------------------------------------------
sqlite3 movies_rating.db -box "WITH split_names AS ( SELECT id, name, register_date, SUBSTR(name, INSTR(name, ' ') + 1) as last_name, SUBSTR(name, 1, INSTR(name, ' ') - 1) as first_name FROM users ) SELECT last_name || ' ' || first_name || '|' || register_date as user_info FROM split_names ORDER BY register_date DESC LIMIT 10;"
echo.

echo 7. С помощью рекурсивного CTE составить таблицу умножения для чисел от 1 до 10.
echo --------------------------------------------------
sqlite3 movies_rating.db -box "WITH RECURSIVE counter(i) AS ( SELECT 1 UNION ALL SELECT i + 1 FROM counter WHERE i < 10 ) SELECT a.i || 'x' || b.i || '=' || (a.i * b.i) as multiplication FROM counter a, counter b ORDER BY a.i, b.i;"
echo.

echo 8. С помощью рекурсивного CTE выделить все жанры фильмов, имеющиеся в таблице movies (каждый жанр в отдельной строке).
echo --------------------------------------------------
sqlite3 movies_rating.db -box "WITH RECURSIVE split_genres(genre, remaining, movie_id) AS ( SELECT CASE WHEN INSTR(genres, '|') > 0 THEN SUBSTR(genres, 1, INSTR(genres, '|') - 1) ELSE genres END as genre, CASE WHEN INSTR(genres, '|') > 0 THEN SUBSTR(genres, INSTR(genres, '|') + 1) ELSE '' END as remaining, id as movie_id FROM movies UNION ALL SELECT CASE WHEN INSTR(remaining, '|') > 0 THEN SUBSTR(remaining, 1, INSTR(remaining, '|') - 1) ELSE remaining END as genre, CASE WHEN INSTR(remaining, '|') > 0 THEN SUBSTR(remaining, INSTR(remaining, '|') + 1) ELSE '' END as remaining, movie_id FROM split_genres WHERE remaining != '' ) SELECT DISTINCT genre FROM split_genres WHERE genre != '' ORDER BY genre;"
echo.

pause