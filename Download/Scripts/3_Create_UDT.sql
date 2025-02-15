USE [Test]
GO
EXEC sp_addtype N'ADDRESS', N'varchar (250)', N'null'
GO
EXEC sp_addtype N'DATA', N'datetime', N'null'
GO
EXEC sp_addtype N'FIO', N'varchar (40)', N'null'
GO
EXEC sp_addtype N'KOD', N'numeric(10,0)', N'null'
GO
EXEC sp_addtype N'LEVEL', N'tinyint', N'not null'
GO
EXEC sp_bindefault N'[dbo].[Empy_Number]', N'[LEVEL]'
GO
EXEC sp_addtype N'LOGICAL', N'tinyint', N'null'
GO
EXEC sp_addtype N'NAME', N'varchar (40)', N'null'
GO
EXEC sp_bindefault N'[dbo].[Empty_String]', N'[NAME]'
GO
EXEC sp_addtype N'NDOK', N'varchar (20)', N'null'
GO
EXEC sp_addtype N'NOTE', N'varchar (200)', N'null'
GO
EXEC sp_bindefault N'[dbo].[Empty_String]', N'[NOTE]'
GO
EXEC sp_addtype N'OBOS', N'char (10)', N'null'
GO
EXEC sp_addtype N'PARENT_ID', N'int', N'null'
GO
EXEC sp_addtype N'PASSWORD', N'varbinary (255)', N'null'
GO
EXEC sp_addtype N'PHONE', N'varchar (20)', N'null'
GO
EXEC sp_addtype N'PK_ID', N'int', N'not null'
GO
EXEC sp_addtype N'POSTAL_KOD', N'char (6)', N'null'
GO
EXEC sp_addtype N'QUANTITY', N'numeric(18,3)', N'null'
GO
EXEC sp_bindefault N'[dbo].[Empy_Number]', N'[QUANTITY]'
GO
EXEC sp_addtype N'SUM', N'numeric(18,2)', N'null'
GO
EXEC sp_bindefault N'[dbo].[Empy_Number]', N'[SUM]'
GO
EXEC sp_addtype N'SUMPRICE', N'decimal(18,4)', N'not null'
GO
EXEC sp_bindefault N'[dbo].[Empy_Number]', N'[SUMPRICE]'
GO
EXEC sp_addtype N'TAG', N'char (1)', N'null'
GO
EXEC sp_addtype N'YEAR', N'smallint', N'not null'
GO
