default: myparser.y myrules.l cgen.c;
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

exam:
	make bookstore
	make reverseWithComprehension
	make prime

bookstore: bookstore.la;
	./myLexer < bookstore.la > bookstore.c
	gcc bookstore.c -o bookstore_app
	@echo "\n"
	./bookstore_app
	
reverseWithComprehension: reverseWithComprehension.la;
	./myLexer < reverseWithComprehension.la > reverseWithComprehension.c
	gcc reverseWithComprehension.c -o reverseWithComprehension_app
	@echo "\n"
	./reverseWithComprehension_app

prime: prime.la;
	./myLexer < prime.la > prime.c
	gcc prime.c -o prime_app
	@echo "\n"
	./prime_app

h: 
	@echo "h	: Display this message"
	@echo "default	: Compile myLexer (Run by calling 'make')"
	@echo "clean	: Remove and remake default"

.DEFAULT:
	@echo "Input $@ unrecognized."
	@echo "h	: Display this message"
	@echo "default	: Compile myLexer (Run by calling 'make')"
	@echo "clean	: Remove and remake default"