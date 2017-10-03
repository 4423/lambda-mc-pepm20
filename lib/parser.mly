%{
(*
 * Copyright (c) 2017 Takahisa Watanabe <takahisa@logic.cs.tsukuba.ac.jp> All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *)
open Syntax
%}
%token <string> VAR      // "<identifier>"
%token <string> CON      // "<identifier>"
%token <int>    INT      // "<integer>"
%token ADD               // "+"
%token SUB               // "-"
%token MUL               // "*"
%token DIV               // "/"
%token EQ                // "="
%token NE                // "<>"
%token LE                // "<"
%token LE_EQ             // "<="
%token GT                // ">"
%token GT_EQ             // ">="
%token COMMA             // ","
%token DOT               // "."
%token SEM               // ";"
%token SEM_SEM           // ";;"
%token COL               // ":"
%token COL_COL           // "::"
%token LPAREN            // "("
%token RPAREN            // ")"
%token LBRACKET          // "["
%token RBRACKET          // "]"
%token LBRACE            // "{"
%token RBRACE            // "{"
%token SINGLE_ARROW      // "->"
%token DOUBLE_ARROW      // "->"
%token BAR               // "|"
%token DOLLAR            // "$"
%token UNIT              // "()"
%token TRUE              // "true"
%token FALSE             // "false"
%token NOT               // "not"
%token FUN               // "fun"
%token LET               // "let"
%token REC               // "rec"
%token IN                // "in"
%token IF                // "if"
%token THEN              // "then"
%token ELSE              // "else"
%token MODULE            // "module"
%token STRUCTURE         // "struct"
%token SIGNATURE         // "sig"
%token END               // "end"
%token VAL               // "val"
%token TYPE              // "type"
%token WITH              // "with"
%token CODE              // "code"
%token LCOD              // ".<"
%token RCOD              // ">."
%token ESC               // ".~"
%token RUN               // "Runcode.run"
%token EOF
%nonassoc BAR
%nonassoc IN ELSE
%left WITH
%left EQ NE GT GT_EQ LE LE_EQ
%right SINGLE_ARROW DOUBLE_ARROW
%right COL_COL
%left ADD SUB
%left MUL DIV
%nonassoc UNARY
%left VAR INT TRUE FALSE UNIT LBRACE LBRACKET LPAREN

%type <Syntax.mod_decl list * Syntax.toplevel list> main
%type <Syntax.core_term> core_term
%type <Syntax.core_type> core_type
%type <Syntax.mod_term> mod_term
%type <Syntax.mod_type> mod_type
%start main
%%

main
  : mod_decl_list toplevel_list EOF
    { List.rev $1, List.rev $2 }
  ;  

toplevel_list
  : toplevel_list toplevel
    { $2 :: $1 }
  |
    { [] }
  ;

toplevel
  : LET VAR type_parameter_list parameter_list EQ core_term SEM_SEM
    { Toplevel_Let ($2, List.rev $3, List.rev $4, $6) }
  | LET REC VAR type_parameter_list parameter_list EQ core_term SEM_SEM
    { Toplevel_LetRec ($3, List.rev $4, List.rev $5, $7) }
  ;

core_type
  : LPAREN core_type RPAREN
    { $2 }
  | LPAREN MODULE mod_type RPAREN
    { ModT $3 }
  | core_type SINGLE_ARROW core_type
    { ArrT ($1, $3) }
  | core_type CODE
    { CodT $1 }
  | path DOT VAR
    { AccT ($1, $3) }
  | VAR
    { VarT $1 }
  ;

core_term
  : simple_term
    { $1 }
  | core_term simple_term
    { AppE ($1, $2) }
  | path DOT VAR
    { AccE ($1, $3) }
  | FUN LPAREN MODULE CON COL mod_type RPAREN SINGLE_ARROW core_term
    { FunModE ($4, $6, $9) }
  | FUN VAR SINGLE_ARROW core_term
    { FunE ($2, $4) }  
  | LET VAR type_parameter_list parameter_list EQ core_term IN core_term
    { LetE ($2, List.rev $3, List.rev $4, $6, $8) }
  | LET REC VAR type_parameter_list parameter_list EQ core_term IN core_term
    { LetRecE ($3, List.rev $4, List.rev $5, $7, $9) }
  | LET MODULE CON EQ core_term IN core_term
    { LetModE ($3, $5, $7) }
  | IF core_term THEN core_term ELSE core_term
    { IfE ($2, $4, $6) }
  | ESC core_term %prec UNARY
    { EscE $2 }
  | RUN core_term %prec UNARY
    { RunE $2 }
  ;

simple_term
  : LPAREN core_term RPAREN
    { $2 }
  | LPAREN MODULE mod_term COL mod_type RPAREN
    { ModE ($3, $5) }
  | LCOD core_term RCOD
    { CodE $2 }
  | VAR
    { VarE $1 }
  ;

mod_decl_list
  : mod_decl_list mod_decl
    { $2 :: $1 }
  |
    { [] }

mod_decl
  : MODULE CON EQ mod_term
    { StructureDec ($2, $4) }
  | MODULE TYPE CON EQ mod_type
    { SignatureDec ($3, $5) }
  ;

mod_term
  : STRUCTURE structure END
    { Structure (List.rev $2) }
  | CON
    { VarM $1 }
  ;

structure
  : structure structure_component
    { $2 :: $1 }
  |
    { [] }
  ;

structure_component
  : TYPE VAR EQ core_type
    { TypeM ($2, $4) }
  | LET REC VAR type_parameter_list parameter_list EQ core_term
    { LetRecM ($3, List.rev $4, List.rev $5, $7) }
  | LET VAR type_parameter_list parameter_list EQ core_term
    { LetM ($2, List.rev $3, List.rev $4, $6) }
  ;

mod_type
  : SIGNATURE signature END
    { Signature (List.rev $2) }
  | CON
    { VarS $1 } 
  | mod_type WITH TYPE VAR EQ core_type
    { Sharing ($1, $4, $6) }
  ;

signature
  : signature signature_component
    { $2 :: $1 }
  |
    { [] }
  ;

signature_component
  : TYPE VAR EQ core_type
    { TypeS ($2, Some $4) }
  | TYPE VAR
    { TypeS ($2, None) }
  | VAL VAR COL core_type
    { ValS ($2, $4) }
  ;

path
  : CON
    { VarP $1 }
  | DOLLAR CON
    { DollarP $2 }
  ;

parameter_list
  : parameter_list parameter
    { $2 :: $1 }
  |
    { [] }
  ;
parameter
  : VAR
    { $1 }
  ;

type_parameter_list
  : type_parameter_list type_parameter
    { $2 :: $1 }
  |
    { [] }
  ;
type_parameter
  : LPAREN TYPE VAR RPAREN
    { $3 }
  ;

