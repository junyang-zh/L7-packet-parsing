class Symbol(object):
    def __init__(self, name, sid):
        self.name = name
        self.sid = sid

class Terminal(Symbol):
    def __init__(self, name, sid, text):
        super().__init__(name, sid)
        # text should be string with escapes intact
        self.text = text

class RETerminal(Terminal):
    def __init__(self, name, sid, text):
        super().__init__(name, sid, text)

class Variable(Symbol):
    def __init__(self, name, sid):
        super().__init__(name, sid)

class Rule(object):
    def __init__(self, priority=0):
        # priority should be uint32_t
        self.priority = priority
        # lhs should be Variable
        self.lhs = None
        # rhs should be a list of Symbols
        self.rhs = []