#INCLUDE	INCLUDE\MAIN.H

FUNCTION NULLIF(LnSRC1)
	RETURN ICASE(VARTYPE(m.LnSRC1) ="X", 'NULL', EMPTY(m.LnSRC1), ;
		'NULL', VARTYPE(m.LnSRC1)=="C", ['] + ALLTRIM(m.LnSRC1) + ['], ;
		VARTYPE(m.LnSRC1)== "D", ['] + DTOC(m.LnSRC1) + ['], ;
		VARTYPE(m.LnSRC1)== "T", ['] + TTOC(m.LnSRC1) + ['], ;
		VARTYPE(m.LnSRC1)= "N" AND !EMPTY(m.LnSRC1), ALLTRIM(STR(m.LnSRC1)), 'NULL')
ENDFUNC

FUNCTION OnShutDown()
	IF VARTYPE(oApp) == "O"
		oApp.Exit_App()
	ELSE
		ON ERROR
		ON SHUTDOWN
		CLEAR EVENTS
	ENDIF
ENDFUNC

FUNCTION NEWOBJ
	LPARAMETERS tcClass, tuParm1, tuParm2, ;
		tuParm3, tuParm4
	LOCAL lcClass, ;
		lcLibrary, ;
		lnPos, ;
		loObject

	lcClass   = UPPER(tcClass)
	lcLibrary = ''
	IF ',' $ lcClass AND LEFT(lcClass, 1) <> ','
		lnPos     = AT(',', lcClass)
		lcLibrary = ALLTRIM(LEFT(lcClass, lnPos - 1))
		lcClass   = ALLTRIM(SUBSTR(lcClass, lnPos + 1))
		IF lcLibrary $ UPPER(SET('CLASSLIB'))
			lcLibrary = ''
		ELSE
			SET CLASSLIB TO (lcLibrary) ADDITIVE
		ENDIF
	ENDIF

	DO CASE
		CASE pcount() = 1
			loObject = CREATEOBJECT(lcClass)
		CASE pcount() = 2
			loObject = CREATEOBJECT(lcClass, @tuParm1)
		CASE pcount() = 3
			loObject = CREATEOBJECT(lcClass, @tuParm1, @tuParm2)
		CASE pcount() = 4
			loObject = CREATEOBJECT(lcClass, @tuParm1, @tuParm2, @tuParm3)
		CASE pcount() = 5
			loObject = CREATEOBJECT(lcClass, @tuParm1, @tuParm2, @tuParm3, ;
				@tuParm4)
	ENDCASE
	RETURN loObject
ENDFUNC

FUNCTION SetDSession
	*-- Ќовые установки среды выполнени€ программы
	SET TALK OFF
	SET NOTIFY OFF
	SET COMPATIBLE OFF

	SET SYSFORMATS OFF
	SET CURRENCY TO 'р'
	SET CURRENCY RIGHT
	SET CENTURY ON
	SET DATE TO GERMAN
	SET DECIMALS TO 2
	SET HOURS TO 24
	SET POINT TO "."
	SET SEPARATOR TO "`"
	SET FDOW  TO 2
	SET FWEEK TO 1

	=CURSORSETPROP("Buffering", 1, 0)
	SET MEMOWIDTH TO 120
	SET FDOW TO 2
	SET ANSI ON
	SET SAFETY OFF
	SET MEMOWIDTH TO 80
	SET MULTILOCKS OFF
	SET DELETED ON
	SET EXCLUSIVE ON
	SET BELL OFF
	SET NEAR OFF
	SET EXACT OFF
	*--	SET EXACT ON
	SET INTENSITY OFF
	SET CONFIRM ON
	SET LOCK OFF
	SET REPROCESS TO 10 SECONDS
	SET NULL ON
	SET NULLDISPLAY TO " "
	CLEAR MACROS
	#IF DEBUGMODE
		SET RESOURCE TO FOXUSER.DBF
		SET RESOURCE ON
		SET DEBUG ON
		SET ESCAPE ON
	#ELSE
		SET RESOURCE OFF
		SET DEBUG OFF
		SET ESCAPE OFF
	#ENDIF
	SET ASSERTS OFF
	SET CPCOMPILE TO 1251
	RETURN .T.
ENDFUNC

FUNCTION ModifyColor
	*	обработка цвета
	LPARAMETERS lnColor, lnDelta, lnIndex
	LOCAL ARRAY S_Rgb[3]
	*	цвет дл€ обработки 0 - 16`777`216
	lnColor	= MIN( 16777216, MAX( 0, iif( VARTYPE( lnColor ) == 'N', lnColor, 0 )))
	*	что надо получить 0 - все цвета, 1-красный, 2-зеленый, 3-синий
	lnIndex	= MIN( 3, MAX( 0, iif( VARTYPE( lnIndex ) == 'N', lnIndex, 0 )))
	*	на сколько надо изменить цвет
	lnDelta	= IIF( VARTYPE( lnDelta ) == 'N', lnDelta , 0 )

	S_Rgb[3]	= INT( lnColor/ 65536 )	&& синий
	lnColor		= lnColor- ( S_Rgb[3] * 65536 )
	S_Rgb[2]	= INT( lnColor/ 256 )	&& зеленый
	lnColor		= lnColor- ( S_Rgb[2] * 256 )
	S_Rgb[1]	= lnColor		&& красный

	IF lnIndex = 0	&& все цвета
		RETURN ( rgb(;
			MAX( 0, MIN( 255,  S_Rgb[ 1 ] + lnDelta )),;
			MAX( 0, MIN( 255,  S_Rgb[ 2 ] + lnDelta )),;
			MAX( 0, MIN( 255,  S_Rgb[ 3 ] + lnDelta ))))
	ELSE			&& один цвет
		RETURN ( MAX( 0, MIN( 255,  S_Rgb[ lnIndex ] + lnDelta )))
	ENDIF
