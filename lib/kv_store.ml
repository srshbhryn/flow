module type S = sig
  type t

  val get : t -> string -> string option Lwt.t
  val set : t -> string -> string -> unit Lwt.t
  val delete : t -> string -> bool Lwt.t
end
