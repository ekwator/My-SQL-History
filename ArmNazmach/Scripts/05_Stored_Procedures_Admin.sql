USE vvk_my
go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_AddUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_AddUser]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_ChangePassword]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_ChangePassword]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_DelUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_DelUser]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_EditUser]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_EditUser]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetUserMenu]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetUserMenu]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetUsers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetUsers]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_TestPassword]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_TestPassword]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_UpdatePermission]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_UpdatePermission]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Admin_GetMenu]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Admin_GetMenu]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE Admin_AddUser 
	@IdUser CHAR(15) = NULL,
	@IdSotrudnik CHAR(15) = NULL,
	@Login_Name CHAR(100) = NULL,
	@Login_Pasw SYSNAME = NULL,
	@NOTE VARCHAR(200) = '',
	@ROLE CHAR(1) = 'W'
--WITH ENCRYPTION
AS
IF (@IdUser IS NULL) OR (@IdSotrudnik IS NULL)  OR  (@Login_Name IS NULL) OR  (@Login_Pasw IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
IF EXISTS(SELECT * FROM Users WHERE Name = @Login_Name)
BEGIN
	RAISERROR ('Данный LOGON=%s уже используется !',  16, 1, @Login_Name)
	RETURN (-3)
END

SELECT @Login_Pasw = pwdencrypt(@Login_Pasw)
INSERT INTO _s_User (id, id_Sotrudnik, Name, Pasw, Role, Note) VALUES
	(@IdUser, @IdSotrudnik, @Login_Name, CONVERT(VARBINARY(256), @Login_Pasw), @ROLE, @NOTE)
IF @@ERROR <>  0
BEGIN
	RAISERROR ('Не могу добавить нового пользователя!',  16, 1)
	RETURN (-1)
END
SELECT * FROM _v_User
	WHERE (user_id = @IdUser)
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
IF (@USERLOGIN IS NULL) OR (@NEWPASS IS NULL) OR (@OLDPASS IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-2)
END
-- Проверка существования пользователя
IF NOT EXISTS(SELECT * FROM _s_User WHERE Name = @USERLOGIN)
BEGIN
	RAISERROR('Не найден пользователь!', 16,1)
	RETURN (-2)
END
IF @OLDPASS IS NOT NULL
-- Есть пароль -> проверка пароля
BEGIN
	SET @PASSW = (SELECT Pasw FROM _s_User WHERE Name = @USERLOGIN)
	IF pwdcompare(@OLDPASS, @PASSW) <> 1
	BEGIN
		RAISERROR('Пароль не верен!', 16,1)
		RETURN (-2)
	END
END
UPDATE _s_User SET Pasw = convert(varbinary(256), pwdencrypt(@NEWPASS))
	WHERE Name = @USERLOGIN
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

CREATE PROCEDURE Admin_DelUser
	@USER_ID CHAR(15) = NULL
AS
-- Удаление пользователя
IF @USER_ID IS NULL
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-2)
END
DECLARE @ROLE CHAR(1)

-- Находим роль пользователя
SELECT @ROLE = Role FROM _s_Users WHERE id = @USER_ID
-- Проверка наличия записи
IF @@ROWCOUNT <> 1
BEGIN
	RAISERROR('Нет требуемого пользователя User_ID=%s !', 16,1, @USER_ID)
	RETURN (-2)
END
-- Проверка того, что пользователь не Начальник
-- Проверка запрета удаления Администратора
IF @ROLE = 'A'
BEGIN
	SELECT @ROLE = Role FROM _s_Users
		-- Проверка наличия других пользователей с правами администратора
	IF @@ROWCOUNT < 2
	BEGIN
		RAISERROR('Нельзя удалять единственного Администратора User_ID=%s !', 16,1, @USER_ID)
		RETURN (-2)
	END
END

BEGIN TRANSACTION
-- Удаляем пользователя из Permission
DELETE FROM _s_Permission WHERE id_User = @USER_ID
IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RAISERROR('Ошибка удаления из таблицы _s_Permission! ', 16,1)
	RETURN (-1)
END	
-- Удаляем данного пользователя
DELETE FROM _s_Users WHERE id = @USER_ID
IF @@ERROR <> 0
BEGIN
	ROLLBACK TRANSACTION
	RAISERROR('Ошибка удаления из таблицы _s_User !', 16,1)	
	RETURN (-1)
END
-- Все хорошо
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

CREATE PROCEDURE Admin_EditUser 
	@USER_ID CHAR(15) = NULL,
	@Sotrudnik_ID CHAR(15) = NULL,
	@Login_Name CHAR(50) = NULL,
	@Login_Pass SYSNAME = '',
	@NOTE VARCHAR(200) = '',
	@ROLE CHAR(1) = 'W'
