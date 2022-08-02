-- ДОБАВЛЯЕМ ДАННЫЕ в таблицу analysis.tmp_rfm_recency
insert into analysis.tmp_rfm_recency (user_id, recency)

-- ПОЛУЧАЕМ МЕТРИКУ recency 

with last_order as (
-- получаем время последнего заказа по каждому клиенту
	select user_id, max(order_ts) as last_order_time 
	from analysis.orders 
	where status = 4     -- выбираем только завершенные заказы 
	group by user_id
    UNION                -- добавляем клиентов у которых нет завершенных заказов 
    select distinct user_id,
           (select min(order_ts) from analysis.orders ) as last_order_time -- проставляем им минимальное время
    from analysis.orders 
    where user_id not in (select distinct user_id from orders o where status = 4)
)
select user_id, NTILE(5) OVER(order by last_order_time) as recency
from last_order
