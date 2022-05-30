#include "routines.h"

extern FILE* istream;

void skip_bytes(long offset) {
    fseek(istream, offset, SEEK_CUR);
}