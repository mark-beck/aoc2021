open Printf

let print_list list =
  Printf.printf "[";
  list |> List.iter (fun e -> Printf.printf "%d, " e);
  Printf.printf "]\n"

let read_whole_file (filename : string) =
  let ch = open_in filename in
  let s = really_input_string ch (in_channel_length ch) in
  close_in ch;
  s

let string_to_list str =
  str |> String.trim |> String.split_on_char ','
  |> List.map (fun e ->
         try int_of_string e
         with ex ->
           printf "Error on |%s|" e;
           raise ex)

let to_age_list list =
  let numbers = [ 0; 1; 2; 3; 4; 5; 6; 7; 8 ] in
  numbers
  |> List.map (fun number ->
         list |> List.filter (fun e -> e = number) |> List.length)

exception SplitError

let shift_down = function x :: xs -> xs @ [ 0 ] | _ -> raise SplitError

let step list =
  let zeros = List.hd list in
  let list = shift_down list in
  list
  |> List.mapi (fun i e -> match i with 6 -> e + zeros | 8 -> zeros | _ -> e)

let rec simulate list n =
  match n with
  | 0 ->
      (* print_list list; *)
      list
  | n ->
      print_string "step ";
      print_int n;
      print_string "  ";
      print_list list;
      print_endline "";
      let list = step list in
      (simulate [@tailcall]) list (n - 1)

let solve list =
  let result = simulate list 256 in
  printf "Result: %d" (List.fold_left ( + ) 0 result)

let () =
  Sys.argv |> Array.to_list |> List.tl |> List.map read_whole_file
  |> List.map string_to_list |> List.map to_age_list |> List.iter solve
