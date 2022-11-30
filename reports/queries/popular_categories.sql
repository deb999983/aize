select 
	psdny.building_class_category as category, count(*) as total_sales
from property_sales_ny psdny 
where sale_price is not null and sale_price > 0
group by building_class_category 
order by total_sales desc limit 10;
