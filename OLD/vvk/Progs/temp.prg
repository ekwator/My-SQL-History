=isdir('temp')
*=NewIdMKB(1000)
***************************************
FUNCTION isdir
LPARAMETERS m.cNameDirectory	&&Наименование искомого каталога (директории)
LOCAL m.rez, m.cRun
m.Rez=.t.
	IF !DIRECTORY(m.cNameDirectory)
		m.cRun='MKDIR '+m.cNameDirectory
		&cRun
		=MESSAGEBOX('Каталог-'+m.cNameDirectory+'Создан')
	ENDIF 
RETURN m.rez
***************************************
FUNCTION NewIdMKB
LPARAMETERS m.KolNewRecords
FOR m.mmm=1 TO m.KolNewRecords
	m.id=oSysMias._id()
	m.id1=m.id
	m.AscId=ALLTRIM(STR(ASC(SUBSTR(m.id,1))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,2))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,3))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,4))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,5))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,6))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,7))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,8))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,9))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,10))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,11))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,12))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,13))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,14))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,15))));
			+'+'+ALLTRIM(STR(ASC(SUBSTR(m.id,16))))
	m.csqlCom='insert into __temp ';
					+'(id,id1,AscId)';
					+'values (?m.id,?m.id1,?m.AscId)'
	=SQLEXEC(oSysmias.nconnectsqlreal,m.csqlCom)
endfor
return
***************************************************
FUNCTION ProbaId
m.nnsek=SECONDS()
	FOR m.nn=1 TO 1000
		oSysMias._id()
	ENDFOR
?'   -'
??m.nn
??' Вызовов за:'
??SECONDS()-m.nnsek
??' секунд'
RETURN
***************************************************
FUNCTION Vozrast
	Lparam d_r,d_s
	privat vozr
	y=year(m.d_s)-year(m.d_r)
	do case
		case month(m.d_s)>month(m.d_r)
			vozr=m.y
		case month(m.d_s)<month(m.d_r)
			vozr=m.y-1
		case month(m.d_s)=month(m.d_r) 
			vozr=iif(day(m.d_s)>day(m.d_r),m.y,m.y-1)
	endcase 
return vozr

