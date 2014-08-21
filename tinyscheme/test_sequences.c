#include "check.h"

int main(int argc, char **argv)
{
	check("(length '(1 2 3))", "3");
	check("(length '#(1 2))", "2");
	check("(element '(1 2) 0)", "1");
	check("(element '(1 2) 1)", "2");
	finish(argv[0]);
}
