// C preamble
%{

#include "routines.h"

extern "C" {
    void yyerror(const char *s);
    int yylex(void);
}

int httprequest, httpversion, bodychunked, bodylength, chunksize;

%}

%union {
    int hex_value;
    int contains_chunked;
    const char* text;
}

// lexer produced terminals
%token CRLF SP EMPTYS LWS CHAR NONWS QDTEXT TEXT
%token<text> TOKEN
%token<hex_value> HEX

// non-terminals with types
%type<contains_chunked> VALUE

/* -------------------- Rule Section -------------------- */
%%

HTTP    :   HTTP_START { bodychunked = 0; bodylength = 0; }
        |   HEADERS
        |   CRLF
        |   BODY
        |   HTTP
        |   %empty
        ;
URL     :   NONWS;
HTTP_START  : VERSION SP STATUS TAILOP CRLF;
            | TOKEN SP URL SP VERSION CRLF { httprequest = 1; };
TAILOP  :   SP TEXT
        |   %empty;
VERSION :   "HTTP/1.0" { httpversion = 0; }
        |   "HTTP/1.1" { httpversion = 1; }
        ;
STATUS  :   HEX;
HEADERS :   HEADER CRLF HEADERS
        |   %empty
        ;
HEADER  :   TOKEN ":" VALUE {
                if (!strcmp($1, "Content-Length")) {
                    bodylength = $3;
                }
                else if (!strcmp($1, "Transfer-Encoding")) {
                    bodychunked = $3;
                }
            }
        ;
VALUE   :   HEX
        |   TEXT VALUE
        |   LWS VALUE
        |   %empty
        ;

BODY: %?{ bodylength > 0 } BODY_SKIPPED { skip_chars(bodylength); }
    | %?{ bodylength == 0 } BODY_NO_LEN;
BODY_SKIPPED: %empty;
BODY_NO_LEN : %?{ bodychunked == 0 } BODY_VERSION
            | %?{ bodychunked == 1 } CHUNK_BODY;
BODY_VERSION: %?{ httpversion == 0 } TAIL_DROPPED { drop_tail(); }
            | %?{ httpversion == 1 } EMPTYS ;
TAIL_DROPPED: %empty;
CHUNK_BODY  : HEX { chunksize = $1; } CHUNK_EXTENSION CRLF { skip_chars(chunksize); } CRLF CHUNK_BODY
            | "0" CRLF HEADERS CRLF
            | "0;" TEXT CRLF HEADERS CRLF
            ;
CHUNK_EXTENSION : ";" TEXT
                | %empty
                ;

%%
/* ----------------- Subroutine Section ----------------- */

void yyerror(const char *format) {
	puts("[ERROR]\t");
	puts(format);
}

// forward arbitrary params to vprintf
void yyerror(const char *format, ...) {
	printf("[ERROR]\t");

	va_list args;
	va_start(args, format);
	vprintf(format, args);
	va_end(args);

	printf("\n");
}

int main(int argc, char *argv[]) {
	const char* input_file, * output_file;
	if (argc < 2) {
        printf("No input file specified, abort.");
        return -1;
    }
	input_file = argv[1];

	FILE* fp = fopen(input_file, "r");
	if (fp == NULL) {
		yyerror("Cannot open file \'%s\'", input_file);
		return -1;
	}

	// altering the yyin(default stdin) to the test file 
	extern FILE* yyin;
	yyin = fp;

	printf("-----begin parsing %s-----\n", input_file);
	yyparse();
	printf("-----end parsing-----\n");

	fclose(fp);
	return 0;
}