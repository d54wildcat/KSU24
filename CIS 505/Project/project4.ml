(* INTERPRETER FOR A HIGHER-ORDER OBJECT-ORIENTED LANGUAGE

      CIS505/705, K-State, Fall 2024

Even the current skeleton enables dialogues such as

# run "+ 3 4" ;;
- : int = 7

You should make 4 modifications, with the suggested order listed below:

#1 == function application
     this is done slightly different from what we did in Project 3;
    you may take inspiration from the lecture notes
        16_MutationsInterpret/04_Boxes_FunctionCalls

Now you can get dialogues such as

# run "apply lambda x + 4 x 
             * 3 5" ;;
- : int = 19

#2 == field retrieval

This is about implementing "get" 
which should retrieve the content of a given field in a given object, 
but which as an important special case
will read from the input stream when asked to retrieve 
the content of the field 'read' from the object 'IO'.
 
To see how to implement that, you may take inspiration
from the implementation of "set!"
(and recall the implementation of input stream reading in Project 2).

Now you can get dialogues such as

# run "let x new a
       let_ set! a x 3
       let_ set! a x 7
       + 4 get a x" ;;
- : int = 11

and also

# run2 "let x get read IO
        let y get read IO
         + x - y" 
    [18 ; 4 ; 33] ;;
- : int = 14

#3 == object creation

As of now, all fields point to the same location.
You must modify this so that whenever a new object is created,
its field is bound to a new location.

Now you can get dialogues such as 

# run "let x new a 
       let y new b
       let_ set! a x 2
       let_ set! b y 7
       + get a x
         get b y" ;;
- : int = 9

#4 == object addition

You should overload '+' so that if applied to two objects,
it returns an object that contains 
the fields present in at least one of the objects
(if a field is present in both, it is the first occurrence that counts).

Now you can get dialogues such as 

# run "let x new a
       let y + new b new a
       let_ set! a x 1
       let_ set! a y 4
       let_ set! b y 7
       let z = + x y
      + get b z 
        get a z" ;;
- : int = 8

One you have done all of the above, you can handle 
all programs from the question text,
and in the uploaded test file.

You should develop your interpreter incrementally, 
and make sure that each new change type checks! 
(If you do not type check until you have made all the required changes,
it is rather likely that you'll get a bunch of error messages 
that may be very hard to understand and fix.)

*)



(* CONCRETE SYNTAX

exp ::= id
     |  num
     |  "lambda" id exp
     |  "apply" exp1 exp2
     |  "let" id exp1 exp0
     |  "let_" exp1 exp0
     |  "if" exp0 exp1 exp2
     |  "+" exp1 exp2  
     |  "*" exp1 exp2  
     |  "-" exp1       
     |  "new" id
     |  "get" id exp0 
     |  "set!" id exp0 exp2

*)

(* EXCEPTIONS *)

exception SourceEndsTooEarly
exception SourceEndsTooLate
exception IdentifierExpectedBut of string

exception NotDeclared of string
exception TestNotNumber
exception PlusNotNumbersOrObjects
exception TimesNotNumbers
exception MinusNotNumber
exception ApplyNotClosure
exception GetNotObject
exception SetNotObject
exception InputExhausted
exception OutputNotNumber
exception FinalNotNumber

(* ABSTRACT SYNTAX *)

type identifier = string

type expE =
 | IdE of identifier
 | NumE of int
 | LambdaE of identifier * expE
 | ApplyE of expE * expE
 | LetE of identifier * expE * expE
 | SequenceE of expE * expE
 | IfE of expE * expE * expE
 | PlusE of expE * expE
 | TimesE of expE * expE
 | MinusE of expE
 | NewE of identifier
 | GetE of identifier * expE
 | SetE of identifier * expE * expE

(* SCANNER *)

type tokenT = 
 | LambdaT
 | ApplyT
 | LetT
 | SequenceT
 | IfT
 | PlusT
 | TimesT
 | MinusT
 | NewT
 | GetT
 | SetT
 | IdT of identifier
 | NumT of int

let print_token : tokenT -> string = fun token -> 
 match token with
 | LambdaT -> "lambda"
 | ApplyT -> "apply"
 | LetT -> "let"
 | SequenceT -> "let_"
 | IfT -> "if"
 | PlusT -> "+"
 | TimesT -> "*"
 | MinusT -> "-"
 | NewT -> "new"
 | GetT -> "get"
 | SetT -> "set!"
 | (IdT id) -> ("identifier "^id)
 | (NumT n) -> "number"

let is_digit : char -> bool = fun ch ->
   Char.code ch >= Char.code '0' && Char.code ch <= Char.code '9'

let char2digit : char -> int = fun ch -> 
   Char.code ch - Char.code '0'

let is_letter : char -> bool = fun ch ->
     (Char.code ch >= Char.code 'a' && Char.code ch <= Char.code 'z')
  || (Char.code ch >= Char.code 'A' && Char.code ch <= Char.code 'Z')

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

