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
S1:
    /*!re2c
        *       { return -1; }
        $       { return count; }
        %s
    */
    }
S0:
    return 0;
}
"""

with open(args.input_ccfg_file, 'r') as fin:
    if (args.output_header):
        with open(args.output_header, 'w+') as foh:
            foh.write(default_header)
    if (args.output_re):
        from lib.unittests.http_lex import get_ruleset
        ruleset = get_ruleset()
        with open(args.output_re, 'w+') as fore:
            fore.write(default_re % ruleset.to_match_block())