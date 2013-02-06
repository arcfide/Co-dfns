\def\title{CO-DFNS PARSER (Version 0.1)}
\def\topofcontents{\null\vfill
  \centerline{\titlefont Co-Dfns Parser}
  \vskip 15pt
  \centerline{(Version 0.1)}
  \vfill}
\def\botofcontents{\vfill
\noindent
Copyright $\copyright$ 2013 Aaron W. Hsu $\.{arcfide@@sacrideo.us}$
\smallskip\noindent
All rights reserved.
}

% These are some helpers for handling some of the apl characters.
\def\aa{\alpha\alpha}
\def\ww{\omega\omega}

@* Parsing Co-Dfns. The Co-Dfns language is a rather difficult one to 
parse effectively. While most of the language is trivial, the language
has one or two parts that are inherently ambiguous if you do not already
know the variable references are functions or values. This document
describes the parser for Co-Dfns. Most of the parser is designed 
around the PEG grammar given in {\tt grammar.peg}, which is used to 
generate a recursive decent, backtracking parser using the {\tt peg(1)}
program. This file sets the surrounding context for this parser 
and configures its settings so that it is usable in the rest of the 
Co-Dfns ecosystem.

At the moment, we compile a |main()| program for doing program 
recognition. It runs the parser on the file given in the command
line until no more content is parsable, and then exits.

@p
#include <stdio.h>
#include <stdlib.h>

@<Declare internal structures@>@;
@<Declare prototypes...@>@;

#include "grammar.c"

@<Define internal functions@>@;
@<Define parsing functions@>@;

void
print_usage_exit(char *progname)
{
	printf("%s : [filename]\n", progname);
	exit(EXIT_FAILURE);
}

int
main(int argc, char *argv[])
{
	yycontext ctx;
	FILE *infile;
	
	memset(&ctx, 0, sizeof(yycontext));
	init_stack(&ctx.op_seen, 50);
	
	switch(argc) {
	case 1: 
		ctx.infile = stdin; 
		break;
	case 2:
		if ((infile = fopen(argv[1], "r")) == NULL) {
			perror(argv[0]);
			exit(EXIT_FAILURE);
		}
		ctx.infile = infile;
		break;
	default:
		print_usage_exit(argv[0]);
	}
	
	while(parse_apl(&ctx));
	
	if (argc == 2 && fclose(infile) == EOF) {
		perror(argv[0]);
		exit(EXIT_FAILURE);
	}
	
	return EXIT_SUCCESS;
}

@ The parser generated by {\tt peg} needs to have a few things customized 
to make things nicer to program with. These settings are made here. In 
particular, the main parser name should be |parse_apl| rather than 
|yyparse| and the parser should use a local context. 

@d YYPARSE parse_apl
@d YY_CTX_LOCAL

@ There are a number of additional fields that we use to deal with the 
extra information that we need when parsing. These fields are members 
of the local context that we setup above.

@d YY_CTX_MEMBERS 
	FILE *infile; /* The input file from which we are reading */
	struct stack op_seen; /* Track whether we have seen operator variables */

@ The default parser uses |YY_INPUT(buf, result, max_size)| to read
input in, but this reads from standard input by default, and we would
like to control the input form of the compiler. To do this, we redefine 
this macro to read from the |ctx->infile| which is a member that we 
set to be the input |FILE *| pointer.

@d YY_INPUT(buf, result, max_size)
{
	int yyc = fgetc(ctx->infile);
	result = (EOF == yyc) ? 0 : (*(buf) = yyc, 1);
}

@* Parsing User-defined Operators. Parsing of operators defined by the user 
gets a little interesting. In particular, in Co-Dfns, an user defined function is 
either an operator or a function, but not both. One can determine statically 
at parse time whether a given procedure is a function or an operator by 
examining the occurences of $\aa$ or $\ww$ that appear in the body of 
the local scope. It's important that only those variables considered in 
the immediate scope matter. A nested operator inside of an user defined 
function should not cause that function to be treated as an operator.
However, if a $\ww$ is found inside of the function body, then it is a 
dyadic operator. If no $\ww$ occurs in the body but an occurence of 
$\aa$ is found, then it must be a monadic operator. If on the other hand, 
neither of these two variables appears, then the user-defined entity must 
be a function.

