CREATE VIEW [dm_fact].[DailyPrices] AS 

WITH E00(N) AS (SELECT 1 UNION ALL SELECT 1)
    ,E02(N) AS (SELECT 1 FROM E00 a, E00 b)
    ,E04(N) AS (SELECT 1 FROM E02 a, E02 b)
    ,E08(N) AS (SELECT 1 FROM E04 a, E04 b)
    ,E16(N) AS (SELECT 1 FROM E08 a, E08 b)
    ,E32(N) AS (SELECT 1 FROM E16 a, E16 b)
    ,cteTally(N) AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E32)
    ,DateRange AS
(
    SELECT ExplodedDate = DATEADD(DAY,N - 1,'2021-01-01')
    FROM cteTally
    WHERE N <= 366
)




SELECT d.ExplodedDate, pp.product_price, pp.product_key 
FROM fact.ProductPrices pp
JOIN DateRange d  
ON d.ExplodedDate >= CAST(pp.from_datetime as date)
    AND d.ExplodedDate <= ISNULL(CAST(pp.to_datetime as date), GETDATE());