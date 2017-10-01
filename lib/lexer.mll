{
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
open Parser
}

let whitespace = [' ' '\t' '\n' '\r']
let digit      = ['0'-'9']
let lower      = ['a'-'z']
let upper      = ['A'-'Z']
let alpha      = (lower | upper)
let ident      = (lower | "_") (alpha | "_" | digit)*

rule token = parse
| whitespace+
    { token lexbuf }
| "(*"
    { comment lexbuf;
      token lexbuf }
| eof
    { EOF  }
| "+"
    { ADD }
| "-"
    { SUB }
| "*"
    { MUL }
| "/"
    { DIV }
| "="
    { EQ }
| "<>"
    { NE }
| "<"
    { LE }
| "<="
    { LE_EQ }
| ">"
    { GT }
| ">="
    { GT_EQ }
| "("
    { LPAREN }
| ")"
    { RPAREN }
| "->"
    { SINGLE_ARROW }
| "=>"
    { DOUBLE_ARROW }
| ","
    { COMMA }
| "|"
    { BAR }
| ":"
    { COL }
| ":"
    { COL_COL }
| "."
    { DOT }
| ";"
    { SEM }
| "()"
    { UNIT }
| "true"
    { TRUE }
| "false"
    { FALSE }
| "not"
    { NOT }
| "fun"
    { FUN }
| "let"
    { LET }
| "rec"
    { REC }
| "in"
    { IN }
| "if"
    { IF }
| "then"
    { THEN }
| "else"
    { ELSE }
| digit+
    { INT (int_of_string @@ Lexing.lexeme lexbuf) }
| ident
    { VAR (Lexing.lexeme lexbuf) }
| _
    { failwith (Printf.sprintf "unknown token %s" (Lexing.lexeme lexbuf)) }

and comment = parse
| eof
    { Printf.eprintf "warning: unterminated comment" }
| "(*"
    { comment lexbuf;
      comment lexbuf }
| "*)"
    { () }
| _
    { comment lexbuf }