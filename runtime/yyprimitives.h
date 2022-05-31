#ifndef YYPRIMITIVES
#define YYPRIMITIVES
/*
#define  YYCTYPE                  int

// *cursor
#define  YYPEEK()                 (fgetc(istream), fseek(istream, -1, SEEK_CUR))
// ++cursor
#define  YYSKIP()                 (fgetc(istream))
// marker = cursor
#define  YYBACKUP()               (marker = ftell(istream))
// cursor = marker
#define  YYRESTORE()              (fseek(istream, marker, SEEK_SET))
// ctxmarker = cursor
#define  YYBACKUPCTX()            (ctxmarker = ftell(istream))
// cursor = ctxmarker
#define  YYRESTORECTX()           (fseek(istream, ctxmarker, SEEK_SET))
// cursor = tag
#define  YYRESTORETAG(tag)        (fseek(istream, tag, SEEK_SET))
// limit - cursor < len
#define  YYLESSTHAN(len)          (limit - ftell(istream) < len)
// tag = cursor
#define  YYSTAGP(tag)             (tag = ftell(istream))
// tag = NULL
#define  YYSTAGN(tag)             (tag = 0)
// cursor += shift
#define  YYSHIFT(shift)           (fseek(istream, shift, SEEK_CUR))
// tag += shift
#define  YYSHIFTSTAG(tag, shift)  (tag += shift)
*/

#include <cstdio>
#include <cstring>

#define BUFSIZE 4095
#define YYEOF 0xFF

typedef unsigned char ubyte;

typedef struct Input {
    FILE *file;
    ubyte buf[BUFSIZE + 1], *lim, *cur, *mar, *tok; // +1 for sentinel
    bool eof;
} Input;

int yyfill(Input &in);

#endif // YYPRIMITIVES