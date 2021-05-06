CREATE TABLE [fact].[ProductPrices] (
    [product_key]   BIGINT        NOT NULL,
    [product_price] FLOAT (53)    NOT NULL,
    [from_datetime] DATETIME2 (7) NOT NULL,
    [to_datetime]   DATETIME2 (7) NULL,
    [IsActive]      BIT           NOT NULL,
    [ChangeHash]    BINARY (64)   NOT NULL,
    [CreatedJobKey] INT           NOT NULL,
    [UpdatedJobKey] INT           NOT NULL,
    CONSTRAINT [FK_ProductPrices_product_key] FOREIGN KEY ([product_key]) REFERENCES [dim].[Product] ([product_key])
);


