CREATE VIEW [dm_fact].[PriceChanges] AS 

WITH
    cte_changes
    AS
    (
        SELECT
            product_key
            ,ROW_NUMBER() OVER(PARTITION BY product_key ORDER BY FROM_datetime) AS price_change_seq
        FROM
        fact.ProductPrices

    )


    ,cte_prev_price
    AS
    (

        SELECT
            pp.product_key
            ,pp.product_price
            ,IsActive
            ,price_change_seq
            ,LAG(pp.product_price, 1,NULL) OVER(
                                                PARTITION BY pp.product_key 
                                                ORDER BY FROM_datetime)        AS [prev_price]
        FROM
        cte_changes chng
        LEFT JOIN fact.ProductPrices pp
        ON chng.product_key = pp.product_key
        WHERE price_change_seq > 1

    )

, cte_change_status AS  (
SELECT
    product_key
,   CASE WHEN prev_price > product_price 
            THEN 'decrease'
            WHEN prev_price < product_price
            THEN 'increase'
            ELSE 'no change'
            END AS [status]

    ,       prev_price    
    ,CASE WHEN prev_price > product_price
            THEN ROUND((prev_price - product_price) / prev_price, 2)
            WHEN prev_price < product_price
            THEN ROUND((product_price - prev_price) / prev_price, 2)
            END AS [perc_change]


FROM cte_prev_price
WHERE IsActive = 1  -- only want current facts. 
) 

SELECT pp.product_key   
,      cs.prev_price            AS [most previous price]
,      cs.perc_change           AS [most previous percentage change]
,      CASE WHEN cs.product_key IS NULL
            THEN 'No Change'
            ELSE 'Change'
            END AS             [Change Status]


FROM fact.ProductPrices pp 
LEFT JOIN cte_change_status cs 
ON cs.product_key = pp.product_key
WHERE pp.IsActive = 1
