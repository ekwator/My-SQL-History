*-- ����������� �������
#INCLUDE	"MAIN.H"

DEFINE CLASS SHeader AS Header
	*-- ����� Header ��� GridBases
	Name = "SHeader"
	Caption = "���������"
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
		*-- ����� ������ SetOrder ������� Grid
		IF THIS.lIsSort
			THIS.lIsSort = .F.
			THIS.Parent.Parent._SetOrder(THIS)
		ENDIF
	ENDPROC
	PROCEDURE RightClick
		LOCAL lnMesto, llResult
		*-- ��������, ��� �������� �� Header
		llResult = THIS.Parent.Parent.GridHitTest(THIS.lnMouseX, THIS.lnMouseY, @lnMesto)
		IF llResult AND (lnMesto = 1)
			THIS.Parent.Parent._SetOption(THIS)
		ENDIF
	ENDPROC
ENDDEFINE

*-- ����� ������� ��� "���������" Grid
DEFINE CLASS SColumn AS Column
	FontChangeAllow = .T.
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
	sDefaultCaption = ""		&& ������������������� ��������� 
	nGrouped = 0
	sAggFunc = ''
	sAggregate = ''
	sFiltrColumn = ''
	sFiltrValue = ''
	nOrderNumber = 0
	sCaptionOriginal = ''		&& ���������� ���������
	sOrderDirect = ''
	sKeyOrderAsc = ''
	sKeyOrderDesc = ''
	lIsNotHide = .F.		&& .T. - ������� ������ ������, .F. - �����
	lIsOrdered = .T.		&& .T. - ������� ����� ����������� � ����������
	lIsFiltred = .T.		&& .T. - ������� ����� ����������� � ����������
	lIsAggregate = 1
	*-- lIsAggregate = 0 - ������� ������ ������������
	*-- lIsAggregate = 1 - �����
	*-- lIsAggregate = 2 - �������
	*-- lIsAggregate = 3 - ���-��
	*-- lIsAggregate = 4 - �������
	*-- lIsAggregate = 5 - ��������
	lIsEdit = .F.
	ColumnControl = "SText1"	&& ������, ������� ����� ���������� � ������ �������
	PROCEDURE Init()
		WITH THIS
			SET TALK OFF
			.AddObject("SText1", "TextBoxForBasesGrid")
			.SText1.Visible = .T.
			.CurrentControl = "SText1"
		ENDWITH
	ENDPROC
	PROCEDURE _FiltrColumnAssign
		LPARAMETERS vNewVal
		THIS.Filtr_Column = m.vNewVal
		THIS.SHeader1.ToolTipText = THIS.SHeader1.sToolTipTextOld + ;
			IIF(EMPTY(m.vNewVal), "", IIF(EMPTY(THIS.SHeader1.sToolTipTextOld), "", "; ") + ;
				"������: " + ALLTRIM(CAST(THIS.sFiltrColumn AS C(254))))
	ENDPROC
	PROCEDURE Moved()
		LOCAL i
		THIS.SHeader1.lIsSort = .F.
		IF TYPE("THIS.Parent.oAgrGrid")=="O" AND THIS.Parent.oAgrGrid.Visible
			*-- ���� ������� ����� ���������, �� ������������� ColumnOrder
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
		*-- ��� ���������� ��� ��� ���������� ������
	ENDPROC
	PROCEDURE _GotFocusToTxt()
		*-- ���������� ��� ��������� ������ �� SText

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

	PROCEDURE _CaptionOriginalAssign
		LPARAMETERS lcCaption
		THIS.sDefaultCaption = m.lcCaption
		IF THIS.Parent.lIsRenameColumnEvent
			THIS.Parent._RenameHeaderCaption(THIS, THIS.sCaptionOriginal)
		ENDIF
	ENDPROC
ENDDEFINE
