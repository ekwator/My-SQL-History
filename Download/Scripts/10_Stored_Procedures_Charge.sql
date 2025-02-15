set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Charge_Delete]
	@CHARGE_ID INT = NULL
AS
-- Удаление вида затрат
IF @CHARGE_ID IS NULL
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
-- Проверка, что нет записей подчиненных
IF EXISTS(SELECT * FROM Charge WHERE Parent_ID = @CHARGE_ID)
BEGIN
	RAISERROR('У данного вида затрат Charge_ID=%d есть подчиненные - удалять нельзя!', 16, 1, @CHARGE_ID)
	RETURN (-2)
END
-- Удаление записей на сервере в таблице Satraty
DELETE FROM Charge WHERE Charge_ID = @CHARGE_ID
IF @@ERROR <> 0
BEGIN
	RAISERROR('Ошибка удаления из таблицы Charge для Charge_ID=%d!', 16, 1, @CHARGE_ID)
	RETURN (-1)
END
RETURN (0)
GO
GRANT  EXECUTE  ON [dbo].[Charge_Delete] TO [WORK_ROLE]
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Charge_GetList]
	@CHARGE_ID INT = NULL
-- Чтения содержимого справочника видов затрат
AS
DECLARE @LEVEL TINYINT
IF @CHARGE_ID IS NULL
	-- Читаем список всего справочника видов затрат
	SELECT * FROM VCharge
		ORDER BY Charge_Level, Name
ELSE	-- Читаем только подчиненные виды затрат
	SELECT * FROM dbo._ChargeTree(@CHARGE_ID)
		ORDER BY Charge_Level, Name
RETURN (0)
GO
GRANT  EXECUTE  ON [dbo].[Charge_GetList] TO [WORK_ROLE]
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Charge_Move]
	@SRC_ID INT = NULL,
	@DST_ID INT = NULL

-- Перенос вида затрат с Charge_ID = @SRC_ID в подчинение @DST_ID
AS
IF (@SRC_ID IS NULL) OR (@DST_ID IS NULL) 
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-2)
END
IF @DST_ID IN (SELECT Charge_ID FROM dbo._ChargeTree(@SRC_ID))
BEGIN
	RAISERROR('Нельзя перемещать ветку статей в себя!', 16,1)
	RETURN (-2)
END

DECLARE @LEVEL_SHIFT SMALLINT,
	@LEV1 SMALLINT,
	@LEV2 SMALLINT

-- Определяем смещение уровней у видов затрат
SET @LEV1 = (SELECT Charge_Level FROM Charge WHERE Charge_ID = @DST_ID)
SET @LEV2 = (SELECT Charge_Level FROM Charge WHERE Charge_ID = @SRC_ID)
SET @LEVEL_SHIFT = @LEV1 - @LEV2 + 1

BEGIN TRANSACTION
UPDATE Charge SET Charge_Level = Charge_Level + @LEVEL_SHIFT
	WHERE Charge_ID IN (SELECT Charge_ID FROM dbo._ChargeTree(@SRC_ID))
IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RAISERROR('Не могу обновить поле Charge_Level в таблице Charge!', 16, 1)
	RETURN (-1)
END
UPDATE Charge SET Parent_ID = @DST_ID WHERE Charge_ID = @SRC_ID
IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RAISERROR('Не могу обновить поле Parent_ID в таблице Charge!', 16, 1)
	RETURN (-1)
END
SELECT * FROM dbo._ChargeTree(@SRC_ID) ORDER BY Charge_Level
COMMIT TRANSACTION
RETURN (0)
GO
GRANT  EXECUTE  ON [dbo].[Charge_Move] TO [WORK_ROLE]
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Charge_Update]
	@CHARGE_ID INT = NULL,
	@NAME CHAR(40) = NULL, 
	@NOTE VARCHAR(200) = '',
	@PARENT_ID INT = NULL,
	@KOD INT = 0
-- Обновление статьи затрат
AS
IF (@CHARGE_ID IS NULL) OR (@NAME IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
DECLARE @LEVEL TINYINT

IF NULLIF(@PARENT_ID, 0) <> 0	-- Подчиненная статья затрат
	SET @LEVEL = (SELECT Charge_Level FROM Charge WHERE Charge_ID = @PARENT_ID) + 1
ELSE				-- Главная статья затрат
	SET @LEVEL = 0

UPDATE Charge SET Name = @NAME, KOD = @KOD,
	Note = @NOTE, Parent_ID = NULLIF(@PARENT_ID, 0), Charge_Level = @LEVEL
WHERE Charge_ID = @CHARGE_ID
IF @@ERROR <> 0
BEGIN
	RAISERROR('Не могу обновить запись в таблице Charge для Charge_ID=%d!', 16,1, @CHARGE_ID)
	RETURN (-1)
END
RETURN (0)
GO
GRANT  EXECUTE  ON [dbo].[Charge_Update] TO [WORK_ROLE]
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Charge_AddNew]
	@NAME CHAR(40) = NULL,
	@NOTE VARCHAR(200) = '',
	@PARENT_ID INT = NULL,
	@KOD INT = 0
