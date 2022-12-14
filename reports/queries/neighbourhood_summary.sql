with residential_buildings as (
	select * from property_sales_ny as psy where residential_units > commercial_units
),
valid_sales as (
	select * from residential_buildings rb 
	where sale_price is not null 
	and sale_price > 10000
	and gross_square_feet is not null and gross_square_feet > 0
	and land_square_feet is not null and land_square_feet > 0
),
property_sales_summary as (
	select neighborhood, count(*) as sold_property_count, round((sum(sale_price) / count(*))) as avg_property_price
	from valid_sales
	group by neighborhood
),
airbnb_base as (
	select *, (price * minimum_nights * number_of_reviews) as min_earnings  from airbnb_data_ny adn 
),
airbnb_summary as (
	select neighbourhood,
		   count(*) as ab_property_count, 
		   round(avg(price)) as avg_price_per_night, 
		   (sum(number_of_reviews) / count(*)) as visits_per_property,
		   (sum(min_earnings) / count(*)) as min_earnings_per_property,
		   ((sum(min_earnings) / count(*)) / 12) as min_earnings_per_property_per_month,
		   round(avg(availability_365)) as avg_availability	   
		   from airbnb_base
	group by neighbourhood
	order by visits_per_property desc
)
select ps.neighborhood, 
	   ab_s.ab_property_count,
	   ps.sold_property_count,
	   ps.avg_property_price,	   
	   ab_s.min_earnings_per_property,
	   ab_s.min_earnings_per_property_per_month,
       round((ps.avg_property_price / ab_s.min_earnings_per_property)) as recovery_period,		
	   ab_s.avg_price_per_night,
	   ab_s.visits_per_property,
	   ab_s.avg_availability
from airbnb_summary ab_s join property_sales_summary ps 
on lower(ps.neighborhood) = lower(ab_s.neighbourhood)
where ab_s.min_earnings_per_property > 0;