One approach to handling this in the PEG grammar would be to have a single
non-terminal for Functions and another one for operators. We could then create 
a number of duplicate subordinate non-terminals that mirrored on another for 
each of the syntaxes, since they are basically the same. This is ugly, because 
the syntax for an operator and a function is the exact same excepting the 
occurences of $\aa$ or $\ww$. 

To make this a little cleaner, we will instead use the |op_seen| field of the 
peg context declared above. This a stack where each element in the stack 
represents one additional level of nesting for user-defined functions and 
operators. At each level we have three different cases. Firstly, we could 
have no operator variables, indicated by the value |UD_FUNC|. We could then 
have a monadic operator, indicated by the value |UD_MONA|. Finally, 
we have a dyadic operator, indicated by the value |UD_DYAD|. Each element 
in the stack is one of these three values. During parsing when we 
encounter a new user-defined function or operator, we push another element 
onto the stack and initialize it to |UD_FUNC|. When we encounter any operator 
variable, then we promote this value upwards to either |UD_MONA| or |UD_DYAD|. 
We never downgrade from |UD_DYAD| to either |UD_MONA| or |UD_FUNC|, and 
we similarly never downgrade from |UD_MONA| to |UD_FUNC|. When we 
encounter the corresponding closing brace of an user-defined function or 
operator, then we can check the value of the top of the stack to determine 
whether we have a function or an operator.

@d UD_FUNC 0
@d UD_MONA 1
@d UD_DYAD 2

@ To support this approach to parsing, we define |ENTER_UD()| that is to be 
called on each entrance to an user-defined function or operator. This will 
do all of the initialization and make sure that things are pushed onto the
stack as appropriate.

@d ENTER_UD() (!push(&ctx->op_seen, (void *) UD_FUNC))

@ When we have seen what might be a closing brace to a function or an 
operator, then we need to check whether it is an operator or what. We also 
need to make sure that we pop the stack appropriately. Thus, we define 
three predicates that will return true or false. For each predicate, we will
only pop the stack if we encounter what we expect and return true.

@d UD_PRED(name, errstr, type)
int name(void *ctxp)
{
	void *val;
	yycontext *ctx = ctxp;
	
	if (pop(&ctx->op_seen, &val)) {
		fprintf(stderr, "%s: unexpected empty stack\n", errstr);
		exit(EXIT_FAILURE);
	}
	
	if (val != (void *) type) return 0;
	else return 1;
}

@<Define parsing functions@>=
UD_PRED(is_ud_func, "is_ud_func", UD_FUNC)@;
UD_PRED(is_ud_mona, "is_ud_mona", UD_MONA)@;
UD_PRED(is_ud_dyad, "is_ud_dyad", UD_DYAD)@;

@ Finally, these functions need to be included in the protypes since they 
are used as a part of the PEG grammar.

@<Declare prototypes used in the grammar@>=
int is_ud_func(void *);
int is_ud_mona(void *);
int is_ud_dyad(void *);

@ When we encounter an operator variable ($\aa$ or $\ww$) then we need 
to set the stack variable appropriately. We do this by popping the current
one and putting the right one back in. The right one is the max of the current 
value and the value of the operator that we have seen.

@d SEEN_OP_VAR(name, errstr, type)
int name(void *ctxp)
{
	void *val;
	yycontext *ctx = ctxp;
	
	if(pop(&ctx->op_seen, &val)) {
		fprintf(stderr, "%s: unexpected empty stack\n", errstr);
		exit(EXIT_FAILURE);
	}
	
	push(&ctx->op_seen, val < (void *)type ? (void *) type : val);
	return 0;
}

@<Define parsing functions@>=
SEEN_OP_VAR(seen_mona_var, "seen_mona_var", UD_MONA)@;
SEEN_OP_VAR(seen_dyad_var, "seen_dyad_var", UD_DYAD)@;

@ And of course, things need to go into the prototype.

@<Declare prototypes...@>=
int seen_mona_var(void *);
int seen_dyad_var(void *);

