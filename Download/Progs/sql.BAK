#INCLUDE	"INCLUDE\MAIN.H"

#DEFINE	ERROR_SQL_COMMAND	"Невыполнимая команда SQL сервера!!!"
#DEFINE	ERROR_SQL_TEXT		"ОШИБКА СЕРВЕРА"

FUNCTION SQL
	*-- Выполнение командны на SQL-Сервере
	*-- Передается один или два параметра:
	*-- 1 - Команда в текстовой переменной lCommand
	*-- 2 - Имя возвращаемого курсора lCursor (может отсутст.)
	*-- Функция возвращает 1 если все OK
	*-- 0 если команда еще выполняется (для ассинхронного режима)
	*-- -1 команда не выполнилась
	*-- 3-ый параметр  - режим синхронного или ассингронного режима работы	
	LPARAMETERS m.lCommand, m.lCursor, m.llAsynchronous, m.llNoSaveToLog
	LOCAL m.lFlag, m.lnResult, m.lnCount, m.lnParNom, m.lcTextErr, ;
		m.lcText, m.lnNum1, m.lnNum2, m.lcSQL_Command, ;
		m.lnResult2, m.lnPos, m.lnCountError, m.i, m.lcTextLog, m.lnNumError
	LOCAL ARRAY m.lErr[1]
	PRIVATE m.ptErrorTime, m.pcErrorText
	m.ptErrorTime = DATETIME()
	m.pcErrorText = ""

	IF EMPTY(NVL(m.lCommand, ''))
		*-- Команда SQL сервера = NULL
		SaveLogODBCError(-998, "Команда SQL не задана!", 'NULL', m.llNoSaveToLog)
		m.pExecSQL = .F.
		MESSAGEBOX("Команда SQL не задана!", 16 + 0 + 0, ERROR_SQL_COMMAND)
		RETURN (-1)
	ENDIF
	m.lnCount = 30
	m.lnParNom = PCOUNT()
	m.pExecSQL = .T.
	DO WHILE m.lnCount > 0
		DO CASE
			CASE m.lnParNom = 1
				m.lnResult = SQL_COMMAND(m.lCommand)
			CASE m.lnParNom = 2
				m.lnResult = SQL_COMMAND(m.lCommand, m.lCursor)
			CASE BETWEEN(m.lnParNom, 3, 4)
				m.lnResult = SQL_COMMAND(m.lCommand, m.lCursor, m.llAsynchronous)
			OTHERWISE
				SaveLogODBCError(-997, "Кол-во параметров больше 4!", m.lCommand, llNoSaveToLog)
				m.pExecSQL = .F.
				RETURN (-1)
		ENDCASE
		IF m.lnResult > 0
			m.pExecSQL = .F.
			RETURN (0)
		ENDIF
		*-- Ошибка
		*-- Загрузка информации об ошибках в массив
		WAIT CLEAR
		AERROR(m.lErr)
		*-- Формируем текст ошибки
		m.lcTextErr = ''
		m.lcTextLog = ''
		m.lnCountError = ALEN(m.lErr,1)
		m.lnNumError = 0
		FOR m.i = m.lnCountError TO 1 STEP -1
			m.lcTextLog = m.lcTextLog + m.lErr[m.i, 3] + CR
			IF INLIST(NVL(m.lErr[m.i, 5], 0), 266, 8153)
				*-- Не надо выводить на экран ошибки с кодами: 266, 8153
				LOOP
			ENDIF
			m.lnNumError = m.lnNumError + 1
			*-- Исключаем служебный текст в символах [] из текста ошибки,
			*-- выводимого на экран
			m.lnPos =  RAT("]", ALLTRIM(m.lErr[m.i, 3]))
			m.lcText = ALLTRIM(SUBSTR(ALLTRIM(m.lErr[m.i, 3]), m.lnPos + 1))
			IF LEN(m.lcText) < 4
				m.lcText = ALLTRIM(m.lErr[m.i, 3])
			ENDIF
			m.lcTextErr = m.lcTextErr + REPLICATE("  ", m.lnNumError) + ;
				CAST(m.lnNumError AS V(3)) + ". " + m.lcText + CR
			IF NVL(m.lErr[m.i, 5],0) = 547
				m.lcTextErr = m.lcTextErr + CR + ;
					REPLICATE("  ", m.lnNumError) + " Изменение (удаление) не возможно!" + CR + ;
					REPLICATE("  ", m.lnNumError) + " Возможные причины:" + CR + ;
					REPLICATE("  ", m.lnNumError) + "	1. Удаление используемого объекта" + CR + ;
					REPLICATE("  ", m.lnNumError) + "	2. Попытка образования отрицательного остатка"
			ENDIF
		ENDFOR
		IF m.lnResult = -999	&& Команда прервана пользователем
			SaveLogODBCError(-999, "Команда SQL - сервера прервана пользователем!", ;
				m.lCommand, llNoSaveToLog)
			m.pExecSQL = .F.
			RETURN (-1)
		ENDIF
		*-- Запись сообщения об ошибке
		IF ATC('PASSWORD', m.lCommand) = 0
			SaveLogODBCError(NVL(lErr[5],0), m.lcTextLog, m.lCommand, m.llNoSaveToLog)
		ELSE
			SaveLogODBCError(NVL(lErr[5],0), m.lcTextLog, '', m.llNoSaveToLog)
		ENDIF
		IF NVL(lErr[5],0) = 1205	&& deadlocked  - делаем 30 попыток
			m.lnCount = m.lnCount - 1
		ELSE
			EXIT
		ENDIF
	ENDDO
	*-- Проверяем, если ли открытые транзакции и откатываем их
	IF SQLGETPROP(m.phServer, 'Asynchronous')
		SQLSETPROP(m.phServer, 'Asynchronous', .F.)
	ENDIF
	SQLEXEC(m.phServer, 'IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION')
	IF !m.llNoSaveToLog
		MESSAGEBOX(m.lcTextErr, 16 + 0 + 0, ERROR_SQL_TEXT)
	ENDIF
	m.pExecSQL = .F.
	RETURN (-1)
