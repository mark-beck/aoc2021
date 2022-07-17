open Printf

exception NoMoves
exception NoBoards
exception BreakLoop

type board = (int * bool) list list

exception FoundWinner of board * int

type game = { moves : int list; boards : board list }

let print_board board =
  printf "printing board\n";
  printf "[\n";
  board
  |> List.iter (fun row ->
         row |> List.iter (fun elem -> Printf.printf "%d " (fst elem));
         Printf.printf "\n");
  printf "]\n"

let print_game game =
  printf "[";
  game.moves |> List.iter (printf "%d,");
  printf "]\n";
  game.boards |> List.iter print_board;
  printf "\n"

let build_board (block : string list) =
  block
  |> List.map (fun x ->
         x |> String.split_on_char ' '
         |> List.filter (fun x -> String.length x != 0)
         |> List.map int_of_string
         |> List.map (fun x -> (x, false)))

let split_in_blocks (lines : string list) =
  let rec aux (lines : string list) (blocks : string list list) =
    match lines with
    | [] -> blocks
    | _ -> (
        let lines2 =
          lines |> List.to_seq
          |> Seq.drop_while (fun x -> String.length x == 0)
          |> Seq.drop_while (fun x -> String.length x != 0)
          |> List.of_seq
        in
        let block =
          lines |> List.to_seq
          |> Seq.drop_while (fun x -> String.length x == 0)
          |> Seq.take_while (fun x -> String.length x != 0)
          |> List.of_seq
        in
        match block with
        | [] -> aux lines2 blocks
        | _ -> aux lines2 (block :: blocks))
  in
  let out = aux lines [] in
  out

let build_game (lines : string list) =
  let moves =
    List.nth lines 0 |> String.split_on_char ','
    |> List.map (fun x -> int_of_string x)
  in
  let boards : board list =
    lines |> List.tl |> split_in_blocks
    |> List.map (fun board -> build_board board)
  in

  { moves; boards }

let rec transpose list =
  match list with
  | [] -> []
  | [] :: xss -> transpose xss
  | (x :: xs) :: xss ->
      (x :: List.map List.hd xss) :: transpose (xs :: List.map List.tl xss)

let has_won board =
  try
    board
    |> List.iter (fun row ->
           if row |> List.for_all (fun x -> snd x) then raise BreakLoop);
    board |> transpose
    |> List.iter (fun row ->
           if row |> List.for_all (fun x -> snd x) then raise BreakLoop);
    false
  with BreakLoop -> true

let rec simulate1 game =
  match game.moves with
  | [] -> raise NoMoves
  | x :: moves ->
      let boards : board list =
        List.map
          (fun board ->
            List.map
              (fun row ->
                List.map
                  (fun elem -> if fst elem == x then (fst elem, true) else elem)
                  row)
              board)
          game.boards
      in
      boards
      |> List.iter (fun board ->
             if has_won board then raise (FoundWinner (board, x)));
      simulate1 { moves; boards }

let rec simulate2 game =
  match game.moves with
  | [] -> raise NoMoves
  | x :: moves ->
      let boards : board list =
        List.map
          (fun board ->
            List.map
              (fun row ->
                List.map
                  (fun elem -> if fst elem == x then (fst elem, true) else elem)
                  row)
              board)
          game.boards
      in
      let boards =
        match boards with
        | [] -> raise NoBoards
        | [ board ] ->
            if has_won board then raise (FoundWinner (board, x)) else [ board ]
        | boards -> boards |> List.filter (fun board -> not (has_won board))
      in
      simulate2 { moves; boards }

let compute_score (board : board) (x : int) =
  x
  * (board |> List.flatten
    |> List.fold_left
         (fun acc elem -> if not (snd elem) then acc + fst elem else acc)
         0)

let read_whole_file (filename : string) =
  let ch = open_in filename in
  let s = really_input_string ch (in_channel_length ch) in
  close_in ch;
  s

let solve1 (game : game) =
  try simulate1 game
  with FoundWinner (board, x) ->
    printf "RESULT PART 1\n";
    print_board board;
    printf "%d\n" (compute_score board x)

let solve2 (game : game) =
  try simulate2 game
  with FoundWinner (board, x) ->
    printf "RESULT PART 2\n";
    print_board board;
    printf "x = %d\n" x;
    printf "%d\n" (compute_score board x)

let solve_file (filename : string) =
  let game =
    filename |> read_whole_file |> String.split_on_char '\n' |> build_game
  in
  solve1 game;
  solve2 game

let () = Sys.argv |> Array.to_list |> List.tl |> List.iter solve_file
