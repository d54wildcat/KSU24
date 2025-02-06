(* INTERPRETER FOR A HIGHER-ORDER FUNCTIONAL LANGUAGE
           (manipulating numbers and polynomials)

      CIS505/705, K-State, Fall 2024

Even the current skeleton enables the user to have dialogues such as

# run "+ 3 4" ;;
- : string = "7"

You should make 5 modifications, with the suggested order listed below:

#1 == Handle variables in polynomials

A polynomial 
    ck x^k + ... + c1 x + c0 
is represented by the list
    [c0; c1 ; ... ; ck].

Given that, write a clause for VarE, the result of reading "var".
This will allow the dialogue
  
# run "var" ;;
- : string = "x"

#2 == Handle function application

Carefully study the lecture notes, to see how to evaluate
   ApplyE(exp1,exp2) 
when exp1 evaluates to a closure.

This will allow dialogues such as

# run "apply lambda w + w 7 4" ;;
- : string = "11"

#3 == Parse "let" expressions.

Extend the scanner and the parser to handle the "let" construct.

This will allow dialogues such as

# run "let f lambda x * x 3 apply f 5" ;;
- : string = "15"

#4 == Overload the "+" operator to allow us to add two polynomials,
         or add a polynomial to a number.

Take inspiration from how '*' is overloaded; 
you must modify the function 'poly_add'.

This will allow dialogues such as

# run "+ 7 var" ;;
- : string = "x + 7"

# run "+ + * * 3 var var * 7 var * var var" ;;
- : string = "4x^2 + 7x"

#5 == Overload function application to allow 
         a polynomial to be applied to a number.

For that purpose, you must modify the function 'poly_apply'
so that for example we have

# poly_apply [7 ; -3; 1] 5 ;;
- : int = 17

since  x^2 -3x + 7 applied to 5 is 25 - 15 + 7 = 17.
Accordingly, this modification will allow dialogues such as

# run "apply + + * var var - * 3 var 7 5" ;;
- : string = "17"

As a bonus we can also solve polynomial equations;
since (x + 5)(x - 4) = 0 has solution 4 we get the dialogue

# run "solve * + var 5 + var - 4" ;;
- : string = "4" 


One you have done all of the above, you can handle 
all programs from the question text,
and in the uploaded test file.

You should develop your interpreter incrementally, 
and make sure that each new change type checks! 
(If you do not type check until you have made all the required changes,
it is rather likely that you'll get a bunch of error messages 
that may be very hard to understand and fix.)

*)

(* -- CONCRETE SYNTAX

exp ::= id
     |  num
     |  "lambda" id exp
     |  "apply" exp1 exp2
     |  "let" id exp1 exp2
     |  "if" exp1 exp2 exp3
     |  "+" exp1 exp2  
     |  "*" exp1 exp2  
     |  "-" exp1       
     |  "var"
     |  "solve" exp0

*)

(* -- EXCEPTIONS *)

exception InputEndsTooEarly
exception InputEndsTooLate
exception IdentifierExpectedBut of string

exception NotDeclared of string
exception TestNotInteger
exception ApplyNumber
exception ApplyPolyNotNumber
exception ClosureAsPoly
exception OutputClosure
exception NoIntegerSolution

(* -- ABSTRACT SYNTAX *)

type identifier = string

type expE =
 | IdE of identifier
 | NumE of int
 | LambdaE of identifier * expE
 | ApplyE of expE * expE
 | LetE of identifier * expE * expE
 | IfE of expE * expE * expE
 | PlusE of expE * expE
 | TimesE of expE * expE
 | MinusE of expE
 | VarE 
 | SolveE of expE

(* -- SCANNER
    converts the input string into a list of "tokens" *)

type tokenT = 
 | LambdaT
 | ApplyT
 | LetT
 | IfT
 | PlusT
 | TimesT
 | MinusT
 | VarT
 | SolveT
 | IdT of identifier
 | NumT of int

