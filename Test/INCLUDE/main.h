*-- ����� ��������� ����������
*-- ������ ���� ������ ���� ������� � ����� ����� ����������

#INCLUDE 	STRINGS.H
#INCLUDE 	FOXPRO.H
#INCLUDE	KEYBOARD.H
#INCLUDE	VB_CONSTANT.H

*-- ��� ������� DEBUGMODE ������ ���� .T.
*-- ��� �������� ������ ���������� ���������� DEBUGMODE � .F.
*-- � ����������������� ���� !!! ������

#DEFINE		DEBUGMODE	.T.

#DEFINE 	NAME_MAIN_WINDOW	"���������������� ������"
#DEFINE		INIFILE				"USER.INI"

*-- �������� ������ WAIT
#DEFINE		WAIT_TIMEOUT		1

#DEFINE CRLF  CHR(13) + CHR(10)
#DEFINE CR    CHR(13)
#DEFINE TAB    CHR(9)

*-- ��� ��������� ������������ � ������ 
*-- ��� ��������� ������� �������� ������
#DEFINE FILE_OK    0
#DEFINE FILE_BOF  1
#DEFINE FILE_EOF  2
#DEFINE FILE_CANCEL  3

#DEFINE			OPEN_FOLDER		0x31
#DEFINE			CLOSE_FOLDER	0x30
#DEFINE			NOT_CHILDREN	0x9F

