with base_temp_table as (
	select 
		timestamp, ROW_NUMBER () OVER ( ORDER BY timestamp) as rn, mean, max, min
	FROM
		weather_data as wd
	ORDER BY timestamp
),
temp_by_week as (
	select ceil(rn / 7) as week, avg(mean) as avg_temp from base_temp_table
	group by week
	order by week
),
with_temp_lag as (
	select *, lag(avg_temp) over(order by week) as previous_week_temp from temp_by_week	
),
base_ps_table as (
	select 
		ps.sale_date, count(*) as total_sales_per_day
	FROM
		property_sales_ny as ps
	
	where sale_date is not NULL		
	group by sale_date
	
), temp_ps_table as (
	select *, ROW_NUMBER () OVER ( ORDER BY sale_date) as rn from base_ps_table order by sale_date
),
sales_per_week as (
	select ceil(rn / 7) as week, sum(total_sales_per_day) as total_sales from temp_ps_table
	group by week
	order by week
),
with_sales_lag as (
	select *, lag(total_sales) over(order by week) as previous_week_sales from sales_per_week 
)
select week::varchar(255), 
	  ((avg_temp - previous_week_temp) / previous_week_temp) * 100 as wow_temp,
	  ((total_sales - previous_week_sales) / previous_week_sales) * 100 as wow_sales
from with_sales_lag join with_temp_lag
using(week)
order by week::integer;
