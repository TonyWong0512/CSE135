Table 1

sta_cat

State | Category | Sales Amount


create table sta_cat as (select u.state, p.category, SUM(o.price*o.quantity) as amount
from user_t u, product p, order_t o
where o.username = u.id 
and   o.product = p.id
group by u.state, p.category
order by amount desc);

create index ... on ... 



Table 2
cus_cat

Customer | State | Category | Sales Amount

create table cus_cat as (select u.id,u.name, p.category, u.state,  SUM(o.price*o.quantity) as amount
from user_t u, product p, order_t o
where o.username = u.id 
and   o.product = p.id
and   
group by u.id, p.category
order by amount desc);


Table 3
sta_pro
State | Product | Category | Sales Amount

create table sta_pro as (select u.state, o.product, p.category, SUM(o.price*o.quantity) as amount
from user_t u, order_t o, product p
where o.username = u.id 
and o.product = p.id
group by u.state, o.product
order by amount desc);



Table 4
cus_pro
Customer | State | Product | category | Sales Amount


state:  STATE VARCHAR(30)
category: CATEGORY	INT NOT NULL
customer: USERNAME	INT NOT NULL
product: PRODUCT INT NOT NULL

create table cus_pro as (select u.id,u.state, u.name as username, p.name, SUM(o.price*o.quantity) as amount
from user_t u, product p, order_t o
where o.username = u.id 
and   o.product = p.id
group by u.id, p.id
order by amount desc);


y
TODO
1) create 2 tables (table 2 and 4)
1) Merge customer part
2) Filter 
3) Trigger (done or inCart)



