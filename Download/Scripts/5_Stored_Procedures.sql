if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AddModul]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AddModul]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AddUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AddUser]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ChangePassword]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ChangePassword]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_DelCloseSession]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_DelCloseSession]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_DelModul]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_DelModul]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_DelUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_DelUser]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_DelVersion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_DelVersion]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_EdModul]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_EdModul]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_EditUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_EditUser]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetListSessions]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetListSessions]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetUserMenu]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetUserMenu]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetUsers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetUsers]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Session_OFF]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Session_OFF]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_Session_ON]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_Session_ON]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_SetActiveVersion]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_SetActiveVersion]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_TestPassword]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_TestPassword]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UpdatePermission]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdatePermission]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Currency_AddNew]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Currency_AddNew]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Currency_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Currency_Delete]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Currency_Edit]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Currency_Edit]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Currency_GetList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Currency_GetList]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Curs_AddNew]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Curs_AddNew]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Curs_Delete]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Curs_Delete]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Curs_Edit]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Curs_Edit]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Curs_GetList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Curs_GetList]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE  PROCEDURE dbo.Admin_AddModul
	@ModulName CHAR(30) = NULL,
	@Path VARCHAR(100) = NULL,
	@Note VARCHAR(200) = NULL
-- Добавлени нового модуля на сервер
AS
IF (@ModulName IS NULL) OR (@Path IS NULL) OR (@Note IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-2)
END
-- Проверка существования модуля
IF EXISTS(SELECT * FROM Moduls WHERE UPPER(Name_File) = UPPER(@ModulName))
BEGIN
	RAISERROR('Данный мордуль уже есть!', 16,1)
	RETURN (-2)
END
INSERT INTO Moduls (Name_File, Path, Note) VALUES 
	(@ModulName, @Path, @Note)
IF @@ERROR <> 0
BEGIN
	RAISERROR('Не могу добавить новый модуль в таблицу MODULS!', 16,1)
	RETURN (-1)
END
SELECT * FROM Moduls WHERE Modul_ID = @@IDENTITY
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_AddModul]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Admin_AddUser 
	@NewUserName CHAR(30) = NULL,
	@Login_Name CHAR(10) = NULL,
	@Login_Pass SYSNAME = '',
	@NOTE VARCHAR(200) = '',
	@ROLE CHAR(1) = 'W'
--WITH ENCRYPTION
AS
IF (@NewUserName IS NULL)  OR  (@Login_Name IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
IF EXISTS(SELECT * FROM Users WHERE Login = @Login_Name)
BEGIN
	RAISERROR ('Данный LOGON=%s уже используется!',  16, 1, @Login_Name)
	RETURN (-3)
END

SELECT @Login_Pass = pwdencrypt(@Login_Pass)
INSERT INTO USERS (FIO, Login, Password, Role, Note) VALUES
	(@NewUserName, @Login_Name, CONVERT(VARBINARY(256), @Login_Pass), @ROLE, @NOTE)
IF @@ERROR <>  0
BEGIN
	RAISERROR ('Не могу добавить нового пользователя!',  16, 1)
	RETURN (-1)
END
SELECT * FROM VUsers
	WHERE User_ID = SCOPE_IDENTITY()
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_AddUser]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Admin_ChangePassword
	@USERLOGIN SYSNAME = NULL,
	@NEWPASS VARCHAR(16) = NULL,
	@OLDPASS VARCHAR(16) = NULL
--WITH ENCRYPTION
AS
DECLARE @PASSW VARBINARY(256)

-- Смена пароля пользователя
IF @USERLOGIN IS NULL
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-2)
END
-- Проверка существования пользователя
IF NOT EXISTS(SELECT * FROM Users WHERE Login = @USERLOGIN)
BEGIN
	RAISERROR('Не найден пользователь!', 16,1)
	RETURN (-2)
END
IF @OLDPASS IS NOT NULL
-- Есть пароль -> проверка пароля
BEGIN
	SET @PASSW = (SELECT Password FROM Users WHERE Login = @USERLOGIN)
	IF pwdcompare(@OLDPASS, @PASSW) <> 1
	BEGIN
		RAISERROR('Пароль не верен!', 16,1)
		RETURN (-2)
	END
