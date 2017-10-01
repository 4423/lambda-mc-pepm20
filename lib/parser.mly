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
%token EOF
%nonassoc BAR
%nonassoc IN ELSE
%left EQ NE GT GT_EQ LE LE_EQ
%right SINGLE_ARROW DOUBLE_ARROW
%right COL_COL
%left ADD SUB
%left MUL DIV
%nonassoc UNARY
%left VAR INT TRUE FALSE UNIT LBRACE LBRACKET LPAREN

%type <Syntax.core_term> main
%start main
%%

main
  : core_term EOF
    { $1 }
  ;  

core_type
  : LPAREN core_type RPAREN
    { $2 }
  | core_type SINGLE_ARROW core_type
    { ArrT ($1, $3) }
  | VAR
    { VarT $1 }
  ;

core_term
  : simple_term
    { $1 }
  | core_term simple_term
    { AppE ($1, $2) }
  | FUN LPAREN VAR COL core_type RPAREN SINGLE_ARROW core_term
    { FunE ($3, $5, $8) }  
  | LET VAR EQ core_term IN core_term
    { LetE ($2, $4, $6) }  
  ;

simple_term
  : LPAREN core_term RPAREN
    { $2 }
  | VAR
    { VarE $1 }
  ;