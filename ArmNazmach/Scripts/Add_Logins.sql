USE Master
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

USE vvk_my
if not exists (select * from dbo.sysusers where name = N'AppAdmin' and uid < 16382)
Begin
	EXEC sp_grantdbaccess N'AppAdmin', N'AppAdmin'
	exec sp_addrolemember N'db_owner', N'AppAdmin'
End
if not exists (select * from dbo.sysusers where name = N'LoginForAll' and uid < 16382)
	EXEC sp_grantdbaccess N'LoginForAll', N'LoginForAll'
GO

if not exists (select * from dbo.sysusers where name = N'WORK_ROLE' and uid < 16382)
BEGIN
	exec sp_addapprole N'WORK_ROLE', N'adf12WW'
END
GO