ENDFUNC

FUNCTION SQL_COMMAND
	*-- Выполнение командны на SQL-Сервере
	*-- Передается один или два параметра:
	*-- 1 - Команда в текстовой переменной lCommand
	*-- 2 - Имя возвращаемого курсора lCursor (может отсутст.)
	*-- Функция возвращает 1 если все OK
	*-- 0 если команда еще выполняется (для ассинхронного режима)
	*-- -1 команда не выполнилась
	*-- 3-ый параметр  - режим синхронного или ассингронного режима работы
	LPARAMETERS m.lCommand, m.lCursor, m.llAsynchronous

	LOCAL m.lResult, m.lcTextErr, m.llOldMode, m.lnAnswer, m.lnKey, ;
		m.lfESC, m.lnPCount, m.lnSec, m.lnTimeOut, m.llMode, m.i, m.lnSecSQL
	LOCAL ARRAY m.laV[12]

	#DEFINE		TXT_SQL		" Обработка запроса на сервере "

	IF EMPTY(m.phServer)
		MESSAGEBOX("Нет соединения с SQL сервером", 16, "ОШИБКА")
		RETURN (-1)
	ENDIF

	laV[1] =  " >----- "
	laV[2] =  " ->---- "
	laV[3] =  " -->--- "
	laV[4] =  " --->-- "
	laV[5] =  " ---->- "
	laV[6] =  " -----> "
	laV[7] =  " -----< "
	laV[8] =  " ----<- "
	laV[9] =  " ---<-- "
	laV[10] = " --<--- "
	laV[11] = " -<---- "
	laV[12] = " <----- "

	m.lnTimeOut = 0.1
	m.llMode = .F.
	m.lfESC = .F.
	m.lnSec = SECONDS()
	m.i = 1
	m.lnSecSQL = SECONDS()
	CLEAR TYPEAHEAD

	IF PCOUNT() = 2 AND VARTYPE(m.lCursor) == "L"
		*-- Передали два параметра и второй логический
		m.llAsynchronous = m.lCursor
		IF SQLGETPROP(m.phServer, 'Asynchronous') <> m.llAsynchronous
			SQLSETPROP(m.phServer, 'Asynchronous', llAsynchronous)
		ENDIF
		m.lResult = 0
		IF SQLGETPROP(m.phServer, 'Asynchronous')
			DO WHILE (m.lResult = 0)
				m.lResult = SQLEXEC(m.phServer, m.lCommand)
				IF m.lResult < 0
					EXIT
				ENDIF
				IF m.llMode
					IF (SECONDS() - m.lnSec) >= m.lnTimeOut
						m.lnSec = SECONDS()
						m.i = IIF(m.i = ALEN(m.laV), 1, m.i+1)
						WAIT WINDOW " [" + laV[m.i] + "] " + TXT_SQL + ;
							ALLTRIM(STR(SECONDS()- m.lnSecSQL)) + " сек." NOWAIT
					ENDIF
				ELSE
					IF (SECONDS() - m.lnSec) >= oApp.TimeLevel
						*-- Пора выводить WAIT WINDOW ...
						m.llMode = .T.
						m.lnSec = SECONDS()
						WAIT WINDOW " [" + laV[m.i] + "] " + TXT_SQL + ;
							ALLTRIM(STR(SECONDS()- m.lnSecSQL)) + " сек." NOWAIT
					ENDIF
				ENDIF
			ENDDO
		ELSE
			m.lResult = SQLEXEC(m.phServer, m.lCommand)
		ENDIF
	ELSE
		IF ISNULL(m.lCommand) OR EMPTY(m.lCommand) OR VARTYPE(m.lCommand) <> "C"
			DO CASE
				CASE ISNULL(m.lCommand)
					m.lcTextErr = 'Значение команды для SQL сервера - NULL'
				CASE VARTYPE(m.lCommand) == "L"
					m.lcTextErr = 'Команда для SQL Server имеет тип Logical'
				OTHERWISE
					m.lcTextErr = 'Непонятная команда для SQL Server'
			ENDCASE
			MESSAGEBOX(ERROR_SQL_COMMAND, 16, "ОШИБКА")
			SaveLogODBCError(999, ERROR_SQL_COMMAND, m.lcTextErr, llNoSaveToLog)
			WAIT CLEAR
			RETURN (-1)
		ENDIF
		m.lnPCount = IIF(PCOUNT() > 1 AND EMPTY(m.lCursor), 1, PCOUNT())
		IF m.lnPCount > 1 AND USED(m.lCursor)
			USE IN (m.lCursor)
		ENDIF
		m.lResult = 0
		IF PCOUNT() = 3 AND VARTYPE(m.llAsynchronous) == 'L'
			IF SQLGETPROP(m.phServer, 'Asynchronous') <> m.llAsynchronous
				SQLSETPROP(m.phServer, 'Asynchronous', m.llAsynchronous)
			ENDIF
		ELSE
			IF !SQLGETPROP(m.phServer, 'Asynchronous')
				SQLSETPROP(m.phServer, 'Asynchronous', .T.)
			ENDIF
		ENDIF
		IF SQLGETPROP(m.phServer, 'Asynchronous')
			*-- Установлен асинхронный режим работы с SQL сервером
			DO WHILE (m.lResult = 0)	&& OR ((lnPCount > 1) AND !USED(lCursor))
				DO CASE
					CASE m.lnPCount = 1
						m.lResult = SQLEXEC(m.phServer, m.lCommand)
					CASE lnPCount >= 2
						m.lResult = SQLEXEC(m.phServer, m.lCommand, m.lCursor)
				ENDCASE
				IF m.lResult < 0
					EXIT
				ENDIF
				IF m.llMode
					IF (SECONDS() - m.lnSec) >= m.lnTimeOut
						m.lnSec = SECONDS()
						m.i = IIF(m.i = ALEN(laV), 1, m.i+1)
						WAIT WINDOW " [" + laV[m.i] + "] " + TXT_SQL + ;
							ALLTRIM(STR(SECONDS()- m.lnSecSQL)) + " сек." NOWAIT
					ENDIF
				ELSE
					IF (SECONDS() - m.lnSec) >= oApp.TimeLevel
						*-- Пора выводить WAIT WINDOW ...
						m.llMode = .T.
						m.lnSec = SECONDS()
						WAIT WINDOW " [" + laV[m.i] + "] " + TXT_SQL + ;
							ALLTRIM(STR(SECONDS()- m.lnSecSQL)) + " сек." NOWAIT
					ENDIF
				ENDIF
			ENDDO
		ELSE
			DO CASE
				CASE m.lnPCount = 1
					m.lResult = SQLEXEC(m.phServer, m.lCommand)
				CASE lnPCount >= 2
					m.lResult = SQLEXEC(m.phServer, m.lCommand, m.lCursor)
			ENDCASE
		ENDIF
	ENDIF
	WAIT CLEAR
	RETURN (m.lResult)
