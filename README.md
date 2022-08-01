# Проект 1
Опишите здесь поэтапно ход решения задачи. 
Вы можете ориентироваться на тот план выполнения проекта, который мы предлагаем в инструкции на платформе.

-- 1. Cоздаём представления для таблиц из схемы production в схему analysis

CREATE VIEW analysis.orderitems AS (
    SELECT *
    FROM production.orderitems
);
CREATE VIEW analysis.orders AS (
    SELECT *
    FROM production.orders
);
CREATE VIEW analysis.orderstatuses AS (
    SELECT *
    FROM production.orderstatuses
);
CREATE VIEW analysis.orderstatuslog AS (
    SELECT *
    FROM production.orderstatuslog
);
CREATE VIEW analysis.products AS (
    SELECT *
    FROM production.products
);
CREATE VIEW analysis.users AS (
    SELECT *
    FROM production.users
);

/* 

2. Cоздаём пустую таблицу для витрины,
   т.к. метрики могут принимать значения только от 1 до 5 и не могут быть пустыми,
   то добавляем ограничения CHECK и NOT NULL

*/


CREATE table analysis.dm_rfm_segments (
user_id int primary key,
recency smallint not null check (recency > 0 and recency <= 5),
frequency smallint not null check (recency > 0 and recency <= 5),
monetary_value smallint not null check (recency > 0 and recency <= 5)
);

-- 3. Cоздаём 3 пустые таблицы для каждой метрики

CREATE TABLE analysis.tmp_rfm_recency (
user_id INT NOT NULL PRIMARY KEY,
recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);
CREATE TABLE analysis.tmp_rfm_frequency (
user_id INT NOT NULL PRIMARY KEY,
frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);
CREATE TABLE analysis.tmp_rfm_monetary_value (
user_id INT NOT NULL PRIMARY KEY,
monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);
