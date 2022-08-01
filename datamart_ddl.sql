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


