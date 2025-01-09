-- 1. Fetch all the paintings which are not displayed on any museums?

select * 
from work 
where museum_id is null;


-- 2. Are there museuems without any paintings?

select * 
from museum m
where not exists (select *
				  from work w
					where w.museum_id=m.museum_id)
					
					
-- 3. How many paintings have an asking price of more than their regular price? 

select * 
from product_size
where sale_price < regular_price;


-- 4. Identify the paintings whose asking price is less than 50% of its regular price
	select * 
	from product_size
	where sale_price < (regular_price*0.5);


-- 5. Which canva size costs the most?
	select cs.label as canva, ps.sale_price
	from (select *
		  , rank() over(order by sale_price desc) as rnk 
		  from product_size) ps
	join canvas_size cs on cs.size_id::text=ps.size_id
	where ps.rnk=1;					 


-- 6. Delete duplicate records from work, product_size, subject and image_link tables
	delete from work 
	where ctid not in (select min(ctid)
						from work
						group by work_id);

	delete from product_size 
	where ctid not in (select min(ctid)
						from product_size
						group by work_id, size_id );

	delete from subject 
	where ctid not in (select min(ctid)
						from subject
						group by work_id, subject );

	delete from image_link 
	where ctid not in (select min(ctid)
						from image_link
						group by work_id );


-- 7. Identify the museums with invalid city information in the given dataset.
	select * from museum 
	where city ~ '^[0-9]'


-- 8. Museum_Hours table has 1 invalid entry. Identify it and remove it.
	delete from museum_hours 
	where ctid not in (select min(ctid)
						from museum_hours
						group by museum_id, day );

-- 9. Fetch the top 10 most famous painting subject.
	select * 
	from (
		select s.subject,count(*) as no_of_paintings,
		rank() over(order by count(*) desc) as ranking
		from work w
		join subject s on s.work_id=w.work_id
		group by s.subject ) x
	where x.ranking <= 10;


-- 10. Identify the museums which are open on both Sunday and Monday. Display Museum Name and city.

SELECT m.name as museum_name, m.city
FROM MUSEUM_HOURS mh1
join museum m on mh1.museum_id = m.museum_id
WHERE day = 'Sunday'
and exists (select 1
		   from museum_hours mh2
		   where mh1.museum_id = mh2.museum_id
		   and mh2.day = 'Monday')
		   		   

-- 11. How many museums are open every single day?
	select count(*)
	from (select museum_id, count(*)
		  from museum_hours
		  group by museum_id
		  having count(1) = 7) x;		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
		   
-- 2. Which museum is open for the longest during a day. Display Museum Name, State and hours open and which day.

select * from (
	SELECT m.name as museum_name, m.state, mh.day, 
		   TO_TIMESTAMP(open, 'HH:MI AM') AS open_time,
		   TO_TIMESTAMP(close, 'HH:MI PM') AS close_time,
		   TO_TIMESTAMP(close, 'HH:MI PM') - TO_TIMESTAMP(open, 'HH:MI AM') AS duration,
		   RANK() OVER (ORDER BY (TO_TIMESTAMP(close, 'HH:MI PM') - TO_TIMESTAMP(open, 'HH:MI AM')) DESC) AS rnk
	FROM museum_hours mh
	join museum m on mh.museum_id=m.museum_id) x
where x.rnk = 1;


-- 3. Display the country and the city with most of museums. Output 2 seperate columns to mention the city and country. If these are 
-- 	  multiple value, seperate them with comma.

with cte_country as (
	select country, count(*),
	rank() over(order by count(*) desc) as rnk
	from museum
	group by 1),
cte_city as (
	select city, count(*),
	rank() over(order by count(*) desc) as rnk
	from museum
	group by 1)
select string_agg(distinct country,','), string_agg(city,',')
from cte_country
cross join cte_city
where cte_country.rnk = 1
and cte_city.rnk = 1;















