public m.oSysMias,m.oMias		
SET TALK OFF
SET SAFE OFF
SET NEAR ON
SET DELETED ON
SET DATE GERMAN
SET HOURS TO 24
SET CENTUR ON
SET CONFIRM OFF
SET EXCLUSIVE OFF
SET COLLATE TO "MACHINE"
*SET MULTILOCKS ON
SET EXACT OFF
SET DEBUG OFF
SET STEP OFF
LOCAL m.cNamePath
m.cNamePath='BMP\;Data\;libs\;Progs\;Forms\;menus\;reports\';
			+';FORMS\DOCS\;FORMS\DOCS\PEDIATR\;FORMS\SPR\;FORMS\JU\';
			+';FORMS\REPORTS\;FORMS\DOCS\LAB\;FORMS\OTHER\'
SET PATH TO (m.cNamePath) ADDITIVE 
*SET Path to  BMP\;Data\;libs\;Progs\;Forms\;menus\;reports\;FORMS\DOCS\;FORMS\DOCS\PEDIATR\;FORMS\SPR\;FORMS\JU\;FORMS\REPORTS\;FORMS\DOCS\LAB\
*SET PATH TO FORMS\DOCS\;FORMS\DOCS\PEDIATR\ ADDITIVE
*SET PATH to ;FORMS\DOCS\LAB\; ADDITIVE
SET CLASSLIB TO Vvk_Mias


* ����-�������� ���������� ��� ������ �� Windows
ON SHUTDOWN DO ExitProg
* ���������� ������
ON ERROR DO ChekErr WITH ERROR(),MESSAGE(),MESSAGE(1),PROGRAM(),LINENO(1) IN start

m.oSysMias=CREATEOBJECT('_sysMias')
m.oMias=CREATEOBJECT('_cntMias')
m.oMias.isDir('TEMP')
m.oMias.isDir('DATA')
DO FORM registration 
DO mainMenu.mpr
*return

*DO FORM start


READ Events

ON ERROR
ON SHUTDOWN



* ������������ ������� ��������� ������
FUNCTION ChekErr
	LPARAMETERS _Error,_Message,_Message1,_Program,_Lineno1
	LOCAL lcErrMessage, lnFH
	lcErrMessage='� ��������� '+_Program+' ��������� ������ (������ '+TRANSFORM(_Lineno1)+')'+CHR(13)+CHR(10)+;
		'������ N:'+TRANSFORM(_Error)+' '+_Message+CHR(13)+CHR(10)+;
		'�������� ���: '+_Message1
	MESSAGEBOX(lcErrMessage,16)

	IF ! FILE('Err.log')
		lnFH=FCREATE('Err.log')
	ELSE
		lnFH=FOPEN('Err.log',2)
	ENDIF

	IF lnFH<>-1
		FSEEK(lnFH,0,2)
		FPUTS(lnFH,lcErrMessage)
		FPUTS(lnFH,'')
		FCLOSE(lnFH)
	ENDIF

	ON SHUTDOWN
	ON ERROR
	KEYBOARD '{ENTER}' PLAIN CLEAR
	RETRY
ENDFUNC
******************************