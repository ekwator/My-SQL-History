use [TEST]
GO
CREATE TABLE [dbo].[Currency] (
	[Currency_ID] [PK_ID] IDENTITY (1, 1) NOT NULL ,
	[Kod] [KOD] NOT NULL ,
	[Name] [NAME] NOT NULL ,
	[Obos] [OBOS] NOT NULL ,
	[Note] [NOTE] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Curs] (
	[Curs_ID] [PK_ID] IDENTITY (1, 1) NOT NULL ,
	[Currency_ID] [PARENT_ID] NOT NULL ,
	[Data] [DATA] NOT NULL ,
	[Curs] [decimal](18, 4) NOT NULL ,
	[Koef] [decimal](8, 0) NOT NULL 
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[Menu] (
	[Menu_ID] [PK_ID] IDENTITY (1, 1) NOT NULL ,
	[Name] [NAME] NULL ,
	[PAD_Number] [KOD] NULL ,
	[POPUP_Name] [NAME] NULL ,
	[Form] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Moduls] (
	[Modul_ID] [PK_ID] IDENTITY (1, 1) NOT NULL ,
	[Name_File] [NAME] NULL ,
	[Note] [NOTE] NULL ,
	[Path] [NOTE] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Permission] (
	[User_ID] [PARENT_ID] NOT NULL ,
	[Menu_ID] [PARENT_ID] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Sessions] (
	[SESSION_ID] [int] IDENTITY (1, 1) NOT NULL ,
	[USER_ID] [int] NOT NULL ,
	[USER_N] [char] (40) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
	[SYS_USER] [char] (40) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
	[COMP_NAME] [char] (40) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
	[DAT_SESSION_ON] [datetime] NOT NULL ,
	[DAT_SESSION_OFF] [datetime] NULL ,
	[BAD] [tinyint] NOT NULL ,
	[PROC_ID] [int] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Users] (
	[Login] [char] (10) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
	[User_ID] [int] IDENTITY (1, 1) NOT NULL ,
	[FIO] [char] (40) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL ,
	[Password] [varbinary] (255) NULL ,
	[Note] [varchar] (200) COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Role] [char] (1) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Versions] (
	[Version_ID] [PK_ID] IDENTITY (1, 1) NOT NULL ,
	[Modul_ID] [PARENT_ID] NOT NULL ,
	[Dat] [DATA] NULL ,
	[N_Version] [KOD] NOT NULL ,
	[Active] [TAG] NOT NULL ,
	[Modul] [text] COLLATE SQL_Latin1_General_CP1251_CI_AS NULL ,
	[Size] [KOD] NULL ,
	[C_Version] [varchar] (50) COLLATE SQL_Latin1_General_CP1251_CI_AS NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Currency] WITH NOCHECK ADD 
	CONSTRAINT [PK_Currency] PRIMARY KEY  CLUSTERED 
	(
		[Currency_ID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[Curs] WITH NOCHECK ADD 
	CONSTRAINT [PK_Curs] PRIMARY KEY  CLUSTERED 
	(
		[Curs_ID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[Menu] WITH NOCHECK ADD 
	CONSTRAINT [XPKMenu] PRIMARY KEY  CLUSTERED 
	(
		[Menu_ID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[Moduls] WITH NOCHECK ADD 
	CONSTRAINT [PK_Moduls] PRIMARY KEY  CLUSTERED 
	(
		[Modul_ID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[Sessions] WITH NOCHECK ADD 
	CONSTRAINT [PK_Sessions] PRIMARY KEY  CLUSTERED 
	(
		[SESSION_ID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[Users] WITH NOCHECK ADD 
	CONSTRAINT [PK_Users] PRIMARY KEY  CLUSTERED 
	(
		[User_ID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[Versions] WITH NOCHECK ADD 
	CONSTRAINT [PK_Versions] PRIMARY KEY  CLUSTERED 
	(
		[Version_ID]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[Curs] ADD 
	CONSTRAINT [DF_Curs_Koef] DEFAULT (1) FOR [Koef]
GO

 CREATE  INDEX [IX_CURRENCY] ON [dbo].[Curs]([Currency_ID]) ON [PRIMARY]
GO

 CREATE  INDEX [XIF1Permitions] ON [dbo].[Permission]([User_ID]) ON [PRIMARY]
GO

 CREATE  INDEX [XIF2Permitions] ON [dbo].[Permission]([Menu_ID]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Sessions] ADD 
	CONSTRAINT [DF_SESSIONS_DAT_SESSION_ON] DEFAULT (getdate()) FOR [DAT_SESSION_ON],
	CONSTRAINT [DF_SESSIONS_BAD] DEFAULT (0) FOR [BAD]
GO

ALTER TABLE [dbo].[Versions] ADD 
	CONSTRAINT [DF_Versions_N_Version] DEFAULT (1) FOR [N_Version]
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[Empty_String]', N'[Currency].[Name]'
GO

EXEC sp_bindefault N'[dbo].[Empty_String]', N'[Currency].[Note]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[Empty_String]', N'[Menu].[Name]'
GO

EXEC sp_bindefault N'[dbo].[Empty_String]', N'[Menu].[POPUP_Name]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[Empty_String]', N'[Moduls].[Name_File]'
GO

EXEC sp_bindefault N'[dbo].[Empty_String]', N'[Moduls].[Note]'
GO

EXEC sp_bindefault N'[dbo].[Empty_String]', N'[Moduls].[Path]'
GO

setuser
GO

setuser
GO

EXEC sp_bindefault N'[dbo].[Empty_String]', N'[Versions].[Active]'
GO

EXEC sp_bindefault N'[dbo].[Empty_String]', N'[Versions].[C_Version]'
GO

EXEC sp_bindefault N'[dbo].[Empy_Number]', N'[Versions].[Size]'
GO

setuser
GO

GRANT  REFERENCES ,  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[Moduls]  TO [WORK_ROLE]
GO

GRANT  REFERENCES ,  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[Versions]  TO [WORK_ROLE]
GO

GRANT  REFERENCES ,  SELECT ,  UPDATE ,  INSERT ,  DELETE  ON [dbo].[Versions]  TO [LoginForAll]
GO

ALTER TABLE [dbo].[Curs] ADD 
	CONSTRAINT [FK_Curs_Currency] FOREIGN KEY 
	(
		[Currency_ID]
	) REFERENCES [dbo].[Currency] (
		[Currency_ID]
	)
GO

ALTER TABLE [dbo].[Permission] ADD 
	CONSTRAINT [R_26] FOREIGN KEY 
	(
		[User_ID]
	) REFERENCES [dbo].[Users] (
		[User_ID]
	) ON DELETE CASCADE ,
	CONSTRAINT [R_27] FOREIGN KEY 
	(
		[Menu_ID]
	) REFERENCES [dbo].[Menu] (
		[Menu_ID]
	) ON DELETE CASCADE 
GO
ALTER TABLE [dbo].[Versions] ADD 
	CONSTRAINT [FK_Versions_Moduls] FOREIGN KEY 
	(
		[Modul_ID]
	) REFERENCES [dbo].[Moduls] (
		[Modul_ID]
	)
GO
CREATE VIEW dbo.VUsers
AS
SELECT	User_ID, FIO, Password, Role, Login, ISNULL(Note, '') AS Note
FROM	dbo.Users
GO
GRANT  SELECT  ON [dbo].[VUsers]  TO [WORK_ROLE]