let print_token token = match token with
 | LambdaT -> "lambda"
 | ApplyT -> "apply"
 | LetT -> "let"
 | IfT -> "if"
 | PlusT -> "+"
 | TimesT -> "*"
 | MinusT -> "-"
 | VarT -> "var"
 | SolveT -> "solve"
 | (IdT id) -> ("identifier "^id)
 | (NumT n) -> "number"
(*Function to check if a character is a digit or a letter*)
let is_digit(ch) = 
   Char.code ch >= Char.code '0' && Char.code ch <= Char.code '9'

let char2digit(ch) = Char.code ch - Char.code '0'

let is_letter(ch) = 
    (Char.code ch >= Char.code 'a' && Char.code ch <= Char.code 'z')
 || (Char.code ch >= Char.code 'A' && Char.code ch <= Char.code 'Z')
(*Scan numbers from input string*)
let scanNum : string -> (int * string) = fun str ->
  let rec get_num acc str = 
    if str = "" 
    then (acc, str)
    else 
      let c = String.get str 0 and 
          str' = String.sub str 1 (String.length str - 1) in
      if is_digit c
      then get_num (10 * acc + (char2digit c)) str' 
      else (acc, str)
 in get_num 0 str
(* Function to scan identifiers (e.g., variable names) from the input string *)
let scanId : string -> (string * string) = fun str ->
  let rec get_id acc str = 
    if str = "" 
    then (acc, str)
    else 
      let c = String.get str 0 and 
          str' = String.sub str 1 (String.length str - 1) in
      if is_letter c || is_digit c || c = '_'
      then get_id (acc ^ (String.make 1 c)) str'
      else (acc, str)
 in get_id "" str
