import argparse

parser = argparse.ArgumentParser(description='Parser generator')
parser.add_argument('input_ccfg_file', metavar='I', type=str,
                    help='input file path')
parser.add_argument('--oh', dest='output_header', action='store',
                    help='path of the header file')
parser.add_argument('--ore', dest='output_re', action='store',
                    help='path of the c file (re file)')
args = parser.parse_args()

with open(args.input_ccfg_file, 'r') as fin:
    import skeleton
    if (args.output_header):
        with open(args.output_header, 'w+') as foh:
            foh.write(skeleton.generate_header())
    if (args.output_re):
        from lib.unittests.http_lex import get_ruleset
        ruleset = get_ruleset()
        with open(args.output_re, 'w+') as fore:
            fore.write(skeleton.generate_re(ruleset.to_match_body()))