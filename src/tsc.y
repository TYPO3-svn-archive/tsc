
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

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include "tsc.h"

#define YYDEBUG 0  

char *claim = "\n\n\
							 \n//------------------------------------------------------------------------------//\
							 \n// Compiled with the TS COMPILER (TSC) - Lead developer elmar.hinz@team-red.net //\
							 \n// -----------------------------------------------------------------------------//\
							 \n\n";
%}

%expect 0
%union { char* str;  struct key *kptr; } 

%token <str> APOSTROPH									 
%token <str> ASSIGN 
%token <str> BACKSLASH 
%token <str> BLANK 
%token <str> DOT 
%token <str> ERROR
%token <str> KEY 
%token <str> MULTIVALUEBEGIN
%token <str> MULTIVALUEEND
%token <str> NEWLINE 
%token <str> VALUE 
%token <str> '{' 
%token <str> '}'
%token <str> '\t' 
%token <str> ' ' 

%type <str> script
%type <str> script_component
%type <str> script_block
%type <str> script_block_body
%type <str> script_block_component

%type <str> entry
%type <kptr> key /* Array keys on a stack. */
%type <str> value_assignment

%type <str> multivalue 
%type <str> value
%type <str> value_segment

%%

start:
	script { printf("%s",$1); }
	;

script:				
	script script_component	{ $$=concat($1, $2); }
	| { $$=""; }
;

script_component:
	script_block NEWLINE 	{ $$=$1; }
	| entry NEWLINE	{ $$=$1; }
	| NEWLINE { $$=""; }
	;

script_block:                             
	key '{' NEWLINE { mark_level(keys); } script_block_body '}' { 
		poplevel(); unmark_level(keys); 
		$$=$5; 
	}
	;

script_block_body:
	script_block_body script_block_component { $$=concat($1, $2); }
	|	{ $$=""; }
	;

script_block_component:
	script_block NEWLINE { $$=$1; }
	| entry	NEWLINE { $$=$1; }
	| NEWLINE { $$=""; }
	;

key: 
	 KEY	{ poplevel(); $$=pushkey($1); }
	| key DOT KEY 	{  $$=pushkey($3); }
	;

entry:																										
	key value_assignment 	{
		char * tmp = make_keystring();
		$$ = malloc(strlen("='';\n") + strlen(tmp) + strlen($2) + 1);
		sprintf($$, "%s='%s';\n", tmp, $2); 
	}
	;

value_assignment:
	ASSIGN value	{	$$=$2; }
	| MULTIVALUEBEGIN multivalue MULTIVALUEEND {  $$=$2; }
	;

multivalue:
	multivalue value NEWLINE  { $$=concat(concat($1, $2), "\n"); }
	| { $$="";}
	;

value:																										
	value value_segment { $$=concat($1, $2); }
	| { $$="";}
	;

value_segment:
	'{' { $$=$1; }			
	| '}' { $$=$1; }
	| APOSTROPH { $$="\\'"; }
	| ASSIGN { $$="="; }
	| BACKSLASH { $$="\\\\"; }
	| BLANK { $$=$1; }
	| DOT	{ $$="."; }
	| VALUE { $$=$1; }
	;

%%

int main(void) {
#if YYDEBUG
		yydebug=1;
#endif
	printf("%s", claim);
	init_keys();
	yyparse();
	return 0;
}

void yyerror(char const *s) {
	fprintf(stderr,"Syntax error on line #%d: %s\n", yylineno,s);
	exit(1);
}

char *concat(char *s1, char *s2) {
	char *out = malloc(strlen(s1) + strlen(s2) + 1);
	strcpy(out, s1);
	strcat(out, s2);
	return out;
}

void init_keys() {
	keys = (key *) malloc (sizeof(key));
	keys->name = "_BASE_";
	keys->is_level = 1; /* The base is treated like a brace level */
	keys->next = 0;
}

key *pushkey(char *name) {
	key *kptr;
	kptr = (key *) malloc (sizeof(key));
	kptr->name = (char *) malloc (strlen(name) +1);
	strcpy (kptr->name, name);
	kptr->is_level = 0;
	kptr->next = keys;
	keys = kptr;
	return kptr;
}
 
void mark_level(key *kptr) {
	kptr->is_level = 1;	
}

void unmark_level(key *kptr) {
	kptr->is_level = 0;	
}

int is_level(key *kptr) {
	return kptr->is_level;
}

void poplevel() {
	key *kptr;
	while(!keys->is_level) {
		kptr = keys;
		keys = kptr->next;
		free (kptr->name);
		free (kptr);	
	}
}

char* make_keystring() {
	key *kptr = keys;
	char *str; 

	/* The last ['key'] has no dot. */
	if(kptr->next) {
		str = (char *) malloc(strlen(kptr->name) + strlen("['']") + 1); 
		sprintf(str, "['%s']", kptr->name); 
		kptr = kptr->next;
	}

	/* Preciding ['keys.'] with a trailing dot. */ 
	while(kptr->next) {
		char *tmp = str;
		str = (char *) malloc(strlen(str) + strlen(kptr->name) + strlen("['.']") + 1); 
		sprintf(str, "['%s.']%s", kptr->name, tmp); 
		kptr = kptr->next;
	}

	/* Prepending "$ts". */
	char *tmp = str;
	str = (char *) malloc(strlen(str) + strlen("$ts") + 1); 
	sprintf(str, "$ts%s", tmp); 
	return str;
}