(* Recursive function to scan the input string and return a list of tokens *)
let rec scan : string -> tokenT list = 
  fun str -> 
   if str = ""
   then []
   else let c = String.get str 0 
        and str1 = String.sub str 1 (String.length str - 1) in
   if is_digit c
   then let (n,str') = scanNum str
         in (NumT n :: (scan str'))
   else if is_letter c
   then let (s,str') = scanId str
     in let token =
       if s = "lambda" then LambdaT
       else if s = "apply" then ApplyT
       else if s = "if" then IfT
       else if s = "var" then VarT
       else if s = "solve" then SolveT
       else if s = "let" then LetT
       else IdT s
     in (token :: scan str')
   else match c with
     | '+' -> PlusT :: (scan str1)
     | '*' -> TimesT :: (scan str1)
     | '-' -> MinusT :: (scan str1)
     | _ -> scan str1

(* -- PARSER *)
(* Function to extract an identifier token from the token list *)
let getIdT : tokenT list -> string * tokenT list =
  fun tokens -> 
   match tokens with
   | [] -> raise InputEndsTooEarly
   | (IdT id) :: tokens' -> (id, tokens')
   | (token :: _) -> 
       raise (IdentifierExpectedBut (print_token token))
(* Recursive function to parse an expression from the token list *)
let rec parseExp : tokenT list -> expE * tokenT list =
   fun tokens ->
    match tokens with
    | [] -> raise InputEndsTooEarly
    | (IdT s) :: tokens1 ->
         (IdE s, tokens1)
    | (NumT z) :: tokens1 ->
         (NumE z, tokens1)
    | VarT :: tokens1 ->
         (VarE, tokens1)
    | SolveT :: tokens1 ->
        let (e1, tokens2) = parseExp tokens1 in
       (SolveE e1, tokens2)
    | MinusT :: tokens1 ->
        let (e1, tokens2) = parseExp tokens1 in
       (MinusE e1, tokens2)
    | PlusT :: tokens1 ->
        let (e1, tokens2) = parseExp tokens1 in
        let (e2, tokens3) = parseExp tokens2 in
       (PlusE(e1,e2), tokens3)
    | TimesT :: tokens1 ->
         let (e1, tokens2) = parseExp tokens1 in
         let (e2, tokens3) = parseExp tokens2 in
       (TimesE(e1,e2), tokens3)
    | ApplyT :: tokens1 ->
        let (e1, tokens2) = parseExp tokens1 in
        let (e2, tokens3) = parseExp tokens2 in
       (ApplyE(e1,e2), tokens3)
    | IfT :: tokens1 ->
        let (e1, tokens2) = parseExp tokens1 in
        let (e2, tokens3) = parseExp tokens2 in
        let (e3, tokens4) = parseExp tokens3 in
       (IfE(e1,e2,e3), tokens4)
    | LambdaT :: tokens1 ->
        let (fp, tokens2) = getIdT tokens1   in
        let (e0, tokens3) = parseExp tokens2 in
       (LambdaE(fp,e0), tokens3)
    | LetT :: tokens1 ->
        let (fp, tokens2) = getIdT tokens1   in
        let (e1, tokens3) = parseExp tokens2 in
        let (e2, tokens4) = parseExp tokens3 in
        (LetE(fp,e1,e2), tokens4)
(* Parse an input string into an abstract syntax tree *)
let parse : string -> expE =
  fun input_string ->
    let tokens = scan input_string in
    let (exp,tokens1) = parseExp tokens
    in if tokens1 = []
       then exp
       else raise InputEndsTooLate

(* -- ENVIRONMENTS *)

type 'a environment =  identifier -> 'a

let initEnv : 'a environment = 
  fun id -> raise (NotDeclared id)

let updateEnv : identifier -> 'a -> 'a environment -> 'a environment =
  fun new_id a env ->
    fun id -> if id = new_id then a else env id

let retrieveEnv : 'a environment -> identifier -> 'a =
  fun env id -> env id

(* -- VALUES *)

type value =
   NumV of int
 | ClosureV of expE * identifier * value environment
 | PolyV of int list

(* -- MANIPULATING POLYNOMIALS *)

let mk_poly v = 
   match v with
   | NumV n -> [n]
   | PolyV poly -> poly
   | ClosureV _ -> raise ClosureAsPoly
(* Negate all coefficients of a polynomial *)
let poly_neg poly =
  List.map (fun c -> -c) poly
(* Multiply all coefficients of a polynomial by a constant *)
let poly_scale c poly =
  List.map (fun ci -> c * ci) poly
(*Add polynomial function*)
  let rec poly_add poly1 poly2 =
    match poly1, poly2 with
    | [], [] -> []
    | [], p2 -> p2
    | p1, [] -> p1
    | (c1 :: rest1), (c2 :: rest2) ->
        (c1 + c2) :: (poly_add rest1 rest2)
(* Helper function to compute base^exp for integer powers *)
let rec int_pow base exp =
  if exp = 0 then 1
  else base * (int_pow base (exp - 1))
let rec poly_apply poly n = 
  List.fold_left (fun acc (i, ci) -> acc + (ci * (int_pow n i))) 0 (List.mapi (fun i ci -> (i, ci)) poly)
(*Multiply two polynomials*)
let rec poly_mul poly1 poly2 =
   match poly1 with
   | [] -> []
   | (c1 :: poly'1) ->
       poly_add
          (poly_scale c1 poly2)
          (0 :: (poly_mul poly'1 poly2))  
(* Print a single term of a polynomial *)
let poly_print_term i ci = 
   match (i, ci) with
   | (_,0) -> "0"
   | (0,_) -> Int.to_string ci
   | (1,1) -> "x"
   | (1,-1) -> "-x"
   | (1,_) -> (Int.to_string ci)^"x"
   | (_,_) ->
        (match ci with
         | 1  -> ""
         | -1 -> "-"
         | _ -> (Int.to_string ci))
       ^"x^"^(Int.to_string i)
(* Print a polynomial starting from a specific degree *)
let rec poly_print_from i poly =
   match poly with
   | [] -> "0"
   | (ci :: poly') ->
        match (poly_print_term i ci, poly_print_from (i+1) poly') with
        | ("0",s2) -> s2
        | (s1,"0") -> s1
        | (s1,s2) -> s2 ^ " + " ^ s1
(* Main function to print a polynomial *)
let poly_print poly = poly_print_from 0 poly      

(*  To solve an integer polynomial
      c_n x^n + ... + c_1 x + c_0 
    with M = max(|c_0|...|c_n|,1)
   it suffices to consider x in -M..M.
  Proof: we may assume c_n != 0.
    Now assume x is such that c_n x^n + ... + c_1 x + c_0 = 0.
    With X = |x|, if X > M we have
             
        X^n
    <= |c_n x^n| 
     = |c_{n-1}x^{n-1} + ... + c_1 x + c_0|
    <= M (X^{n-1} + ... + 1)
     = M ((X^n - 1)/(X - 1))
      
    and since X - 1 >= M we infer
        X^n <= X^n - 1
     which is a contradiction

*)
(* Function to solve a polynomial equation by checking possible integer roots *)
let rec attempt poly bound k =
   match (poly_apply poly k, poly_apply poly (-k)) with
   | (0, _) -> k
   | (_, 0) -> -k
   | _ -> if k = bound
          then raise NoIntegerSolution
          else attempt poly bound (k + 1)
(* Find the maximum coefficient in a polynomial *)
let max_c poly = 
      List.fold_right (fun c1 mx -> max (abs c1) mx) poly 1
(* Function to solve a polynomial by checking roots in the range -M to M *)
let poly_solve poly =
   attempt poly (max_c poly) 0

(* -- EVALUATING EXPRESSIONS *)

let rec eval exp env =
   match exp with
   | IdE id -> retrieveEnv env id
   | NumE n -> NumV n
   | LambdaE(id,exp1) -> 
       ClosureV (exp1, id, env)
   | ApplyE(exp1,exp2) ->
       (match (eval exp1 env, eval exp2 env) with
         | (ClosureV(exp0,x,env0), v2) ->  
             let env' = updateEnv x v2 env0 in
              eval exp0 env'
         | (PolyV poly, NumV n) -> NumV (poly_apply poly n)
         | (PolyV _, _) -> raise ApplyPolyNotNumber
         | (NumV _, _) -> raise ApplyNumber)
   | LetE(id,exp1,exp2) ->
       let v1 = eval exp1 env in
       let env' = updateEnv id v1 env in
        eval exp2 env'
   | IfE(exp0,exp1,exp2) ->
       (match (eval exp0 env) with
         | NumV n ->
             if n > 0
             then eval exp1 env
             else eval exp2 env
         | _ -> raise TestNotInteger)
   | SolveE (exp1) -> 
       (match (eval exp1 env) with
        | v -> NumV (poly_solve (mk_poly v))
       )
   | PlusE(exp1,exp2) ->
       (match (eval exp1 env, eval exp2 env) with
        | (NumV n1, NumV n2) -> NumV (n1 + n2)
        | v1, v2 -> PolyV (poly_add (mk_poly v1) (mk_poly v2))
       )
   | TimesE(exp1,exp2) ->
       (match (eval exp1 env, eval exp2 env) with
        | (NumV n1, NumV n2) -> NumV (n1 * n2)
        | (v1, v2) -> PolyV (poly_mul (mk_poly v1) (mk_poly v2))
       )
   | MinusE(exp1) ->
       (match (eval exp1 env) with
        | NumV n -> NumV (- n)
        | v -> PolyV (poly_neg (mk_poly v))
       )
   | VarE -> PolyV [0;1]


let run x = 
  try
    (match (eval (parse x) initEnv) with
       | NumV n -> Int.to_string n
       | PolyV poly -> poly_print poly
       | ClosureV _ -> raise OutputClosure
    ) with
   | InputEndsTooEarly -> 
        "input prematurely exhausted"
   | InputEndsTooLate ->
        "input continues after expression is parsed"
   | IdentifierExpectedBut s ->
        "identifier expected but "^s^" seen"
   | NotDeclared s ->
         "identifier <"^s^"> not bound to value"
   | TestNotInteger ->
         "test expression not integer"
   | ApplyNumber ->
         "function part of application is a number"
   | ApplyPolyNotNumber ->
         "function part of application is a polynomial but argument is not a number"
   | ClosureAsPoly -> 
         "a closure where a polynomial or number was expected"
   | OutputClosure ->
         "program returns a closure"
   | NoIntegerSolution ->
         "polynomial has no integer solution"
