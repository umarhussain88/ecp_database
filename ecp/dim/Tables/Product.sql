CREATE TABLE [dim].[Product] (
    [product_key]             BIGINT  NOT NULL IDENTITY(1,1)
,   [product_id]              VARCHAR (50)   NOT NULL
,   [product_name]            VARCHAR (255)  NULL
,   [product_listing]         VARCHAR (255)  NULL
,   [product_brand_long]           VARCHAR (75)   NULL
,   [product_brand_short]           VARCHAR (75)   NULL
,   [product_category]        VARCHAR (75)   NULL
,   [product_img_src]         VARCHAR (255)  NULL

,	[IsActive]						bit             NOT NULL
,	[ChangeHash]					binary(64)		NOT NULL
,	[CreatedJobKey]					int             NOT NULL
,	[UpdatedJobKey]					int             NOT NULL

,	CONSTRAINT [product_key] PRIMARY KEY CLUSTERED ([product_key] ASC)
);

