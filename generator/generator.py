import argparse

parser = argparse.ArgumentParser(description='Parser generator')
parser.add_argument('input_ccfg_file', metavar='I', type=str,
                    help='input file path')
parser.add_argument('--oh', dest='output_header', action='store',
                    help='path of the header file')
parser.add_argument('--oc', dest='output_c', action='store',
                    help='path of the c file')
args = parser.parse_args()

default_header = '''
#include "routines.h"

int parse();
'''
default_c = '''
#include "parse.h"

extern FILE* istream;

int parse() {
    int c;
    while ((c = fgetc(istream)) != EOF) {
        printf("%c", c);
    }
    return 0;
}
'''

with open(args.input_ccfg_file, 'r') as fin:
    if (args.output_header):
        with open(args.output_header, 'w+') as foh:
            foh.write(default_header)
    if (args.output_c):
        with open(args.output_c, 'w+') as foc:
            foc.write(default_c)