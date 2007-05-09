
/*********************************************************************************
 *	TypoScript Compiler [TSC] 
 *********************************************************************************/

/*********************************************************************************

	 Translate typoscript to a PHP array
	 Copyright (C) 2007 Elmar Hinz <elmar.hinz@team-red.net> 

	 This library is free software; you can redistribute it and/or
	 modify it under the terms of the GNU Lesser General Public
	 License as published by the Free Software Foundation; either
	 version 2.1 of the License, or (at your option) any later version.

	 This library is distributed in the hope that it will be useful,
	 but WITHOUT ANY WARRANTY; without even the implied warranty of
	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	 Lesser General Public License for more details.

	 You should have received a copy of the GNU Lesser General Public
	 License along with this library; if not, write to the Free Software
	 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

 *********************************************************************************/

%{
#include <stdlib.h>
#include "tsc.h"
#include "y.tab.h"

#define YYSTR yylval.str = malloc(strlen(yytext)+1 ); strcpy(yylval.str,yytext); 
#define TEST printf(" ->%s<- ", yytext); 
%}

%x keyMode
%x valueMode
%x multivalueMode 

APOSTROPH							[']
ASSIGN								[=]
BACKSLASH							[\\]
BLANK      						[\t ]+
BRACE									[{}]
DOT										[\.]
ENDLINE								[\t ]*\n
KEY										[A-Za-z0-9]+
MULTIVALUEBEGIN		   	[(][\t ]*$ 
MULTIVALUEEND			    ^[\t ]*[)][\t ]*$
VALUE									[^'\r\t\n\\ ]*

%%

<keyMode,INITIAL>{
	{ASSIGN}							BEGIN(valueMode); 									return ASSIGN; 
	{BRACE}																										return *yytext;
	{DOT}																											return DOT;
	{ENDLINE}																		yylineno++; 	return NEWLINE; 
	{KEY} 								YYSTR 															return KEY; 
	{MULTIVALUEBEGIN}			BEGIN(multivalueMode);							return MULTIVALUEBEGIN; 
}

<valueMode>{
	{APOSTROPH}																								return APOSTROPH;
	{BACKSLASH}																								return BACKSLASH;
	{BLANK}								YYSTR																return BLANK;
	{ENDLINE}							BEGIN(keyMode); 			yylineno++; 	return NEWLINE; 
	{VALUE}								YYSTR 															return VALUE; 
}

<multivalueMode>{
	{APOSTROPH}																								return APOSTROPH;
	{BACKSLASH}																								return BACKSLASH;
	{BLANK}								YYSTR																return BLANK;
	{ENDLINE}																		yylineno++; 	return NEWLINE; 
	{MULTIVALUEEND}				BEGIN(keyMode);			  yylineno++;		return MULTIVALUEEND; 
	{VALUE}								YYSTR 															return VALUE; 
}

<*>{BLANK}  																								;
<*>.																												return ERROR;

%%

int yywrap (void) {
	return 1;
}

