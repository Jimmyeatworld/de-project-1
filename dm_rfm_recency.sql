-- ДОБАВЛЯЕМ ДАННЫЕ в таблицу analysis.tmp_rfm_recency
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
from user_numbers