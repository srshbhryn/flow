open Lwt.Infix
open Lwt.Syntax
open Cmdliner
open Flow.Utils

let handle_client log_oc _addr (ic, oc) =
  let i0, i1 = copy ic in
  let i2 = prefixize (string_of_sockaddr _addr ^ "\t") i1 in
  let conn0 = Flow.Conn.new_conn i0 oc in
  let conn1 = Flow.Conn.new_conn i2 log_oc in
  let* () = Lwt.join [ Flow.Conn.echo conn0; Flow.Conn.echo conn1 ] in
  let* () = Lwt_io.close i0 in
  let* () = Lwt_io.close i1 in
  let* () = Lwt_io.close i2 in
  Lwt.return ()

(* --- Cmdliner Integration --- *)

(* 1. Define argument converters/defaults *)

let port_term : int Term.t =
  let doc = "The port number to listen on." in
  Arg.(value & opt int 9000 & info [ "p" ] ~docv:"PORT" ~doc)

let logfile_term : string Term.t =
  let doc = "File to write server logs to." in
  Arg.(value & opt string "server.log" & info [ "l" ] ~docv:"LOGFILE" ~doc)

(* 2. Define the main execution function *)

let run port logfile =
  Lwt_main.run
    ( Lwt_io.open_file ~mode:Lwt_io.Output
        ~flags:[ Unix.O_CREAT; Unix.O_WRONLY; Unix.O_APPEND ]
        logfile
    >>= fun log_oc ->
      let _server =
        Lwt_io.establish_server_with_client_address
          (Unix.ADDR_INET (Unix.inet_addr_any, port))
          (handle_client log_oc)
      in

      Printf.printf "Listening on port %d, logging to %s\n%!" port logfile;
      fst (Lwt.wait ()) )

(* 3. Define the command structure *)

let server_cmd =
  Cmd.v
    (Cmd.info "echo" ~doc:"A simple Lwt-based echo server.")
    Term.(const run $ port_term $ logfile_term)

(* 4. Entry point *)

let () = exit (Cmd.eval server_cmd)
