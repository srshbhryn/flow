open Lwt.Infix
open Lwt.Syntax
open Cmdliner

(* Convert "ip:port" or unix path into sockaddr *)
let sockaddr_of_string s =
  match String.split_on_char ':' s with
  | [ ip; port ] ->
      let addr = Unix.inet_addr_of_string ip in
      let port = int_of_string port in
      Unix.ADDR_INET (addr, port)
  | _ -> Unix.ADDR_UNIX s

(* Create a new upstream connection *)
let create_upstream addr =
  Lwt_io.open_connection addr >|= fun (ic, oc) -> Flow.Conn.new_conn ic oc

(* Proxy logic *)
let proxy_client pool _addr (client_ic, client_oc) =
  Lwt_pool.use pool (fun upstream ->
      let client = Flow.Conn.new_conn client_ic client_oc in
      let* () = Flow.Conn.proxy client upstream in
      Lwt.return ())

(* --- Cmdliner arguments --- *)

let port_term : int Term.t =
  let doc = "The port number to listen on." in
  Arg.(value & opt int 8000 & info [ "p" ] ~docv:"PORT" ~doc)

let upstream_term : string Term.t =
  let doc = "Upstream to connect to." in
  Arg.(value & opt string "127.0.0.1:9000" & info [ "u" ] ~docv:"UPSTREAM" ~doc)

let pool_size_term : int Term.t =
  let doc = "Maximum upstream connections in the pool." in
  Arg.(value & opt int 10 & info [ "n" ] ~docv:"POOL" ~doc)

(* --- Main run function --- *)

let run port upstream pool_size =
  let upstream_addr = sockaddr_of_string upstream in

  let pool =
    Lwt_pool.create pool_size (fun () -> create_upstream upstream_addr)
  in

  Lwt_main.run
    (let _server =
       Lwt_io.establish_server_with_client_address
         (Unix.ADDR_INET (Unix.inet_addr_any, port))
         (proxy_client pool)
     in
     Printf.printf "Proxy listening on port %d → %s\n%!" port upstream;
     fst (Lwt.wait ()))

(* --- Cmdliner command --- *)

let proxy_cmd =
  Cmd.v
    (Cmd.info "proxy" ~doc:"A simple Lwt TCP proxy with connection pooling.")
    Term.(const run $ port_term $ upstream_term $ pool_size_term)

(* --- Entry point --- *)

let () = exit (Cmd.eval proxy_cmd)
