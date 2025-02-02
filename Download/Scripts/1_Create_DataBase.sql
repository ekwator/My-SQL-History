USE Master
GO
CREATE DATABASE [TEST]  ON (NAME = N'TEST_Data', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL\data\TEST_Data.MDF' , 
	SIZE = 2, FILEGROWTH = 10%) 
	LOG ON (NAME = N'TEST_Log', 
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL\data\TEST_Log.LDF' , 
	SIZE = 1, FILEGROWTH = 10%)
 COLLATE SQL_Latin1_General_CP1251_CI_AS
GO
exec sp_dboption N'TEST', N'autoclose', N'false'
GO
exec sp_dboption N'TEST', N'bulkcopy', N'false'
GO
exec sp_dboption N'TEST', N'trunc. log', N'false'
GO
exec sp_dboption N'TEST', N'torn page detection', N'true'
GO
exec sp_dboption N'TEST', N'read only', N'false'
GO
exec sp_dboption N'TEST', N'dbo use', N'false'
GO
exec sp_dboption N'TEST', N'single', N'false'
GO
exec sp_dboption N'TEST', N'autoshrink', N'false'
GO
exec sp_dboption N'TEST', N'ANSI null default', N'false'
GO
exec sp_dboption N'TEST', N'recursive triggers', N'false'
GO
exec sp_dboption N'TEST', N'ANSI nulls', N'false'
GO
exec sp_dboption N'TEST', N'concat null yields null', N'false'
GO
exec sp_dboption N'TEST', N'cursor close on commit', N'false'
GO
exec sp_dboption N'TEST', N'default to local cursor', N'false'
GO
exec sp_dboption N'TEST', N'quoted identifier', N'false'
GO
exec sp_dboption N'TEST', N'ANSI warnings', N'false'
GO
exec sp_dboption N'TEST', N'auto create statistics', N'true'
GO
exec sp_dboption N'TEST', N'auto update statistics', N'true'
GO
if( (@@microsoftversion / power(2, 24) = 8) and (@@microsoftversion & 0xffff >= 724) )
	exec sp_dboption N'TEST', N'db chaining', N'false'
GO
if not exists (select * from master.dbo.syslogins where loginname = N'LoginForAll')
BEGIN
	declare @logindb nvarchar(132), @loginlang nvarchar(132) select @logindb = N'master', @loginlang = N'us_english'
	if @logindb is null or not exists (select * from master.dbo.sysdatabases where name = @logindb)
		select @logindb = N'master'
	if @loginlang is null or (not exists (select * from master.dbo.syslanguages where name = @loginlang) and @loginlang <> N'us_english')
		select @loginlang = @@language
	exec sp_addlogin N'LoginForAll', '123', @logindb, @loginlang
END
GO
if not exists (select * from master.dbo.syslogins where loginname = N'AppAdmin')
BEGIN
	declare @logindb nvarchar(132), @loginlang nvarchar(132) select @logindb = N'master', @loginlang = N'us_english'
	if @logindb is null or not exists (select * from master.dbo.sysdatabases where name = @logindb)
		select @logindb = N'master'
	if @loginlang is null or (not exists (select * from master.dbo.syslanguages where name = @loginlang) and @loginlang <> N'us_english')
		select @loginlang = @@language
	exec sp_addlogin N'AppAdmin', '111222333', @logindb, @loginlang
END
GO

USE Test
if not exists (select * from dbo.sysusers where name = N'AppAdmin' and uid < 16382)
	EXEC sp_grantdbaccess N'AppAdmin', N'AppAdmin'
if not exists (select * from dbo.sysusers where name = N'LoginForAll' and uid < 16382)
	EXEC sp_grantdbaccess N'LoginForAll', N'LoginForAll'
GO
exec sp_addrolemember N'db_owner', N'AppAdmin'
GO
USE Test
exec sp_addapprole N'WORK_ROLE', N'b22222222'
