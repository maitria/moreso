#include "check.h"

int main(int argc, char **argv)
{
	check("(length '(1 2 3))", "3");
	check("(length '#(1 2))", "2");
	check("(element '(1 2) 0)", "1");
	check("(element '(1 2) 1)", "2");
	check("(let ((v (vector 1 2 3))) (set-element! v 1 42) v)",
	      "#(1 42 3)");

	finish(argv[0]);
}
