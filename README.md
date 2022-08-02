# Проект 1
Опишите здесь поэтапно ход решения задачи. 
Вы можете ориентироваться на тот план выполнения проекта, который мы предлагаем в инструкции на платформе.

-- 1. СОЗДАЁМ ПРЕДСТАВЛЕНИЯ для таблиц из схемы production в схему analysis

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

2. СОЗДАЁМ ПУСТУЮ ТАБЛИЦУ ДЛЯ ВИТРИНЫ,
   т.к. метрики могут принимать значения только от 1 до 5 и не могут быть пустыми,
   то добавляем ограничения CHECK и NOT NULL

*/


CREATE table analysis.dm_rfm_segments (
user_id int primary key,
recency smallint not null check (recency > 0 and recency <= 5),
frequency smallint not null check (recency > 0 and recency <= 5),
monetary_value smallint not null check (recency > 0 and recency <= 5)
);

-- 3. СОЗДАЁМ 3 ПУСТЫЕ ТАБЛИЦЫ ДЛЯ КАЖДОЙ МЕТРИКИ

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

-- 4.1 ДОБАВЛЯЕМ ДАННЫЕ в таблицу analysis.tmp_rfm_recency
insert into analysis.tmp_rfm_recency (user_id, recency)
-- ПОЛУЧАЕМ МЕТРИКУ recency
-- получаем дату и время последнего успешного заказа по каждому клиенту
with last_order as (
	select user_id, max(order_ts) as last_order_time
	       --sum(payment) as closed_payment
	from analysis.orders o 
	where status = 4     -- выбираем только завершенные заказы
	group by user_id
	),
-- нумеруем и сортируем клиентов по времени последнего заказа
user_numbers as (
	select *, 
	       row_number() over(order by last_order_time) as number
	from last_order)
-- разбиваем пользователей на сегменты
select user_id,
       case when number <= round((select count(1) from user_numbers) / 5.0) then 1
            when number between round((select count(1) from user_numbers) / 5.0) + 1 and round((select count(1) from user_numbers) / 5.0) * 2 then 2
            when number between round((select count(1) from user_numbers) / 5.0) * 2 + 1 and round((select count(1) from user_numbers) / 5.0) * 3 then 3
            when number between round((select count(1) from user_numbers) / 5.0) * 3 + 1 and round((select count(1) from user_numbers) / 5.0) * 4 then 4
            when number >= round((select count(1) from user_numbers) / 5.0) * 4 + 1 then 5
            end as recency
from user_numbers;

-- 4.2 ДОБАВЛЯЕМ ДАННЫЕ в таблицу analysis.tmp_rfm_frequency
insert into analysis.tmp_rfm_frequency (user_id, frequency)
-- ПОЛУЧАЕМ МЕТРИКУ frequency
-- получаем кол-во завершенных заказов по каждому клиенту
with closed_orders_count as (
	select user_id, 
	       count(1) as closed_orders
	from analysis.orders o 
	where status = 4        -- выбираем только завершенные заказы
	group by user_id
	),
-- нумеруем и сортируем клиентов по кол-ву заказов
user_numbers as (
	select *, 
	       row_number() over(order by closed_orders) as number
	from closed_orders_count)
-- разбиваем пользователей на сегменты
select user_id,
       case when number <= round((select count(1) from user_numbers) / 5.0) then 1
            when number between round((select count(1) from user_numbers) / 5.0) + 1 and round((select count(1) from user_numbers) / 5.0) * 2 then 2
            when number between round((select count(1) from user_numbers) / 5.0) * 2 + 1 and round((select count(1) from user_numbers) / 5.0) * 3 then 3
            when number between round((select count(1) from user_numbers) / 5.0) * 3 + 1 and round((select count(1) from user_numbers) / 5.0) * 4 then 4
            when number >= round((select count(1) from user_numbers) / 5.0) * 4 + 1 then 5
            end as frequency
from user_numbers
order by number;

-- 4.3 ДОБАВЛЯЕМ ДАННЫЕ в таблицу analysis.tmp_rfm_monetary_value
insert into analysis.tmp_rfm_monetary_value (user_id, monetary_value)
-- ПОЛУЧАЕМ МЕТРИКУ monetary_value
-- получаем суммы завершенных заказов по каждому клиенту
with closed_orders_payment as (
	select user_id, 
	       sum(payment) as closed_payment
	from analysis.orders o 
	where status = 4        -- выбираем только завершенные заказы
	group by user_id
	),
-- нумеруем и сортируем клиентов по сумме заказов
user_numbers as (
	select *, 
	       row_number() over(order by closed_payment) as number
	from closed_orders_payment)
-- разбиваем пользователей на сегменты
select user_id,
       case when number <= round((select count(1) from user_numbers) / 5.0) then 1
            when number between round((select count(1) from user_numbers) / 5.0) + 1 and round((select count(1) from user_numbers) / 5.0) * 2 then 2
            when number between round((select count(1) from user_numbers) / 5.0) * 2 + 1 and round((select count(1) from user_numbers) / 5.0) * 3 then 3
            when number between round((select count(1) from user_numbers) / 5.0) * 3 + 1 and round((select count(1) from user_numbers) / 5.0) * 4 then 4
            when number >= round((select count(1) from user_numbers) / 5.0) * 4 + 1 then 5
            end as monetary_value
from user_numbers;

-- 5. ДОБАВЛЯЕМ ДАННЫЕ В ИТОГОВУЮ ВИТРИНУ
insert into analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
-- Соединяем все таблицы в одну
select *
from analysis.tmp_rfm_recency as t1
left join analysis.tmp_rfm_frequency as t2 using(user_id)
left join analysis.tmp_rfm_monetary_value as t3 using(user_id);

/*
10 записей
(user_id, recency, frequency, monetary_value)
0	1	3	4
1	4	3	3
2	2	3	5
3	2	3	3
4	4	3	3
5	5	5	5
6	1	3	5
7	4	3	2
8	1	1	3
9	1	2	2
 */
 
 -- 6. ПОЧИНИЛ ПРЕДСТАВЛЕНИЕ c заказами в схеме analysis
 CREATE OR REPLACE VIEW analysis.orders AS
SELECT orders.order_id,
    orders.order_ts,
    orders.user_id,
    orders.bonus_payment,
    orders.payment,
    orders.cost,
    orders.bonus_grant,
    t2.status as status
   FROM production.orders
LEFT JOIN (select order_id, max(status_id) as status from production.orderstatuslog group by 1) as t2 using (order_id)











