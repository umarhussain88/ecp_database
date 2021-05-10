CREATE VIEW [dm_dim].[LastUpdated] AS 

SELECT DATEADD(HH,1,MAX(extractiondate)) [Last Scraped Date]
FROM stg_ecp.product_data;