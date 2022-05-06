%{

#include "HTTP.tab.h"
#include "routines.h"

extern "C" {
	int yywrap(void);
	int yylex(void);
}

%}


crlf        (\r?\n)
sp          (\x20)
emptys      (\x00*)
lws         ((\r?\n)?[ \t]+)
char        ([\x00-\x7f])
hex         ([A-Fa-f0-9]+)
nonws       ([^\x00-\x1f\x7f ]+)
qdtext      ([^\x00-\x1f\x7f"]+)
text        ([^\x00-\x1f\x7f]+)
token       ([^\x00-\x1f\(\)<>@,;:\\"\/\[\]?={}]+)

/* -------------------- Rule Section -------------------- */
%%

{crlf}      { return CRLF; }
{sp}        { return SP; }
{emptys}    { return EMPTYS; }
{lws}       { return LWS; }
{char}      { return CHAR; }
{hex}       { yylval.hex_value = strtol(yytext, NULL, 16); return HEX; }
{nonws}     { return NONWS; }
{qdtext}    { return QDTEXT; }
{text}      { return TEXT; }
{token}     { yylval.text = strdup(yytext); return TOKEN; }

%%
/* ----------------- Subroutine Section ----------------- */

int yywrap(void) {
    puts("-----Lex: The File Ends-----\n");
    return 1;
}