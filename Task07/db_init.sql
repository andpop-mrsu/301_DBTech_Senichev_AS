-- Включение поддержки внешних ключей
PRAGMA foreign_keys = ON;

-- Таблица категорий автомобилей
CREATE TABLE car_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    description TEXT
);

-- Таблица сотрудников
CREATE TABLE employees (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone TEXT NOT NULL UNIQUE,
    hire_date DATE NOT NULL DEFAULT (date('now')),
    dismissal_date DATE,
    revenue_percent REAL NOT NULL DEFAULT 0.3 CHECK (revenue_percent >= 0 AND revenue_percent <= 1),
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
);

-- Таблица услуг
CREATE TABLE services (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    price REAL NOT NULL CHECK (price >= 0),
    car_category_id INTEGER NOT NULL,
    FOREIGN KEY (car_category_id) REFERENCES car_categories(id) ON DELETE RESTRICT
);

-- Таблица боксов (постов мойки)
CREATE TABLE boxes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    number INTEGER NOT NULL UNIQUE,
    description TEXT,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
);

-- Таблица записей на услуги
CREATE TABLE appointments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    client_name TEXT NOT NULL,
    client_phone TEXT NOT NULL,
    car_model TEXT NOT NULL,
    car_category_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    box_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    status TEXT NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    notes TEXT,
    created_at DATETIME NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (car_category_id) REFERENCES car_categories(id),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (box_id) REFERENCES boxes(id),
    FOREIGN KEY (service_id) REFERENCES services(id),
    CHECK (end_time > start_time)
);

-- Таблица выполненных работ (для учета и расчета зарплаты)
CREATE TABLE completed_services (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_id INTEGER NOT NULL UNIQUE,
    employee_id INTEGER NOT NULL,
    service_id INTEGER NOT NULL,
    box_id INTEGER NOT NULL,
    actual_start DATETIME NOT NULL,
    actual_end DATETIME NOT NULL,
    revenue REAL NOT NULL CHECK (revenue >= 0),
    notes TEXT,
    completed_at DATETIME NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (service_id) REFERENCES services(id),
    FOREIGN KEY (box_id) REFERENCES boxes(id)
);

-- Таблица расчетов зарплаты
CREATE TABLE salary_calculations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    total_revenue REAL NOT NULL CHECK (total_revenue >= 0),
    employee_percent REAL NOT NULL CHECK (employee_percent >= 0 AND employee_percent <= 1),
    salary_amount REAL NOT NULL CHECK (salary_amount >= 0),
    calculated_at DATETIME NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    CHECK (period_end >= period_start)
);

-- Создание индексов для ускорения запросов
CREATE INDEX idx_employees_name ON employees(last_name, first_name);
CREATE INDEX idx_employees_active ON employees(is_active) WHERE is_active = 1;
CREATE INDEX idx_appointments_date ON appointments(start_time);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_employee ON appointments(employee_id, start_time);
CREATE INDEX idx_appointments_box ON appointments(box_id, start_time);
CREATE INDEX idx_completed_services_date ON completed_services(actual_start);
CREATE INDEX idx_completed_services_employee ON completed_services(employee_id, actual_start);
CREATE INDEX idx_services_category ON services(car_category_id);

-- Заполнение тестовыми данными

-- Категории автомобилей
INSERT INTO car_categories (name, description) VALUES
('Легковой', 'Легковые автомобили до 5 мест'),
('Внедорожник', 'Кроссоверы и внедорожники'),
('Минивен', 'Семейные минивэны'),
('Коммерческий', 'Грузовые и коммерческие автомобили');

-- Сотрудники
INSERT INTO employees (first_name, last_name, phone, hire_date, revenue_percent) VALUES
('Иван', 'Петров', '+79161234567', '2023-01-15', 0.3),
('Анна', 'Сидорова', '+79162345678', '2023-02-20', 0.35),
('Сергей', 'Козлов', '+79163456789', '2022-11-10', 0.28),
('Мария', 'Иванова', '+79164567890', '2024-03-05', 0.32),
('Алексей', 'Смирнов', '+79165678901', '2022-08-25', 0.25);

-- Бывший сотрудник (для теста данных об уволенных)
INSERT INTO employees (first_name, last_name, phone, hire_date, dismissal_date, revenue_percent, is_active) VALUES
('Дмитрий', 'Васильев', '+79166789012', '2022-05-10', '2023-12-31', 0.3, 0);

