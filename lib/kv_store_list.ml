type t = (string * string) list ref

let create () = ref []
let get t key = Lwt.return (List.assoc_opt key !t)

let set t key value =
  t := (key, value) :: List.remove_assoc key !t;
  Lwt.return ()
;;

let delete t key =
  let existed = List.mem_assoc key !t in
  t := List.remove_assoc key !t;
  Lwt.return existed
;;