END
UPDATE Users SET Password = convert(varbinary(256), pwdencrypt(@NEWPASS))
	WHERE Login = @USERLOGIN
IF (@@ERROR <> 0) OR (@@ROWCOUNT <> 1)
BEGIN
	RAISERROR('Не удалось сменить пароль!', 16,1)
	RETURN (-2)
END
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_ChangePassword]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Admin_DelCloseSession
AS
/*
Удаление из таблицы SESSIONS данные о завершенных сессиях
Автор: Климов А.П.
Вызывается:
Форма Admin_Main
*/
DELETE FROM SESSIONS WHERE (DAT_SESSION_OFF IS NOT NULL) OR (BAD = 1)
IF @@ERROR <> 0
BEGIN
	RAISERROR('Ошибка удаления завершенных сессий из таблицы SESSIONS!', 16,1)
	RETURN (-1)
END

RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_DelCloseSession]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.Admin_DelModul
	@MODULID INT = NULL
AS
-- Удаление модуля 
IF @MODULID IS NULL
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-2)
END
-- Проверяем, что для данного файла нет версия на сервере
IF EXISTS(SELECT * FROM Versions WHERE Modul_ID = @MODULID)
BEGIN
	RAISERROR('Для данного файла существуют версии - удалять нельзя!', 16,1)
	RETURN (-3)
END
DELETE FROM Moduls WHERE Modul_ID = @MODULID
IF @@ERROR <> 0
BEGIN
	RAISERROR('Не могу удалить файл с сервера (таблица MODULS)!', 16,1)
	RETURN (-3)
END
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_DelModul]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Admin_DelUser
	@USER_ID INT = NULL
AS
-- Удаление пользователя
IF @USER_ID IS NULL
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-2)
END
DECLARE @ROLE CHAR(1)

-- Находим роль пользователя
SELECT @ROLE = Role FROM Users WHERE User_ID = @USER_ID
-- Проверка наличия записи
IF @@ROWCOUNT <> 1
BEGIN
	RAISERROR('Нет требуемого пользователя User_ID=%d!', 16,1, @USER_ID)
	RETURN (-2)
END
-- Проверка того, что пользователь не Начальник
-- Проверка запрета удаления Администратора
IF @ROLE = 'A'
BEGIN
	RAISERROR('Нельзя удалять Администратора User_ID=%d!', 16,1, @USER_ID)
	RETURN (-2)
END

BEGIN TRANSACTION
-- Удаляем пользователя из Permission
DELETE FROM Permission WHERE User_ID = @USER_ID
IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RAISERROR('Ошибка удаления из таблицы Permission!', 16,1)
	RETURN (-1)
END	
-- Удаляем данного пользователя
DELETE FROM Users WHERE User_ID = @USER_ID
IF @@ERROR <> 0
BEGIN
	-- Все хорошо
	ROLLBACK TRANSACTION
	RAISERROR('Ошибка удаления из таблицы Users!', 16,1)	
	RETURN (-1)
END
COMMIT TRANSACTION
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_DelUser]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE  PROCEDURE dbo.Admin_DelVersion
	@VERID INT = NULL
AS
-- Удаление версии модуля с сервера
IF @VERID IS NULL
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
DELETE FROM Versions WHERE Version_ID = @VERID
IF @@ERROR <> 0
BEGIN
	RAISERROR('Не могу удалить версию файла с сервера (таблица VERSIONS) для Version_ID=%d!', 16,1,@VERID)
	RETURN (-1)
END
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_DelVersion]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE  PROCEDURE dbo.Admin_EdModul
	@MODID INT = NULL,
	@ModulName VARCHAR(40) = NULL,
	@Path VARCHAR(200) = NULL,
	@Note VARCHAR(200) = NULL
