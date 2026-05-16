open Lwt.Syntax

(** Internal representation of an actor.

    An actor owns a mailbox implemented with an {!Lwt_stream}. Messages are
    pushed into the mailbox and processed sequentially by the actor loop. *)
type 'msg t = { push : 'msg option -> unit }

(** Spawn a new actor process and start its message loop. *)
let spawn (initial_state : 'state) (handler : 'state -> 'msg -> 'state Lwt.t) : 'msg t =
  let stream, push_to_stream = Lwt_stream.create () in
  let rec loop state =
    let* msg = Lwt_stream.get stream in
    match msg with
    | Some msg ->
      let* next_state = handler state msg in
      loop next_state
    | None -> Lwt.return_unit
  in
  Lwt.async (fun () -> loop initial_state);
  { push = push_to_stream }
;;

(** Send a message to the actor. *)
let send actor msg = actor.push (Some msg)

(** Stop the actor by closing its mailbox. *)
let stop actor = actor.push None
