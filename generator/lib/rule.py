class Symbol(object):
    def __init__(self, name, sid):
        self.name = name
        self.sid = sid

class Terminal(Symbol):
    def __init__(self, name, sid, text):
        super().__init__(name, sid)
        # text should be string with escapes intact
        self.text = text
    def to_define_statement(self):
        return '%s = %s ;' % (self.name, self.text)

class RETerminal(Terminal):
    def __init__(self, name, sid, text):
        super().__init__(name, sid, text)

class Variable(Symbol):
    def __init__(self, name, sid):
        super().__init__(name, sid)

class Rule(object):
    def __init__(self, priority=0, lhs=None, rhs=[], action=''):
        # priority should be uint32_t
        self.priority = priority
        # lhs should be Variable
        self.lhs = lhs
        # rhs should be a list of Symbols
        self.rhs = rhs
        # action should be a c fragment
        self.action = action
        # predicate should be a c expression
        self.predicate = '1'

class TerminalRule(Rule):
    '''
        TerminalRules are the rules that only have an terminal at rhs,
        including re terminals.
    '''
    def __init__(self, priority=0, lhs=None, rhs=[None], action=''):
        super().__init__(priority, lhs, rhs, action)
    def to_match_statement(self):
        return '%s\n @ltag %s { %s }\n' % (self.rhs[0].to_define_statement(), self.rhs[0].name, self.action)

class RegularRule(Rule):
    '''
        RegularRules are the rules that only have two symbols at rhs;
        the first is a terminal and the second is a non-terminal.
    '''
    def __init__(self, priority=0, lhs=None, rhs=[None, None], action=''):
        super().__init__(priority, lhs, rhs, action)
    def to_match_goto_statement(self):
        return '%s\n @ltag %s { %s }\n' % (self.rhs[0].to_define_statement(), self.rhs[0].name, self.action + \
            'if (' + self.predicate + ') {' + \
                'goto ' + self.rhs[1].name + '1 ;' + \
            '}' + \
            'else {' + \
                'goto ' + self.rhs[1].name + '0 ;' + \
            '}'
        )

class SharedLHSRegularRuleSeq(object):
    '''
        SharedLHSRegularRuleSeq is a sequence of Rules having the same lhs
        (with the same value of predicate), in priority desc order.
        The field `seq` contains RegularRules or TerminalRules.
        It is a basic block to construct the lpdfa rules.
    '''
    def __init__(self, seq=[None], lhs_name='', predicate_val='0'):
        self.seq = seq
        self.lhs_name = lhs_name
        self.predicate_val = predicate_val
    def to_match_block(self):
        self.seq.sort(reverse=True, key=lambda r : r.priority)
        block = []
        for rule in self.seq:
            if (isinstance(rule, TerminalRule)):
                block.append(rule.to_match_statement())
            elif (isinstance(rule, RegularRule)):
                block.append(rule.to_match_goto_statement())
            else:
                raise Exception('Provided grammar may not be regular!')
        return ''.join(block)

class RegularGrammar(object):
    '''
        RegularGrammar is a set of SharedLHSRegularRuleSeqs.
        The init state is the state of the first ruleseq.
    '''
    def __init__(self, seq=[None]):
        self.seq = seq
    def to_match_body(self):
        body = []
        for block in self.seq:
            body.append(block.lhs_name + block.predicate_val + ':\n/*!re2c\n')
            # TODO: judge whether to add th eps or EOF rules
            # Add empty rule and EOF rule
            body.append(r'''
                *   { return -1; }
                $   { return count; }
            ''')
            body.append(block.to_match_block())
            body.append('*/\n')
        return ''.join(body)