type t = (string, string) Hashtbl.t

let get t key =
  let v =
    try Some (Hashtbl.find t key) with
    | Not_found -> None
  in
  Lwt.return v
;;

let set t key value =
  Hashtbl.replace t key value;
  Lwt.return ()
;;

let delete t key =
  let existed = Hashtbl.mem t key in
  Hashtbl.remove t key;
  Lwt.return existed
;;

let create size = Hashtbl.create size