-- Редактирование модуля на сервер
AS
IF (@ModulName IS NULL) OR (@Path IS NULL) OR (@Note IS NULL) OR (@MODID IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
UPDATE Moduls SET Name_File = @ModulName, Path =  @Path, Note = @Note
	WHERE Modul_ID = @MODID
IF @@ERROR <> 0
BEGIN
	RAISERROR('Не могу обновить модуль в таблице MODULS для Modul_ID=%d!', 16,1, @MODID)
	RETURN (-1)
END
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_EdModul]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Admin_EditUser 
	@USER_ID INT = NULL,
	@UserName VARCHAR(40) = NULL,
	@Login_Name VARCHAR(20) = NULL,
	@Login_Pass SYSNAME = '',
	@NOTE VARCHAR(200) = '',
	@ROLE CHAR(1) = 'W'
--WITH ENCRYPTION
AS
IF (@UserName IS NULL) OR  (@Login_Name IS NULL) OR (@USER_ID IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
IF EXISTS(SELECT * FROM Users WHERE Login = @Login_Name AND User_ID <> @USER_ID)
BEGIN
	RAISERROR ('Данный LOGON=%s уже используется!',  16, 1, @Login_Name)
	RETURN (-2)
END
DECLARE @PASS VARBINARY(255)
SET @PASS = pwdencrypt(@Login_Pass)

UPDATE Users SET FIO = @UserName, Login = @Login_Name, Password = CONVERT(VARBINARY(256), @PASS)
	,Role = @ROLE, Note = @NOTE
WHERE User_ID = @USER_ID
IF @@ERROR <>  0
BEGIN
	RAISERROR ('Не могу обновить пользователя User_ID=%d!',  16, 1, @USER_ID)
	RETURN (-1)
END
RETURN (0)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_EditUser]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.Admin_GetListSessions
	@MODE TINYINT = 0
AS
/*
Чтения списка всех сессий 
Автор: Климов А.П.
Вызывается:
Форма Admin_Main
@MODE = 0 - читаем все записи
@MODE = 1 - читаем только записи из активных сессий

Сессий считается открытой, если поле DAT_SESSION_OFF пусто и в таблице temdb.dbo.sysobjects есть запись:
Name = '#' + Sessions.COMP+NAME + '**_VS_**' + Sessions.SYS_USER + **_VS_** и
XType = 'u'
*/
IF @MODE = 0
	SELECT s.BAD, s.SESSION_ID, s.USER_ID, s.USER_N, s.SYS_USER, s.COMP_NAME, s.DAT_SESSION_ON, s.DAT_SESSION_OFF,
		ACTIVE = 
		CASE 	WHEN s.BAD = 1 THEN 'Z'
			WHEN (s.BAD = 0) AND (s.DAT_SESSION_OFF IS NULL) AND (EXISTS (SELECT * FROM tempdb..sysobjects t
				WHERE t.Name
			 LIKE '#'+DB_NAME() COLLATE SQL_Latin1_General_CP1251_CI_AS  + '**_VS_**' + 
				RTRIM(s.COMP_NAME COLLATE SQL_Latin1_General_CP1251_CI_AS) +'**_VS_**' + 
				RTRIM(s.SYS_USER)+'**_VS_**%' AND t.XType = 'u')) 
			THEN 'A'
			WHEN (s.BAD = 0) AND (s.DAT_SESSION_OFF IS NOT NULL) THEN 'P'
		ELSE 'U'
		END, ISNULL(CLIENT_SOFT, '') AS CLIENT_SOFT
	FROM SESSIONS s 
	ORDER BY DAT_SESSION_ON DESC
ELSE
	SELECT s.BAD, s.SESSION_ID, s.USER_ID, s.USER_N, s.SYS_USER, s.COMP_NAME, s.DAT_SESSION_ON, s.DAT_SESSION_OFF,
		ACTIVE = 'A', ISNULL(CLIENT_SOFT, '') AS CLIENT_SOFT
	FROM SESSIONS s INNER JOIN tempdb..sysobjects t 
		ON s.SESSION_ID = 
			CASE
				WHEN CHARINDEX('<ID=', Name) > 0 THEN CAST(SUBSTRING (t.Name,  CHARINDEX('<ID=', t.Name) + 4 , 20 )  AS INT)
				ELSE 0
			END
	WHERE t.Name LIKE '#'+DB_NAME() COLLATE SQL_Latin1_General_CP1251_CI_AS  + '**_VS_**%' AND t.XType = 'u'
	ORDER BY s.DAT_SESSION_ON DESC

