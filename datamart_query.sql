-- ДОБАВЛЯЕМ ДАННЫЕ В ИТОГОВУЮ ВИТРИНУ
insert into analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
-- Соединяем все таблицы в одну
select *
from analysis.tmp_rfm_recency as t1
left join analysis.tmp_rfm_frequency as t2 using(user_id)
left join analysis.tmp_rfm_monetary_value as t3 using(user_id)

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


