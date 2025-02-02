*-- Главная программа
#INCLUDE	INCLUDE\MAIN.H

PUSH KEY
CLEAR
CLEAR PROGRAM
CLOSE ALL
SET SYSMENU TO

#IF DEBUGMODE
	SET RESOURCE ON
#ELSE
	SET RESOURCE OFF
	CLOSE DEBUGGER
	SET VIEW OFF
#ENDIF

*-- Сохраняем установки для последующего восстановления
PUBLIC gcOldDir, gcOldPath, gcOldClassLib, gcOldEscape, gcOldTalk

IF SET('TALK') = 'ON'
	SET TALK OFF
	gcOldTalk = 'ON'
ELSE
	gcOldTalk = 'OFF'
ENDIF

gcOldEscape   	= SET('ESCAPE')
gcOldDir       	= FULLPATH(CURDIR())
gcOldPath     	= SET('PATH')
gcOldClassLib 	= SET('CLASSLIB')
plOldFlagEnd 	= .T.
plOldFirstStart = .T.

_SCREEN.Icon = "LOGO.ICO"
*-- Определяет, что FoxPro обрабатываtт команды SQL в стиле FoxPro 9.0
SET ENGINEBEHAVIOR 90
SET REPORTBEHAVIOR 90
_TOOLTIPTIMEOUT = 0
_INCSEEK 		= 2

*-- Определяем внешние DLL библиотеки
DECLARE INTEGER GetPrivateProfileString IN Win32API  AS GetPrivStr ;
	STRING cSection, STRING cKey, STRING cDefault, STRING @cBuffer, ;
	INTEGER nBufferSize, STRING cINIFile
DECLARE INTEGER WritePrivateProfileString IN Win32API AS WritePrivStr ;
	STRING cSection, STRING cKey, STRING cValue, STRING cINIFile
DECLARE INTEGER FindWindow IN Win32API AS FindWindow ;
	STRING cClassName, STRING cNameWindow
DECLARE INTEGER SQLConfigDataSource IN odbccp32.DLL INTEGER, INTEGER, ;
	STRING, STRING
DECLARE INTEGER GetSysColor IN User32.DLL INTEGER
DECLARE INTEGER SetCursorPos IN WIN32API INTEGER, INTEGER
DECLARE INTEGER GetAsyncKeyState IN WIN32API AS GetKeyState ;
	INTEGER lnKey

LOCAL i, lcSys16, lcProgram

*-- Закрываем все открытые проекты
IF TYPE("_VFP.Projects.Count") = "N"
	FOR m.i = 1 TO _VFP.Projects.Count
		IF TYPE("_VFP.Projects(m.i)") = "O"
			_VFP.Projects(m.i).Close()
		ENDIF
	ENDFOR
ENDIF

*-- Определение глобальных переменных
PUBLIC oApp, oError, phServer, pExecSQL
m.phServer = 0
m.pExecSQL = .F.

PUBLIC ARRAY mes_text[12], mes_main[12]
mes_text[1]="января"
mes_text[2]="февраля"
mes_text[3]="марта"
mes_text[4]="апреля"
mes_text[5]="мая"
mes_text[6]="июня"
mes_text[7]="июля"
mes_text[8]="августа"
mes_text[9]="сентября"
mes_text[10]="октября"
mes_text[11]="ноября"
mes_text[12]="декабря"

mes_main[1]="Январь"
mes_main[2]="Февраль"
mes_main[3]="Март"
mes_main[4]="Апрель"
mes_main[5]="Май"
mes_main[6]="Июнь"
mes_main[7]="Июль"
mes_main[8]="Август"
mes_main[9]="Сентябрь"
mes_main[10]="Октябрь"
mes_main[11]="Ноябрь"
mes_main[12]="Декабрь"
_VFP.AutoYield = .T.
* SQL ODBC отображает SQL_BINARY, SQL_VARBINARY, и SQL_LONGVARBINARY  типы как типу Blob капли или Varbinary.
CURSORSETPROP("MapBinary", .T., 0) 
*-- Добавляем свойство в _SCREEN для анализа перезапуска приложения
IF  TYPE("_SCREEN.Restart") = "U"
	_SCREEN.AddProperty("Restart", .F.)
ELSE
	_SCREEN.Restart = .F.
ENDIF
IF  TYPE("_SCREEN.FirstStart") = "U"
	_SCREEN.AddProperty("FirstStart", .T.)
ELSE
	_SCREEN.FirstStart = .T.
ENDIF

DO WHILE _SCREEN.Restart OR _SCREEN.FirstStart
	_SCREEN.FirstStart = .F.
	m.lcSys16 = SYS(16)
	m.lcProgram = SUBSTR(m.lcSys16, AT(":", m.lcSys16) - 1)
	CD LEFT(m.lcProgram, RAT("\", m.lcProgram))
	*-- Если стартовали из MAIN.PRG, то переходим в головную директорию
	IF (RIGHT(m.lcProgram, 3) == "FXP") OR (RIGHT(m.lcProgram, 3) == "PRG")
		CD ..
	ENDIF
	SET DEFAULT TO (SYS(5)+SYS(2003) + '\')
	SET PATH TO DATA, FORMS, CLASSES, REPORTS, PROGS, INCLUDE, BITMAPS
	SET CLASSLIB TO MyClass, Export, Doc, MyControls, Progress, Report, Split, UO, XML
	SET PROCEDURE TO Utils, class_define, sql
	oApp = NEWOBJECT("CSFW", "CLASSES\MYCLASS.VCX")
	IF !ISNULL(oApp) AND TYPE("oApp") = "O"
		IF oApp.DO()
			READ EVENTS
		ELSE
			_SCREEN.Restart = .F.
		ENDIF
		RELEASE m.oError
		RELEASE m.oApp
	ENDIF
ENDDO

#IF !DEBUGMODE
	ON SHUTDOWN
	QUIT
#ELSE
	ON SHUTDOWN
	_SCREEN.Icon =""
	_SCREEN.FirstStart = .T.
	SET HELP TO
	CLEAR ALL
	CLOSE ALL
	CLEAR PROGRAM
	SET SYSMENU NOSAVE
	SET SYSMENU TO DEFAULT
	SET SYSMENU ON
#ENDIF
