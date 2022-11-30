select 
	substring(psdny.building_class_category, 0, 10) AS category,
	sum(sale_price) / count(*) as avg_unit_price 
from property_sales_ny psdny 
where sale_price is not null and sale_price > 0
group by building_class_category 
order by avg_unit_price desc;
