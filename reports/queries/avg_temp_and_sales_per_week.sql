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
)
select sw.week::varchar(255), total_sales, avg_temp from sales_per_week as sw
join temp_by_week as tw on sw.week = tw.week
order by sw.week;
