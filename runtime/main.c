/*  main.c
    The entry point of the parser
*/

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

#include "parse.h"

// The global input stream
FILE* istream = NULL;

int main(int argc, char *argv[]) {

    // Parsing arguments
    enum { HELP_MODE, PARSE_MODE } mode = PARSE_MODE;
    int opt;
    while ((opt = getopt(argc, argv, "h")) != -1) {
        switch (opt) {
        case 'h': mode = HELP_MODE; break;
        default:
            fprintf(stderr, "Usage: %s [-h] [file]\n", argv[0]);
            exit(EXIT_FAILURE);
        }
    }

    // Handles modes other than PARSE_MODE
    switch (mode) {
    case HELP_MODE:
        fprintf(stdout, "This is a generated parser.\n");
        return 0;
    case PARSE_MODE:
        break;
    default: exit(EXIT_FAILURE);
    }

    // Parsing
    /// Setting the input stream
    if (optind < argc) {
        istream = fopen(argv[optind], "rb");
        if (istream == NULL) {
            perror(argv[optind]);
            exit(EXIT_FAILURE);
        }
    }
    else {
        fprintf(stdout, "Usage: %s [-h] [file]\n", argv[0]);
        exit(EXIT_FAILURE);
    }
    /// Start the user defined parsing program
    parse();
    fclose(istream);
    return 0;
}