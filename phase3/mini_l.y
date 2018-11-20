    /*
    ----------------------------------------
    Syntax Analyzer/Parser for MINI-L (v3)
    Sean Richardson
    ----------------------------------------
    */


    /*
    ----------------------------------------
    Declarations
    ----------------------------------------
    */


%{

#include "heading.h"

// externals in flex file
extern int curline;
extern int curpos;

// externals for fixing g++ errors
extern FILE* yyin;  // multiple declarations of yyin
extern int yylex(); // ‘yylex’ was not declared in this scope

// user subroutines
void yyerror(string);
void yyerror(const char *msg);

// symbol table && stack
string buf;
stringstream ss;
map<string,string> symtab;
vector< map<string,string> > symstk;

%}

%union{
    int     ival;
    string* sval; // for raw char array yytext
}

%error-verbose

%start program

%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF
%token IF THEN ENDIF ELSE WHILE DO FOREACH IN BEGINLOOP ENDLOOP CONTINUE READ WRITE AND OR NOT TRUE FALSE RETURN

%token ADD SUB MULT DIV MOD

%token EQ NEQ LT GT LTE GTE

%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN

%token IDENT

%token NUMBER

    /*

%token <chval> IDENT
%token <ival> NUMBER
%type  <ival> expression

    */

%right ASSIGN
%left OR
%left AND
%right NOT
%left NEQ
%left EQ
%left GTE
%left GT
%left LTE
%left LT
%left MINUS
%left PLUS
%left MOD
%left DIV
%left MULT
%right UMINUS
%left R_SQUARE_BRACKET
%left L_SQUARE_BRACKET
%left R_PAREN
%left L_PAREN

%%

    /*
    ----------------------------------------
    Grammar Rules
    ----------------------------------------
    */


program
    : functions
        {
            //cout << "prog_start -> functions" << endl;
        }
    ;

functions
    : /* epsilon */
        {
            //cout << "functions -> epsilon" << endl;
        }
    | function functions
        {
            //cout << "functions -> function functions" << endl;
        }
    ;

function
    : FUNCTION identifier SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY
        {
            //cout << "function -> FUNCTION IDENT SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS declarations END_LOCALS BEGIN_BODY statements END_BODY" << endl;

            /*  goal to output "func", ss.str(), and "endfunc"
                each rule should write to the string stream,
                after output reset ss.str() to ""
            */

            cout << "func" << " ";

            //cout << ss.str() << "\n";

            while(getline(ss,buf)){ output(buf); }

            cout << "endfunc" << "\n\n";

            buf = "";
            ss.str("");
            ss.clear();
        }
    ;

declarations
    : /* epsilon */
        {
            //cout << "declarations -> epsilon" << endl;
        }
    | declaration SEMICOLON declarations
        {
            //cout << "declarations -> declaration SEMICOLON declarations" << endl;
        }
    ;

declaration
    : identifiers COLON INTEGER
        {
            //cout << "declaration -> identifiers COLON INTEGER" << endl;

            ss << "." << "\n";
        }
    | identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
        {
            //cout << "declaration -> identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER" << endl;

            ss << ".[]" << "\n";
        }
    ;

identifiers
    : identifier
        {
            //cout << "ident -> IDENT " << *yylval.sval << endl;

            //output("_"+*yylval.sval)
        }
    | identifier COMMA identifiers
        {
            //cout << "identifiers -> ident COMMA identifiers" << endl;

            //output("_"+*yylval.sval)
        }
    ;

identifier
    : IDENT
        {
            //cout << "ident -> IDENT " << *yylval.sval << endl;

            ss << *yylval.sval << "\n";
        }
    ;

statements
    : /* epsilon */
        {
            //cout << "statements -> epsilon" << endl;
        }
    | statement SEMICOLON statements
        {
            //cout << "statements -> statement SEMICOLON statements" << endl;
        }
    ;

statement
    : var ASSIGN expression
        {
            //cout << "statement -> var ASSIGN expression" << endl;

            ss << "=" << "\n";
        }
    | IF bool-expr THEN statements ENDIF
        {
            //cout << "statement -> IF bool_exp THEN statements ENDIF" << endl;

            ss << "?:=" << "\n";
        }
    | IF bool-expr THEN statements ELSE statements ENDIF
        {
            //cout << "statement -> IF bool_exp THEN statements ELSE statements ENDIF" << endl;

            ss << "?:=" << "\n";
        }
    | WHILE bool-expr BEGINLOOP statements ENDLOOP
        {
            //cout << "statement -> WHILE bool_exp BEGINLOOP statements ENDLOOP" << endl;
        }
    | DO BEGINLOOP statements ENDLOOP WHILE bool-expr
        {
            //cout << "statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_exp" << endl;
        }
    | READ vars
        {
            //cout << "statement -> READ vars" << endl;

            ss << ".<" << "\n";
        }
    | WRITE vars
        {
            //cout << "statement -> WRITE vars" << endl;

            ss << ".>" << "\n";
        }
    | CONTINUE
        {
            //cout << "statement -> CONTINUE" << endl;
        }
    | RETURN expression
        {
            //cout << "statement -> RETURN expression" << endl;

            ss << "ret" << "\n";
        }
    ;

bool-expr
    : relation-and-expr
        {
            //cout << "bool_exp -> relation_and_exp" << endl;
        }
    | relation-and-expr OR relation-and-expr
        {
            //cout << "bool_exp -> relation_and_exp OR relation_and_exp" << endl;

            ss << "||" << "\n";
        }
    ;

