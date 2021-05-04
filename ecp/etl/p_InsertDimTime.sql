CREATE PROCEDURE [etl].[p_InsertDimTime]
	@jobKey	int
AS
BEGIN


/**********************************************************************************************************************
** Description:  Populate date dimension
** Runtime:      6 - 45 seconds (AMD Ryzen 7 3800x 8 cores /16 logical processors | 32 GB memory)
** Record Count: 86,400 records | 1 second grain
**********************************************************************************************************************/
SET NOCOUNT ON;							-- Eliminate any dataset counts
SET DATEFORMAT DMY;						-- Set dateformat for correct string interpretation
SET DATEFIRST 1;						-- Set which day is the first day of week (1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun)

DECLARE @jobLogKey	int				-- Identity for Job Log Table
,		@section	nvarchar(2048)	-- document your steps by setting this variable
,       @proc		sysname;        -- Name of this procedure
SET     @proc		= '[etl].[p_InsertDimTime]';

-- Log the start time of the Procedure
EXEC [etl_audit].[p_InsertJobLog] @procName = @proc, @jobKey = @jobKey, @jobLogKey = @jobLogKey OUTPUT;

BEGIN TRY 

DECLARE
    @Hour        INT    = 0
   ,@Minute      INT
   ,@Second      INT
   ,@MinuteOfDay INT    = 0
   ,@SecondOfDay INT    = 0
   ,@AmPm        CHAR(2);

INSERT INTO [dim].[Time] (
    [time_key]
   ,[Hour 24]
   ,[Hour 24 Short]
   ,[Hour 24 Medium]
   ,[Hour 24 Full]
   ,[Hour 12]
   ,[Hour 12 Short]
   ,[Hour 12 Short Trim]
   ,[Hour 12 Medium]
   ,[Hour 12 Medium Trim]
   ,[Hour 12 Full]
   ,[Hour 12 Full Trim]
   ,[AM PM Code]
   ,[AM PM]
   ,Minute
   ,[Minute Of Day]
   ,[Minute Code]
   ,[Minute Short]
   ,[Minute 24 Full]
   ,[Minute 12 Full]
   ,[Minute 12 Full Trim]
   ,[Half Hour Code]
   ,[Half Hour]
   ,[Half Hour Short]
   ,[Half Hour 24 Full]
   ,[Half Hour 12 Full]
   ,[Half Hour 12 Full Trim]
   ,Second
   ,[Second Of Day]
   ,[Second Short]
   ,[Full Time 24]
   ,[Full Time 12]
   ,[Full Time 12 Trim]
   ,[Full Time]
)
VALUES
     (-1
     ,0
     ,'UN'
     ,'UNKWN'
     ,'UNKNOWN'
     ,12
     ,'UNKWN'
     ,'UNKWN'
     ,'UNKNOWN'
     ,'UNKNOWN'
     ,'UNKNOWN'
     ,'UNKNOWN'
     ,0
     ,'UN'
     ,0
     ,0
     ,0
     ,'UN'
     ,'UNKNOWN'
     ,'UNKNOWN'
     ,'UNKNOWN'
     ,0
     ,0
     ,'UN'
     ,'UNKNOWN'
     ,'UNKNOWN'
     ,'UNKNOWN'
     ,0
     ,0
     ,'UN'
     ,'UNKNOWN'
     ,'UNKNOWN'
     ,'UNKNOWN'
     ,N'00:00:00');

