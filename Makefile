# User-defined variables
TARGET=httppar
GRAMMAR=example/http.ccfg

# Build variables
CC=gcc
CFLAGS=-O2 -I. -I./runtime

GENERATED_H=parse.h
GENERATED_C=parse.c

C_FILES=$(wildcard runtime/*.c) $(GENERATED_C)
HEADERS=$(wildcard runtime/*.h) $(GENERATED_H)
OBJECTS=$(patsubst %.c,%.o,$(C_FILES))

.PHONY: all clean

all: $(TARGET)

clean:
	rm -rf $(GENERATED_H) $(GENERATED_C) $(OBJECTS) $(TARGET)

# Generate parse.h and parse.c from grammar file using the python generator
$(GENERATED_H) $(GENERATED_C): $(GRAMMAR)
	python generator/generator.py $^ --$(subst parse.,o,$@) $@

# Build all the .o files
$(OBJECTS):

# Link all the objects
$(TARGET): $(GENERATED_C) $(GENERATED_H) $(OBJECTS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJECTS)