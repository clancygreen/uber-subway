SELECT 
    A.year, 
    A.pickup_datetime 
FROM (
    SELECT 
        pickup_datetime, 
        EXTRACT(year FROM pickup_datetime) AS year 
    FROM trips
) A 
WHERE A.year > 2018 OR A.year < 2009
ORDER BY A.pickup_datetime;
