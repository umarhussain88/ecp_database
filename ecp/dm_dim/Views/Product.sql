CREATE VIEW dm_dim.Product AS 

WITH cte_current_price AS (
    SELECT ROW_NUMBER() OVER(PARTITION BY [product_key] order by from_datetime DESC) as seq 
    ,   product_key
    ,   from_datetime
    ,   product_price 
    FROM fact.ProductPrices
)


SELECT p.product_key
,      p.product_id
,      p.product_name                                AS [Product Name]
,      p.product_listing                             AS [Product Listing]
,      p.product_img_src                            
,      'https://eurocarparts.com' + 
       REPLACE(p.product_url,
                'https://www.eurocarparts.com', '')          AS [Product URL]
,      p.product_brand_short                         AS [Product Brand Name]
,      ISNULL(pch.[Number of Changes],0)             AS [Number of Changes]
,      ISNULL(pch.[Most Recent Change Date]          
             , '1900-01-01')                         AS [Most Recent Change Date]
,      ISNULL(c.[Category Parent], '')               AS [Category Parent]                   
,      ISNULL(c.[Category Child 1], 
                     p.product_listing)              AS [Category Child 1]   
,      ISNULL(c.[Category Child 2], 
                    p.product_listing)               AS [Category Child 2]   
,      ISNULL(c.[Category Child 3], '')              AS [Category Child 3]  
,      ISNULL(pc.[most previous price], 0)           AS [Previous Price]
,      ISNULL(pc.[most previous percentage change]
             , 0.0)                                  AS [Percentage Change]
,      ISNULL(pc.[Change Status], 'No Change')       AS [Change Status]      
,      ps.[First Known Date]
,      ps.[Number Of Hours Active]
,      ps.[Number Of Days Active]       
,      ps.[Currently On Website]
,      cp.product_price                              AS [Active Price]
,      cp.from_datetime                              AS [Current Known Date]

, ROW_NUMBER() OVER(
    PARTITION BY pc.[Change Status]
    ORDER BY  pch.[Most Recent Change Date] DESC 
            , p.product_key DESC 
) RankOrder


FROM dim.Product p 
LEFT JOIN dm_dim.PriceChangeHistory pch 
ON p.product_key = pch.product_key
LEFT JOIN dm_dim.Category c 
ON p.product_key = c.product_key
LEFT JOIN dm_fact.PriceChanges pc 
ON p.product_key = pc.product_key
AND [Change Status] = 'Change'
LEFT JOIN dm_dim.ProductStatus ps 
ON p.product_key = ps.product_key
LEFT JOIN cte_current_price cp 
ON cp.product_key = p.product_key
AND seq = 1
WHERE p.product_id NOT IN ('-1') -- test record.