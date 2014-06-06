/*
create table cus_pro as (select u.id,u.state, u.name as username, p.name, SUM(o.price*o.quantity) as amount
from user_t u, product p, order_t o
where o.username = u.id 
and   o.product = p.id
group by u.id, p.id
order by amount desc);

create table cus_cat as (select u.id,u.name, p.category, u.state,  SUM(o.price*o.quantity) as amount
from user_t u, product p, order_t o
where o.username = u.id 
and   o.product = p.id
group by u.id, p.category
order by amount desc);
*/


create index cus_pro_uid_idx ON cus_pro (id);
create index cus_pro_state_idx ON cus_pro(state);
create index cus_pro_name_idx ON cus_pro(name);
create index cus_pro_amount_idx ON cus_pro(amount);

create index cus_cat_uid_idx ON cus_cat(id);
create index cus_cat_cid_idx ON cus_cat(category);
create index cus_cat_state_idx ON cus_cat(state);
create index cus_cat_amount_idx ON cus_cat(amount);


