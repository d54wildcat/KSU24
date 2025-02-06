(* Task 1a *)
let rec pos_diffs z =
  match z with
  | [] -> [] (* Base case: empty list returns an empty list *)
  | (h1, h2) :: t -> 
      if h1 > h2 then 
        (h1 - h2) :: pos_diffs t  (* If h1 > h2, calculate the difference and add it to the result *)
      else 
        pos_diffs t  (* Otherwise, skip to the next pair *)

(*Task 1b*)
let pos_diffsG z =
  (* Filter pairs where the first element is greater than the second *)
  let filtered_pairs = List.filter (fun (x, y) -> x > y) z in
  (* Map the filtered pairs to their differences *)
  List.map (fun (x, y) -> x - y) filtered_pairs

(* Task 2a *)
let rec count_singles z =
  match z with
  | [] -> 0  (* Base case: empty list returns 0 *)
  | h :: t -> 
      match h with
      | [_] -> 1 + count_singles t  (* If the head is a singleton list, add 1 and recurse *)
      | _ -> count_singles t  (* If the head is not a singleton, recurse without adding *)

(* Task 2b *)
let count_singlesG z =
  List.fold_right
    (fun sublist acc ->
       match sublist with
       | [_] -> acc + 1  (* If the sublist is a singleton, increment the accumulator *)
       | _ -> acc        (* If not, keep the accumulator unchanged *)
    )
    z 0  (* Initial accumulator is 0 *)

(* Task 3*)
let prep_avg z =
  List.fold_right
    (fun x (sum, count) -> (sum + x, count + 1))  (* Add each element to the sum, increment the count *)
    z
    (0, 0)  (* Initial accumulator: (sum = 0, count = 0) *)
