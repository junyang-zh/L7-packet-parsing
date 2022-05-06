%{
#include "HTTP.tab.h"
%}


crlf        (\r?\n);
sp          (\x20);
lws         ((\r?\n)?[ \t]+);
char        ([\x00-\x7f]);
nonws       ([^\x00-\x1f\x7f ]+);
text        ([^\x00-\x1f\x7f]+);
qdtext      ([^\x00-\x1f\x7f"]+);
token       ([^\x00-\x1f()<>@,;:\\"\/[]?={}]+);

/* -------------------- Rule Section -------------------- */
%%



%%
/* ----------------- Subroutine Section ----------------- */