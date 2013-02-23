%{
#include <stdint.h>
#include <string.h>

#include "y.tab.h"

#define YY_NO_UNPUT

void read_comment();
int read_data();
int read_ident();
int read_int(int base);
int read_string();
%}

%option noyywrap

ident			[_[:alpha:]][_[:alnum:]]*

decdigits		[[:digit:]]+
octdigits		[0-7]+
hexdigits		[[:xdigit:]]+

data			(\\.|[^'\\])*
string			[^\"]*

whitespace		[[:space:]]+

%%

"#"			read_comment();

"break"			return BREAK;
"continue"		return CONTINUE;
"else"			return ELSE;
"export"		return EXPORT;
"for"			return FOR;
"foreach"		return FOREACH;
"function"		return FUNCTION;
"global_var"		return GLOBAL;
"if"			return IF;
"import"		return IMPORT;
"include"		return INCLUDE;
"local_var"		return LOCAL;
"repeat"		return REPEAT;
"return"		return RETURN;
"until"			return UNTIL;
"x"			return REP;
"while"			return WHILE;

"FALSE"			return FALSE;
"NULL"			return UNDEF;
"TRUE"			return TRUE;

"><"			return SUBSTR_EQ;
">!<"			return SUBSTR_NE;

"=~"			return REGEX_EQ;
"!~"			return REGEX_NE;

"=="			return CMP_EQ;
"!="			return CMP_NE;
"<="			return CMP_LE;
">="			return CMP_GE;

"="			return ASS_EQ;
"+="			return ADD_EQ;
"-="			return SUB_EQ;
"*="			return MUL_EQ;
"/="			return DIV_EQ;
"%="			return MOD_EQ;
">>="			return SRL_EQ;
">>>="			return SRA_EQ;
"<<="			return SLL_EQ;

"||"			return OR;
"&&"			return AND;
"!"			return NOT;

"|"			return BIT_OR;
"^"			return BIT_XOR;
"&"			return BIT_AND;
">>>"			return BIT_SRA;
">>"			return BIT_SRL;
"<<"			return BIT_SLL;

"<"			return CMP_LT;
">"			return CMP_GT;

"++"			return INCR;
"--"			return DECR;

"**"			return EXP;

"+"			return ADD;
"-"			return SUB;
"*"			return MUL;
"/"			return DIV;
"%"			return MOD;

"~"			return BIT_NOT;

"."			return PERIOD;
","			return COMMA;
":"			return COLON;
";"			return SEMICOLON;
"("			return LPAREN;
")"			return RPAREN;
"["			return LBRACK;
"]"			return RBRACK;
"{"			return LBRACE;
"}"			return RBRACE;

{ident}			return read_ident();

0[xX]{hexdigits}	return read_int(16);
0{octdigits}		return read_int(8);
{decdigits}		return read_int(10);

'{data}'		return read_data();
\"{string}\"		return read_string();

{whitespace}		/* Ignored. */

%%

void read_comment()
{
	char ch;

	/* Consume input until EOL or EOF. */
	do {
		ch = input();
	} while (ch != '\n' && ch != 0);
}

int read_data()
{
	yylval.str = strdup(yytext);

	return DATA;
}

int read_ident()
{
	yylval.str = strdup(yytext);

	return IDENT;
}

int read_int(int base)
{
	yylval.num = (int32_t) strtol(yytext, NULL, base);

	return INTEGER;
}

int read_string()
{
	yylval.str = strdup(yytext);

	return STRING;
}
