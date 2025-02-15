set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EdIzm_GetList]
	@EdIzm_ID INT = NULL
-- Чтения содержимого справочника единицы измерения
AS
DECLARE @LEVEL TINYINT
IF @EdIzm_ID IS NULL
	-- Читаем список всего справочника
	SELECT * FROM _v_EdIzm
		ORDER BY [Level], Name
ELSE	-- Читаем только подчиненные виды затрат
	SELECT * FROM dbo._EdIzmTree(@EdIzm_ID)
		ORDER BY [Level], Name
RETURN (0)
GO
GRANT  EXECUTE  ON [dbo].[EdIzm_GetList] TO [WORK_ROLE]
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EdIzm_Move]
	@SRC_ID INT = NULL,
	@DST_ID INT = NULL

-- Перенос единицы измерения с ID = @SRC_ID в подчинение @DST_ID
AS
IF (@SRC_ID IS NULL) OR (@DST_ID IS NULL) 
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-2)
END
IF @DST_ID IN (SELECT ID FROM dbo._EdIzmTree(@SRC_ID))
BEGIN
	RAISERROR('Нельзя перемещать ветку в себя!', 16,1)
	RETURN (-2)
END

DECLARE @LEVEL_SHIFT SMALLINT,
	@LEV1 SMALLINT,
	@LEV2 SMALLINT

-- Определяем смещение уровней у единиц измерения
SET @LEV1 = (SELECT [Level] FROM _s_EdIzm WHERE id = @DST_ID)
SET @LEV2 = (SELECT [Level] FROM _s_EdIzm WHERE id = @SRC_ID)
SET @LEVEL_SHIFT = @LEV1 - @LEV2 + 1

BEGIN TRANSACTION
UPDATE _s_EdIzm SET [Level] = [Level] + @LEVEL_SHIFT
	WHERE id IN (SELECT id FROM dbo._EdIzmTree(@SRC_ID))
IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RAISERROR('Не могу обновить поле Level в таблице _s_EdIzm!', 16, 1)
	RETURN (-1)
END
UPDATE _s_EdIzm SET id_Parent = @DST_ID WHERE id = @SRC_ID
IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RAISERROR('Не могу обновить поле id_Parent в таблице _s_EdIzm!', 16, 1)
	RETURN (-1)
END
SELECT * FROM dbo._ChargeTree(@SRC_ID) ORDER BY [Level]
COMMIT TRANSACTION
RETURN (0)
GO
GRANT  EXECUTE  ON [dbo].[EdIzm_Move] TO [WORK_ROLE]
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EdIzm_Update]
	@EdIzm_ID CHAR(15) = NULL,
	@NAME CHAR(25) = NULL, 
	@ID_PARENT CHAR(15) = NULL,
	@KODOKEI CHAR(15) = ""
-- Обновление единицы измерения
AS
IF (@EdIzm_ID IS NULL) OR (@NAME IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
DECLARE @LEVEL TINYINT

IF NULLIF(@ID_PARENT, 0) <> 0	-- Подчиненная единица измерения
	SET @LEVEL = (SELECT [Level] FROM _s_EdIzm WHERE id = @ID_PARENT) + 1
ELSE				-- Главная единица измерения
	SET @LEVEL = 0

UPDATE _s_EdIzm SET Name = @NAME, KODOKEI = @KODOKEI,
	id_Parent = NULLIF(@ID_PARENT, ""), [Level] = @LEVEL
WHERE id = @EdIzm_ID
IF @@ERROR <> 0
BEGIN
	RAISERROR('Не могу обновить запись в таблице _s_EdIzm для id=%d!', 16,1, @EdIzm_ID)
	RETURN (-1)
END
RETURN (0)
GO
GRANT  EXECUTE  ON [dbo].[EdIzm_Update] TO [WORK_ROLE]
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EdIzm_AddNew]
	@NEW_ID	CHAR(15) = NULL,
	@NAME CHAR(25) = NULL,
	@PARENT_ID CHAR(15) = NULL,
	@KODOKEI CHAR(3) = ""
AS
-- Добавляем новую единицу измерения
IF (@NEW_ID IS NULL) OR (@NAME IS NULL)
BEGIN
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
DECLARE @LEVEL TINYINT

IF NULLIF(@ID_PARENT, 0) <> 0	-- Подчиненная единица измерения
	SET @LEVEL = (SELECT [Level] FROM _s_EdIzm WHERE id = @ID_PARENT) + 1
Else
	SET @LEVEL = 0		-- Главная единица измерения
INSERT INTO _s_EdIzm (id, Name, [Level], id_Parent, KODOKEI) VALUES
	(@NEW_ID, @NAME, @LEVEL, NULLIF(@ID_PARENT, 0), @KODOKEI)
IF @@ERROR <> 0
BEGIN
	RAISERROR('Не могу добавить новую еденицу измерения!', 16,1)
	RETURN (-3)
END
SELECT * FROM _V_EdIzm WHERE id = @NEW_ID
RETURN (0)
GO
GRANT  EXECUTE  ON [dbo].[EdIzm_AddNew] TO [WORK_ROLE]
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EdIzm_Copy]
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
