CREATE VIEW dm_dim.[PriceChangeHistory] AS 

WITH cte_changes AS (

    SELECT product_key
    ,   COUNT(*) as [Number of Changes]
    ,   MAX(from_datetime) [Most Recent Change Date]

    FROM fact.productprices 
    GROUP BY product_key
)

select product_key
,      [Number of Changes]
,      [Most Recent Change Date]
FROM cte_changes
WHERE [Number of Changes] > 1