%{
#include <stdint.h>
#include <string.h>

#include "token.h"
#include "y.tab.h"

#define YY_NO_UNPUT

static pos_t position = 0;

int make_token(int type);
void read_comment();
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

"break"			return make_token(BREAK);
"continue"		return make_token(CONTINUE);
"else"			return make_token(ELSE);
"export"		return make_token(EXPORT);
"for"			return make_token(FOR);
"foreach"		return make_token(FOREACH);
"function"		return make_token(FUNCTION);
"global_var"		return make_token(GLOBAL);
"if"			return make_token(IF);
"import"		return make_token(IMPORT);
"include"		return make_token(INCLUDE);
"local_var"		return make_token(LOCAL);
"repeat"		return make_token(REPEAT);
"return"		return make_token(RETURN);
"until"			return make_token(UNTIL);
"x"			return make_token(REP);
"while"			return make_token(WHILE);

"FALSE"			return make_token(FALSE);
"NULL"			return make_token(UNDEF);
"TRUE"			return make_token(TRUE);

"><"			return make_token(SUBSTR_EQ);
">!<"			return make_token(SUBSTR_NE);

"=~"			return make_token(REGEX_EQ);
"!~"			return make_token(REGEX_NE);

"=="			return make_token(CMP_EQ);
"!="			return make_token(CMP_NE);
"<="			return make_token(CMP_LE);
">="			return make_token(CMP_GE);

"="			return make_token(ASS_EQ);
"+="			return make_token(ADD_EQ);
"-="			return make_token(SUB_EQ);
"*="			return make_token(MUL_EQ);
"/="			return make_token(DIV_EQ);
"%="			return make_token(MOD_EQ);
">>="			return make_token(SRL_EQ);
">>>="			return make_token(SRA_EQ);
"<<="			return make_token(SLL_EQ);

"||"			return make_token(OR);
"&&"			return make_token(AND);
"!"			return make_token(NOT);

"|"			return make_token(BIT_OR);
"^"			return make_token(BIT_XOR);
"&"			return make_token(BIT_AND);
">>>"			return make_token(BIT_SRA);
">>"			return make_token(BIT_SRL);
"<<"			return make_token(BIT_SLL);

"<"			return make_token(CMP_LT);
">"			return make_token(CMP_GT);

"++"			return make_token(INCR);
"--"			return make_token(DECR);

"**"			return make_token(EXP);

"+"			return make_token(ADD);
"-"			return make_token(SUB);
"*"			return make_token(MUL);
"/"			return make_token(DIV);
"%"			return make_token(MOD);

"~"			return make_token(BIT_NOT);

"."			return make_token(PERIOD);
","			return make_token(COMMA);
":"			return make_token(COLON);
";"			return make_token(SEMICOLON);
"("			return make_token(LPAREN);
")"			return make_token(RPAREN);
"["			return make_token(LBRACK);
"]"			return make_token(RBRACK);
"{"			return make_token(LBRACE);
"}"			return make_token(RBRACE);

{ident}			return make_token(IDENT);

0[xX]{hexdigits}	return make_token(INTEGER);
0{octdigits}		return make_token(INTEGER);
{decdigits}		return make_token(INTEGER);

'{data}'		return make_token(DATA);
\"{string}\"		return make_token(STRING);

{whitespace}		/* Ignored. */

%%

int make_token(int type)
{
	pos_t len = strlen(yytext);
	yylval.tok = token_new("fake.nasl", position, position + len - 1);
	position += len;

	return type;
}

void read_comment()
{
	char ch;

	/* Consume input until EOL or EOF. */
	do {
		ch = input();
	} while (ch != '\n' && ch != 0);
}
