open Flow
open Lwt.Syntax

type store_instance =
  | Store : (module Kv_store.S with type t = 'a) * 'a -> store_instance

type store_config =
  | List
  | Hashlib of int

let create_store config =
  match config with
  | List ->
    let module S = Kv_store_list in
    Store ((module S : Kv_store.S with type t = S.t), S.create ())
  | Hashlib n ->
    let module S = Kv_store_hashlib in
    Store ((module S : Kv_store.S with type t = S.t), S.create n)
;;

let process_command actor line =
  let parts = String.split_on_char ' ' line |> List.filter (fun s -> s <> "") in
  match parts with
  | [ "GET"; key ] ->
    let p, r = Lwt.task () in
    let () = Actor.send actor (Kv_actor.Get (key, r)) in
    let* result = p in
    (match result with
     | Some v -> Lwt.return ("VALUE " ^ v)
     | None -> Lwt.return "NOT_FOUND")
  | [ "SET"; key; value ] ->
    let p, r = Lwt.task () in
    let () = Actor.send actor (Kv_actor.Set (key, value, r)) in
    let* () = p in
    Lwt.return "OK"
  | [ "DELETE"; key ] ->
    let p, r = Lwt.task () in
    let () = Actor.send actor (Kv_actor.Delete (key, r)) in
    let* existed = p in
    if existed then Lwt.return "DELETED" else Lwt.return "NOT_FOUND"
  | _ -> Lwt.return "ERROR: Invalid command"
;;

let handle_connection _sockaddr ic oc actor =
  let rec loop () =
    let* line = Lwt_io.read_line_opt ic in
    match line with
    | None -> Lwt.return_unit
    | Some cmd ->
      let* response = process_command actor cmd in
      let* () = Lwt_io.write_line oc response in
      loop ()
  in
  loop ()
;;

let server port config =
  let (Store ((module Store), store)) = create_store config in
  let module StoreActor = Kv_actor.Make (Store) in
  let* actor = StoreActor.start store in
  let listen_address = Unix.(ADDR_INET (inet_addr_loopback, port)) in
  let _server =
    Lwt_io.establish_server_with_client_socket listen_address (fun _addr fd ->
      let ic = Lwt_io.of_fd ~mode:Lwt_io.Input fd in
      let oc = Lwt_io.of_fd ~mode:Lwt_io.Output fd in
      handle_connection _addr ic oc actor)
  in
  let* () = Lwt_io.printlf "Server listening on port %d" port in
  fst (Lwt.wait ())
;;

let run port store hash_size =
  let config =
    match store with
    | `List -> List
    | `Hash -> Hashlib hash_size
  in
  Lwt_main.run (server port config)
;;

(* Cmdliner *)

open Cmdliner

let port_arg =
  let doc = "Port to listen on." in
  let env = Cmd.Env.info "KV_PORT" in
  Arg.(value & opt int 7000 & info [ "p"; "port" ] ~doc ~env)
;;

let store_arg =
  let doc = "Store backend (list | hash)." in
  let env = Cmd.Env.info "KV_STORE" in
  let stores = [ "list", `List; "hash", `Hash ] in
  Arg.(value & opt (enum stores) `List & info [ "store" ] ~doc ~env)
;;

let hash_size_arg =
  let doc = "Size of the hash store (used only when --store=hash)." in
  let env = Cmd.Env.info "KV_HASH_SIZE" in
  Arg.(value & opt int 16 & info [ "hash-size" ] ~doc ~env)
;;

let cmd =
  let doc = "Run the Key-Value store TCP server" in
  let info = Cmd.info "kv" ~doc in
  Cmd.v info Term.(const run $ port_arg $ store_arg $ hash_size_arg)
;;

let () = exit (Cmd.eval cmd)
