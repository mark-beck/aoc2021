open! Core

type field = {
  x : int;
  y : int;
  v : int;
}

let compare_field f1 f2 =
      let cmp_x = Int.compare f1.x f2.x in
      if cmp_x <> 0 then cmp_x
      else 
        let cmp_y = Int.compare f1.y f2.y in
        if cmp_y <> 0 then cmp_y else
          Int.compare f1.v f2.v

let print_field field =
  printf "[%d|%d] -> %d\n" field.x field.y field.v

let print_basin basin =
  let size = basin |> List.length in
  printf "found basin of size %d:\n" size;
  basin |> List.iter ~f:print_field;
  printf "\n"


let print_fields basin =
  printf "fields: \n";
  basin |> List.iter ~f:print_field;
  printf "\n"


let not_contains (list : field list) (element : field) =
  List.exists list ~f:(fun e -> Caml.(=) e element) |> not

let get_nbs i j matr =
  let nbs = [] in
  let nbs = try matr.(i).(j + 1) :: nbs with _ -> nbs in
  let nbs = try matr.(i).(j - 1) :: nbs with _ -> nbs in
  let nbs = try matr.(i + 1).(j) :: nbs with _ -> nbs in
  let nbs = try matr.(i - 1).(j) :: nbs with _ -> nbs in
  nbs

let get_nbs_with_pos i j matr = 
  let nbs = [] in
  let nbs = try {x = i; y = j + 1; v = matr.(i).(j + 1)} :: nbs with _ -> nbs in
  let nbs = try {x = i; y = j - 1; v = matr.(i).(j - 1)} :: nbs with _ -> nbs in
  let nbs = try {x = i + 1; y = j; v = matr.(i + 1).(j)} :: nbs with _ -> nbs in
  let nbs = try {x = i - 1; y = j; v = matr.(i - 1).(j)} :: nbs with _ -> nbs in 
  nbs

let rec explore_basin matrix exploring found =
  printf "explore basin:\n";
  printf "exploring: ";
  print_fields exploring;
  printf "found: ";
  print_fields found;
  match exploring with
  | [] -> found
  | _  -> 
    let new_exploring = exploring 
    |> List.map ~f:(fun field -> get_nbs_with_pos field.x field.y matrix) 
    |> List.concat
    |> List.dedup_and_sort ~compare:compare_field
    |> List.filter ~f:(fun field -> field.v <> 9) 
    |> List.filter ~f:(not_contains exploring)
    |> List.filter ~f:(not_contains found)
    in
    explore_basin matrix new_exploring (exploring @ found)
    
let get_lowpoints riskmap =
  let lowpoints = ref [] in
  Array.iteri riskmap ~f:(fun i row ->
    Array.iteri row ~f:(fun j e ->
      if e <> 0 then lowpoints := ({x = i; y = j; v = e - 1} :: !lowpoints)));
  !lowpoints


let is_lowest (element : int) (nbs : int list) =
nbs |> List.exists ~f:(fun x -> x <= element) |> not


let to_matrix (content : string list) = 
  content |> List.map ~f:(fun line ->
    line |> String.to_list |> List.map ~f:String.of_char |> List.map ~f:Int.of_string |> Array.of_list) 
  |> Array.of_list

let get_risk_levels matrix =
  matrix |> Array.mapi ~f:(fun i row ->
    row |> Array.mapi ~f:(fun j e ->
    if get_nbs i j matrix |> is_lowest e then e + 1 else 0))

let print_matrix matrix =
  Array.iter matrix ~f:(fun row ->
    printf "\n"; Array.iter row ~f:(fun e -> printf "%d " e)); printf "\n"

let print_with_nbs matrix =
  matrix |> Array.iteri ~f:(fun i row ->
    row |> Array.iteri ~f:(fun j e ->
      printf "element at [%d|%d] -> %d\n" i j e;
    get_nbs i j matrix |> List.to_string ~f:Int.to_string |> printf "nbs: %s \n"))

let solve1 (file: string) =
  In_channel.with_file file ~f:begin fun file ->
    let matrix = In_channel.input_lines file |> to_matrix in
    print_matrix matrix;
    print_with_nbs matrix;
    let risk_levels = get_risk_levels matrix in
    print_matrix risk_levels;
    risk_levels |> Array.map ~f:(Array.reduce_exn ~f:(+)) |> Array.reduce_exn ~f:(+) |> printf "result of 1: %d\n"
  end

let solve2 file =
  In_channel.with_file file ~f:begin fun file ->
    let matrix = In_channel.input_lines file |> to_matrix in
    let risk_levels = get_risk_levels matrix in
    print_matrix risk_levels;
    let basins = risk_levels |> get_lowpoints |> List.map ~f:(fun lowpoint -> explore_basin matrix [lowpoint] []) in
    basins |> List.iter ~f:print_basin;
    let first_3 = List.take (basins |> List.map ~f:List.length |> List.sort ~compare:Int.compare |> List.rev) 3 in 
    printf "result of 2: %d\n" (first_3 |> List.reduce_exn ~f:(fun x y -> x * y))
  end



let () = 
let file = Sys.get_argv () |> Array.to_list |> List.tl_exn in 
file |> List.iter ~f:solve1;
file |> List.iter ~f:solve2