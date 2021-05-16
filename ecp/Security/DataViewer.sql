CREATE LOGIN [DataViewer] WITH PASSWORD = '$(DataViewerLoginPassword)';
GO

CREATE USER DataViewer FROM LOGIN [DataViewer];
GO

GRANT CONNECT TO DataViewer;
GO

GRANT EXECUTE ON SCHEMA::dm_dim TO DataViewer;
GO

GRANT EXECUTE ON SCHEMA::dm_fact TO DataViewer;
GO

GRANT SELECT ON SCHEMA::etl_config TO DataViewer;
GO

GRANT SELECT ON SCHEMA::etl_audit TO DataViewer;
GO