RETURN (0)
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_GetListSessions]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Admin_GetUserMenu 
	@USER_ID INT = NULL
AS
IF NOT EXISTS(SELECT * FROM Users WHERE User_ID = @USER_ID)
BEGIN
	RAISERROR('Не найден пользователь USER_ID=%d!', 16,1, @USER_ID)
	RETURN (-2)
END
IF (SELECT Role From Users WHERE User_ID = @USER_ID) = 'A'
	SELECT MENU_ID, Name, PAD_Number, POPUP_Name, ISNULL(Form, '') AS Form
	FROM Menu ORDER BY PAD_Number
ELSE
	-- Получаем список объектов к которым имеет доступ пользователь @USER_ID
	SELECT m.MENU_ID, m.Name, m.PAD_Number, m.POPUP_Name, ISNULL(m.Form, '') AS Form
	FROM Menu m INNER JOIN Permission p ON m.Menu_ID = p.Menu_ID
	WHERE p.User_ID = @USER_ID
	ORDER BY m.PAD_Number
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_GetUserMenu]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Admin_GetUsers
AS
-- Получаем список пользователй
SELECT * FROM VUsers
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_GetUsers]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Admin_Session_OFF
	@SESSION_ID INT = NULL
AS
/*
Установка в таблицы SESSIONS даты и времени отключения пользователя
*/
IF @SESSION_ID IS NULL
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
UPDATE SESSIONS SET DAT_SESSION_OFF = GETDATE()
	WHERE SESSION_ID = @SESSION_ID
IF @@ERROR <> 0
BEGIN
	RAISERROR('Ошибка обновления таблицы SESSIONS=%d!', 16,1, @SESSION_ID)
	RETURN (-1)
END
RETURN (0)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_Session_OFF]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Admin_Session_ON
	@USER_ID INT = NULL
AS
/*
Запись в таблицу SESSIONS данные о подключаемом пользователе
*/
IF (@USER_ID IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-2)
END
DECLARE @USERNAME VARCHAR(40),
	@APP_NAME NVARCHAR(128)
SELECT @APP_NAME = LTRIM(RTRIM(program_name))  + ', ' + LTRIM(RTRIM(net_library))
	FROM master.dbo.sysprocesses WHERE spid = @@SPID

SELECT @USERNAME = FIO FROM Users WHERE USER_ID = @USER_ID
IF @USERNAME IS NULL
BEGIN
	RAISERROR('Не найден пользователь!', 16,1)
	RETURN (-2)
END
-- Проверяем, нет ли зависших сессий для данного компьютера
IF EXISTS (SELECT * FROM SESSIONS WHERE (COMP_NAME = HOST_NAME()) AND (DAT_SESSION_OFF IS NULL) AND (BAD = 0))
BEGIN
	-- Ставим флаг BAD = 1 для таких записей
	UPDATE SESSIONS SET BAD = 1 WHERE (COMP_NAME = HOST_NAME())  AND (DAT_SESSION_OFF IS NULL)
END
-- Добавляем новую запись
INSERT INTO SESSIONS (USER_ID, USER_N, SYS_USER, COMP_NAME, DAT_SESSION_ON, DAT_SESSION_OFF, BAD, PROC_ID, CLIENT_SOFT) VALUES
	(@USER_ID, @USERNAME, SYSTEM_USER, HOST_NAME(), GETDATE(), NULL, 0, @@SPID, @APP_NAME)
IF @@ERROR <> 0
BEGIN
	RAISERROR('Ошибка добавления записи в таблице сессий!', 16, 1)
	RETURN
END
SELECT * FROM SESSIONS WHERE SESSION_ID = SCOPE_IDENTITY()
RETURN (0)
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_Session_ON]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE dbo.Admin_SetActiveVersion
	@VERID INT = NULL,
	@MODE CHAR(1) = NULL
