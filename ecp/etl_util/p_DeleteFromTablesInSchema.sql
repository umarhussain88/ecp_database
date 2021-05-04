CREATE PROCEDURE [etl_util].[p_DeleteFromTablesInSchema]
	@jobKey	int
,	@SchemaName sysname
AS
BEGIN

	/* ===============================================================================================================
	Author:			Carl Follows
	Create date:	05/10/2016
	Description:	Deletes data from all tables in the specified schema
	=============================================================================================================== */

	SET NOCOUNT ON                      -- Eliminate any dataset counts
   
	DECLARE @jobLogKey  int             -- Identity for Job Log Table
    ,		@section	nvarchar(2048)	-- document your steps by setting this variable
	,       @proc		sysname;        -- Name of this procedure
	SET     @proc		= '[etl_util].[p_DeleteFromTablesInSchema]'

	-- Log the start time of the Procedure
    EXEC [etl_audit].[p_InsertJobLog] @procName = @proc, @jobKey = @jobKey, @jobLogKey = @jobLogKey OUTPUT;
   
	BEGIN TRY

		SET @section = 'Identify tables in scope of deletion';
		EXEC [etl_audit].[p_UpdateJobLog_EndSection] @section = @section, @jobLogKey = @jobLogKey OUTPUT; 

			IF OBJECT_ID('tempdb..#Tables') IS NOT NULL
				DROP TABLE #Tables;

			CREATE TABLE #Tables
			(		DelSeq		smallint
			,		TABLE_NAME	varchar(256)
			)

			INSERT INTO #Tables
			(		DelSeq		
			,		TABLE_NAME
			)
			SELECT  ROW_NUMBER() OVER(ORDER BY TABLE_NAME) AS DelSeq
			,       TABLE_NAME
			FROM    INFORMATION_SCHEMA.TABLES
			WHERE   TABLE_SCHEMA = @SchemaName
			AND     TABLE_TYPE = 'BASE TABLE'

		SET @section = 'Loop through tables in schema and delete data';
		EXEC [etl_audit].[p_UpdateJobLog_EndSection] @section = @section, @jobLogKey = @jobLogKey OUTPUT;

			DECLARE  @records          int = (SELECT COUNT(*) FROM #Tables)
			,        @i                int = 1
			,        @tableName        sysname
			,        @SqlCommand     nvarchar(max);
         
			WHILE @i <= @records
			BEGIN

					SET @tableName = (SELECT TABLE_NAME FROM #Tables WHERE DelSeq = @i)
					SET @SqlCommand = 'DELETE FROM [' + @SchemaName + '].[' + @tableName + ']';

				SET @section = @SqlCommand;
				EXEC [etl_audit].[p_UpdateJobLog_EndSection] @section = @section, @jobLogKey = @jobLogKey OUTPUT;

					EXEC sp_executesql @stmt = @SqlCommand;

					SET @i += 1;
			END
		 
			IF OBJECT_ID('tempdb..#Tables') IS NOT NULL
				DROP TABLE #Tables;

	END TRY

	BEGIN CATCH
   
		-- Log the error and raise it again
		EXEC [etl_audit].[p_LogAndRaiseSqlError] @jobLogKey = @jobLogKey;
	  
	END CATCH

	-- Log the end of the Procedure Run, success or otherwise    
	EXEC [etl_audit].[p_UpdateJobLog_EndProcedure] @jobLogKey = @jobLogKey;

END