ENDFUNC

FUNCTION SaveLogODBCError
	LPARAMETERS lErrorNumber, lTextError, txtCommandSQL, lNoSaveToLog
	*-- Процедура записывает сообщение об ошибке в файл ошибок
	LOCAL lFile

	IF lNoSaveToLog&& не нужно ничего писать в лог
		RETURN
	ENDIF

	IF !DIRECTORY("LOG")
		MKDIR LOG
	ENDIF
	m.lFile = "LOG\" + LOGFILE
	pcErrorText = "********** " + TTOC(ptErrorTime) + " **********" + ;
		CHR(13) + CHR(10) +;
		"ODBC драйвер вернул ошибку № " + ALLTRIM(STR(m.lErrorNumber)) + ;
		CHR(13) + CHR(10) +;
		"Сервер: " + oApp.SQLServer + CHR(13) + CHR(10) +;
		"SQL-Login: " + oApp.User_login + CHR(13) + CHR(10) +;
		lTextError + CHR(13) + CHR(10) +;
		"Пользователь - " + SYS(0) + CHR(13) + CHR(10) +;
		"Команда " + m.txtCommandSQL + CHR(13) + CHR(10) + ;
			CHR(13) + CHR(10)
	= STRTOFILE(pcErrorText, m.lFile, 1)
