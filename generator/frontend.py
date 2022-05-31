# frontend.py
# TODO: CURRENTLY RUBBISH, NEED REDO WITH bison/antlr

import rule

def read_ruleset(file):
    sid = 0
    prio = 100
    result = []
    for line in file:
        tokens = line.split(' ')
        cur_rule = rule.Rule(prio)
        cur_rule.lhs = rule.Variable(tokens[0], sid)
        sid += 1
        cur_rule.rhs.append(rule.RETerminal('re%d' % sid, sid, tokens[2]))
        sid += 1
        prio -= 1
        result.append(cur_rule)
