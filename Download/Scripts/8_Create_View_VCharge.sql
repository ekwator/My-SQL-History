SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VCharge]
AS
SELECT	Charge_ID, Name, ISNULL(Note, '') AS Note,
	ISNULL(KOD, 0) AS KOD, 
	Charge_Level, ISNULL(Parent_ID, 0) AS Parent_ID
FROM Charge
GO
GRANT  SELECT  ON [dbo].[VCharge] TO [WORK_ROLE]
GO
