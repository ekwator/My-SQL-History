*-- Определения классов
#INCLUDE	"MAIN.H"

DEFINE CLASS SHeader AS Header
	*-- Класс Header для GridBases
	BackColor = RGB(136,192,184)
	Name = "SHeader"
	Caption = "Заголовок"
	Alignment = 2
	FontName = "Arial"
	FontSize = 8
	WordWrap = .T.
	lIsSort = .F.
	lnMouseX = 0
	lnMouseY = 0
	sToolTipTextOld = ""
	PROCEDURE Init
		WITH THIS
			.sToolTipTextOld = .ToolTipText
		ENDWITH
	ENDPROC
	PROCEDURE MouseDown()
		LPARAMETERS nButton, nShift, nXCoord, nYCoord
		WITH THIS
			.lnMouseX = nXCoord
			.lnMouseY = nYCoord
			.lIsSort = .T.
		ENDWITH
	ENDPROC
	PROCEDURE Click
		*-- Вызов метода SetOrder объекта Grid
		IF THIS.lIsSort
			THIS.lIsSort = .F.
			THIS.Parent.Parent._SetOrder(THIS)
		ENDIF
	ENDPROC
	PROCEDURE RightClick
		LOCAL lnMesto, llResult
		*-- Проверям, что щелкнули на Header
		llResult = THIS.Parent.Parent.GridHitTest(THIS.lnMouseX, THIS.lnMouseY, @lnMesto)
		IF llResult AND (lnMesto = 1)
			THIS.Parent.Parent._SetOption(THIS)
		ENDIF
	ENDPROC
ENDDEFINE

*-- Класс колонки для "Разумного" Grid
DEFINE CLASS SColumn AS Column
	lFontChangeAllow = .T.
	BackColor = RGB(255,255,255)
	FontName = "Arial"
	FontSize = 8
	Name = "SColumn"
	HeaderClass = "SHeader"
	HeaderClassLibrary = "class_define.prg"
	sFormat = 'Z'
	sDefaultFont = ''
	lDefaultVisible = .T.
	nDefaultWidth = 0
	nDefaultOrder = 0
	sDefaultCaption = ""		&& Запрограммированный заголовок 
	nGrouped = 0
	sAggFunc = ''
	sAgregate = ''
	sFiltrColumn = ''
	sFiltrValue = ''
	nOrderNumber = 0
	sCaptionOriginal = ''		&& Измененный заголовок
	sOrderDirect = ''
	sKeyOrderAsc = ''
	sKeyOrderDesc = ''
	lIsNotHide = .F.		&& .T. - колонку нельзя скрыть, .F. - можно
	lIsOrdered = .T.		&& .T. - колонка может участвовать в сортировке
	lIsFiltred = .T.		&& .T. - колонка может участвовать в фильтрации
	lIsAgregate = 1
	*-- lIsAgregate = 0 - колонку нельзя агрегировать
	*-- lIsAgregate = 1 - сумма
	*-- lIsAgregate = 2 - среднее
	*-- lIsAgregate = 3 - Кол-во
	*-- lIsAgregate = 4 - минимум
	*-- lIsAgregate = 5 - максимум
	lIsEdit = .F.
	ColumnControl = "SText1"	&& Объект, который будет выводиться в данную колонку
	PROCEDURE Init()
		WITH THIS
			SET TALK OFF
			.AddObject("SText1", "TextBoxForBasesGrid")
			.SText1.Visible = .T.
			.CurrentControl = "SText1"
		ENDWITH
	ENDPROC
	PROCEDURE sFiltrColumn_Assign
		LPARAMETERS vNewVal
		THIS.sFiltrColumn = m.vNewVal
		THIS.SHeader1.ToolTipText = THIS.SHeader1.sToolTipTextOld + ;
			IIF(EMPTY(m.vNewVal), "", IIF(EMPTY(THIS.SHeader1.sToolTipTextOld), "", "; ") + ;
				"ФИЛЬТР: " + ALLTRIM(CAST(THIS.sFiltrColumn AS C(254))))
	ENDPROC
	PROCEDURE Moved()
		LOCAL i
		THIS.SHeader1.lIsSort = .F.
		IF TYPE("THIS.Parent.oAgrGrid")=="O" AND THIS.Parent.oAgrGrid.Visible
			*-- Если включен режим агрегатов, то устанавливаем ColumnOrder
			FOR i = 1 TO THIS.Parent.ColumnCount
				THIS.Parent.oAgrGrid.Columns(i).ColumnOrder = THIS.Parent.Columns(i).ColumnOrder
			ENDFOR
		ENDIF
		IF THIS.Parent.lIsMoveColumnEvent
			THIS.Parent._ColumnMove(THIS)
		ENDIF
	ENDPROC
	PROCEDURE RightClick
		THIS.Parent.RightClick()
	ENDPROC
	PROCEDURE _UpdateData()
		LPARAMETERS lValue
		*-- Тут помещается код для обновления данных
	ENDPROC
	PROCEDURE _GotFocusToTxt()
		*-- Вызывается при попадания фокуса на SText

	ENDPROC
	PROCEDURE Resize()
		LOCAL i
		IF (TYPE("THIS.Parent.oAgrGrid") == "O") AND THIS.Parent.oAgrGrid.Visible
			FOR m.i = 1 TO THIS.Parent.ColumnCount
				IF THIS.Parent.oAgrGrid.Columns[m.i].ColumnOrder = THIS.ColumnOrder
					EXIT
				ENDIF
			ENDFOR
			THIS.Parent.oAgrGrid.Columns[m.i].Width = THIS.Width
		ENDIF
		IF THIS.Parent.lIsResizeColumnEvent
			THIS.Parent._ColumnResize(THIS)
		ENDIF
	ENDPROC

	PROCEDURE sCaptionOriginal_Assign
		LPARAMETERS lcCaption
		THIS.sDefaultCaption = m.lcCaption
		IF THIS.Parent.lIsRenameColumnEvent
			THIS.Parent._RenameHeaderCaption(THIS, THIS.sCaptionOriginal)
		ENDIF
	ENDPROC
ENDDEFINE
