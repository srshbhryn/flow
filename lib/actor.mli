(** A lightweight actor abstraction built on top of Lwt.

    Actors process messages sequentially in a dedicated loop while allowing
    concurrent message sending. Each actor maintains its own internal state
    that evolves as messages are handled. *)

(** Abstract actor handle. *)
type 'msg t

(** [spawn initial_state handler] creates a new actor.

    The actor starts with [initial_state]. For every received message [msg],
    [handler state msg] is called and returns the next state.

    The handler runs sequentially for each message.

    Returns a handle that can be used to {!send} messages to the actor
    or {!stop} it. *)
val spawn : 'state -> ('state -> 'msg -> 'state Lwt.t) -> 'msg t

(** [send actor msg] pushes [msg] into the actor's mailbox.

    Messages are processed in the order they are received. *)
val send : 'msg t -> 'msg -> unit

(** [stop actor] stops the actor gracefully.

    This closes the actor's mailbox and terminates its message loop
    once all previously queued messages have been processed. *)
val stop : 'msg t -> unit
