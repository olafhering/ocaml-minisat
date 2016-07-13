
(* This file is free software. See file "license" for more details. *)

type t

type lit = int

type assumptions = lit array

module Raw = struct
  external create : unit -> t = "caml_minisat_new"
  external delete : t -> unit = "caml_minisat_delete"

  external add_clause_a : t -> lit array -> bool = "caml_minisat_add_clause_a"

  external simplify : t -> bool = "caml_minisat_simplify"

  external solve : t -> lit array -> bool = "caml_minisat_solve"

  external nvars : t -> int = "caml_minisat_nvars"
  external nclauses : t -> int = "caml_minisat_nclauses"
  external nconflicts : t -> int = "caml_minisat_nconflicts"

  external set_nvars : t -> int -> unit = "caml_minisat_set_nvars"

  external value : t -> lit -> int = "caml_minisat_value"

  external set_verbose: t -> int -> unit = "caml_minisat_set_verbose"
end

let create () =
  let s = Raw.create() in
  Gc.finalise Raw.delete s;
  s

exception Unsat

let check_ret_ b =
  if not b then raise Unsat

let add_clause_a s a = Raw.add_clause_a s a |> check_ret_

let add_clause_l s lits = add_clause_a s (Array.of_list lits)

let simplify s = Raw.simplify s |> check_ret_

let solve ?(assumptions=[||]) s =
  Raw.solve s assumptions |> check_ret_

type value =
  | V_undef
  | V_true
  | V_false

let value s lit = match Raw.value s lit with
  | 1 -> V_true
  | 0 -> V_undef
  | -1 -> V_false
  | _ -> assert false

let set_verbose = Raw.set_verbose
