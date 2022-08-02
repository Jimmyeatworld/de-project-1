-- ДОБАВЛЯЕМ ДАННЫЕ в таблицу analysis.tmp_rfm_monetary_value
insert into analysis.tmp_rfm_monetary_value (user_id, monetary_value)
-- ПОЛУЧАЕМ МЕТРИКУ monetary_value 

with orders_payment as ( 
-- получаем суммы завершенных заказов по каждому клиенту 
	select user_id,  
           sum(payment) as payment 
    from analysis.orders 
    where status = 4        -- выбираем только завершенные заказы 
    group by user_id 
    UNION                   -- добавляем клиентов у которых нет завершенных заказов 
    select distinct user_id,
           0 as payment 
    from analysis.orders
    where user_id not in (select distinct user_id from analysis.orders o where status = 4)
)
select user_id, NTILE(5) OVER(order by payment) as monetary_value
from orders_payment