AS
-- Добавляем новый вид затрат
IF (@NAME IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
DECLARE @NEW_ID INT,
	@LEVEL TINYINT

IF NULLIF(@PARENT_ID, 0) <> 0	-- Подчиненный вид затрат
	SET @LEVEL = (SELECT Charge_Level FROM Charge WHERE Charge_ID = @PARENT_ID) + 1
ELSE
	SET @LEVEL = 0		-- Главный вид затрат
INSERT INTO Charge (Name, Note, Charge_Level, Parent_ID, KOD) VALUES
	(@NAME, @NOTE, @LEVEL, NULLIF(@PARENT_ID, 0), @KOD)
IF @@ERROR <> 0
BEGIN
	RAISERROR('Не могу добавить новый вид затрат!', 16,1)
	RETURN (-3)
ENDSET @NEW_ID = SCOPE_IDENTITY()
SELECT * FROM VCharge WHERE Charge_ID = @NEW_ID
RETURN (0)
GO
GRANT  EXECUTE  ON [dbo].[Charge_AddNew] TO [WORK_ROLE]
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Charge_Copy]
	@SRC_ID INT = NULL,
	@DST_ID INT = NULL
-- Копирование видов затрат с Charge_ID = @SRC_ID в подчинение с Charge_ID = @DST_ID
AS
IF (@SRC_ID IS NULL) OR (@DST_ID IS NULL) 
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
DECLARE @LEVEL_SHIFT INT,
	@LEV1 INT,
	@LEV2 INT,
	@NEW_ID INT,
	@OLD_ID INT,
	@STACK_COUNT INT,
	@ID INT,
	@ID_CURRENT INT,
	@ID_MAIN INT,
	@LEVEL INT

-- Определяем смещение уровней у вида затрат
SET @LEV1 = (SELECT Charge_Level FROM Charge WHERE Charge_ID = @DST_ID)
SET @LEV2 = (SELECT Charge_Level FROM Charge WHERE Charge_ID = @SRC_ID)
SET @LEVEL_SHIFT = @LEV1 - @LEV2 + 1

-- Временная таблица для имитации структуры стэка
CREATE TABLE #STACK (ID INT, ID_NEW INT, Level INT)

-- Список всех копируемых выдов затрат 
CREATE TABLE #LIST (Charge_ID INT, NAME CHAR(40), Parent_ID INT, Charge_Level TINYINT, 
	KOD CHAR(10), NOTE VARCHAR(200))
INSERT INTO #LIST (Charge_ID, NAME, Parent_ID, Charge_Level, KOD, NOTE)
SELECT Charge_ID, NAME, Parent_ID, Charge_Level, KOD, NOTE
FROM dbo._ChargeTree(@SRC_ID)

BEGIN TRANSACTION
-- Добавляем корневой вид затрат (Charge_ID = @SRC_ID)
INSERT INTO Charge (NAME, Parent_ID, Charge_Level, KOD, NOTE)
SELECT NAME, @DST_ID, Charge_Level + @LEVEL_SHIFT, KOD, NOTE
FROM #LIST WHERE Charge_ID = @SRC_ID
IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RAISERROR('Не могу добавить запись в таблицу Charge!', 16,1)
	RETURN (-1)
END
SET @ID_MAIN = SCOPE_IDENTITY()
-- Инициируем стэк
INSERT INTO #STACK (ID, ID_NEW, Level)
	VALUES (@SRC_ID, @ID_MAIN, 1)
SET @STACK_COUNT = 1
WHILE (@STACK_COUNT > 0)
BEGIN
	-- Извлекаем из стэка самую последнюю запись (MAX Level) с удалением ее из стэка
	SET @LEVEL = (SELECT MAX(Level) FROM #STACK)
	SELECT @OLD_ID = ID, @NEW_ID = ID_NEW FROM #STACK WHERE Level = @LEVEL
	DELETE FROM #STACK WHERE Level = @LEVEL
	SET @STACK_COUNT = @STACK_COUNT - 1

	-- Создаем список ветки с Parent_ID = @OLD_ID
	DECLARE List CURSOR FORWARD_ONLY LOCAL STATIC FOR
		SELECT Charge_ID FROM #LIST WHERE Parent_ID = @OLD_ID
	OPEN List
	FETCH NEXT FROM List INTO @ID_CURRENT
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Записываем в Charge записи с новым значением Parent_ID = @NEW_ID и Charge_Level
		INSERT INTO Charge (NAME, Parent_ID, Charge_Level, KOD, NOTE)
		SELECT NAME, @NEW_ID, Charge_Level + @LEVEL_SHIFT, KOD, NOTE
		FROM #LIST WHERE Charge_ID = @ID_CURRENT
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK TRANSACTION
			RAISERROR('Не могу добавить запись в таблицу Satraty!', 16,1)
			RETURN (-1)
		END
		SET @ID = SCOPE_IDENTITY()
		-- Каждую новую запись помещаем в стэк 
		SET @STACK_COUNT = @STACK_COUNT + 1
		INSERT INTO #STACK (ID, ID_NEW, Level)
			VALUES (@ID_CURRENT, @ID, @STACK_COUNT)
		FETCH NEXT FROM List INTO @ID_CURRENT
	END
	CLOSE List
	DEALLOCATE List
END
COMMIT TRANSACTION
SELECT * FROM VCharge WHERE Charge_ID IN (SELECT Charge_ID FROM dbo._ChargeTree(@ID_MAIN))
ORDER BY Charge_Level, Name
RETURN (0)
GO
GRANT  EXECUTE  ON [dbo].[Charge_Copy] TO [WORK_ROLE]
GO
