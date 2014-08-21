#undef STANDALONE
#define STANDALONE 0
#include "scheme.c"
#include <assert.h>

int check_count = 0;
int fail_count = 0;
int error_count = 0;

void check(char *expression, char *expect)
{
	scheme *sc;
	char *statement;
	pointer result;
	FILE *initf;

	sc = scheme_init_new();
	initf = fopen("init.scm", "r");
	scheme_load_named_file(sc, initf, "init.scm");
	fclose(initf);
	scheme_set_input_port_file(sc, stdin);
	scheme_set_output_port_file(sc, stdout);

	statement = (char*)malloc(2*strlen(expression) +  2*strlen(expect) + 512);
	sprintf(statement, "\
(define (check)\n\
  (let ((result %s))\n\
    (if (equal? result '%s)\n\
      #t\n\
      (begin\n\
	(display \"FAIL: \")\n\
	(write '%s)\n\
	(display \" => \")\n\
	(write '%s)\n\
	(display \" got: \")\n\
	(write result)\n\
	(newline)\n\
	#f))))",
		expression, expect,
		expression,
		expect);
	scheme_load_string(sc, statement);
	free(statement);

	result = scheme_apply0(sc, "check");
	if (result == sc->T) {
		++check_count;
	} else if (result == sc->F) {
		++check_count;
		++fail_count;
	} else {
		++check_count;
		++error_count;
	}

	scheme_deinit(sc);
}

int main(int argc, char **argv)
{
	check("(length '(1 2 3))", "3");
	check("(length '#(1 2))", "2");
	check("(element '(1 2) 0)", "1");
	check("(element '(1 2) 1)", "2");

	printf(" %s: %d tests, %d failed, %d errors.\n", argv[0], check_count, fail_count, error_count);
	if (fail_count == 0 && error_count == 0)
		exit(0);
	else
		exit(1);
}
