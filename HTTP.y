%token HTTP

%{
    int bodychunked, bodylength, httpversion;
%}

/* -------------------- Rule Section -------------------- */
%%

HTTP :      HTTP_START
            { bodychunked = 0; bodylength = 0; }
        |   HEADERS
        |   CRLF
        |   BODY
        |   HTTP
        |   %empty
        ;
URL : NONWS;
HTTP_START : VERSION SP STATUS TAILOP CRLF;
HTTP_START 10 : TOKEN SP URL SP VERSION CRLF { httprequest = 1 };
TAILOP : SP TEXT;
TAILOP : ;
VERSION: HTTP\/1\.0 { httpversion = 0 };
VERSION: HTTP\/1\.1 { httpversion = 1 };
VERSION 10 : HTTP\/[0-9]+\.[0-9]+;
STATUS : /\d\d\d/;
HEADERS : HEADER CRLF HEADERS;
HEADERS : ;
HEADER : /(?i:Content-Length):\s*/ { bodylength = getnum() };
HEADER : /(?i:Transfer-Encoding: \s*chunked)/ { bodychunked = 1 };
HEADER 10 : TOKEN /:/ VALUE;
VALUE : TEXT VALUE;
VALUE : LWS VALUE;
VALUE : ;

BODY [bodylength > 0] : // { bodylength = skip(bodylength) };
BODY [bodylength == 0] : BODY_NO_LEN;
BODY_NO_LEN [bodychunked == 1] : CHUNK_BODY;
BODY_NO_LEN [bodychunked == 0] : BODY_VERSION;
BODY_VERSION [httpversion == 0] : // [bodylength := drop_tail()];
BODY_VERSION [httpversion == 1] : /\x00*/ ;
    /* BODY_VERSION [httpversion == 1; httprequest == 0] : // [bodylength := drop_tail()] ; */
BODY_XML : CRLF [bodyend := bodyend + pos()] XML;
CHUNK_BODY : // [chunksize := gethex()] CHUNK_EXTENSION CRLF [chunksize := skip(chunksize)] CRLF CHUNK_BODY;
CHUNK_BODY 99 : /0/ CRLF HEADERS CRLF;
CHUNK_BODY 99 : /0;/ TEXT CRLF HEADERS CRLF;
CHUNK_EXTENSION : /;/ TEXT;
CHUNK_EXTENSION : ;
XML : XVER XENV [bodyend := skip_to(bodyend)];
XVER : /:\?xml\ version="1\.0"\?>\s*/ ;
XENV : /<soap:Envelope\xmlns:soap="http:\/\/www\.w3\.org\ /2003\/05\/soap-envelope">/ XHDR XBDY /<\/soap:Envelope>/ ;
XHDR : /\s*<soap:Header>\s*<\/soap:Header>\s*/ ;
XBDY : /\s*<soap:Body>\s*/ ARRAY /\s*<\/soap:Body>\s*/;
ARRAY : /<array>/ ARRAY /<\/array>/
ARRAY ; ARRAY : ;

%%
/* ----------------- Subroutine Section ----------------- */