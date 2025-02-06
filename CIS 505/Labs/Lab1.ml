(*Task 1*)
let add4 = (+) 4;;

let twice f x = f (f x);;

let add8 = twice add4;;

(*Task 2*)
let rec repeat_apply n f x =
  if n = 0 then
    x
  else
    repeat_apply (n - 1) f (f x);;
(*Task 3*)
let times a b = repeat_apply a ((+) b) 0;;

(*Task 4*)
let power a b = repeat_apply b (times a) 1;;