ENDFUNC

FUNCTION ErrMessage
	LPARAMETERS lMessage, lCaption

	LOCAL lnAnswer
	m.lCaption = IIF(VARTYPE(m.lCaption) == "C", m.lCaption, IIF(TYPE("_SCREEN.ActiveForm") == "O", ;
		_SCREEN.ActiveForm.Caption, _SCREEN.Caption))
	=MESSAGEBOX(m.lMessage, 0, m.lCaption)
ENDFUNC

FUNCTION GetDate
	*-- Получаем дату с SQL - сервера
	LOCAL lDat, lnError

	m.lnError = SQL("SELECT GETDATE()", "_tCurDat")

	IF m.lnError = 0
		m.lDat = DATE(YEAR(_tCurDat.Exp), MONTH(_tCurDat.Exp), DAY(_tCurDat.Exp))
	ELSE
		m.lDat = DATE()
	ENDIF
	USE IN _tCurDat
	RETURN (m.lDat)
ENDFUNC

FUNCTION GetDateTime
	*-- Получаем дату и времени с SQL - сервера
	LPARAMETERS lnDataSession
	*-- Получаем дату с SQL - сервера
	LOCAL lDat, lnError

	m.lnError = SQL("SELECT GETDATE()", "_tCurDat")

	IF m.lnError = 0
		m.lDat = _tCurDat.Exp
	ELSE
		m.lDat = DATETIME()
	ENDIF
	USE IN _tCurDat
	RETURN (m.lDat)
ENDFUNC
