-- ДОБАВЛЯЕМ ДАННЫЕ в таблицу analysis.tmp_rfm_monetary_value
insert into analysis.tmp_rfm_monetary_value (user_id, monetary_value)
-- ПОЛУЧАЕМ МЕТРИКУ monetary_value 

with orders as (

	select u.id as user_id, 
	       order_id,
	       COALESCE(order_ts, cast('2021-12-31' as timestamp)) as order_ts, 
	       -- заменяем null на дату, которая меньше 2022г, просто, чтобы клиенты без завершенных заказов попали в 1 сегмент
	       COALESCE(payment, 0) as payment 
	       -- заменяем null на 0, чтобы можно было просуммировать
	from analysis.users as u
	left join (select user_id, order_id, order_ts, payment 
	           from analysis.orders
	           where status = 4) as o on u.id = o.user_id 
),
orders_payment as (

	select user_id, sum(payment) as payment 
	from orders
	group by 1
)

select user_id, NTILE(5) OVER(order by payment) as monetary_value
from orders_payment




