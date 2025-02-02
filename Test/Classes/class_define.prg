*-- ����������� �������
#INCLUDE	INCLUDE\MAIN.H

DEFINE CLASS SHeader AS Header
	*-- ����� Header ��� "���������" Grid
	Name = "SHeader"
	Caption = "���������"
	Alignment = 2
	FontName = "Arial"
	FontSize = 8
	WordWrap = .T.
	IsSort = .F.
	lnMouseX = 0
	lnMouseY = 0
	ToolTipTextOld = ""
	PROCEDURE Init
		WITH THIS
			.ToolTipTextOld = .ToolTipText
		ENDWITH
	ENDPROC
	PROCEDURE MouseDown()
		LPARAMETERS nButton, nShift, nXCoord, nYCoord
		WITH THIS
			.lnMouseX = nXCoord
			.lnMouseY = nYCoord
			.IsSort = .T.
		ENDWITH
	ENDPROC
	PROCEDURE Click
		*-- ����� ������ SetOrder ������� Grid
		IF THIS.IsSort
			THIS.IsSort = .F.
			THIS.Parent.Parent.SetOrder(THIS)
		ENDIF
	ENDPROC
	PROCEDURE RightClick
		LOCAL lnMesto, llResult
		*-- ��������, ��� �������� �� Header
		llResult = THIS.Parent.Parent.GridHitTest(THIS.lnMouseX, THIS.lnMouseY, @lnMesto)
		IF llResult AND (lnMesto = 1)
			THIS.Parent.Parent.SetOption(THIS)
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
	Format = 'Z'
	Default_Font = ''
	Default_Visible = .T.
	Default_Width = 0
	Default_Order = 0
	Default_Caption = ""
	Grouped = 0
	AggFunc = ''
	Aggregate = ''
	Filtr_Column = ''
	Filtr_Value = ''
	Order_Number = 0
	Caption_Original = ''
	Order_Direct = ''
	Key_Order_Asc = ''
	Key_Order_Desc = ''
	IsNotHide = .F.		&& .T. - ������� ������ ������, .F. - �����
	IsOrdered = .T.		&& .T. - ������� ����� ����������� � ����������
	IsFiltred = .T.		&& .T. - ������� ����� ����������� � ����������
	Caption_Default = ''
	IsAggregate = 1
	*-- IsAggregate = 0 - ������� ������ ������������
	*-- IsAggregate = 1 - �����
	*-- IsAggregate = 2 - �������
	*-- IsAggregate = 3 - ���-��
	*-- IsAggregate = 4 - �������
	*-- IsAggregate = 5 - ��������
	IsEdit = .F.
	ColumnControl = "SText1"	&& ������, ������� ����� ���������� � ������ �������
	PROCEDURE Init()
		WITH THIS
			SET TALK OFF
			.AddObject("SText1", "Text_For_Smart_Grid")
			.SText1.Visible = .T.
			.CurrentControl = "SText1"
		ENDWITH
	ENDPROC
	PROCEDURE Filtr_Column_Assign
		LPARAMETERS vNewVal
		THIS.Filtr_Column = m.vNewVal
		THIS.SHeader1.ToolTipText = THIS.SHeader1.ToolTipTextOld + ;
			IIF(EMPTY(m.vNewVal), "", IIF(EMPTY(THIS.SHeader1.ToolTipTextOld), "", "; ") + ;
				"������: " + ALLTRIM(CAST(THIS.Filtr_Column AS C(254))))
	ENDPROC
	PROCEDURE Moved()
		LOCAL i
		THIS.SHeader1.IsSort = .F.
		IF TYPE("THIS.Parent.oAgrGrid")=="O" AND THIS.Parent.oAgrGrid.Visible
			*-- ���� ������� ����� ���������, �� ������������� ColumnOrder
			FOR i = 1 TO THIS.Parent.ColumnCount
				THIS.Parent.oAgrGrid.Columns(i).ColumnOrder = THIS.Parent.Columns(i).ColumnOrder
			ENDFOR
		ENDIF
		IF THIS.Parent.IsMoveColumnEvent
			THIS.Parent.ColumnMove(THIS)
		ENDIF
	ENDPROC
	PROCEDURE RightClick
		THIS.Parent.RightClick()
	ENDPROC
	PROCEDURE UpdateData()
		LPARAMETERS lValue
		*-- ��� ���������� ��� ��� ���������� ������
	ENDPROC
	PROCEDURE GotFocusToTxt()
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
		IF THIS.Parent.IsResizeColumnEvent
			THIS.Parent.ColumnResize(THIS)
		ENDIF
	ENDPROC

	PROCEDURE Caption_Original_Assign
		LPARAMETERS lcCaption
		THIS.Caption_Original = m.lcCaption
		IF THIS.Parent.IsRenameColumnEvent
			THIS.Parent.RenameHeaderCaption(THIS, THIS.Caption_Original)
		ENDIF
	ENDPROC
ENDDEFINE
