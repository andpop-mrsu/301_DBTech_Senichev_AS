# Описание файлов данных

Данные представляют собой набор информации о фильмах, пользователях и их оценках.

## Файлы в директории

### `genres.txt`
Содержит список жанров фильмов, каждый на отдельной строке:
- Action
- Adventure
- Animation
- Children's
- Comedy
- Crime
- Documentary
- Drama
- Fantasy
- Film-Noir
- Horror
- Musical
- Mystery
- Romance
- Sci-Fi
- Thriller
- War
- Western

### `movies.csv`
Таблица с информацией о фильмах. Содержит колонки:
- `movieId` - уникальный идентификатор фильма
- `title` - название фильма с годом выпуска в скобках
- `genres` - перечень жанров фильма через разделитель "|"

Пример: "1,Toy Story (1995),Adventure|Animation|Children|Comedy|Fantasy"

### `occupation.txt`
Содержит список профессий пользователей, каждый на отдельной строке:
- administrator
- artist
- doctor
- educator
- engineer
- entertainment
- executive
- healthcare
- homemaker
- lawyer
- librarian
- marketing
- none
- other
- programmer
- retired
- salesman
- scientist
- student
- technician
- writer

### `ratings.csv`
Таблица с оценками фильмов пользователями. Содержит колонки:
- `UserId` - идентификатор пользователя
- `MovieId` - идентификатор фильма
- `Rating` - оценка (от 0.5 до 5.0)
- `Timestamp` - временная метка оценки

### `ratings_count.txt`
Созданный файл с информацией о:
- Минимальном идентификаторе пользователя и количестве его оценок
- Максимальном идентификаторе пользователя и количестве его оценок

### `sqlite.txt`
Созданный файл с информацией о:
- Версии установленной SQLite
- Доступных режимах вывода данных в утилите sqlite3

### `tags.csv`
Таблица с тегами, которые пользователи назначают фильмам. Содержит колонки:
- `userid` - идентификатор пользователя
- `movieid` - идентификатор фильма
- `tag` - текст тега
- `timestamp` - временная метка создания тега

### `users.txt`
Таблица с информацией о пользователях. Формат данных с разделителем "|":
- `UserId` - идентификатор пользователя
- `Name` - полное имя пользователя
- `Email` - email адрес
- `Gender` - пол (male/female)
- `RegistrationDate` - дата регистрации
- `Occupation` - профессия из списка occupation.txt

Пример: "1|Devonte Stamm|marianne.krajcik@bartoletti.com|male|2010-09-19|technician"