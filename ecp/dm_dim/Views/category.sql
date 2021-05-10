CREATE VIEW [dm_dim].[Category] AS 

    SELECT product_key
    , MAX(CASE WHEN s.[Position] = 2 THEN 
            s.[value]        END )    AS [Category Parent] 
    , MAX(CASE WHEN s.[Position] = 3 THEN 
            s.[value]        END )    AS [Category Child 1] 
    , MAX(CASE WHEN s.[Position] = 4 THEN 
            s.[value]        END )    AS [Category Child 2] 
    , MAX(CASE WHEN s.[Position] = 5 THEN 
            s.[value]        END )    AS [Category Child 3] 

    from dim.product
    CROSS APPLY (
        SELECT value, 
        ROW_NUMBER() OVER(ORDER BY product_key DESC) as Position 
        FROM string_split(product_category, '/')
        
    ) s 

    GROUP BY product_key; 