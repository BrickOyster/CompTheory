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

all:
	@echo "\n array_comprehension\n" 
	make array_comprehension
	@echo "\n bookstore\n" 
	make bookstore
	@echo "\n prime\n" 
	make prime
	@echo "\n qsort_comprehension\n" 
	make qsort_comprehension
	@echo "\n qsort\n" 
	make qsort
	@echo "\n qsortWithComp\n" 
	make qsortWithComp
	@echo "\n reverseWithComprehension\n" 
	make reverseWithComprehension
	@echo "\n useless\n" 
	make useless

array_comprehension: LambdaCodeExamples/array_comprehension.la;
	./myLexer < LambdaCodeExamples/array_comprehension.la > o.c
	@echo "\n"
	gcc o.c -o output
	@echo "\n"
	./output
	
bookstore: LambdaCodeExamples/bookstore.la;
	./myLexer < LambdaCodeExamples/bookstore.la > o.c
	gcc o.c -o output
	@echo "\n"
	./output

prime: LambdaCodeExamples/prime.la;
	./myLexer < LambdaCodeExamples/prime.la > o.c
	gcc o.c -o output
	@echo "\n"
	./output

qsort_comprehension: LambdaCodeExamples/qsort_comprehension.la;
	./myLexer < LambdaCodeExamples/qsort_comprehension.la > o.c
	gcc o.c -o output
	@echo "\n"
	./output

qsort: LambdaCodeExamples/qsort.la;
	./myLexer < LambdaCodeExamples/qsort.la > o.c
	gcc o.c -o output
	@echo "\n"
	./output

qsortWithComp: LambdaCodeExamples/qsortWithComp.la;
	./myLexer < LambdaCodeExamples/qsortWithComp.la > o.c
	gcc o.c -o output
	@echo "\n"
	./output

reverseWithComprehension: LambdaCodeExamples/reverseWithComprehension.la;
	./myLexer < LambdaCodeExamples/reverseWithComprehension.la > o.c
	gcc o.c -o output
	@echo "\n"
	./output

useless: LambdaCodeExamples/useless.la;
	./myLexer < LambdaCodeExamples/useless.la > o.c
	gcc o.c -o output
	@echo "\n"
	./output

h: 
	@echo "h	: Display this message"
	@echo "default	: Compile myLexer (Run by calling 'make')"
	@echo "clean	: Remove and remake default"

.DEFAULT:
	@echo "Input $@ unrecognized."
	@echo "h	: Display this message"
	@echo "default	: Compile myLexer (Run by calling 'make')"
	@echo "clean	: Remove and remake default"