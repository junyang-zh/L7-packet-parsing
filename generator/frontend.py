# frontend.py
# TODO: CURRENTLY RUBBISH, NEED REDO WITH bison/antlr

import rule
import copy

def read_ruleset(file):
    sid = 0
    prio = 100
    result = []
    for line in file:
        tokens = line.split(':')
        cur_rule = rule.TerminalRule(prio)
        cur_rule.lhs = rule.Variable(tokens[0], sid)
        cur_rule.action = 'printf("%8s    |   %.*s\\n"  , "' + cur_rule.lhs.name + '", (int)(in.cur-ltag), ltag); count++; continue;'
        sid += 1
        cur_rule.rhs[0] = rule.RETerminal('re%d' % sid, sid, ''.join(tokens[1:]).strip()[:-2])
        sid += 1
        prio -= 1
        result.append(copy.deepcopy(cur_rule))
    return rule.TerminalRuleSeq(result)
