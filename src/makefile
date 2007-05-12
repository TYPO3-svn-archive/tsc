

#--- Running ---------------------------------------------------

ts1 : cleansilent tsc ../examples/input1.ts  
		./tsc < ../examples/input1.ts	

ts2 : cleansilent tsc ../examples/input2.ts
	./tsc < ../examples/input2.ts

ts3 : cleansilent tsc ../examples/input3.ts
	./tsc < ../examples/input3.ts


#--- Making ---------------------------------------------------

tsc : lex.yy.c y.tab.c   
	cc lex.yy.c y.tab.c -o tsc 

lex.yy.c : tsc.l y.tab.h tsc.h
	lex	tsc.l

y.tab.h: tsc.y tsc.h
	yacc -d tsc.y 

y.tab.c: tsc.y tsc.h
	yacc -d tsc.y 


#---Cleaning up ---------------------------------------------------

cleansilent :
	/bin/rm -f *.c
	/bin/rm -f y.tab.*

cleanmsg :
	echo "Folgende Dateien werden nun gelöscht:"
	echo "      " *.c
	echo "      " y.tab.* 

clean : cleanmsg cleansilent	

