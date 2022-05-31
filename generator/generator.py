import argparse

parser = argparse.ArgumentParser(description='Parser generator')
parser.add_argument('input_ccfg_file', metavar='I', type=str,
                    help='input file path')
parser.add_argument('--oh', dest='output_header', action='store',
                    help='path of the header file')
parser.add_argument('--ore', dest='output_re', action='store',
                    help='path of the c file (re file)')
args = parser.parse_args()

default_header = '''
#ifndef PARSE
#define PARSE

#include "routines.h"
#include "yyprimitives.h"

int parse();

#endif
'''
default_re = r"""
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

    for (;;) {
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
    /*!re2c
        crlf =        ([\r]?[\n]) ;
        sp =          ([\x20]) ;
        emptys =      ([\x00]*) ;
        lws =         ([\r]?[\n]?[ \t]+) ;
        char =        ([\x00-\x7f]) ;
        hex =         ([A-Fa-f0-9]+) ;
        nonws =       ([^\x00-\x1f\x7f ]+) ;
        text =        ([^\x00-\x1f\x7f]+) ;
        qdtext =      ([^\x00-\x1f\x7f"]+) ;
        token =       ([^\x00-\x1f\(\)<>@,;:\\"\/\[\]?={}]+) ;
    */
    /*!re2c
        *       { return -1; }
        $       { return count; }
        @ltag   crlf    { printf("%8s    |   %.*s\n"  , "crlf", (int)(in.cur-ltag)-1, ltag); continue; }
        @ltag   emptys  { printf("%8s    |   %.*s\n"  , "emptys", (int)(in.cur-ltag)-1, ltag); continue; }
        @ltag   lws     { printf("%8s    |   %.*s\n"  , "lws", (int)(in.cur-ltag)-1, ltag); continue; }
        @ltag   char    { printf("%8s    |   %.*s\n"  , "char", (int)(in.cur-ltag)-1, ltag); count++; continue; }
        @ltag   hex     { printf("%8s    |   %.*s\n"  , "hex", (int)(in.cur-ltag)-1, ltag); count++; continue; }
        @ltag   nonws   { printf("%8s    |   %.*s\n"  , "nonws", (int)(in.cur-ltag)-1, ltag); count++; continue; }
        @ltag   text    { printf("%8s    |   %.*s\n"  , "text", (int)(in.cur-ltag)-1, ltag); count++; continue; }
        @ltag   qdtext  { printf("%8s    |   %.*s\n"  , "qdtext", (int)(in.cur-ltag)-1, ltag); count++; continue; }
        @ltag   token   { printf("%8s    |   %.*s\n"  , "token", (int)(in.cur-ltag)-1, ltag); count++; continue; }
    */
    }
    return 0;
}
"""

with open(args.input_ccfg_file, 'r') as fin:
    import frontend
    rules = frontend.read_ruleset(fin)
    
    if (args.output_header):
        with open(args.output_header, 'w+') as foh:
            foh.write(default_header)
    if (args.output_re):
        with open(args.output_re, 'w+') as fore:
            fore.write(default_re)