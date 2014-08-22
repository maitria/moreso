#include "check.h"

void check_string_p_returns_t_for_char_vectors()
{
	check("(string? '#(#\\a #\\b #\\c))", "#t");
	check("(string? '#())", "#t");
	check("(string? '#(#\\a #\\b 42))", "#f");
	check("(string? 42)", "#f");
}

void check_subvector_works()
{
	check("(subvector #(#\\a #\\b #\\c) 1 2)", "#(#\\b)");
	check("(subvector #(#\\a #\\b #\\c) 1)", "#(#\\b #\\c)");
	check("(subvector #(#\\a #\\b #\\c) 0)", "#(#\\a #\\b #\\c)");
	check("(subvector #(#\\a #\\b #\\c) 3)", "#()");
	check("(subvector #(1 2 3) 1 2)", "#(2)");
}

void check_as_vector()
{
	check("(as-vector #(#\\a 2 #\\c))", "#(#\\a 2 #\\c)");
	check("(as-vector #(#\\a 3 #\\c) #(5 #f))", "#(#\\a 3 #\\c 5 #f)");
}

void check_element()
{
	check("(element \"abc\" 1)", "#\\b");
}

void check_length()
{
	check("(length \"abc\")", "3");
}

int main(int argc, char **argv)
{
	check_string_p_returns_t_for_char_vectors();
	check_subvector_works();
	check_as_vector();
	check_element();
	check_length();
	finish(argv[0]);
}
