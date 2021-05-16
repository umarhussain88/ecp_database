CREATE TABLE [dim].[Product] (
    [product_key]         BIGINT        IDENTITY (1, 1) NOT NULL,
    [product_id]          VARCHAR (50)  NOT NULL,
    [product_name]        VARCHAR (255) NULL,
    [product_listing]     VARCHAR (255) NULL,
    [product_brand_long]  VARCHAR (75)  NULL,
    [product_category]    VARCHAR (75)  NULL,
    [product_img_src]     VARCHAR (255) NULL,
    [IsActive]            BIT           NOT NULL,
    [ChangeHash]          BINARY (64)   NOT NULL,
    [CreatedJobKey]       INT           NOT NULL,
    [UpdatedJobKey]       INT           NOT NULL,
    [product_brand_short] VARCHAR (75)  NULL,
    [product_url]         VARCHAR (255) NULL,
    CONSTRAINT [product_key] PRIMARY KEY CLUSTERED ([product_key] ASC)
);





