open Lwt.Infix
open Lwt.Syntax

(*

   module Conn = struct
     type t = {
       input: Lwt_io.input_channel;
       output: Lwt_io.output_channel;
     };;

     (* TODO exclude following function from Conn signature *)
     let rec pipe i o = let* red = Lwt_io.read_line_opt i in
       match red with
         | None -> Lwt.return ()
         | Some line ->
             let* () = Lwt_io.write_line o line in pipe i o
     ;;

     let echo c = pipe c.input c.output
     let proxy c0 c1 = Lwt.join [
       pipe c0.input c1.output;
       pipe c1.input c0.output;
     ]

   end *)

let handle_client log_oc _addr (ic, oc) =
  let rec loop () =
    let* red = Lwt_io.read_line_opt ic in
    match red with
    | None -> Lwt_io.write_line log_oc "client disconnected"
    | Some "exit" ->
        Lwt_io.write_line log_oc "client: exit" >>= fun () ->
        Lwt_io.write_line oc "Goodbye!"
    | Some line ->
        let* () = Lwt_io.write_line log_oc ("client: " ^ line) in
        let* () = Lwt_io.write_line oc ("echo: " ^ line) in
        loop ()
  in
  loop ()

let () =
  let port = 9000 in
  Lwt_main.run
    ( Lwt_io.open_file ~mode:Lwt_io.Output
        ~flags:[ Unix.O_CREAT; Unix.O_WRONLY; Unix.O_APPEND ]
        "server.log"
    >>= fun log_oc ->
      let _server =
        Lwt_io.establish_server_with_client_address
          (Unix.ADDR_INET (Unix.inet_addr_any, port))
          (handle_client log_oc)
      in

      Printf.printf "Listening on port %d\n%!" port;

      fst (Lwt.wait ()) )