ENDFUNC


*-- ќбращение значени€ переменной дл€ обратной сортировки и преобразование ее в символ
FUNCTION Revers
	LPARAMETERS luStr, lnPrecision, lnScale
	DO CASE
		CASE VARTYPE(m.luStr) = "T"
			RETURN Revers(TTOC(m.luStr,1))
		CASE VARTYPE(m.luStr) == "C"
			m.luStr = CHRTRAN(NVL(m.luStr, ""), ["э], [э"])
			RETURN CHRTRAN(m.luStr, " !#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~®ЄєјЅ¬√ƒ≈«»… ЋћЌќѕ–—“”‘’÷„ЎўЏџ№Ёёяабвгдежзийклмнопрстуфхцчшщъыью€", ;
				"€юьыъщшчцхфутсрпонмлкйизжедгвбаяёЁ№џЏўЎ„÷’‘”“—–ѕќЌћЋ …»«≈ƒ√¬ЅјєЄ®~}|{zyxwvutsrqponmlkjihgfedcba`_^]\[ZYWVUTSRQPONMLKJIHGFEDCBA@?>=<;:9876543210/.-,+*)('&%$#! ")
		CASE VARTYPE(m.luStr) == "N"
			m.lnPrecision = IIF(VARTYPE(m.lnPrecision)=="N", m.lnPrecision, 18)
			m.lnScale = IIF(VARTYPE(m.lnScale)=="N", m.lnScale, 2)
			RETURN Revers( NumToStr( m.luStr, m.lnPrecision, m.lnScale ))
		CASE VARTYPE(m.luStr) = "D"
			m.luStr = NVL(m.luStr, {})
			RETURN  STR(99999999 - VAL(DTOS(m.luStr)))
		OTHERWISE
			RETURN ""
	ENDCASE
ENDFUNC

FUNCTION NumToStr
	LPARAMETERS luStr, lnPrecision, lnScale
	luStr = NVL(luStr, 0)
	lnPrecision = IIF(VARTYPE(lnPrecision)=="N", lnPrecision, 18)
	lnScale = IIF(VARTYPE(lnScale)=="N", lnScale, 2)
	RETURN IIF(luStr < 0, 'A', 'Z') + ;
		IIF(luStr < 0, STR(-99999999999999.99 - luStr,lnPrecision,lnScale), STR(luStr,lnPrecision,lnScale))
ENDFUNC

FUNCTION SaveToINIFile
	LPARAMETERS lcName, lcRasdel, lcValue, lcIniFile
	*-- «апись одного параметра в INI - файл
	LOCAL lcEntry, lPath
	m.lcIniFile = IIF(VARTYPE(m.lcIniFile) == "C", m.lcIniFile, INIFILE)
	m.lPath = SYS(5)+SYS(2003) + '\'
	=WritePrivStr(m.lcRasdel, m.lcName, m.lcValue, m.lPath + m.lcIniFile)
ENDFUNC

FUNCTION ReadFromINIFile
	LPARAMETERS lcName, lcRasdel, lcIniFile
	*-- „тение одного параметра из INI - файла
	LOCAL  lcBuffer, lcRetValue, lPath
	m.lcIniFile = IIF(VARTYPE(m.lcIniFile) == "C", m.lcIniFile, INIFILE)
	m.lPath = SYS(5)+SYS(2003) + '\'
	m.lcBuffer = SPACE(100) + CHR(0)
	*-- „итаем позицию окна из INI файла
	m.lcRetValue = ""
	TRY
		IF GetPrivStr(m.lcRasdel, m.lcName, "", @m.lcBuffer, LEN(m.lcBuffer), ;
				m.lPath + m.lcIniFile) > 0
			m.lcRetValue = ALLTRIM(LEFT(m.lcBuffer, AT(CHR(0), m.lcBuffer)-1))
		ENDIF
	CATCH
		m.lcRetValue = ""
	ENDTRY
	RETURN (m.lcRetValue)
ENDFUNC

FUNCTION FormIsObject()
	LPARAMETERS NameForm
	*-- ¬озвращает .T. если активна€ форма объект (тип- "O") и имеет
	*-- базовый класс "Form".
	IF PCOUNT() = 0 OR EMPTY(NameForm)
		RETURN (TYPE("_SCREEN.ActiveForm") == "O" AND ;
			UPPER(_SCREEN.ACTIVEFORM.BASECLASS) = "FORM")
	ELSE
		RETURN (TYPE("_SCREEN.ActiveForm") == "O" AND ;
			UPPER(_SCREEN.ACTIVEFORM.BASECLASS) = "FORM" ;
			AND UPPER(NameForm) == UPPER(_SCREEN.ACTIVEFORM.NAME))
	ENDIF
ENDFUNC
