
# How many different products are being sold?

select count(distinct order_id) from order_items;
select count(distinct product_category_name) from products;
select count(distinct product_id) from order_items;
select count(distinct product_id) from products;


# What are the most popular categories?

select c.product_category_name_english, count(a.order_id) from order_items a
inner join products b
on a.product_id = b.product_id
inner join product_category_name_translation c
on b.product_category_name = c.product_category_name
group by b.product_category_name
order by 2 desc
limit 10;


# How popular are tech products compared to other categories?

select count(b.order_id), c.product_category_name_english, a.product_category_name from products a
inner join product_category_name_translation c
on a.product_category_name = c.product_category_name
inner join order_items b
on a.product_id = b.product_id
group by a.product_category_name
order by 1 desc
limit 10;

select count(order_id) from products a
inner join order_items b
on a.product_id = b.product_id
where a.product_category_name IN ('telefonia', 'informatica_acessorios', 'eletronicos', 'consoles_games', 'pcs', 'pc_gamer', 'dvds_blu_ray', 'cds_dvds_musicais', 'musica', 'audio');



# What's the average price of the products being sold?

select  round(avg(price), 2) from order_items;


# Are expensive tech products popular?
select count(b.order_id), 
	case 
		when price > 1000 then "Expensive"
		when price > 100 then "Mid-range"
		else "Cheap"
	end as "price_range"
from products a
inner join order_items b
on a.product_id = b.product_id
where a.product_category_name IN ('telefonia', 'informatica_acessorios', 'eletronicos', 'consoles_games', 'pcs', 'pc_gamer', 'dvds_blu_ray', 'cds_dvds_musicais', 'musica', 'audio')
group by price_range
order by 1 desc;

# What’s the average monthly revenue of Magist’s sellers?
drop table month_stuff;

create table month_stuff (
	select a.seller_id,  month(b.order_purchase_timestamp) as month, sum(a.price) as total_price from order_items a 
	inner join orders b
	on a.order_id = b.order_id
	group by 1, 2
	order by 1, 2 desc
    );
select seller_id, sum(total_price), count(month), sum(total_price)/count(month) as average_monthly from month_stuff
group by 1
order by 4 desc;

with monthy as (
	select a.seller_id,  month(b.order_purchase_timestamp) as month, sum(a.price) as total_price from order_items a 
	inner join orders b
	on a.order_id = b.order_id
	group by 1, 2
	order by 1, 2 desc
    )
select seller_id, sum(total_price), count(month), sum(total_price)/count(month) as average_monthly from monthy
group by 1
order by 4 desc;


# How many sellers are there?

select count(distinct seller_id) from sellers;

# What’s the average revenue of all the sellers?

with sellers_rev as (
	select seller_id, sum(price) as total_price from order_items
	group by 1
	order by 2 desc
    )
select avg(total_price) as average_rev from sellers_rev;

# What’s the average revenue of sellers that sell tech products?
with sellers_rev_tech as (
	select seller_id, sum(price) as total_price from order_items a
	inner join products b
	on a.product_id = b.product_id
	where b.product_category_name IN ('telefonia', 'informatica_acessorios', 'eletronicos', 'consoles_games', 'pcs', 'pc_gamer', 'dvds_blu_ray', 'cds_dvds_musicais', 'musica', 'audio')
	group by 1
	order by 2 desc
    )
select avg(total_price) as average_rev from sellers_rev_tech; 

# What’s the average time between the order being placed and the product being delivered?

select round(round(avg(order_delivered_customer_date - order_purchase_timestamp),0)/1000/60/60/24, 2) as days from orders;

# How many orders are delivered on time vs orders delivered with a delay?

with main as ( 
	select * from orders
	where order_delivered_customer_date and order_estimated_delivery_date is not null
    ),
    d1 as (
	select order_delivered_customer_date - order_estimated_delivery_date as delay from main
    ), 
    d2 as (
	select 
		case when delay > 0 then 1 else 0 end as pos_del,
		case when delay <=0 then 1 else 0 end as neg_del from d1
	group by delay
    )
select sum(pos_del) as delay, sum(neg_del) as on_time from d2;

# Is there any pattern for delayed orders, e.g. big products being delayed more often?

with main as ( 
	select * from orders
	where order_delivered_customer_date and order_estimated_delivery_date is not null
    ),
    d1 as (
	select *, (order_delivered_customer_date - order_estimated_delivery_date)/1000/60/60/24 as delay from main
    )
		select * from d1 a
    inner join order_items b
    on a.order_id = b.order_id
    inner join products c
    on b.product_id = c.product_id
    where delay > 0
    order by delay desc, product_weight_g desc;

#group by on the delay_range, then different aggregate functions about the product weight
with main as ( 
	select * from orders
	where order_delivered_customer_date and order_estimated_delivery_date is not null
    ),
    d1 as (
	select *, (order_delivered_customer_date - order_estimated_delivery_date)/1000/60/60/24 as delay from main
    )
		select 
			case 
				when delay > 101 then "> 100 day Delay"
				when delay > 3 and delay < 8 then "3-7 day delay"
                when delay > 1.5 then "1.5 - 3 days delay"
				else "< 1.5 day delay"
			end as "delay_range", 
            avg(product_weight_g) as weight_avg,
            max(product_weight_g) as max_weight,
            min(product_weight_g) as min_weight,
            sum(product_weight_g) as sum_weight,
            count(*) as product_count from d1 a
    inner join order_items b
    on a.order_id = b.order_id
    inner join products c
    on b.product_id = c.product_id
    where delay > 0
    group by delay_range
    order by weight_avg desc;
    


