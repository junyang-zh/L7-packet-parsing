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

class TerminalRule(Rule):
    def __init__(self, priority=0, lhs=None, rhs=[None], action=''):
        super().__init__(priority, lhs, rhs, action)
    def to_match_statement(self):
        return '%s\n @ltag %s { %s }\n' % (self.rhs[0].to_define_statement(), self.rhs[0].name, self.action)

class TerminalRuleSeq(object):
    def __init__(self, seq=[]):
        self.seq = seq
    def to_match_block(self):
        self.seq.sort(reverse=True, key=lambda r : r.priority)
        block = []
        for rule in self.seq:
            block.append(rule.to_match_statement())
        return ''.join(block)
