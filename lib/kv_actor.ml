open Lwt.Syntax

type msg =
  | Get of string * string option Lwt.u
  | Set of string * string * unit Lwt.u
  | Delete of string * bool Lwt.u

module Make (Store : Kv_store.S) = struct
  type state = Store.t

  let handler state msg =
    match msg with
    | Get (k, resolver) ->
      let* v = Store.get state k in
      Lwt.wakeup resolver v;
      Lwt.return state
    | Set (k, v, resolver) ->
      let* () = Store.set state k v in
      Lwt.wakeup resolver ();
      Lwt.return state
    | Delete (k, resolver) ->
      let* existed = Store.delete state k in
      Lwt.wakeup resolver existed;
      Lwt.return state
  ;;

  let start store = Lwt.return (Actor.spawn store handler)
end