let scanId : string -> (string * string) = fun str ->
  let rec get_id acc str = 
    if str = "" 
    then (acc, str)
    else 
      let c = String.get str 0 and 
          str' = String.sub str 1 (String.length str - 1) in
      if is_letter c || is_digit c || c = '_' || c = '?' || c = '!'
      then get_id (acc ^ (String.make 1 c)) str'
      else (acc, str)
 in get_id "" str

let rec scan : string -> tokenT list = 
  fun str -> 
   if str = ""
   then []
   else let c = String.get str 0 
        and str1 = String.sub str 1 (String.length str - 1) in
   if is_digit c
   then let (n,str') = scanNum str
         in (NumT n :: (scan str'))
   else if is_letter (c)
   then let (s,str') = scanId str
     in let token =
       if s = "lambda" then LambdaT
       else if s = "apply" then ApplyT
       else if s = "let" then LetT
       else if s = "let_" then SequenceT
       else if s = "if" then IfT
       else if s = "new" then NewT
       else if s = "get" then GetT
       else if s = "set!" then SetT
       else IdT s
     in (token :: scan str')
   else match c with
     | '+' -> PlusT :: (scan str1)
     | '-' -> MinusT :: (scan str1)
     | '*' -> TimesT :: (scan str1)
     | _ -> scan str1

(* PARSER *)

let getIdT : tokenT list -> string * tokenT list =
  fun tokens -> 
   match tokens with
   | [] -> raise SourceEndsTooEarly
   | (IdT id) :: tokens' -> (id, tokens')
   | (token :: _) -> 
       raise (IdentifierExpectedBut (print_token token))

let rec parseExp : tokenT list -> expE * tokenT list =
   fun tokens ->
    match tokens with
    | [] -> raise SourceEndsTooEarly
    | (IdT s) :: tokens1 ->
         (IdE s, tokens1)
    | (NumT z) :: tokens1 ->
         (NumE z, tokens1)
    | MinusT :: tokens1 ->
        let (e1, tokens2) = parseExp tokens1 in
       (MinusE(e1), tokens2)
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
    | SequenceT :: tokens1 ->
         let (e1, tokens2) = parseExp tokens1 in
         let (e2, tokens3) = parseExp tokens2 in
       (SequenceE(e1,e2), tokens3)
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
         let (id1, tokens2) = getIdT tokens1  in
         let (e1, tokens3) = parseExp tokens2 in
         let (e2, tokens4) = parseExp tokens3 in
       (LetE(id1,e1,e2), tokens4)
    | NewT :: tokens1 ->
         let (field, tokens2) = getIdT tokens1 in
       (NewE field, tokens2)
    | GetT :: tokens1 ->
         let (field, tokens2) = getIdT tokens1 in
         let (e0, tokens3) = parseExp tokens2 in
       (GetE (field,e0), tokens3)
    | SetT :: tokens1 ->
         let (field, tokens2) = getIdT tokens1 in
         let (e0, tokens3) = parseExp tokens2 in
         let (e2, tokens4) = parseExp tokens3 in
       (SetE(field,e0,e2), tokens4)

let parse : string -> expE =
  fun input_string ->
    let tokens = scan input_string in
    let (exp,tokens1) = parseExp tokens
    in if tokens1 = []
       then exp
       else raise SourceEndsTooLate

(* DICTIONARIES *)

type ('a,'b) dictionary =  'a -> 'b

let insertDict : 'a -> 'b -> ('a,'b) dictionary -> ('a,'b) dictionary =
  fun new_key new_val env ->
    fun key -> if key = new_key then new_val else env key

let retrieveDict : ('a,'b) dictionary -> 'a -> 'b =
  fun env key -> env key

let emptyDict : (string,'b) dictionary = 
  fun key -> raise (NotDeclared key)

let defaultDict: 'b -> ('a,'b) dictionary =
  fun default -> fun _ -> default 

(* LOCATIONS *)

type location = int

let io_loc = 1  (* location causing input/output *)

let ioObject_loc = 2  (* location of object IO *)

let next_free = ref 3

let new_location : unit -> location = (* will return 3; 4; 5 ... *)
  fun () ->
    let new_loc = !next_free in
    (next_free := !next_free + 1 ;
     new_loc)

(* VALUES and ENVIRONMENTS *)

type environment = (identifier,location) dictionary

type value =
   NumV of int
 | ClosureV of expE * identifier * environment
 | ObjV of environment

(* STORES and STATES *)

type store = (location,value) dictionary

type inputStream = int list
type runTimeState = store * inputStream

(* EVALUATING EXPRESSIONS  *)

let rec eval : expE -> environment -> runTimeState -> value * runTimeState =
  fun exp env state ->
   match state with
     (sto, inp) ->
   match exp with
   | IdE id -> (retrieveDict sto (retrieveDict env id), state)
   | NumE n -> (NumV n, state)
   | LambdaE(id,exp1) -> 
       (ClosureV (exp1, id, env), state)
   | ApplyE(exp1,exp2) ->
      (let (v1,state1) = eval exp1 env state  in
      let (v2,state2) = eval exp2 env state1 in
      match v1 with
      | ClosureV(exp0, x, env0) ->
          (let loc = new_location () in
          let env1 = insertDict x loc env0 in
          let sto' = insertDict loc v2 (fst state2) in
          eval exp0 env1 (sto', snd state2))
        | _ -> raise ApplyNotClosure)
   | SequenceE(exp1,exp2) ->
      (let (_,state1) = eval exp1 env state  in
       eval exp2 env state1)
   | LetE(id,exp1,exp2) ->
       eval (ApplyE (LambdaE(id,exp2), exp1)) env state
   | IfE(exp0,exp1,exp2) ->
       (match (eval exp0 env state) with
         | (NumV n, state0) ->
             if n > 0
             then eval exp1 env state0
             else eval exp2 env state0
         | _ -> raise TestNotNumber)
   | PlusE(exp1,exp2) ->
      (let (v1,state1) = eval exp1 env state  in
       let (v2,state2) = eval exp2 env state1 in
       match (v1,v2) with
        | (ObjV env1, ObjV env2) ->
          let combined_env = 
            fun key -> try env1 key with NotDeclared _ -> env2 key in
           (ObjV combined_env, state2)
        | (NumV n1, NumV n2) -> (NumV (n1 + n2), state2)
        | _ -> raise PlusNotNumbersOrObjects
       )
   | MinusE(exp1) ->
      (let (v1,state1) = eval exp1 env state  in
      match v1 with
        | NumV n1 -> (NumV (- n1), state1)
        | _ -> raise MinusNotNumber
      )
   | TimesE(exp1,exp2) ->
      (let (v1,state1) = eval exp1 env state  in
       let (v2,state2) = eval exp2 env state1 in
      match (v1,v2) with
        | (NumV n1, NumV n2) -> (NumV (n1 * n2), state2)
        | _ -> raise TimesNotNumbers
      )
   | NewE field ->
      let loc = new_location () in
      let env' = insertDict field loc emptyDict in
      (ObjV env', (insertDict loc (NumV 0) sto, inp))
   | GetE(field,exp0) ->
      (match eval exp0 env state with
        | (ObjV env0, (sto0, inp0)) -> 
            let loc = retrieveDict env0 field in
            if loc = io_loc then
              match inp0 with
                | [] -> raise InputExhausted
                | h::t -> (NumV h, (sto0, t))
            else (retrieveDict sto0 loc, (sto0, inp0))          
        | _ -> raise GetNotObject)
   | SetE(field,exp0,exp2) ->
      (let (v0,state0) = eval exp0 env state  in
       let (v2,state2) = eval exp2 env state0 in
       match v0 with
       | ObjV env0 -> 
        let (sto2, inp2) = state2 in
        let loc = retrieveDict env0 field in
        if loc = io_loc then
          match v2 with
          | NumV n2 -> 
              print_string ((string_of_int n2) ^ "\n");
              (v2, state2)
          | _ -> raise OutputNotNumber
        else
          (v2, (insertDict loc v2 sto2, inp2))
    | _ -> raise SetNotObject
      )
let run2 prog input = 
   let objIO = ObjV (insertDict "read" io_loc 
                       (insertDict "write" io_loc emptyDict)) in
   let initEnv = insertDict "IO" ioObject_loc emptyDict in
   let initSto = insertDict ioObject_loc objIO (defaultDict (NumV 0)) in
   let initState = (initSto, input) in
  try
    (match (eval (parse prog) initEnv initState) with
       | (NumV n, _) -> n
       | _ -> raise FinalNotNumber
    ) with
   | SourceEndsTooEarly -> 
       (print_string "source program prematurely exhausted\n"; 0)
   | SourceEndsTooLate ->
       (print_string "source program continues after expression is parsed\n"; 0)
   | IdentifierExpectedBut s ->
       (print_string ("identifier expected but "^s^" seen\n"); 0)
   | NotDeclared s ->
       (print_string ("identifier "^s^" not bound to value\n"); 0)
   | TestNotNumber ->
       (print_string "test expression not a number\n"; 0)
   | ApplyNotClosure ->
       (print_string "function part of application does not evaluate to closure\n"; 0)
   | PlusNotNumbersOrObjects ->
       (print_string "'+' is not applied to two numbers or to two objects\n"; 0)
   | MinusNotNumber ->
       (print_string "'-' has a non-number as argument\n"; 0)
   | TimesNotNumbers ->
       (print_string "'*' has a non-number as argument\n"; 0)
   | GetNotObject ->
       (print_string "field read from non-object\n"; 0)
   | SetNotObject ->
       (print_string "field written to non-object\n"; 0)
   | InputExhausted ->
       (print_string "input stream prematurely exhausted\n"; 0)
   | OutputNotNumber ->
       (print_string "value printed is not a number\n"; 0)
   | FinalNotNumber ->
       (print_string "final value of program is not a number\n"; 0)

let run prog =
   run2 prog []
