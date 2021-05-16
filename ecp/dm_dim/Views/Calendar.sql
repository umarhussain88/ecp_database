CREATE VIEW dm_dim.Calendar AS

SELECT c.* 
FROM dim.Calendar c
CROSS APPLY(
    SELECT CAST(MIN(from_datetime) AS date) AS min_d
    ,      CAST(MAX(from_datetime) AS date) AS max_d
    FROM fact.ProductPrices
) m 
WHERE ActualDate >= min_d
AND   ActualDate <= max_d