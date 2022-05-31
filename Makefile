# User-defined variables
TARGET=httppar
GRAMMAR=example/http.ccfg

# Build variables
CC=g++
CFLAGS=-O2 -I. -I./runtime
MAKE=make

RE2C_DIR=./thirdparty/re2c
RE2C=$(RE2C_DIR)/re2c

GENERATED_H=./parse.h
GENERATED_RE=./parse.re
GENERATED_C=./parse.c

C_FILES=$(wildcard runtime/*.c) $(GENERATED_C)
HEADERS=$(wildcard runtime/*.h) $(GENERATED_H)
OBJECTS=$(patsubst %.c,%.o,$(C_FILES))

.PHONY: all clean

all: $(TARGET)

clean:
	rm -rf $(GENERATED_H) $(GENERATED_RE) $(GENERATED_C) $(OBJECTS) $(TARGET)

# Build the re2c submodule (used by generator)
$(RE2C):
	cd $(RE2C_DIR) && autoreconf -i -W all && ./configure --prefix=`pwd` && $(MAKE) && $(MAKE) install

# Generate parse.h and parse.c from grammar file using the python generator
$(GENERATED_H) $(GENERATED_RE): $(GRAMMAR)
	python generator/generator.py $(GRAMMAR) --$(subst parse.,o,$@) $@

$(GENERATED_C): $(RE2C) $(GENERATED_RE)
	$< $(GENERATED_RE) -o $@ -i --case-ranges

# Build all the .o files
$(OBJECTS):

# Link all the objects
$(TARGET): $(GENERATED_C) $(GENERATED_H) $(OBJECTS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJECTS)