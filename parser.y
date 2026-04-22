%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
void yyerror(const char *s);

typedef enum {
    NODE_PROGRAM, NODE_VAR_DECL, NODE_ASSIGN, NODE_BINOP, NODE_NUMBER,
    NODE_IDENTIFIER, NODE_STRING, NODE_PRINT, NODE_IF,
    NODE_LOOP, NODE_FUNC_DEF, NODE_FUNC_CALL, NODE_RETURN, 
    NODE_PARAM_LIST, NODE_CONDOP
} NodeType;

typedef struct ASTNode {
    NodeType type;
    char* str_val;
    int int_val;
    char op;
    char* str_val2;
    struct ASTNode* left;
    struct ASTNode* right;
    struct ASTNode* cond;
    struct ASTNode* next; 
} ASTNode;

ASTNode* create_node(NodeType type) {
    ASTNode* node = (ASTNode*)malloc(sizeof(ASTNode));
    node->type = type; node->str_val = NULL; node->str_val2 = NULL;
    node->int_val = 0; node->op = 0;
    node->left = NULL; node->right = NULL; node->cond = NULL; node->next = NULL;
    return node;
}

ASTNode* create_num(int val) { ASTNode* n = create_node(NODE_NUMBER); n->int_val = val; return n; }
ASTNode* create_id(char* name) { ASTNode* n = create_node(NODE_IDENTIFIER); n->str_val = strdup(name); return n; }
ASTNode* create_str(char* val) { ASTNode* n = create_node(NODE_STRING); n->str_val = strdup(val); return n; }
ASTNode* create_binop(char op, ASTNode* l, ASTNode* r) {
    ASTNode* n = create_node(NODE_BINOP); n->op = op; n->left = l; n->right = r; return n;
}
ASTNode* create_condop(char* op, ASTNode* l, ASTNode* r) {
    ASTNode* n = create_node(NODE_CONDOP); n->str_val2 = strdup(op); n->left = l; n->right = r; return n;
}
ASTNode* create_var_decl(char* name, ASTNode* expr) {
    ASTNode* n = create_node(NODE_VAR_DECL); n->str_val = strdup(name); n->left = expr; return n;
}
ASTNode* create_assign(char* name, ASTNode* expr) {
    ASTNode* n = create_node(NODE_ASSIGN); n->str_val = strdup(name); n->left = expr; return n;
}
ASTNode* create_print(ASTNode* expr) { ASTNode* n = create_node(NODE_PRINT); n->left = expr; return n; }
ASTNode* create_if(ASTNode* cond, ASTNode* true_b, ASTNode* false_b) {
    ASTNode* n = create_node(NODE_IF); n->cond = cond; n->left = true_b; n->right = false_b; return n;
}
ASTNode* create_loop(ASTNode* count, ASTNode* body) {
    ASTNode* n = create_node(NODE_LOOP); n->cond = count; n->left = body; return n;
}
ASTNode* create_func(char* name, ASTNode* params, ASTNode* body) {
    ASTNode* n = create_node(NODE_FUNC_DEF); n->str_val = strdup(name); n->cond = params; n->left = body; return n;
}
ASTNode* create_call(char* name, ASTNode* args) {
    ASTNode* n = create_node(NODE_FUNC_CALL); n->str_val = strdup(name); n->left = args; return n;
}
ASTNode* create_ret(ASTNode* expr) { ASTNode* n = create_node(NODE_RETURN); n->left = expr; return n; }
ASTNode* create_param_list(char* name, ASTNode* next) {
    ASTNode* n = create_node(NODE_PARAM_LIST); n->str_val = strdup(name); n->next = next; return n;
}

void generate_code(ASTNode* node);

void generate_block(ASTNode* node) {
    while(node) {
        generate_code(node);
        node = node->next;
    }
}

