USE [TEST]
GO
/****** Object:  UserDefinedFunction [dbo].[_ChargeTree]    Script Date: 05/13/2006 16:05:29 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[_ChargeTree] (@CHARGE_ID INT)  
RETURNS @ListS TABLE (Charge_ID INT, NAME CHAR(40), Parent_ID INT, Charge_Level TINYINT, 
	KOD CHAR(10), NOTE VARCHAR(200))
AS  
BEGIN 
	DECLARE @LEVEL TINYINT
	IF @CHARGE_ID IS NULL OR @CHARGE_ID = 0
	BEGIN
		SET @LEVEL = 0
		INSERT INTO @ListS (Charge_ID, NAME, Parent_ID, Charge_Level, KOD, NOTE)
		SELECT Charge_ID, NAME, ISNULL(Parent_ID, 0), Charge_Level, KOD, NOTE
		FROM Charge WHERE Charge_Level = @LEVEL
	END
	ELSE
	BEGIN
		INSERT INTO @ListS (Charge_ID, NAME, Parent_ID, Charge_Level, KOD, NOTE) 
		SELECT Charge_ID, NAME, ISNULL(Parent_ID, 0), Charge_Level, 
			KOD, NOTE
		FROM Charge WHERE Charge_ID = @CHARGE_ID
		SELECT @LEVEL = Charge_Level FROM @ListS
	END
	WHILE @@ROWCOUNT > 0
	BEGIN
		SET @LEVEL = @LEVEL + 1
		INSERT INTO @ListS (Charge_ID, NAME, Parent_ID, Charge_Level, KOD, NOTE)
		SELECT p.Charge_ID, p.NAME, ISNULL(p.Parent_ID, 0), p.Charge_Level, p.KOD, p.NOTE
		FROM Charge p INNER JOIN @ListS t ON p.PArent_ID = t.Charge_ID 
			AND t.Charge_Level = @LEVEL - 1
	END
	RETURN
END
GO
GRANT  SELECT  ON [dbo].[_ChargeTree] TO [WORK_ROLE]
GO