WHILE @Hour < 24
    BEGIN
        SET @Minute = 0;

        WHILE @Minute < 60
            BEGIN
                SET @Second = 0;

                WHILE @Second < 60
                    BEGIN

                        IF @Hour < 12
                            BEGIN
                                SET @AmPm = 'AM';
                            END;
                        ELSE
                            BEGIN
                                SET @AmPm = 'PM';
                            END;

                        INSERT INTO [dim].[Time] (
                            [time_key]
                           ,[Hour 24]
                           ,[Hour 24 Short]
                           ,[Hour 24 Medium]
                           ,[Hour 24 Full]
                           ,[Hour 12]
                           ,[Hour 12 Short]
                           ,[Hour 12 Short Trim]
                           ,[Hour 12 Medium]
                           ,[Hour 12 Medium Trim]
                           ,[Hour 12 Full]
                           ,[Hour 12 Full Trim]
                           ,[AM PM Code]
                           ,[AM PM]
                           ,Minute
                           ,[Minute Of Day]
                           ,[Minute Code]
                           ,[Minute Short]
                           ,[Minute 24 Full]
                           ,[Minute 12 Full]
                           ,[Minute 12 Full Trim]
                           ,[Half Hour Code]
                           ,[Half Hour]
                           ,[Half Hour Short]
                           ,[Half Hour 24 Full]
                           ,[Half Hour 12 Full]
                           ,[Half Hour 12 Full Trim]
                           ,Second
                           ,[Second Of Day]
                           ,[Second Short]
                           ,[Full Time 24]
                           ,[Full Time 12]
                           ,[Full Time 12 Trim]
                           ,[Full Time]
                        )
                        VALUES
                             ((@Hour * 10000) + (@Minute * 100) + @Second                                                                                                                                                      /* time_key */
                             ,@Hour                                                                                                                                                                                            /* Hour 24 */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), @Hour), 2)                                                                                                                                                       /* Hour 24 Short */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), @Hour), 2) + ':00'                                                                                                                                               /* Hour 24 Medium */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), @Hour), 2) + ':00:00'                                                                                                                                            /* Hour 24 Full */
                             ,IIF(@Hour % 12 = 0, 12, @Hour % 12)                                                                                                                                                              /* Hour 12 */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), IIF(@Hour % 12 = 0, 12, @Hour % 12)), 2) + ' ' + @AmPm                                                                                                           /* Hour 12 Short */
                             ,CONVERT(VARCHAR(2), IIF(@Hour % 12 = 0, 12, @Hour % 12)) + ' ' + @AmPm                                                                                                                           /* Hour 12 Short Trim */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), IIF(@Hour % 12 = 0, 12, @Hour % 12)), 2) + ':00 ' + @AmPm                                                                                                        /* Hour 12 Medium */
                             ,CONVERT(VARCHAR(2), IIF(@Hour % 12 = 0, 12, @Hour % 12)) + ':00 ' + @AmPm                                                                                                                        /* Hour 12 Medium Trim */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), IIF(@Hour % 12 = 0, 12, @Hour % 12)), 2) + ':00:00 ' + @AmPm                                                                                                     /* Hour 12 Full */
                             ,CONVERT(VARCHAR(2), IIF(@Hour % 12 = 0, 12, @Hour % 12)) + ':00:00 ' + @AmPm                                                                                                                     /* Hour 12 Full Trim */
                             ,@Hour / 12                                                                                                                                                                                       /* AM PM Code */
                             ,@AmPm                                                                                                                                                                                            /* AM PM */
                             ,@Minute                                                                                                                                                                                          /* Minute */
                             ,@MinuteOfDay                                                                                                                                                                                     /* Minute Of Day */
                             ,(@Hour * 100) + (@Minute)                                                                                                                                                                        /* Minute Code */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), @Minute), 2)                                                                                                                                                     /* Minute Short */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), @Hour), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @Minute), 2) + ':00'                                                                                          /* Minute 24 Full */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), IIF(@Hour % 12 = 0, 12, @Hour % 12)), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @Minute), 2) + ':00 ' + @AmPm                                                   /* Minute 12 Full */
                             ,CONVERT(VARCHAR(2), IIF(@Hour % 12 = 0, 12, @Hour % 12)) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @Minute), 2) + ':00 ' + @AmPm                                                                   /* Minute 12 Full Trim */
                             ,(@Hour * 100) + ((@Minute / 30) * 30)                                                                                                                                                            /* Half Hour Code */
                             ,@Minute / 30                                                                                                                                                                                     /* Half Hour */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), ((@Minute / 30) * 30)), 2)                                                                                                                                       /* Half Hour Short */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), @Hour), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), ((@Minute / 30) * 30)), 2) + ':00'                                                                            /* Half Hour 24 Full */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), IIF(@Hour % 12 = 0, 12, @Hour % 12)), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), ((@Minute / 30) * 30)), 2) + ':00 ' + @AmPm                                     /* Half Hour 12 Full */
                             ,CONVERT(VARCHAR(2), IIF(@Hour % 12 = 0, 12, @Hour % 12)) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), ((@Minute / 30) * 30)), 2) + ':00 ' + @AmPm                                                     /* Half Hour 12 Full Trim*/
                             ,@Second                                                                                                                                                                                          /* Second */
                             ,@SecondOfDay                                                                                                                                                                                     /* Second Of Day */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), @Second), 2)                                                                                                                                                     /* Second Short */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), @Hour), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @Minute), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @Second), 2)                                             /* Full Time 24 */
                             ,RIGHT('0' + CONVERT(VARCHAR(2), IIF(@Hour % 12 = 0, 12, @Hour % 12)), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @Minute), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @Second), 2) + ' ' + @AmPm /* Full Time 12 */
                             ,CONVERT(VARCHAR(2), IIF(@Hour % 12 = 0, 12, @Hour % 12)) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @Minute), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @Second), 2) + ' ' + @AmPm                 /* Full Time 12 Trim*/
                             ,CONVERT(TIME, RIGHT('0' + CONVERT(VARCHAR(2), @Hour), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @Minute), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(2), @Second), 2))                              /* Full Time */
                            );
                        SET @Second = @Second + 1;
                        SET @SecondOfDay = @SecondOfDay + 1;
                    END;

                SET @Minute = @Minute + 1;
                SET @MinuteOfDay = @MinuteOfDay + 1;
            END;

        SET @Hour = @Hour + 1;
    END;

     END TRY

    BEGIN CATCH

		-- Log the error and raise it again
		EXEC [etl_audit].[p_LogAndRaiseSqlError] @jobLogKey = @jobLogKey;

    END CATCH

    -- Log the end of the Procedure Run, success or otherwise    
    EXEC [etl_audit].[p_UpdateJobLog_EndProcedure] @jobLogKey = @jobLogKey;

END