@* Dealing with function variables and application. 
The most annoying thing about parsing APL is the ambiguity that you get 
when dealing with variables that are bound to functions. Consider the 
following program fragment:

\medskip{\tt A B C}\medskip

\noindent In the above, the parsing of this depends on the values of 
the various variables. If they are all values, then this is an array 
or value. If C is a function then if this were considered as a single 
statement, we would have an error on our hands. If on the other 
hand C is a value, then we have many possible parsings that we 
could encounter depending on whether B is a function, value, or 
operator, and whether A is a value or function. 

In order to deal with this, we actually have to track the value 
versus function versus operator status of the various variables 
for each user-defined function. We will achieve this by using a variable
environment that tracks the types of the variable. For this we need 
a variable/type pair structure. The type variables will be one 
of |VT_VAL|, |VT_FUN|, or |VT_OPR|. These names have their obvious 
meaning.

@<Declare internal structures@>=
enum var_type { VT_VAL, VT_FUN, VT_OPR };
struct vt_pair {
	enum var_type type;
	const char var_name[];
};

@* Stacks. We make use of a number of stacks when parsing. All of these
operate over data, so we have a |struct stack| structure that allows us to 
work with them in a single interface. 

@<Declare internal structures@>=
struct stack {
	void **end;
	void **current;
	void **start;
};

@ Before a stack is used, it must be initialized. The |init_stack()| function
initializes a given stack pointer to the appropriate values and allocates 
enough space to hold a stack of |count| elements. It returns 0 on success, 
and a non-zero integer on failure.

@<Define internal functions@>=
int
init_stack(struct stack *stk, int count)
{
	void **buf;
	
	if ((buf = malloc(count * sizeof(void *))) == NULL) {
		perror("init_stack");
		return 1;
	}
	
	stk->end = buf + count;
	stk->current = buf;
	stk->start = buf;
	
	return 0;
}

@ The function |resize_stack()| takes a stack and a new count and resizes it to 
the appropriate count. It returns zero on success and a non-zero value on failure.

@<Define internal functions@>=
int
resize_stack(struct stack *stk, int count)
{
	void **buf;
	
	buf = stk->start;
	
	if ((buf = realloc(buf, count * sizeof(void *))) == NULL) {
		perror("resize_stack");
		return 1;
	}
	
	stk->end = buf + count;
	stk->current = buf + (stk->current - stk->start);
	stk->start = buf;
	
	return 0;
}

@ We can ask the size of a given stack using the |STACK_SIZE| macro.

@d STACK_SIZE(stk) ((stk)->end - (stk)->start)

@ We use the |push()| procedure to push an element onto the stack. 
This may trigger a resize of the stack if there is no enough space 
to hold the new element. It returns zero if the push succeeds, 
and non-zero if the push fails.

@<Define internal functions@>=
int
push(struct stack *stk, void *elm)
{
	if (stk->end == stk->current)
		if (resize_stack(stk, STACK_SIZE(stk) * 1.5)) {
			fprintf(stderr, "push: Failed to resize stack\n");
			return 1;
		}
	
	*(stk->current++) = elm;
	
	return 0;
}

@ We use the |pop()| macro to get an element off of the stack with a 
given type. We return a zero if the pop suceeds and a non-zero value 
if the pop fails. The resulting element is stored in the space provided.

@<Define internal functions@>=
int
pop(struct stack *stk, void **val)
{
	if (stk->start == stk->current)
	    return 1;
	
	*val = *(--stk->current);

	return 0;
}

@ We can |peek()| at a stack to get its value without actually decrementing 
the stack. We return zero if there is an element that can be peeked, and 
non-zero if there was no element to peek. If there was no element to peek, 
then the value of |val| is no modified.

@<Define internal functions@>=
int
peek(struct stack *stk, void **val)
{
	if (stk->start == stk->current)
		return 1;
	
	*val = *(stk->current - 1);
	return 0;
}

@ Finally we put these all into the prototypes list.

@<Declare prototypes...@>=
int push(struct stack *, void *);
int pop(struct stack *, void **);
int peek(struct stack *, void **);


@* Index.
