
type 'a bin_tree = 
    Empty
  | Node of 'a             (* content   *)
          * 'a bin_tree    (* left tree *)
          * 'a bin_tree    (* right tree *)

(* === Search Tree === 

A binary tree is a search tree iff for all non-empty subtrees: 
  + all nodes occurring in the left child are less than the root
  + all nodes occurring in the right child are greater than the root
*)
let treeA =
  Node (28,
    Node (15,
      Node (12, Empty, Empty),
      Node (30, Empty, Empty)),
    Node (40,
      Node (35, Empty, Empty),
      Node (43, Empty, Empty)))

let treeB =
  Node (28,
    Node (15,
      Node (12, Empty, Empty),
      Node (20, Empty, Empty)),
    Node (40,
      Empty,
      Node (43, Empty, Empty)))

let rec is_search_with_bound p t =
  match t with
  | Empty -> true
  | Node(n, t1, t2) ->
        p n &&
        is_search_with_bound (fun x -> x < n && p x) t1 &&
        is_search_with_bound (fun x -> x > n && p x) t2

let is_search t = is_search_with_bound (fun _-> true) t

(* Test cases to verify the implementation *)
let _ = Printf.printf "Tree A is a search tree: %b\n" (is_search treeA)  (* Expected: false *)
let _ = Printf.printf "Tree B is a search tree: %b\n" (is_search treeB)  (* Expected: true *)
(* === Balanced Tree: *)

(* === Perfect Binary Tree:

A binary tree is perfect, with height n, if 
  + all nodes have either two children or no children, and
  + all leaves (that is nodes without children) have distance n from the root.
)*)

let rec is_perfect t =
  match t with
  | Empty -> Some 0
  | Node(_, t1, t2) ->
     (match (is_perfect t1, is_perfect t2) with
        | (Some h1, Some h2) -> 
          if h1 = h2 then Some (h1 + 1)
          else None
        | _ -> None)

let _ = match is_perfect treeA with
  | Some h -> Printf.printf "Tree A is perfect with height: %d\n" h  (* Expected: Some 2 *)
  | None -> Printf.printf "Tree A is not perfect\n"

let _ = match is_perfect treeB with
  | Some h -> Printf.printf "Tree B is perfect with height: %d\n" h  (* Expected: None *)
  | None -> Printf.printf "Tree B is not perfect\n"
(* === Folding *)

let rec foldt f e t =
   match t with
  | Empty -> e
  | Node (n,left,right) ->
      f n (foldt f e left) (foldt f e right)

let is_perfect' =
   foldt 
      (fun _ left right -> 
         match (left, right) with
         | (Some h1, Some h2) ->
          if  h1 = h2 then Some (h1+1)
          else None
         | _ -> None)
      (Some 0)

let _ = match is_perfect' treeA with
  | Some h -> Printf.printf "Tree A is perfect with height: %d\n" h  (* Expected: Some 2 *)
  | None -> Printf.printf "Tree A is not perfect\n"

let _ = match is_perfect' treeB with
  | Some h -> Printf.printf "Tree B is perfect with height: %d\n" h  (* Expected: None *)
  | None -> Printf.printf "Tree B is not perfect\n"