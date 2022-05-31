#include "yyprimitives.h"

int yyfill(Input &in) {
    if (in.eof) return 1;

    const size_t shift = in.tok - in.buf;
    const size_t used = in.lim - in.tok;

    // Error: lexeme too long. In real life could reallocate a larger buffer.
    if (shift < 1) return 2;

    // Shift buffer contents (discard everything up to the current token).
    memmove(in.buf, in.tok, used);
    in.lim -= shift;
    in.cur -= shift;
    in.mar -= shift;
    in.tok -= shift;

    // Fill free space at the end of buffer with new data from file.
    in.lim += fread(in.lim, 1, BUFSIZE - used, in.file);
    in.lim[0] = YYEOF;
    in.eof = in.lim < in.buf + BUFSIZE;
    return 0;
}
