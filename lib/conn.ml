open Lwt.Syntax

type t = { input : Lwt_io.input_channel; output : Lwt_io.output_channel }

let rec pass i o =
  let* red = Lwt_io.read_line_opt i in
  match red with
  | None -> Lwt.return ()
  | Some line ->
      let* () = Lwt_io.write_line o line in
      pass i o

let echo c = pass c.input c.output
let proxy c0 c1 = Lwt.join [ pass c0.input c1.output; pass c1.input c0.output ]
let new_conn ic oc = { input = ic; output = oc }
