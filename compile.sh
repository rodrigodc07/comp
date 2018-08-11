bison -d trab.y
flex trab.l
cc lex.yy.c trab.tab.c -o trab
