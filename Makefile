# file name definitions
GRAMMER_FILE = HTML
LEXICAL_FILE = C0Lex
INTERMEDIATE = Common

# tools
LEX = flex			# using the flex tool as the lexical analyzer
YACC = bison		# can be tested using the bison tool
CC = g++			# default compiler and linker

# CC debug/optimize option
OPT = -O3

# output and testing
OBJECT = HeliumC	# output parser
TESTFILE = TestFile.c0

$(OBJECT): $(LEXICAL_FILE).yy.o $(GRAMMER_FILE).tab.o $(INTERMEDIATE).o
	$(CC) $(LEXICAL_FILE).yy.o $(GRAMMER_FILE).tab.o $(INTERMEDIATE).o -o $(OBJECT) $(OPT)
	@./$(OBJECT) $(TESTFILE)

$(LEXICAL_FILE).yy.o: $(LEXICAL_FILE).yy.c $(GRAMMER_FILE).tab.h $(INTERMEDIATE).h
	$(CC) -c $(LEXICAL_FILE).yy.c $(INTERMEDIATE).h $(OPT)

$(GRAMMER_FILE).tab.o: $(GRAMMER_FILE).tab.c $(INTERMEDIATE).h
	$(CC) -c $(GRAMMER_FILE).tab.c $(INTERMEDIATE).h $(OPT)

$(INTERMEDIATE).o: $(INTERMEDIATE).c $(INTERMEDIATE).h
	$(CC) -c $(INTERMEDIATE).c $(INTERMEDIATE).h $(OPT)

$(GRAMMER_FILE).tab.c $(GRAMMER_FILE).tab.h: $(GRAMMER_FILE).y
	$(YACC) -d -v $(GRAMMER_FILE).y

$(LEXICAL_FILE).yy.c: $(LEXICAL_FILE).l
	$(LEX) -o $(LEXICAL_FILE).yy.c $(LEXICAL_FILE).l

clean:
	@rm -f $(OBJECT) *.o *.tab.c *.tab.h *.yy.c *.h.gch