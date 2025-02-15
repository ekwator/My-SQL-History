if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Curs_GetList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Curs_GetList]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Curs_GetList
	@CURRENCY_ID INT = NULL,
	@DATA DATETIME = NULL
/*
Получаем список курсов для выбранной валюты @CURRENCY_ID
Автор: Климов А.П.
Вызывается из:
CURRENCY_MAIN
Если передана валюта и не передана @CURRENCY_ID
то возвращаем список курсов всех валют на выбранную дату
Если не передана и дата, то выбираем текущую дату
*/
AS
IF @CURRENCY_ID IS NOT NULL
	SELECT Curs_ID, Curs, Data, Koef
		FROM Curs
	WHERE Currency_ID = @CURRENCY_ID
	ORDER BY Data DESC
ELSE
BEGIN
	IF @DATA IS NULL
		SET @DATA = GETDATE()
	-- Читаем список курсов всех валют на дату @DATA
	SELECT Currency.Currency_ID, Currency.Kod, Currency.Name, Currency.Obos
		, Curs.Curs_ID, Curs.Curs, Curs.Data, Curs.Koef
	FROM Curs INNER JOIN Currency ON Currency.Currency_ID = Curs.Currency_ID
	WHERE Curs.Data = (SELECT MAX(c.Data) FROM Curs c WHERE c.Currency_ID = Curs.Currency_ID AND c.Data <= @DATA)
	ORDER BY Currency.Kod, Curs.Data
END
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Curs_GetList]  TO [WORK_ROLE]
GO

