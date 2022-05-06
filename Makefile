# file name definitions
GRAMMER_NAME = HTTP
LEXICAL_NAME = HTTP
INTERMEDIATE = routines

# tools
LEX = flex
YACC = bison
CC = g++

# CC debug/optimize option
OPT = -O2

# parser
OBJECT = HTTPpar

$(OBJECT): $(LEXICAL_NAME).yy.o $(GRAMMER_NAME).tab.o $(INTERMEDIATE).o
	$(CC) $^ -o $@ $(OPT)

$(LEXICAL_NAME).yy.o: $(LEXICAL_NAME).yy.c $(GRAMMER_NAME).tab.h $(INTERMEDIATE).h
	$(CC) -c $(LEXICAL_NAME).yy.c $(INTERMEDIATE).h $(OPT)

$(GRAMMER_NAME).tab.o: $(GRAMMER_NAME).tab.c $(INTERMEDIATE).h
	$(CC) -c $(GRAMMER_NAME).tab.c $(INTERMEDIATE).h $(OPT)

$(INTERMEDIATE).o: $(INTERMEDIATE).c $(INTERMEDIATE).h
	$(CC) -c $(INTERMEDIATE).c $(INTERMEDIATE).h $(OPT)

$(GRAMMER_NAME).tab.c $(GRAMMER_NAME).tab.h: $(GRAMMER_NAME).y
	$(YACC) -d -v $(GRAMMER_NAME).y

$(LEXICAL_NAME).yy.c: $(LEXICAL_NAME).l
	$(LEX) -o $@ $(LEXICAL_NAME).l

clean:
	@rm -f $(OBJECT) *.o *.tab.c *.tab.h *.yy.c *.h.gch *.output