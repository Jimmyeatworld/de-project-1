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
