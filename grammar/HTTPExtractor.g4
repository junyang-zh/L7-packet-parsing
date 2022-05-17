grammar HTTPExtractor;

// These are all supported parser sections:

// Parser file header. Appears at the top in all parser related files. Use e.g. for copyrights.
@parser::header {/* parser/listener/visitor header section */}

// Appears before any #include in h + cpp files.
@parser::preinclude {/* parser precinclude section */}

// Follows directly after the standard #includes in h + cpp files.
@parser::postinclude {
/* parser postinclude section */
#ifndef _WIN32
#pragma GCC diagnostic ignored "-Wunused-parameter"
#endif
}

// Directly preceeds the parser class declaration in the h file (e.g. for additional types etc.).
@parser::context {
int httprequest, httpversion, bodychunked, bodylength, chunksize;
}

// Appears in the private part of the parser in the h file.
// The function bodies could also appear in the definitions section, but I want to maximize
// Java compatibility, so we can also create a Java parser from this grammar.
// Still, some tweaking is necessary after the Java file generation (e.g. bool -> boolean).
@parser::members {
/* public parser declarations/members section */
void skip_chars(size_t count) {
    extern FILE* yyin;
    while (count--) fgetc(yyin);
}
void drop_tail() {
    // idk what to do
}
}

// Appears in the public part of the parser in the h file.
@parser::declarations {/* private parser declarations section */}

// Appears in line with the other class member definitions in the cpp file.
@parser::definitions {/* parser definitions section */}

// Additionally there are similar sections for (base)listener and (base)visitor files.
@parser::listenerpreinclude {/* listener preinclude section */}
@parser::listenerpostinclude {/* listener postinclude section */}
@parser::listenerdeclarations {/* listener public declarations/members section */}
@parser::listenermembers {/* listener private declarations/members section */}
@parser::listenerdefinitions {/* listener definitions section */}

@parser::baselistenerpreinclude {/* base listener preinclude section */}
@parser::baselistenerpostinclude {/* base listener postinclude section */}
@parser::baselistenerdeclarations {/* base listener public declarations/members section */}
@parser::baselistenermembers {/* base listener private declarations/members section */}
@parser::baselistenerdefinitions {/* base listener definitions section */}

@parser::visitorpreinclude {/* visitor preinclude section */}
@parser::visitorpostinclude {/* visitor postinclude section */}
@parser::visitordeclarations {/* visitor public declarations/members section */}
@parser::visitormembers {/* visitor private declarations/members section */}
@parser::visitordefinitions {/* visitor definitions section */}

@parser::basevisitorpreinclude {/* base visitor preinclude section */}
@parser::basevisitorpostinclude {/* base visitor postinclude section */}
@parser::basevisitordeclarations {/* base visitor public declarations/members section */}
@parser::basevisitormembers {/* base visitor private declarations/members section */}
@parser::basevisitordefinitions {/* base visitor definitions section */}


// Lexer works
Crlf:		('\r'?'\n');
Sp:	        ('\u0020');
Emptys:		('\u0000'+);
Lws:		(('\r'?'\n')?[ \t]+);
Char:		('\u0000'..'\u007f');
Hex:		([A-Fa-f0-9]+);
Nonws:		([^\u0000-\u001f\u007f ]+);
Qdtext:		([^\u0000-\u001f\u007f"]+);
Text:		([^\u0000-\u001f\u007f]+);
Token:		((~([\u0000-\u001f] | [()<>@,:\\;"/?={|}] | '[' | ']'))+);

// Actual grammar start.
http    :   http_start { bodychunked = 0; bodylength = 0; }
        |   headers
        |   Crlf
        |   body
        //|   http
        |   // empty
        ;
url     :   Nonws;
http_start  : version Sp status tailop Crlf
            | Token Sp url Sp version Crlf { httprequest = 1; };
tailop  :   Sp Text
        |   // empty
        ;
version :   'http/1.0' { httpversion = 0; }
        |   'http/1.1' { httpversion = 1; }
        ;
status  :   Hex;
headers :   header Crlf headers
        |   // empty
        ;
header  :   'Content-Length' ':' value {
                bodylength = $value.text;
            }
        |   'Transfer-Encoding' ':' value {
                bodychunked = $value.text;
            }
        |   Token ':' value
        ;
value   :   Hex
        |   Text value
        |   Lws value
        |   // empty
        ;

body: { bodylength > 0 }? body_skipped { skip_chars(bodylength); }
    | { bodylength == 0 }? body_no_len;
body_skipped: // empty
            ;
body_no_len : { bodychunked == 0 }? body_version
            | { bodychunked == 1 }? chunk_body;
body_version: { httpversion == 0 }? tail_dropped { drop_tail(); }
            | { httpversion == 1 }? Emptys ;
tail_dropped: // empty
            ;
chunk_body  : Hex { chunksize = $Hex; } chunk_extension Crlf { skip_chars(chunksize); } Crlf chunk_body
            | '0' Crlf headers Crlf
            | '0;' Text Crlf headers Crlf
            ;
chunk_extension : ';' Text
                | // empty
                ;
