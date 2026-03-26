open Lwt.Infix
open Lwt.Syntax

let copy ic =
  let r1, w1 = Lwt_io.pipe () in
  let r2, w2 = Lwt_io.pipe () in

  let rec loop () =
    Lwt.catch
      (fun () -> Lwt_io.read_line_opt ic)
      (function
        | Lwt_io.Channel_closed _ -> Lwt.return_none | exn -> Lwt.fail exn)
    >>= function
    | None ->
        Lwt.join
          [
            Lwt.catch (fun () -> Lwt_io.close w1) (fun _ -> Lwt.return_unit);
            Lwt.catch (fun () -> Lwt_io.close w2) (fun _ -> Lwt.return_unit);
          ]
    | Some line ->
        Lwt_io.write_line w1 line >>= fun () ->
        Lwt_io.write_line w2 line >>= fun () -> loop ()
  in

  Lwt.async loop;
  (r1, r2)

let prefixize p ic =
  let r, w = Lwt_io.pipe () in
  let () =
    Lwt.async
      (let rec loop () =
         let open Lwt_io in
         let* red = read_line_opt ic in
         match red with
         | None -> close w
         | Some line ->
             let* () = write_line w (p ^ line) in
             loop ()
       in
       loop)
  in
  r

let string_of_sockaddr = function
  | Unix.ADDR_INET (addr, port) ->
      Printf.sprintf "%s:%d" (Unix.string_of_inet_addr addr) port
  | Unix.ADDR_UNIX path -> path

let sockaddr_of_string s =
  match String.split_on_char ':' s with
  | [ ip; port ] ->
      let addr = Unix.inet_addr_of_string ip in
      let port = int_of_string port in
      Unix.ADDR_INET (addr, port)
  | _ -> Unix.ADDR_UNIX s
