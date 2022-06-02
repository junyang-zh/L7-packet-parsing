import copy

from .. import rule

def get_ruleset():
    lex_rules = r'''
        crlf :        ([\r]?[\n]) ;
        sp :          ([\x20]) ;
        emptys :      ([\x00]*) ;
        lws :         (([\r]?[\n])?[ \t]+) ;
        char :        ([\x00-\x7f]) ;
        hex :         ([A-Fa-f0-9]+) ;
        nonws :       ([^\x00-\x1f\x7f ]+) ;
        qdtext :      ([^\x00-\x1f\x7f"]+) ;
        text :        ([^\x00-\x1f\x7f]+) ;
        token :       ([^\x00-\x1f\(\)<>@,;:\\"\/\[\]?={}]+) ;
    '''
    state = rule.Variable('S', 1)
    sid = 1
    prio = 100
    result = []
    for line in lex_rules.strip().split('\n'):
        if (line == ''):
            continue
        tokens = line.split(':')
        prio -= 1
        cur_rule = rule.RegularRule(prio)
        cur_rule.lhs = state
        cur_rule.action = \
        'printf("%8s    |   %.*s\\n"  , "' + tokens[0].strip() + '", (int)(in.cur-ltag), ltag); count++;'
        cur_rule.rhs[0] = rule.RETerminal('re%d' % sid, sid, ''.join(tokens[1:]).strip()[:-2])
        sid += 1
        cur_rule.rhs[1] = state
        result.append(copy.deepcopy(cur_rule))
    blocks = [rule.SharedLHSRegularRuleSeq(result, 'S', '1'), rule.SharedLHSRegularRuleSeq([], 'S', '0')]
    return rule.RegularGrammar(blocks)