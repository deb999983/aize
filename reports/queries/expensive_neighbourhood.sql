select neighbourhood, count(*) as property_count, avg(price) as avg_price_per_night from airbnb_data_ny
group by neighbourhood
order by avg_price_per_night desc;
