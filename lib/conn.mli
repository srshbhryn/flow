type t

val echo : t -> unit Lwt.t
val proxy : t -> t -> unit Lwt.t
val new_conn : Lwt_io.input_channel -> Lwt_io.output_channel -> t
