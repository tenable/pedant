%{
#include <stdint.h>
#include <string.h>

#include "y.tab.h"

#define YY_NO_UNPUT

int convert(int base);
%}

%option noyywrap

ident			[_[:alpha:]][_[:alnum:]]*
decdigits		[[:digit:]]+
hexdigits		[[:xdigit:]]+
whitespace		[[:space:]]+

%%

"#"			{ /*comment();*/ return BREAK; }

"break"			{ return BREAK; }
"continue"		{ return CONTINUE; }
"else"			{ return ELSE; }
"export"		{ return EXPORT; }
"for"			{ return FOR; }
"foreach"		{ return FOREACH; }
"function"		{ return FUNCTION; }
"global_var"		{ return GLOBAL; }
"if"			{ return IF; }
"import"		{ return IMPORT; }
"include"		{ return INCLUDE; }
"local_var"		{ return LOCAL; }
"repeat"		{ return REPEAT; }
"return"		{ return RETURN; }
"until"			{ return UNTIL; }
"x"			{ return REP; }
"while"			{ return WHILE; }

"FALSE"			{ return FALSE; }
"NULL"			{ return UNDEF; }
"TRUE"			{ return TRUE; }

"><"			{ return SUBSTR_EQ; }
">!<"			{ return SUBSTR_NE; }

"=~"			{ return REGEX_EQ; }
"!~"			{ return REGEX_NE; }

"=="			{ return CMP_EQ; }
"!="			{ return CMP_NE; }
"<="			{ return CMP_LE; }
">="			{ return CMP_GE; }

"="			{ return ASS_EQ; }
"+="			{ return ADD_EQ; }
"-="			{ return SUB_EQ; }
"*="			{ return MUL_EQ; }
"/="			{ return DIV_EQ; }
"%="			{ return MOD_EQ; }
">>="			{ return SRL_EQ; }
">>>="			{ return SRA_EQ; }
"<<="			{ return SLL_EQ; }

"||"			{ return OR; }
"&&"			{ return AND; }
"!"			{ return NOT; }

"|"			{ return BIT_OR; }
"^"			{ return BIT_XOR; }
"&"			{ return BIT_AND; }
">>>"			{ return BIT_SRA; }
">>"			{ return BIT_SRL; }
"<<"			{ return BIT_SLL; }

"<"			{ return CMP_LT; }
">"			{ return CMP_GT; }

"++"			{ return INCR; }
"--"			{ return DECR; }

"**"			{ return EXP; }

"+"			{ return ADD; }
"-"			{ return SUB; }
"*"			{ return MUL; }
"/"			{ return DIV; }
"%"			{ return MOD; }

"~"			{ return BIT_NOT; }

"."			{ return PERIOD; }
","			{ return COMMA; }
":"			{ return COLON; }
";"			{ return SEMICOLON; }
"("			{ return LPAREN; }
")"			{ return RPAREN; }
"["			{ return LBRACK; }
"]"			{ return RBRACK; }
"{"			{ return LBRACE; }
"}"			{ return RBRACE; }

{ident}			{ yylval.str = strdup(yytext); return IDENT; }

0[xX]{hexdigits}	{ return convert(16); }
0{decdigits}		{ return convert(8); }
{decdigits}		{ return convert(10); }

{whitespace}		/* Ignored. */

%%

void comment()
{
	char ch;

	/* Consume input until EOL or EOF. */
	do {
		ch = input();
	} while (ch != '\n' && ch != 0);
}

int convert(int base)
{
	yylval.num = 42;

	return INTEGER;
}
