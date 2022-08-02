-- ДОБАВЛЯЕМ ДАННЫЕ в таблицу analysis.tmp_rfm_frequency
insert into analysis.tmp_rfm_frequency (user_id, frequency)
-- ПОЛУЧАЕМ МЕТРИКУ frequency 

with orders_count as ( 
-- получаем кол-во завершенных заказов по каждому клиенту 
	select user_id,  
           count(1) as orders 
    from analysis.orders 
    where status = 4        -- выбираем только завершенные заказы 
    group by user_id 
    UNION                   -- добавляем клиентов у которых нет завершенных заказов 
    select distinct user_id,
           0 as orders 
    from analysis.orders
    where user_id not in (select distinct user_id from analysis.orders o where status = 4)
)
select user_id, NTILE(5) OVER(order by orders) as frequency
from orders_count




