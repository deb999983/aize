
with base as (
SELECT (
  CASE 
    WHEN price >= 0 AND price <= 50 THEN '0-50'
    WHEN price > 50 AND price <= 100 THEN '50-100'
    WHEN price > 100 AND price <= 150 THEN '100-150'
	WHEN price > 150 AND price <= 200 THEN '100-150'
    WHEN price > 200 AND price <= 250 THEN '200-250'
    WHEN price > 250 AND price <= 300 THEN '250-300'    
    WHEN price > 300 AND price <= 350 THEN '300-350'    
    WHEN price > 350 AND price <= 400 THEN '350-400'
    WHEN price > 400 AND price <= 450 THEN '350-400'
    WHEN price > 450 AND price <= 500 THEN '450-500'    
    WHEN price > 500 AND price <= 550 THEN '500-550'
    WHEN price > 550 AND price <= 600 THEN '550-600'
    WHEN price > 600 AND price <= 650 THEN '600-650'
    WHEN price > 650 AND price <= 700 THEN '650-700'
    WHEN price > 700 AND price <= 750 THEN '700-750'    
    WHEN price > 750 AND price <= 1000 THEN '750-1000'
    WHEN price > 1000 AND price <= 10000 THEN '1000-10000'    
  END
) as price_range, count(*) as property_count
from airbnb_data_ny adn
group by price_range
)
select * from base order by length(price_range), price_range;



