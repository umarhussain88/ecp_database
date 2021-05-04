CREATE TABLE [fact].[ProductPrices] 
(	[product_key]       bigint          NOT NULL
,	[product_price]		FLOAT (53)      NOT NULL
,	[date_key]			INT		NOT NULL
,   [time_key]          INT        NOT NULL 

,	[IsActive]          bit             NOT NULL
,	[ChangeHash]        binary (64)     NOT NULL
,	[CreatedJobKey]     int             NOT NULL
,	[UpdatedJobKey]     int             NOT NULL

,   CONSTRAINT [FK_ProductPrices_product_key] FOREIGN KEY ([product_key]) REFERENCES [dim].[Product] ([product_key])
,   CONSTRAINT [FK_ProductPrices_date_key]    FOREIGN KEY ([date_key])    REFERENCES [dim].[Calendar] ([DateKey])
,   CONSTRAINT [FK_ProductPrices_time_key]    FOREIGN KEY ([time_key])    REFERENCES [dim].[Time] ([time_key])

)
