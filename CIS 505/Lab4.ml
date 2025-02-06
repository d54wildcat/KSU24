(* === LEXER *)

exception Lex

type token = 
 | PlusT
 | TimesT
 | MinusT
 | NumT of int

type state = 
 | InitState 
 | NumberState of int

let explode : string -> char list =
  fun str -> 
     List.init (String.length str)
               (String.get str)

let isWhiteSpace : char -> bool =
  fun c ->
    match c with
    | ' ' -> true
    | '\t' -> true
    | '\n' -> true
    | _ -> false

let isDigit : char -> bool =
  fun c ->
    '0' <= c && c <= '9'

let digit2int : char -> int =
  fun c ->
    (Char.code c) - (Char.code '0')

let rec lx : state -> char list -> token list =
  fun state cs ->
    match (state,cs) with
    | (InitState, []) -> []
    (* Ignore whitespace *)
    | (InitState, ' ' :: rest) -> lx InitState rest
    (* Handle the plus operator *)
    | (InitState, '+' :: rest) -> PlusT :: lx InitState rest
    (* Handle the times operator *)
    | (InitState, '*' :: rest) -> TimesT :: lx InitState rest
    (* Handle the minus operator *)
    | (InitState, '-' :: rest) -> MinusT :: lx InitState rest
    (* Handle digits, starting a number *)
    | (InitState, c :: rest) when '0' <= c && c <= '9' ->
        let digit = int_of_char c - int_of_char '0' in
        lx (NumberState digit) rest
    (* Handle continuing numbers in NumState *)
    | (NumberState n, c :: rest) when '0' <= c && c <= '9' ->
        let digit = int_of_char c - int_of_char '0' in
        lx (NumberState (n * 10 + digit)) rest
    (* End of a number, switch back to InitState *)
    | (NumberState n, rest) -> NumT n :: lx InitState rest
    (* Catch-all for lexical errors *)
    | _ -> raise Lex

let lex : char list -> token list =
  fun cs -> lx InitState cs

(* === PARSER *)

exception ParseTooMuch
exception ParseTooLittle

type expr =
 | PlusExp of expr * expr
 | TimesExp of expr * expr
 | MinusExp of expr
 | NumExp of int

let rec parseExp : token list -> (expr * token list) =
  fun tokens ->
    match tokens with
     | (NumT z) :: tokens1 ->
          (NumExp z, tokens1)
      (* Case for PlusT: parse two subexpressions and return PlusExp *)
    | PlusT :: tokens1 ->
      let (exp1, tokens2) = parseExp tokens1 in
      let (exp2, tokens3) = parseExp tokens2 in
      (PlusExp (exp1, exp2), tokens3)
  
  (* Case for TimesT: parse two subexpressions and return TimesExp *)
  | TimesT :: tokens1 ->
      let (exp1, tokens2) = parseExp tokens1 in
      let (exp2, tokens3) = parseExp tokens2 in
      (TimesExp (exp1, exp2), tokens3)
  
  (* Case for MinusT: parse one subexpression and return MinusExp *)
  | MinusT :: tokens1 ->
      let (exp1, tokens2) = parseExp tokens1 in
      (MinusExp exp1, tokens2)

  (* Case when there are no more tokens: raise error for incomplete input *)
  | [] -> raise ParseTooLittle
  | _ -> raise ParseTooMuch

let parse: token list -> expr =
  fun tokens ->
    match parseExp tokens with
    | (e, []) -> e
    (* Case when there are leftover tokens (input stops too late) *)
    | (_, _::_) -> raise ParseTooMuch

(* === INTERPRETER *)

let rec eval : expr -> int =
  fun e ->
    match e with
    | NumExp n -> n
    | PlusExp (e1,e2)
         -> (eval e1) + (eval e2)
    | TimesExp (e1,e2)
         -> (eval e1) * (eval e2)
    | MinusExp (e1)
         -> - (eval e1)

let interpret : string -> int =
  fun input_string ->
     try 
       (eval (parse (lex (explode input_string))))
    with Lex -> (print_string "Lexical Error\n" ; 0)
       | ParseTooMuch -> (print_string "Input Stops Too Late\n"; 0)
       | ParseTooLittle -> (print_string "Input Stops Too Soon\n"; 0)
    
