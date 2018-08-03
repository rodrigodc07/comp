bison -d g6.y
flex g6.l
cc lex.yy.c g6.tab.c -o g6