-- Услуги
INSERT INTO services (name, description, duration_minutes, price, car_category_id) VALUES
('Экспресс-мойка', 'Быстрая наружная мойка', 15, 500, 1),
('Полная мойка', 'Мойка кузова и салона', 45, 1500, 1),
('Детейлинг', 'Комплексная чистка и полировка', 120, 5000, 1),
('Мойка внедорожника', 'Полная мойка внедорожника', 60, 2000, 2),
('Химчистка салона', 'Глубокая чистка салона', 90, 3500, 1),
('Полировка кузова', 'Защитная полировка', 180, 8000, 1);

-- Боксы
INSERT INTO boxes (number, description) VALUES
(1, 'Основной бокс, мойка легковых авто'),
(2, 'Бокс для внедорожников'),
(3, 'Детейлинг стоянка'),
(4, 'Экспресс-мойка');

-- Записи на услуги (на ближайшие дни)
INSERT INTO appointments (client_name, client_phone, car_model, car_category_id, employee_id, box_id, service_id, start_time, end_time, status) VALUES
('Александр Новиков', '+79167778899', 'Toyota Camry', 1, 1, 1, 1, '2024-03-20 10:00:00', '2024-03-20 10:15:00', 'completed'),
('Елена Кузнецова', '+79168889900', 'Honda CR-V', 2, 2, 2, 4, '2024-03-20 11:00:00', '2024-03-20 12:00:00', 'completed'),
('Павел Орлов', '+79169990011', 'BMW X5', 2, 3, 2, 4, '2024-03-20 14:00:00', '2024-03-20 15:00:00', 'scheduled'),
('Ольга Семенова', '+79161010112', 'Kia Rio', 1, 4, 1, 2, '2024-03-21 09:00:00', '2024-03-21 09:45:00', 'scheduled'),
('Михаил Попов', '+79162121213', 'Mercedes E-Class', 1, 1, 3, 3, '2024-03-21 11:00:00', '2024-03-21 13:00:00', 'scheduled');

-- Выполненные работы
INSERT INTO completed_services (appointment_id, employee_id, service_id, box_id, actual_start, actual_end, revenue) VALUES
(1, 1, 1, 1, '2024-03-20 10:05:00', '2024-03-20 10:20:00', 500),
(2, 2, 4, 2, '2024-03-20 11:10:00', '2024-03-20 12:05:00', 2000);

-- Расчеты зарплаты
INSERT INTO salary_calculations (employee_id, period_start, period_end, total_revenue, employee_percent, salary_amount) VALUES
(1, '2024-02-01', '2024-02-29', 75000, 0.3, 22500),
(2, '2024-02-01', '2024-02-29', 52000, 0.35, 18200),
(3, '2024-02-01', '2024-02-29', 68000, 0.28, 19040);

-- Создание представлений для отчетов

-- Представление для загруженности боксов
CREATE VIEW box_occupancy AS
SELECT 
    b.number as box_number,
    date(a.start_time) as work_date,
    COUNT(*) as appointments_count,
    SUM(strftime('%s', a.end_time) - strftime('%s', a.start_time))/3600.0 as total_hours
FROM boxes b
LEFT JOIN appointments a ON b.id = a.box_id AND a.status != 'cancelled'
GROUP BY b.id, date(a.start_time);

-- Представление для востребованности услуг
CREATE VIEW service_popularity AS
SELECT 
    s.name as service_name,
    c.name as car_category,
    COUNT(*) as total_appointments,
    SUM(s.price) as total_revenue
FROM services s
JOIN appointments a ON s.id = a.service_id
JOIN car_categories c ON s.car_category_id = c.id
WHERE a.status != 'cancelled'
GROUP BY s.id
ORDER BY total_appointments DESC;

-- Представление для выручки по сотрудникам
CREATE VIEW employee_revenue AS
SELECT 
    e.first_name || ' ' || e.last_name as employee_name,
    COUNT(DISTINCT cs.id) as completed_services,
    SUM(cs.revenue) as total_revenue,
    SUM(cs.revenue * e.revenue_percent) as employee_income
FROM employees e
LEFT JOIN completed_services cs ON e.id = cs.employee_id
WHERE e.is_active = 1
GROUP BY e.id;

-- Представление для свободных временных слотов
CREATE VIEW available_slots AS
SELECT 
    b.number as box_number,
    datetime('now', '+' || (s.duration_minutes * (row_number() over () - 1)) || ' minutes') as suggested_start,
    datetime('now', '+' || (s.duration_minutes * row_number() over ()) || ' minutes') as suggested_end
FROM boxes b
CROSS JOIN services s
WHERE b.is_active = 1
LIMIT 20;