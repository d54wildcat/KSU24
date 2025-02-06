(* 
 Below are 8 trees.
  
 Four are search trees:
   tree1, tree2, tree5, tree6

 Four are perfect trees:
   tree1, tree3  (all leaves have depth 1)
   tree5, tree7  (all leaves have depth 3)

*)


let tree1 =
  Node
   (28,
    Node (15,Empty,Empty),
    Node (41,Empty,Empty)
   )
(*
        28
       /  \
      /    \
     15    41
*)

let tree2 =
  Node
   (28,
    Node (15,Empty,Empty),
    Node (41,
          Node(35,Empty,Empty),
          Empty)
   )
(*
        28
       /  \
      /    \
     15    41
           /
         35
*)

let tree3 =
  Node
   (28,
    Node (15,Empty,Empty),
    Node (27,Empty,Empty)
   )
(*
        28
       /  \
      /    \
     15    27
*)

let tree4 =
  Node
   (28,
    Node (15,Empty,
           Node(31,Empty,Empty)),
    Node (41,Empty,Empty)
   )
(*
        28
       /  \
      /    \
     15    41
      \
       31
*)

let tree5 =
  Node 
   (27,
    Node
     (12,
      Node
       (7, 
        Node (6,Empty,Empty), 
        Node (9,Empty,Empty)),
      Node
       (20,
        Node (14,Empty,Empty), 
        Node (25,Empty,Empty))),
    Node
     (40,
      Node
       (30, 
        Node (28,Empty,Empty), 
        Node (35,Empty,Empty)),
      Node
       (48,
        Node (45,Empty,Empty), 
        Node (50,Empty,Empty))))
(*
              27
              / \
             /   \
            /     \
           /       \
          /         \
         /           \
        /             \
      12              40
      / \             / \
     /   \           /   \
    /     \         /     \
   7      20      30      48
  / \     / \     / \     / \
 6   9  14  25  28   35  45  50
*)

let tree6 =
  Node 
   (27,
    Node
     (12,
      Node
       (7, 
        Node (6,Empty,Empty), 
        Node (9,Empty,Empty)),
      Node
       (20,
        Node (14,Empty,Empty), 
        Node (25,Empty,Empty))),
    Node
     (40,
      Node
       (30, 
        Empty,
        Node (35,Empty,Empty)),
      Node
       (48,
        Node (45,Empty,Empty), 
        Node (50,Empty,Empty))))
(*
              27
              / \
             /   \
            /     \
           /       \
          /         \
         /           \
        /             \
      12              40
      / \             / \
     /   \           /   \
    /     \         /     \
   7      20      30      48
  / \     / \       \     / \
 6   9  14  25       35  45  50
*)

let tree7 =
  Node 
   (27,
    Node
     (12,
      Node
       (7, 
        Node (6,Empty,Empty), 
        Node (9,Empty,Empty)),
      Node
       (20,
        Node (14,Empty,Empty), 
        Node (25,Empty,Empty))),
    Node
     (40,
      Node
       (30, 
        Node (29,Empty,Empty),
        Node (41,Empty,Empty)),
      Node
       (48,
        Node (45,Empty,Empty), 
        Node (50,Empty,Empty))))
(*
              27
              / \
             /   \
            /     \
           /       \
          /         \
         /           \
        /             \
      12              40
      / \             / \
     /   \           /   \
    /     \         /     \
   7      20      30      48
  / \     / \     / \     / \
 6   9  14  25  29   41  45  50
*)

let tree8 =
  Node 
   (27,
    Node
     (12,
      Node
       (7, Empty, Empty),
      Node
       (20,
        Node (11,Empty,Empty), 
        Node (25,Empty,Empty))),
    Node
     (40,
      Node
       (30, 
        Node (28,Empty,Empty),
        Node (35,Empty,Empty)),
      Node
       (48,
        Node (45,Empty,Empty), 
        Node (50,Empty,Empty))))
(*
              27
              / \
             /   \
            /     \
           /       \
          /         \
         /           \
        /             \
      12              40
      / \             / \
     /   \           /   \
    /     \         /     \
   7      20      30      48
          / \     / \     / \
        11  25  28   35  45  50
*)
