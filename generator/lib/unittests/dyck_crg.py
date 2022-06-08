'''
    The Dyck (e.g. "[[[][[]]][]][]") CRG is:
    {cnt==0} S  -> ;
                |  '[' {cnt += 1;} S;
    {cnt>0}  S  -> ']' {cnt -= 1;} S;
                |  '[' {cnt += 1;} S;
'''

from .. import rule

def gen_ruleset():
    state = rule.Variable('S', 1)
    rule.RegularRule()