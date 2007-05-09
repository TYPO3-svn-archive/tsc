
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

/* --------- Variable declarations --------*/

struct key { /* Data type for links in the chain of symbols.  */
	char *name;  /* Name of symbol. */
	struct key *next;  /* Link field. */
	int is_level; /* Boolean: Level of braced clause? */
};
typedef struct key key;

key *keys;  /* The keys table: a chain of `struct key'.  */
int yylineno; /* Linenumber counter. */

/* --------- Function declarations --------*/

char *concat(char *, char *);
void init_keys(); /* Initialize the keystack with a basic entry. Always stays. Never popped or counted. */
key *pushkey (char *); /* Add a key on top of the stack. */
void poplevel(); /* Pop all keys down to the next level. */
void mark_level(key *); /* Mark a key as the level, where the braces are. */
void unmark_level(key *); /* Unmark as braces level. */
int	is_level(key *); /* Is this a braces level? */
char *make_keystring(); /* Create the current keystring. */
void yyerror(char const *); /* Throw an error. */
int yylex (void); /* Get the next token from the tokenizer. */