--WITH ENCRYPTION
AS
IF (@Login_Name IS NULL) OR (@USER_ID IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
IF EXISTS(SELECT * FROM _s_User WHERE Name = @Login_Name AND id <> @USER_ID)
BEGIN
	RAISERROR ('Данный LOGON=%s уже используется !',  16, 1, @Login_Name)
	RETURN (-2)
END
DECLARE @PASS VARBINARY(255)
SET @PASS = pwdencrypt(@Login_Pass)
IF (@Sotrudnik_ID IS NULL)
	BEGIN
	UPDATE _s_User SET Name = @Login_Name, Pasw = CONVERT(VARBINARY(256), @PASS)
	,Role = @ROLE, Note = @NOTE
	WHERE id = @USER_ID
	END
ELSE
	BEGIN
	UPDATE _s_User SET id_Sotrudnik = @Sotrudnik_ID, Name = @Login_Name, Pasw = CONVERT(VARBINARY(256), @PASS)
	,Role = @ROLE, Note = @NOTE
	WHERE id = @USER_ID
	END
IF @@ERROR <>  0
BEGIN
	RAISERROR ('Не могу обновить пользователя User_ID=%s !',  16, 1, @USER_ID)
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

CREATE PROCEDURE Admin_GetUserMenu 
	@USER_ID CHAR(15) = NULL
AS
IF NOT EXISTS(SELECT * FROM _s_User WHERE id = @USER_ID)
BEGIN
	RAISERROR('Не найден пользователь id=%s !', 16,1, @USER_ID)
	RETURN (-2)
END
IF (SELECT Role From _s_User WHERE id = @USER_ID) = 'A'
	SELECT id, Name, PAD_Number, POPUP_Name, ISNULL(Form, '') AS Form
	FROM _s_Menu ORDER BY PAD_Number
ELSE
	-- Получаем список объектов к которым имеет доступ пользователь @USER_ID
	SELECT m.id, m.Name, m.PAD_Number, m.POPUP_Name, ISNULL(m.Form, '') AS Form
	FROM Menu m INNER JOIN _s_Permission p ON m.id = p.id_Menu
	WHERE p.id_User = @USER_ID
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
SELECT * FROM _v_User
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


CREATE PROCEDURE Admin_TestPassword
	@USERLOGIN VARCHAR(50) = NULL,
	@PASSWORD VARCHAR(16) = NULL
--WITH ENCRYPTION
AS
-- Проверка правильности пользователя
SET DATEFORMAT dmy

DECLARE @PASSW VARBINARY(255)

IF (@USERLOGIN IS NULL) OR (@PASSWORD IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END
-- Ищем пользователя
IF NOT EXISTS (SELECT * FROM _s_User WHERE Name = @USERLOGIN)
BEGIN
	SELECT '' AS User_ID
	RETURN (0)
END
-- Проверка пароля
SET @PASSW = (SELECT Pasw FROM _s_User WHERE Name = @USERLOGIN)
IF pwdcompare(@PASSWORD, @PASSW) <> 1
	SELECT '' AS User_ID
ELSE
	SELECT * FROM _v_User
	WHERE (dbo._v_User.Login = @USERLOGIN)
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

GRANT  EXECUTE  ON [dbo].[Admin_TestPassword]  TO [AppAdmin]
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
	@MENU_ID CHAR(15) = NULL,
	@USER_ID CHAR(15) = NULL,
	@MENU_NAME VARCHAR(50) = NULL,
	@PAD_N SMALLINT = NULL,
	@MODE TINYINT = NULL
AS
IF (@MENU_ID IS NULL) OR (@USER_ID IS NULL) OR (@MENU_NAME IS NULL) OR (@PAD_N IS NULL) OR (@MODE IS NULL)
BEGIN
	RAISERROR('Не заданы все параметры!', 16,1)
	RETURN (-3)
END

IF NOT EXISTS(SELECT * FROm _s_User WHERE id = @USER_ID)
BEGIN
	RAISERROR('Пользовател User_ID=%s не найден!', 16,1, @USER_ID)
	RETURN (-2)
END

SELECT @MENU_ID = id FROM _s_Menu WHERE POPUP_Name = @MENU_NAME AND PAD_Number = @PAD_N
IF @MENU_ID IS NULL
BEGIN
	RAISERROR('Пункт меню не найден!', 16,1)
	RETURN (-2)
END

IF @MODE = 1
BEGIN
	-- Установка прав для 
	IF NOT EXISTS(SELECT * FROM _s_Permission WHERE id_Menu = @MENU_ID 
		AND id_User =  @USER_ID)
	BEGIN
		INSERT INTO _s_Permission (id_User, id_Menu) VALUES (@USER_ID, @MENU_ID)
		IF @@ERROR <> 0
		BEGIN
			RAISERROR('Не могу добавить запись в таблицу Permission для id_User=%s !', 16,1, @USER_ID)
			RETURN (-1)
		END
	END	
END
ELSE
BEGIN
	-- Удаление прав
	DELETE FROM _s_Permission WHERE id_Menu = @MENU_ID AND id_User =  @USER_ID
	IF @@ERROR <> 0
	BEGIN
		RAISERROR('Не могу удалить запись из таблицы Permission для id_User=%s !', 16,1, @USER_ID)
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

CREATE PROCEDURE Admin_GetMenu
AS
-- Получаем список меню пользователй
SELECT * FROM _v_Menu
RETURN (0)


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT  EXECUTE  ON [dbo].[Admin_GetMenu]  TO [WORK_ROLE]
GO
