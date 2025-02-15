USE [TEST]
GO
/****** Object:  Table [dbo].[Charge]    Script Date: 06/01/2006 23:34:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Charge](
	[Charge_ID] [PK_ID] IDENTITY(1,1) NOT NULL,
	[Charge_Level] [LEVEL] NULL,
	[Parent_ID] [PARENT_ID] NULL,
	[Name] [NAME] NULL,
	[KOD] [KOD] NULL,
	[Note] [NOTE] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Charge] WITH NOCHECK ADD 
	CONSTRAINT [PK_Charge] PRIMARY KEY  CLUSTERED 
	(
		[Charge_ID]
	)  ON [PRIMARY] 

GO
