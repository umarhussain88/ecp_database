CREATE VIEW [dm_dim].[ProductStatus] AS 

WITH cte_last_update AS (
    SELECT product_key
    ,      from_datetime
    ,      ROW_NUMBER() OVER(PARTITION BY product_key ORDER BY from_datetime DESC) AS [seq]
    FROM fact.ProductPrices
)
, cte_first_known_date AS (
    SELECT product_key
    ,      MIN(from_datetime) as [earliest date known]
    FROM fact.ProductPrices pp 
    GROUP BY product_key
)

SELECT 

    pp.product_key
,   pp.product_price                               AS [Product Price]
,   fkd.[earliest date known]                      AS [First Known Date]
,   DATEDIFF(HH, fkd.[earliest date known], ISNULL(pp.to_datetime,
                                         GETDATE() )
                                                 ) AS [Number Of Hours Active]
,   DATEDIFF(DD, fkd.[earliest date known], ISNULL(pp.to_datetime,
                                         GETDATE() )
                                                 ) AS [Number Of Days Active]
,   CASE WHEN 
    pp.[IsActive] = 1 
    THEN 'Yes'
    ELSE 'No'       END                           AS [Currently On Website]

FROM cte_last_update lu 
LEFT JOIN fact.ProductPrices pp
ON lu.product_key = pp.product_key
AND lu.from_datetime = pp.from_datetime
LEFT JOIN cte_first_known_date fkd 
ON lu.product_key = fkd.product_key
WHERE lu.seq = 1