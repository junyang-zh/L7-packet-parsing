#include "routines.h"

void skip_chars(size_t count) {
	extern FILE* yyin;
    while (count--) fgetc(yyin);
}

void drop_tail() {
    // idk what to do
}