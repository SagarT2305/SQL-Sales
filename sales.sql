---Case Study Questions
select * from sales;
select * from menu;
select * from members;

-- 1. What is the total amount each customer spent at the restaurant?
	select s.customer_id,sum(m.price) total_amt_spent
	from sales s left join menu m
	on s.product_id =m.product_id
	group by s.customer_id

-- 2. How many days has each customer visited the restaurant?
	select customer_id, count(distinct order_date) as visits
	from Sales
	group by customer_id


-- 3. What was the first item from the menu purchased by each customer?
	with cte as(
	select s.customer_id, m.product_name as dish
	from sales s left join menu m
	on s.product_id =m.product_id
	where s.order_date = (select min(order_date) from sales)
	),
	cte2 as(
	select *, row_number() over(partition by customer_id order by (select null)) as rn from cte
	)
	select customer_id, dish from cte2 where rn =1
	


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
		select m.product_name, count(*) cnt
		from sales s left join menu m
		on s.product_id =m.product_id
		group by m.product_name



-- 5. Which item was the most popular for each customer?
		with cte as (
		select m.product_name, count(*) cnt,
		row_number() over(order by count(*) desc) as rn
		from sales s left join menu m
		on s.product_id =m.product_id
		group by m.product_name 
		--order by cnt desc
		) 

		select product_name from cte where rn =1



-- 6. Which item was purchased first by the customer after they became a member?
		with cte as(
		select s.customer_id,  m.product_name, s.order_date, mm.join_date,
			datediff(day,mm.join_date , s.order_date) day_diff
			   ,dense_rank() over(partition by s.customer_id 
			   order by datediff(day,mm.join_date , s.order_date)) as rn
		from sales s 
		left join members mm on s.customer_id =mm.customer_id
		left join menu m on s.product_id =m.product_id
		where s.order_date > mm.join_date
		)
		select customer_id, product_name 
		from cte 
		where rn=1


-- 7. Which item was purchased just before the customer became a member?
		
		with cte as(
		select s.customer_id,  m.product_name, s.order_date, mm.join_date,
			datediff(day,s.order_date, mm.join_date ) day_diff
			  ,dense_rank() over(partition by s.customer_id 
			   order by datediff(day,s.order_date, mm.join_date )) as rn
		from sales s 
		left join members mm on s.customer_id =mm.customer_id
		left join menu m on s.product_id =m.product_id
		where s.order_date < mm.join_date
		)
		select customer_id, product_name
		from cte 
		where rn=1
		


-- 8. What is the total items and amount spent for each member before they became a member?
		
		select s.customer_id,  count(m.product_name) total_items, sum(m.price) amt_spent	
		from sales s 
		left join members mm on s.customer_id =mm.customer_id
		left join menu m on s.product_id =m.product_id
		where s.order_date < mm.join_date
		group by s.customer_id



-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier -
--how many points would each customer have?
		with cte as (
		select s.customer_id, m.product_name, m.price, m.price*10 as pts,
			case when m.product_name='sushi' then (m.price*10)*2 else m.price*10 end as final_pts
		from sales s 
		left join menu m on s.product_id =m.product_id	
		)
		select customer_id, sum(final_pts) as pts
		from cte 
		group by customer_id



-- 10. In the first week after a customer joins the program (including their join date) 
--they earn 2x points on all items, not just sushi 
--how many points do customer A and B have at the end of January?
	
	with cte as(
	select s.customer_id,  m.product_name, s.order_date, mm.join_date, m.price
			,datediff(day, mm.join_date, s.order_date) +1 as day_diff
		from sales s 
		left join members mm on s.customer_id =mm.customer_id
		left join menu m on s.product_id =m.product_id
		where s.order_date > mm.join_date and order_date < '2021-01-31'
		)

		select customer_id, sum(case when day_diff <=7 then (price*10)*2 else price*10 end) as points
		from cte
		group by customer_id
	