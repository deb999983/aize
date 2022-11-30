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
	select neighborhood_group, count(*) as sold_property_count, round((sum(sale_price) / count(*))) as avg_property_price
	from valid_sales
	group by neighborhood_group
),
airbnb_base as (
	select *, (price * minimum_nights * number_of_reviews) as min_earnings  from airbnb_data_ny adn 
),
airbnb_summary as (
	select neighbourhood_group,
		   count(*) as ab_property_count, 
		   avg(price) as avg_price_per_night, 
		   (sum(number_of_reviews) / count(*)) as visits_per_property,
		   (sum(min_earnings) / count(*)) as min_earnings_per_property,
		   ((sum(min_earnings) / count(*)) / 12) as min_earnings_per_property_per_month,
		   avg(availability_365) as avg_availability	   
		   from airbnb_base
	group by neighbourhood_group
	order by visits_per_property desc
)
select ps.neighborhood_group, 
	   ab_s.ab_property_count,
	   ab_s.avg_price_per_night,
	   ab_s.visits_per_property,
	   ab_s.min_earnings_per_property,
	   ab_s.min_earnings_per_property_per_month,
	   ab_s.avg_availability,
	   ps.sold_property_count,
	   ps.avg_property_price,	   
	  (ps.avg_property_price / ab_s.min_earnings_per_property) as recovery_period 
from airbnb_summary ab_s join property_sales_summary ps 
on ps.neighborhood_group = ab_s.neighbourhood_group;
