-- ДОБАВЛЯЕМ ДАННЫЕ в таблицу analysis.tmp_rfm_monetary_value
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
from user_numbers




