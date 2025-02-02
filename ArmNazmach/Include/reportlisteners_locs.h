* locs for VCX super-classes

#DEFINE OUTPUTCLASS_APPNAME_LOC              "��� ����� - ����������� ����������"

#DEFINE OUTPUTCLASS_CONFIGTABLECREATED_LOC   "���������������� ������� "+ lcDBF + " �������."
                                             
#DEFINE OUTPUTCLASS_CONFIGTABLEWRONG_LOC     "���������������� ������� ����� �� ���������� ������."

* this is different from XML because in the XML class they
* are used in SEEK() and require specific tagnames, whereas
* the superclasses just require certain indexes for optimizing LOCATES,

#DEFINE OUTPUTCLASS_CONFIGINDEXMISSING_LOC   "���������������� ������� ����������� "+ CHR(13) + ;
                                                                                                   "���� ��� ����� ��������� ��������."

#DEFINE OUTPUTCLASS_INITSTATUS_LOC           "�������������... "
#DEFINE OUTPUTCLASS_PREPSTATUS_LOC           "������� �������... "
#DEFINE OUTPUTCLASS_RUNSTATUS_LOC            "���������� ������... "
#DEFINE OUTPUTCLASS_TIME_SECONDS_LOC         SPACE(1) + "������ (�)"
#DEFINE OUTPUTCLASS_CANCEL_INSTRUCTIONS_LOC  "������� Esc ��� ������... "
#DEFINE OUTPUTCLASS_REPORT_CANCELQUERY_LOC   "���������� ���������� ������?"+CHR(13) + ;
                                             "(���� ������� '���(No)', ���������� ������ ������������.)"
#DEFINE OUTPUTCLASS_REPORT_INCOMPLETE_LOC    "���������� ������ ���� ��������." + CHR(13) + ;
                                             "�� �������� �� ������ ���������."

#DEFINE OUTPUTCLASS_SUCCESS_LOC              THIS.sAppName+" ������� ��� ����� ���" + ;
                                             CHR(13) + THIS.sTargetFileName+"." + CHR(13) + ;
                                             IIF(THIS.lAllowModalMessages,;
                                              "������� '��(Yes)' ��� ����������" + CHR(13) + ;
                                             "����� ����� ����� � ������ ������.","")

#DEFINE OUTPUTCLASS_NOFILECREATE_LOC         "���� " + THIS.sTargetFileName+" �� ����� ���� ������."

#DEFINE OUTPUTCLASS_CREATEERRORS_LOC         THIS.sAppName+" ������ ��� ������ ���"+ ;
                                             CHR(13)+THIS.sTargetFileName+". "+CHR(13)+ ;
                                             "������ ��������� ������ � ��������." + CHR(13) + ;
                                             OUTPUTCLASS_REPORT_INCOMPLETE_LOC

#DEFINE OUTPUTCLASS_NOCREATE_LOC             THIS.sAppName +" �� �������� ��� �������� ������."
 
#DEFINE OUTPUTCLASS_ERRNOLABEL_LOC           "������:           "
#DEFINE OUTPUTCLASS_ERRPROCLABEL_LOC         "�����:       "
#DEFINE OUTPUTCLASS_ERRLINELABEL_LOC         "�����:            " 

* the following loc is eval'd for updateListener's actual progress bar message.  
* In most cases,
* changing this value is overkill, as the localizable portions of
* the message are already localized as separate properties.
* All the status messagse as well as the therm caption can
* also be set at runtime without touching the locs.
#DEFINE OUTPUTCLASS_THERMCAPTION_LOC        [cMessage+ " "+ TRANSFORM(INT(THIS.nPercentDone*100)) + "%" ] + ;
                                            [+ IIF(NOT THIS.lIncludeSeconds, "" , " "+] + ;
                                            [TRANSFORM(IIF(THIS.lIsRunning,DATETIME(), THIS.dReportStopRunDateTime)-] + ;
                                            [THIS.dReportStartRunDateTime)+" " + THIS.sSecondsText)]


* locs for XML Listener class:

#DEFINE OUTPUTXML_APPNAME_LOC               "XML Listener"

#DEFINE OUTPUTXML_CONFIGTAGMISSING_LOC      "At least one required index tag is missing "+ CHR(13) + ;
                                            "from the configuration table."

#DEFINE OUTPUTXML_FRXMISSING_LOC            "Required FRX cursor is not available." 
   
   
#DEFINE OUTPUTXML_FRXCURSOR_MISSING_LOC     "FRX cursor helper object cannot be found in " + CHR(13)+ ;
                                            "_FRXCURSOR.VCX, "+CHR(13)+ ; 
                                            "_REPORTOUTPUT." + CHR(13) + CHR(13)+ ;
                                            "Some features of this class may not be active."   

* locs for XML Display Listener Class:

#DEFINE OUTPUTXMLDISPLAY_APPNAME_LOC        "XML Display Listener"

* locs for HTML:

#DEFINE OUTPUTHTML_APPNAME_LOC              "HTML Listener"