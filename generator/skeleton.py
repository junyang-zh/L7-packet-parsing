header_skeleton = r'''
#ifndef PARSE
#define PARSE

#include "routines.h"
#include "yyprimitives.h"

int parse();

#endif
'''

re_skeleton = r"""
#include "parse.h"

extern FILE* istream;

int parse() {
    Input in;
    in.file = istream;
    in.cur = in.mar = in.tok = in.lim = in.buf + BUFSIZE;
    in.eof = 0;
    in.lim[0] = YYEOF;

    int count = 0;
    const ubyte *ltag;
    /*!stags:re2c format = 'const ubyte *@@;\n'; */
    /*!re2c
        re2c:api:style = free-form;
        re2c:define:YYCTYPE  = ubyte;
        re2c:define:YYCURSOR = in.cur;
        re2c:define:YYMARKER = in.mar;
        re2c:define:YYLIMIT  = in.lim;
        re2c:define:YYFILL   = "yyfill(in) == 0";
        re2c:eof = 255;
        re2c:tags = 1;
    */
    // The body of the match logic will be added here
    %s
    return -1;
}
"""

def generate_header():
    global header_skeleton
    return header_skeleton

def generate_re(body):
    global re_skeleton
    return re_skeleton % body