void generate_code(ASTNode* node) {
    if (!node) return;
    switch (node->type) {
        case NODE_PROGRAM:
            printf("#include <stdio.h>\n#include <stdbool.h>\n\n");
            ASTNode* f = node->left;
            while(f) {
                if(f->type == NODE_FUNC_DEF) {
                    printf("int %s(", f->str_val);
                    ASTNode* p = f->cond;
                    while(p) { printf("int %s", p->str_val); if(p->next) printf(", "); p = p->next; }
                    printf(") {\n"); generate_block(f->left); printf("}\n\n");
                }
                f = f->next;
            }
            printf("int main() {\n");
            ASTNode* m = node->left;
            while(m) {
                if(m->type != NODE_FUNC_DEF) generate_code(m);
                m = m->next;
            }
            printf("    return 0;\n}\n");
            break;
        case NODE_VAR_DECL:
            printf("    int %s = ", node->str_val); generate_code(node->left); printf(";\n"); break;
        case NODE_ASSIGN:
            printf("    %s = ", node->str_val); generate_code(node->left); printf(";\n"); break;
        case NODE_BINOP:
            generate_code(node->left); printf(" %c ", node->op); generate_code(node->right); break;
        case NODE_CONDOP:
            generate_code(node->left); printf(" %s ", node->str_val2); generate_code(node->right); break;
        case NODE_NUMBER: printf("%d", node->int_val); break;
        case NODE_IDENTIFIER: printf("%s", node->str_val); break;
        case NODE_STRING: printf("%s", node->str_val); break;
        case NODE_PRINT:
            if (node->left->type == NODE_STRING) { printf("    printf("); generate_code(node->left); printf(");\n"); }
            else { printf("    printf(\"%%d\\n\", "); generate_code(node->left); printf(");\n"); }
            break;
        case NODE_IF:
            printf("    if("); generate_code(node->cond); printf(") {\n");
            generate_block(node->left);
            printf("    }");
            if (node->right) { printf(" else {\n"); generate_block(node->right); printf("    }"); }
            printf("\n"); break;
        case NODE_LOOP:
            printf("    for(int i=0; i<"); generate_code(node->cond); printf("; i++) {\n");
            generate_block(node->left); printf("    }\n"); break;
        case NODE_FUNC_CALL:
            printf("%s(", node->str_val);
            ASTNode* a = node->left;
            while(a) { generate_code(a); if(a->next) printf(", "); a = a->next; }
            printf(")"); break;
        case NODE_RETURN:
            printf("    return "); generate_code(node->left); printf(";\n"); break;
        default: break;
    }
}

ASTNode* root = NULL;
%}

%union { int num; char* str; struct ASTNode* node; }
%token KEYWORD_SUNO KEYWORD_CHALO KEYWORD_TIMES KEYWORD_KAAM KEYWORD_WAPAS
%token DATATYPE_NUMBER DATATYPE_SHABD COND_AGAR COND_NAHI_TO
%token <num> NUMBER
%token <str> IDENTIFIER STRING
%type <node> program elements element statements statement var_declaration assignment_statement print_statement expression condition func_params call_args
%left '+' '-'
%left '*' '/'
%%
program: elements { root = create_node(NODE_PROGRAM); root->left = $1; };
elements: element elements { $1->next = $2; $$ = $1; } | { $$ = NULL; };
element: statement | KEYWORD_KAAM IDENTIFIER '(' func_params ')' '{' statements '}' { $$ = create_func($2, $4, $7); };
statements: statement statements { $1->next = $2; $$ = $1; } | { $$ = NULL; };
statement: var_declaration | assignment_statement | print_statement 
         | KEYWORD_WAPAS expression ';' { $$ = create_ret($2); } 
         | COND_AGAR '(' condition ')' '{' statements '}' { $$ = create_if($3, $6, NULL); }
         | COND_AGAR '(' condition ')' '{' statements '}' COND_NAHI_TO '{' statements '}' { $$ = create_if($3, $6, $10); }
         | KEYWORD_CHALO '(' expression KEYWORD_TIMES ')' '{' statements '}' { $$ = create_loop($3, $7); };
var_declaration: DATATYPE_NUMBER IDENTIFIER '=' expression ';' { $$ = create_var_decl($2, $4); }
               | DATATYPE_SHABD IDENTIFIER '=' STRING ';' { $$ = create_var_decl($2, create_str($4)); };
assignment_statement: IDENTIFIER '=' expression ';' { $$ = create_assign($1, $3); };
expression: NUMBER { $$ = create_num($1); } | IDENTIFIER { $$ = create_id($1); } 
          | expression '+' expression { $$ = create_binop('+', $1, $3); } 
          | expression '-' expression { $$ = create_binop('-', $1, $3); } 
          | expression '*' expression { $$ = create_binop('*', $1, $3); } 
          | expression '/' expression { $$ = create_binop('/', $1, $3); } 
          | IDENTIFIER '(' call_args ')' { $$ = create_call($1, $3); };
func_params: DATATYPE_NUMBER IDENTIFIER { $$ = create_param_list($2, NULL); } | DATATYPE_NUMBER IDENTIFIER ',' func_params { $$ = create_param_list($2, $4); } | { $$ = NULL; };
call_args: expression { $$ = $1; $$->next = NULL; } | expression ',' call_args { $$ = $1; $$->next = $3; } | { $$ = NULL; };
print_statement: KEYWORD_SUNO '(' STRING ')' ';' { $$ = create_print(create_str($3)); } | KEYWORD_SUNO '(' expression ')' ';' { $$ = create_print($3); };
condition: expression '<' expression { $$ = create_condop("<", $1, $3); } | expression '>' expression { $$ = create_condop(">", $1, $3); };
%%
void yyerror(const char *s) { fprintf(stderr, "Error on line %d: %s\n", yylineno, s); }
int main(int argc, char **argv) {
    extern FILE *yyin;
    if (argc > 1) yyin = fopen(argv[1], "r");
    yyparse();
    freopen(".hidden_temp.c", "w", stdout);
    generate_code(root);
    freopen("/dev/tty", "w", stdout);
    system("gcc .hidden_temp.c -o .hidden_exec && ./.hidden_exec");
    system("rm -f .hidden_temp.c .hidden_exec");
    return 0;
}
