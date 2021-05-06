CREATE PROCEDURE [stg_ecp].[p_InsertDwFactProductPrices]
	@jobKey	int
AS
BEGIN

	/* ==================================================================================================================
	Description:	Create Fact Table for Products.
	================================================================================================================== */

    SET NOCOUNT ON						-- Eliminate any dataset counts

    DECLARE @jobLogKey	int				-- Identity for Job Log Table
    ,		@section	nvarchar(2048)	-- document your steps by setting this variable
	,       @proc		sysname;        -- Name of this procedure
	SET     @proc		= '[stg_ecp].[p_InsertDwFactProductPrices]';
	
	-- Log the start time of the Procedure
    EXEC [etl_audit].[p_InsertJobLog] @procName = @proc, @jobKey = @jobKey, @jobLogKey = @jobLogKey OUTPUT;
	
    BEGIN TRY
	
		SET @section = 'Rebuild the fact'
		EXEC [etl_audit].[p_UpdateJobLog_EndSection] @section = @section, @jobLogKey = @jobLogKey OUTPUT;
		
			-- Identify the source dataset		
				WITH dat AS (SELECT    
                id                                      AS [product_id]
                ,           price                       AS [product_price]
                ,           extractiondate              AS [extraction_date]
                ,			ROW_NUMBER()
                                OVER(PARTITION BY   	[id]
										,				[price]
                                        ORDER BY       [extractiondate] DESC

                                    )                   AS [BusinessKeySeq]
                ,		    1				            AS [IsActive]
                FROM	    [stg_ecp].[product_data]
				
						)

        , ky AS (SELECT p.[product_key]
                ,       dat.[product_price] 
                -- ,       c.DateKey as [date_key]
                -- ,       t.time_key
                ,       dat.extraction_date
                ,       dat.[IsActive]

                FROM dat 
                INNER JOIN dim.product p 
                ON  p.product_id = dat.product_id 
                WHERE BusinessKeySeq = 1


        )
        
        , src AS (SELECT ky.[product_key]
                ,        ky.[product_price]
                ,        ky.extraction_date
                ,        ky.[IsActive]
                ,			ch.[ChangeHash]

                FROM ky 
                CROSS APPLY (SELECT CAST(HASHBYTES	( 'SHA2_512'
                                        , ISNULL(CAST(ky.[product_price] AS nvarchar), '')
                                        ) AS binary(64)
                            ) AS [ChangeHash]
                ) ch

        )

			MERGE	[fact].[ProductPrices] AS tgt
			USING	src
			ON		tgt.[product_key] = src.[product_key]
			AND		tgt.[product_price] = src.[product_price]
			

			WHEN NOT MATCHED THEN
				INSERT
				(		
						[product_key]	
				,		[product_price]	
	
                ,       [from_datetime]
                ,       [to_datetime]

				,		[IsActive]
				,		[ChangeHash]
				,		[CreatedJobKey]
				,		[UpdatedJobKey]
				)
				VALUES
				(		src.[product_key]	
				,		src.[product_price]	
                ,       GETDATE()
                ,       NULL  		

				,		src.[IsActive]
				,		src.[ChangeHash]
				,		@jobKey
				,		@jobKey
				)

			WHEN NOT MATCHED BY SOURCE AND to_datetime IS NULL THEN
				UPDATE
				SET		[IsActive]		= 0
                ,       [to_datetime]   = src.[extraction_date]
				,		[ChangeHash]	= CAST('' AS binary(64))
				,		[UpdatedJobKey]	= @jobKey;

    END TRY

    BEGIN CATCH

		-- Log the error and raise it again
		EXEC [etl_audit].[p_LogAndRaiseSqlError] @jobLogKey = @jobLogKey;

    END CATCH

    -- Log the end of the Procedure Run, success or otherwise    
    EXEC [etl_audit].[p_UpdateJobLog_EndProcedure] @jobLogKey = @jobLogKey;

END