relation-and-expr
    : relation-expr
        {
            //cout << "relation_and_exp -> relation_exp" << endl;
        }
    | relation-expr AND relation-and-expr
        {
            //cout << "relation_and_exp -> relation_exp AND relation_exp" << endl;

            ss << "&&" << "\n";
        }
    ;

relation-expr
    : expression comp expression
        {
            //cout << "relation_exp -> expression comp expression" << endl;
        }
    | TRUE
        {
            //cout << "relation_exp -> TRUE" << endl;
        }
    | FALSE
        {
            //cout << "relation_exp -> FALSE" << endl;
        }
    | L_PAREN bool-expr R_PAREN
        {
            //cout << "relation_exp -> L_PAREN bool-exp R_PAREN" << endl;
        }
    | NOT expression comp expression
        {
            //cout << "relation_exp -> NOT expression comp expression" << endl;
        }
    | NOT TRUE
        {
            //cout << "relation_exp -> NOT TRUE" << endl;
        }
    | NOT FALSE
        {
            //cout << "relation_exp -> NOT FALSE" << endl;
        }
    | NOT L_PAREN bool-expr R_PAREN
        {
            //cout << "relation_exp -> NOT L_PAREN bool-exp R_PAREN" << endl;
        }
    ;

comp
    : EQ
        {
            //cout << "comp -> EQ" << endl;

            ss << "==" << "\n";
        }
    | NEQ
        {
            //cout << "comp -> NEQ" << endl;

            ss << "!=" << "\n";
        }
    | GT
        {
            //cout << "comp -> GT" << endl;

            ss << ">" << "\n";
        }
    | LT
        {
            //cout << "comp -> LT" << endl;

            ss << "<" << "\n";
        }
    | GTE
        {
            //cout << "comp -> GTE" << endl;

            ss << ">=" << "\n";
        }
    | LTE
        {
            //cout << "comp -> LTE" << endl;

            ss << "<=" << "\n";
        }
    ;

expressions
    :   /* empty */
        {
            //cout << "expression -> epsilon" << endl;
        }
    | expression
        {
            //cout << "expressions -> expression" << endl;
        }
    | expression COMMA expressions
        {
            //cout << "expressions -> expression COMMA expressions" << endl;
        }
    ;

expression
    : mult-expr
        {
            //cout << "expression -> multiplicative_expression" << endl;
        }
    | mult-expr ADD expression
        {
            //cout << "expression -> multiplicative_expression ADD multiplicative_expression" << endl;

            ss << "+" << "\n";
        }
    | mult-expr SUB expression
        {
            //cout << "expression -> multiplicative_expression SUB multiplicative_expression" << endl;

            ss << "-" << "\n";
        }
    ;

mult-expr
    : term
        {
            //cout << "multiplicative_expression -> term" << endl;
        }
    | term MULT term
        {
            //cout << "multiplicative_expression -> term MULT term" << endl;

            ss << "*" << "\n";
        }
    | term DIV term
        {
            //cout << "multiplicative_expression -> term DIV term" << endl;

            ss << "/" << "\n";
        }
    | term MOD term
        {
            //cout << "multiplicative_expression -> term MOD term" << endl;

            ss << "%" << "\n";
        }
    ;

term
    : var
        {
            //cout << "term -> var" << endl;
        }
    | NUMBER
        {
            //cout << "term -> NUMBER" << " " << yylval.ival << endl;

            ss << yylval.ival << "\n";
        }
    | L_PAREN expression R_PAREN
        {
            //cout << "term -> L_PAREN expression R_PAREN" << endl;
        }
    | identifier L_PAREN expressions R_PAREN
        {
            //cout << "term -> identifiers L_PAREN expressions R_PAREN" << endl;

            ss << "param" << "\n";
            // expressions stored as params here
            ss << "call" << "\n";
            // identifier, stored expressions from param
        }
    | SUB var
        {
            //cout << "term -> SUB var" << endl;
        }
    | SUB NUMBER
        {
            //cout << "term -> SUB NUMBER" << " " << yylval.ival << endl;

            ss << (-1 * yylval.ival) << "\n";
        }
    | SUB L_PAREN expression R_PAREN
        {
            //cout << "term -> SUB L_PAREN expression R_PAREN" << endl;
        }
    | SUB identifier L_PAREN expressions R_PAREN
        {
            //cout << "term -> SUB identifiers L_PAREN expressions R_PAREN" << endl;
        }
    ;

vars
    : var
        {
            //cout << "vars -> var" << endl;
        }
    | var COMMA vars
        {
            //cout << "vars -> var COMMA vars" << endl;
        }
    ;

var
    : identifier
        {
            //cout << "var -> ident" << endl;
        }
    | identifier L_SQUARE_BRACKET expression R_SQUARE_BRACKET
        {
            //cout << "var -> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET" << endl;
        }
    ;


%%


    /*
    ----------------------------------------
    User subroutines
    ----------------------------------------
    */


int main(int argc, char** argv)
{
    /* try to read from a input file */
    if(argc >= 2)
    {
        yyin = fopen(argv[1], "r");
        if(yyin == NULL)
        {
           yyin = stdin;
        }
    }
    else
    {
        yyin = stdin;
    }

    yyparse(); /* calls yylex() */
}

void yyerror(const char *msg)
{
   yyerror(string(msg));
}

void yyerror(string s)
{
   cout << "parser yyerror at Line " << curline << ", position " << curpos << ": " << s << endl;
}