-- Установка для загрузки версии с Version_ID = @VERID
AS
IF @VERID IS NULL
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
IF @MODE IS NULL
	SET @MODE = 'S'
IF @MODE = 'S'
BEGIN
	-- Установка признака активности у версии @VERID
	BEGIN TRANSACTION
	-- Снимаем у всех версий признак активности
	UPDATE Versions SET Active = '' 
		WHERE Version_ID <> @VERID AND 
		Modul_ID = (SELECT Modul_ID FROM Versions WHERE Version_ID = @VERID)
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRANSACTION
		RAISERROR('Не могу снять флаг активности в таблице VERSIONS!', 16,1)
		RETURN (-1)
	END
	-- Устанавливаем флаг активности
	UPDATE Versions SET Active = 'A' WHERE Version_ID = @VERID
	IF (@@ERROR <> 0) OR (@@ROWCOUNT <> 1)
	BEGIN
		ROLLBACK TRANSACTION
		RAISERROR('Не могу установить флаг активности в таблице VERSIONS!', 16,1)
		RETURN (-1)
	END
	COMMIT TRANSACTION
	RETURN (0)
END
ELSE
BEGIN
	-- Снятие признака активности у версии @VERID
	UPDATE Versions SET Active = '' WHERE Version_ID = @VERID
	IF @@ERROR <> 0
	BEGIN
		RAISERROR('Не могу снять флаг активности в таблице VERSIONS!', 16,1)
		RETURN (-1)
	END
	RETURN (0)
END


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_SetActiveVersion]  TO [LoginForAll]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Admin_TestPassword
	@USERLOGIN VARCHAR(40) = NULL,
	@PASSWORD VARCHAR(16) = NULL
--WITH ENCRYPTION
AS
-- Проверка правильности пользователя
SET DATEFORMAT dmy

DECLARE @PASSW VARBINARY(255)

IF @USERLOGIN IS NULL
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
-- Ищем пользователя
IF NOT EXISTS (SELECT * FROM Users WHERE Login = @USERLOGIN)
BEGIN
	SELECT 0 AS User_ID
	RETURN (0)
END
-- Проверка пароля
SET @PASSW = (SELECT Password FROM Users WHERE  Login = @USERLOGIN)
IF pwdcompare(@PASSWORD, @PASSW) <> 1
	SELECT 0 AS User_ID
ELSE
	SELECT User_ID, Login, FIO, ISNULL(Note, '') AS Note, Role
	FROM Users
	WHERE Login = @USERLOGIN
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_TestPassword]  TO [public]
GO

GRANT  EXECUTE  ON [dbo].[Admin_TestPassword]  TO [guest]
GO

GRANT  EXECUTE  ON [dbo].[Admin_TestPassword]  TO [LoginForAll]
GO

GRANT  EXECUTE  ON [dbo].[Admin_TestPassword]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Admin_UpdatePermission 
	@USER_ID INT = NULL,
	@MENU_NAME VARCHAR(40) = NULL,
	@PAD_N SMALLINT = NULL,
	@MODE TINYINT = NULL
