void skip_chars(size_t count) {
	extern FILE* yyin;
    while (count--) fgetc(yyin);
}