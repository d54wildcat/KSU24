
(* INTERPRETER FOR A SMALL INTERACTIVE HIGHER-ORDER CALCULATOR 
   CIS505/705, K-State, Fall 2024 *)

(* EXCEPTIONS FOR ERRORS *)

exception IllformedInput
exception StackEmpty
exception KeyNotFound
exception RepeatNegative

(* EXCEPTIONS FOR SIDE EFFECTS *)

exception Exit
exception TopStack
exception ShowStack

(* AUXILIARY FUNCTIONS *)

(* DICTIONARY OPERATIONS *)

let initDict = fun key -> raise KeyNotFound

let rec lookupDict dictionary key =
   dictionary key

let rec insertDict dict key value =
   fun k -> if k = key then value else dict k

(* DECOMPOSING THE STACK *)

let top_of stack =
   match stack with
    | [] -> raise StackEmpty
    | n :: stack' -> n

let rest_of stack =
   match stack with
    | [] -> raise StackEmpty
    | n :: stack' -> stack'

(* INTERPRETING THE INPUT *)

let get_number str = 
  let rec get_num str acc = 
    if str = "" 
    then acc
    else 
      let c = String.get str 0 and 
          str' = String.sub str 1 (String.length str - 1) in
      let d =  Char.code c  - Char.code '0' in
      if d >= 0 && d < 10 
      then 
        let m =
          match acc with
           | None -> d
           | Some n -> 10 * n + d
        in get_num str' (Some m)
      else acc
  in get_num str None

(* Implementing the C operation: Copy the top of the stack *)
let copy_top stack =
  match stack with
  | [] -> raise StackEmpty
  | top :: _ -> top :: stack

(* Implementing the - operation: Subtract *)
let subtract stack =
  match stack with
  | [] | [_] -> raise StackEmpty
  | x :: y :: rest -> (y - x) :: rest

(* New subtraction logic *)
let subtract_correct stack =
  let sub_n = top_of stack in
  let new_stack = rest_of stack in
  (sub_n, new_stack)

(* Implementing the B operation: Bind the current function *)
let bind dict curfun =
  print_string "bind the current function to which name?
";
  let name = read_line () in
  insertDict dict name curfun

(* Implementing the W operation: Apply the current function twice *)
let apply_twice curfun x = curfun (curfun x)

(* Implementing the R operation: Repeat the current function k times *)
let repeat_function curfun k =
  let rec repeat f n x =
    if n < 0 then raise RepeatNegative
    else if n = 0 then x
    else repeat f (n - 1) (f x)
  in repeat curfun k

(* THE READ-EVAL-PRINT LOOP *)

(* interpret: 
      (string -> int -> int)          Dictionary of Functions
   -> (int -> int)                    Current Function 
   -> int list                        Stack of Numbers
   ->  unit                     
 *)

let rec interpret dict curfun stack =  
  (* READ, AND THEN EVAL BASED ON WHAT IS READ *)
  (print_string "? " ;
   let inp = read_line () in
   try 
    (match inp with
     | "A" -> 
        interpret dict curfun ((curfun (top_of stack)) :: (rest_of stack))
     | "G" -> 
          (print_string "get which function?
";
            let str = read_line () in
            interpret dict (lookupDict dict str) stack
          )
     | "S" -> raise ShowStack
     | "T" -> raise TopStack 
     | "X" -> raise Exit
     | "+" -> 
          interpret dict ((+) (top_of stack)) (rest_of stack)
     | "*" -> 
          interpret dict  (( * ) (top_of stack)) (rest_of stack)
     | "-" -> 
          let (sub_n, new_stack) = subtract_correct stack in
          interpret dict (fun x -> x - sub_n) new_stack
     | "C" -> 
          interpret dict curfun (copy_top stack)
     | "B" -> 
          interpret (bind dict curfun) curfun stack
     | "W" -> 
          interpret dict (apply_twice curfun) stack
     | "R" ->
      
          let k = top_of stack in
          interpret dict (repeat_function curfun k) (rest_of stack)
     | _ -> 
        (match get_number inp with
         | Some n -> interpret dict curfun (n :: stack)
         | None -> raise IllformedInput)
    ) with Exit ->
         (print_string "Hopefully you enjoyed using the CIS505/705 calculator! Bye
"; 
            ())
    |   excp ->
          (print_string
            (match excp with
              | TopStack ->
                  (match stack with
                    | [] -> "Stack is empty
"
                    | n :: _ -> "Top of stack: "^(Int.to_string n)^"
")
              | ShowStack -> 
                  "Stack (top first): "^
                  (String.concat " , " (List.map Int.to_string stack))^"
"
              | IllformedInput -> "Input ill-formed
"
              | StackEmpty -> "Stack is empty
"
              | KeyNotFound -> "Identifier not found in dictionary
"
              | RepeatNegative -> "Iterate called on negative number
"
              | _ -> "System Exception
");
            interpret dict curfun stack)
  )

(* INVOCATION *)
 (* run: unit -> unit *)

let run () = 
  (print_string "The CIS505/705 Calculator is ready!
";
    interpret        (* initially,                   *)
      initDict       (* dictionary is empty          *)
      (fun x -> x)   (* current function is identity *)
      []             (* number stack is empty        *)
   )