AS
IF (@USER_ID IS NULL) OR  (@MENU_NAME IS NULL) OR (@PAD_N IS NULL) OR (@MODE IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
DECLARE @MENU_ID INT
IF NOT EXISTS(SELECT * FROm Users WHERE User_ID = @USER_ID)
BEGIN
	RAISERROR('Пользовател User_ID=%d не найден!', 16,1, @USER_ID)
	RETURN (-2)
END

SELECT @MENU_ID = Menu_ID FROM Menu WHERE POPUP_Name = @MENU_NAME AND PAD_Number = @PAD_N
IF @MENU_ID IS NULL
BEGIN
	RAISERROR('Пункт меню не найден!', 16,1)
	RETURN (-2)
END

IF @MODE = 1
BEGIN
	-- Установка прав для 
	IF NOT EXISTS(SELECT * FROM Permission WHERE Menu_ID = @MENU_ID 
		AND User_ID =  @USER_ID)
	BEGIN
		INSERT INTO Permission (User_ID, Menu_ID) VALUES (@USER_ID, @MENU_ID)
		IF @@ERROR <> 0
		BEGIN
			RAISERROR('Не могу добавить запись в таблицу Permission для User_ID=%d!', 16,1, @USER_ID)
			RETURN (-1)
		END
	END	
END
ELSE
BEGIN
	-- Удаление прав
	DELETE FROM Permission WHERE Menu_ID = @MENU_ID AND User_ID =  @USER_ID
	IF @@ERROR <> 0
	BEGIN
		RAISERROR('Не могу удалить запись из таблицы Permission для User_ID=%d!', 16,1, @USER_ID)
		RETURN (-1)
	END
END
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_UpdatePermission]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Currency_AddNew
	@KOD INT = NULL,
	@NAME VARCHAR(40) = NULL,
	@OBOS VARCHAR(10) = NULL,
	@NOTE VARCHAR(200) = ''
AS
DECLARE @NEW_ID INT

IF  (@KOD IS NULL) OR (@NAME IS NULL) OR (@OBOS IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
INSERT INTO Currency  (Kod, Name, Obos, Note) VALUES 
	(@KOD, @NAME, @OBOS, @NOTE)
IF @@ERROR <> 0
BEGIN
	RAISERROR('Не могу добавить новую валюту в таблицу Currency!', 16,1)
	RETURN (-1)
END
SET @NEW_ID = SCOPE_IDENTITY()
SELECT Currency_ID, Kod, Name, Obos, Note
	FROM Currency 
WHERE Currency_ID = @NEW_ID
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Currency_AddNew]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Currency_Delete
	@CURRENCY_ID INT = NULL
AS
IF @CURRENCY_ID IS NULL
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
BEGIN TRANSACTION
-- Удаляем все курсы  для данной валюты
DELETE FROM Curs
WHERE Currency_ID = @CURRENCY_ID
IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RAISERROR('Не могу удалить курсы для выбранной валюты Currency_ID=%d!', 16,1, @CURRENCY_ID)
	RETURN (-1)
END
-- Удаляем валюты
DELETE FROM Currency WHERE Currency_ID = @CURRENCY_ID
IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RAISERROR('Не могу удалить валюту для Currency_ID=%d!', 16,1, @CURRENCY_ID)
	RETURN (-1)
END
COMMIT TRANSACTION
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Currency_Delete]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Currency_Edit
	@CURRENCY_ID INT = NULL,
	@KOD INT = NULL,
	@NAME VARCHAR(40) = NULL,
	@OBOS VARCHAR(10) = NULL,
	@NOTE VARCHAR(200) = ''
AS
IF  (@KOD IS NULL) OR (@NAME IS NULL) OR (@OBOS IS NULL) OR (@CURRENCY_ID IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
UPDATE Currency  SET Kod = @KOD, Name = @NAME, Obos = @OBOS, Note = @NOTE
WHERE Currency_ID = @CURRENCY_ID
IF @@ERROR <> 0
BEGIN
	RAISERROR('Не могу обновить валюту Currency_ID=%d!', 16,1, @CURRENCY_ID)
	RETURN (-1)
END
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Currency_Edit]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Currency_GetList
	@MODE TINYINT = 0
/*
Получаем список валют
Автор: Климов А.П.
Вызывается из:
CURRENCY_MAIN
*/
AS
IF @MODE = 0
	SELECT Currency_ID,  Kod, Name, Obos, Note
		FROM Currency 
	ORDER BY Name
ELSE
	SELECT Currency_ID,  Kod, Name, Obos, Note
		FROM Currency 
	UNION ALL
	SELECT 0, 0, 'Российские рубли', 'Рубли', ''
	ORDER BY Name


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Currency_GetList]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Curs_AddNew
	@CURRENCY_ID INT = NULL,
	@DATA DATETIME = NULL,
	@CURS DECIMAL(18,4) = NULL,
	@KOEF DECIMAL(8,0) =NULL
