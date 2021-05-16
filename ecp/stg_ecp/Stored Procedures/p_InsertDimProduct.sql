CREATE PROCEDURE [stg_ecp].[p_InsertDwDimProduct]
	@jobKey	int
AS
BEGIN

	/* ==================================================================================================================
	Description:	Update from the stage tables into the DW
    EXEC stg_ecp.p_InsertDwDimProduct 2
	================================================================================================================== */

    SET NOCOUNT ON						-- Eliminate any dataset counts

    DECLARE @jobLogKey	int				-- Identity for Job Log Table
    ,		@section	nvarchar(2048)	-- document your steps by setting this variable
	,       @proc		sysname;        -- Name of this procedure
	SET     @proc		= '[stg_ecp].[p_InsertDwDimProduct]';
	
	-- Log the start time of the Procedure
    EXEC [etl_audit].[p_InsertJobLog] @procName = @proc, @jobKey = @jobKey, @jobLogKey = @jobLogKey OUTPUT;
	
    BEGIN TRY
	
		SET @section = 'Rebuild the dimension'
		EXEC [etl_audit].[p_UpdateJobLog_EndSection] @section = @section, @jobLogKey = @jobLogKey OUTPUT;
		
			-- Identify the source dataset		
				WITH dat AS (SELECT     DISTINCT 
                                [id]					AS [product_id]
						,       [name]					AS [product_name]
                        ,       LTRIM(RTRIM(
                                    REPLACE(
                                        list,'Category Listing -', '')
                                    )
                                        )               AS [product_listing]
                        ,       [category]              AS [product_category]
                        ,       [brand]                 AS [product_brand_long]
                        ,       CASE WHEN brand IS NOT NULL 
                                     THEN b.val 
                                     ELSE NULL END      AS [product_brand_short]
                        ,       [imgsrc]                AS [product_img_src]
                        ,       [friendlyurl]           AS [product_url]
						,		[extractiondate]		AS [SourceFileExtractDateTime]
						,       ROW_NUMBER()
									OVER(PARTITION BY   [id]
										 ORDER BY       [extractiondate] DESC
                                         
                                        )               AS [BusinessKeySeq]
                        ,		1			            AS [IsActive]
						FROM	[stg_ecp].[product_data]
                        CROSS APPLY (
                        SELECT UPPER(REPLACE(LEFT(friendlyurl, CHARINDEX('-', friendlyurl) -1 ), '/p/', '')) as val 
                        WHERE CHARINDEX('-', friendlyurl) >0  
                                    ) b
						
                        )

        , src AS ( SELECT 

                            dat.[product_id]
                        ,   dat.[product_name]
                        ,   dat.[product_listing]
                        ,   dat.[product_category]
                        ,   dat.[product_brand_short]
                        ,   dat.[product_brand_long]
                        ,   dat.[product_img_src]
                        ,   dat.[product_url]
                        ,   dat.[isActive]
                        ,	ch.[ChangeHash]
                        FROM dat 
                        CROSS APPLY (SELECT CAST(HASHBYTES	( 'SHA2_512'
                                    , ISNULL(CAST(dat.[product_listing]           AS nvarchar), '')
                                    + ISNULL(CAST(dat.[product_category]          AS nvarchar), '')
                                    + ISNULL(CAST(dat.[product_brand_short]       AS nvarchar), '')
                                    + ISNULL(CAST(dat.[product_brand_long]        AS nvarchar), '')
                                    + ISNULL(CAST(dat.[product_img_src]           AS nvarchar), '')
                                    + ISNULL(CAST(dat.[product_url]               AS nvarchar), '')
                                    + ISNULL(CAST(dat.[IsActive]                  AS nvarchar), '')
                                                                    ) AS binary(64)
                                                        ) AS [ChangeHash]
                                            ) ch
                                
                        WHERE BusinessKeySeq = 1

                )

			MERGE	[dim].[product] AS tgt
			USING	src
			ON		tgt.[product_id]	= src.[product_id]
			
			WHEN MATCHED AND tgt.[ChangeHash] != src.[ChangeHash] THEN
				UPDATE
				SET		    
                        [product_listing]           = src.[product_listing]        
                ,       [product_category]          = src.[product_category]        
                ,       [product_brand_short]       = src.[product_brand_short]    
                ,       [product_brand_long]        = src.[product_brand_long]    
                ,       [product_img_src]           = src.[product_img_src]  
                ,       [product_url]               = src.[product_url]  

                ,		[IsActive]						= src.[IsActive]      
				,		[ChangeHash]					= src.[ChangeHash]
				,		[UpdatedJobKey]					= @jobKey

			WHEN NOT MATCHED THEN
				INSERT
				(		[product_id]
                ,       [product_name]
                ,       [product_listing]
                ,       [product_category]
                ,       [product_brand_short]
                ,       [product_brand_long]
                ,       [product_img_src]
                ,       [product_url]

                ,		[IsActive]
				,		[ChangeHash]
				,		[CreatedJobKey]
				,		[UpdatedJobKey]
				)
				VALUES
				(		src.[product_id]
                ,       src.[product_name]
                ,       src.[product_listing]
                ,       src.[product_category]
                ,       src.[product_brand_short]
                ,       src.[product_brand_long]
                ,       src.[product_img_src]
                ,       src.[product_url]

                ,		[IsActive]
				,		src.[ChangeHash]
				,		@jobKey
				,		@jobKey
				)

			WHEN NOT MATCHED BY SOURCE THEN
				UPDATE
				SET		[IsActive]		= 0
				,		[ChangeHash]	= CAST('' AS binary(64))
				,		[UpdatedJobKey]	= @jobKey;

    END TRY

    BEGIN CATCH

		-- Log the error and raise it again
        
		EXEC [etl_audit].[p_LogAndRaiseSqlError] @jobLogKey = @jobLogKey;
        EXEC [etl_audit].[p_UpdateJob] @jobKey = @JobKey, @JobStatus = 'Failure'

    END CATCH

    -- Log the end of the Procedure Run, success or otherwise    
    EXEC [etl_audit].[p_UpdateJobLog_EndProcedure] @jobLogKey = @jobLogKey;
    EXEC [etl_audit].[p_UpdateJob] @jobKey = @JobKey, @JobStatus = 'Success'

END


