cmnd = "$1"

default: myrules.l;
	@bison -d -v -r all myparser.y
	@flex myrules.l
	@gcc -o myLexer myparser.tab.c lex.yy.c cgen.c -lfl

clean: lex.yy.c  myLexer;
	@rm lex.yy.c
	@rm myLexer
	@rm myparser.tab.c
	@rm myparser.tab.h
	@rm myparser.output
	@make

h: 
	@echo "h	: Display this message"
	@echo "default	: Compile myLexer (Run by calling 'make')"
	@echo "clean	: Remove and remake default"

.DEFAULT:
	@echo "Input $@ unrecognized."
	@echo "h	: Display this message"
	@echo "default	: Compile myLexer (Run by calling 'make')"
	@echo "clean	: Remove and remake default"