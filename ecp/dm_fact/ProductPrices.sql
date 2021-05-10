CREATE VIEW [dm_fact].[ProductPrices] AS 
SELECT 
    pp.product_key
,   pp.product_price                               AS [Product Price]
,   pp.from_datetime                               AS [First Known Date]
,   DATEDIFF(HH, pp.from_datetime, ISNULL(pp.to_datetime,
                                         GETDATE() )
                                                 ) AS [Number Of Hours Active]
,   CASE WHEN 
    pp.[IsActive] = 1 
    THEN 'YES'
    ELSE 'NO'       END                           AS [Currently On Website]

FROM fact.ProductPrices pp;