AS
IF  (@CURRENCY_ID IS NULL)  OR (@DATA IS NULL) OR (@CURS IS NULL) OR (@KOEF IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
DECLARE @CURS_ID INT

-- Проверяем нет ли уже курса для данной валюты и даты
SET @CURS_ID = (SELECT Curs_ID FROM Curs WHERE Currency_ID = @CURRENCY_ID AND Data = @DATA)
IF @CURS_ID IS NOT NULL
BEGIN
	UPDATE Curs  SET Curs = @CURS, Koef = @KOEF
	WHERE Curs_ID = @CURS_ID
	IF @@ERROR <> 0
	BEGIN
		RAISERROR('Не могу обновить курс для Curs_ID=%d!', 16,1, @CURS_ID)
		RETURN (-1)
	END
END
ELSE
BEGIN
	INSERT INTO Curs  (Currency_ID, Curs, Data, Koef) VALUES 
		(@CURRENCY_ID, @CURS, @DATA, @KOEF)
	IF @@ERROR <> 0
	BEGIN
		RAISERROR('Не могу добавить новый курс для выбранной валюты!', 16,1)
		RETURN (-1)
	END
	SET @CURS_ID = SCOPE_IDENTITY()
END
SELECT Curs_ID, Currency_ID, Curs, Data, Koef
	FROM Curs
WHERE Curs_ID = @CURS_ID
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Curs_AddNew]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Curs_Delete
	@CURS_ID INT = NULL
/*
Удаление курс валюты
Автор: Климов А.П.
Вызывается из:
CURRENCY_MAIN
*/
AS
IF @CURS_ID IS NULL
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
DELETE FROM Curs WHERE Curs_ID = @CURS_ID
IF @@ERROR <> 0
BEGIN
	RAISERROR('Не могу удалить курс Curs_ID=%d!', 16,1, @CURS_ID)
	RETURN (-3)
END
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Curs_Delete]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Curs_Edit
	@CURS_ID INT = NULL,
	@DATA DATETIME = NULL,
	@CURS DECIMAL(18,4) = NULL,
	@KOEF DECIMAL(8,0) = NULL
AS
IF  (@CURS_ID IS NULL) OR (@DATA IS NULL)  OR (@CURS IS NULL) OR (@KOEF IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
DECLARE @CURRENCY_ID INT
IF @KOEF = 0
BEGIN
	RAISERROR('Коэффициент пересчета Koef=%d не может быть 0!', 16,1, @KOEF)
	RETURN (-2)
END

-- Определяем валюту для выбранной цены
SELECT @CURRENCY_ID = Currency_ID FROM Curs WHERE Curs_ID = @CURS_ID
IF @CURRENCY_ID IS NULL
BEGIN
	RAISERROR('Не найден курс в таблице Curs для Curs_ID=%d!', 16,1, @CURS_ID)
	RETURN (-2)
END
-- Проверяем нет ли уже курса для данной валюты и даты
IF EXISTS(SELECT * FROM Curs WHERE Currency_ID = @CURRENCY_ID AND Data = @DATA AND Curs_ID <> @CURS_ID)
BEGIN
	RAISERROR('Для выбранной валюты на выбранную дату уже курс есть!', 16,1)
	RETURN (-2)
END
UPDATE Curs  SET Data = @DATA , Curs = @CURS, Koef = @KOEF
WHERE Curs_ID = @CURS_ID
IF @@ERROR <> 0
BEGIN
	RAISERROR('Не могу обновить курс для Curs_ID=%d!', 16,1, @CURS_ID)
	RETURN (-1)
END
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Curs_Edit]  TO [WORK_ROLE]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Curs_GetList
	@CURRENCY_ID INT = NULL
/*
Получаем список курсов для выбранной валюты
Автор: Климов А.П.
Вызывается из:
CURRENCY_MAIN
*/
AS
IF @CURRENCY_ID IS NULL
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END

SELECT Curs_ID, Curs, Data, Koef
	FROM Curs
WHERE Currency_ID = @CURRENCY_ID
ORDER BY Data DESC


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Curs_GetList]  TO [WORK_ROLE]
GO

