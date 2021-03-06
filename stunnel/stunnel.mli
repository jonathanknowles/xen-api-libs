(*
 * Copyright (C) 2006-2009 Citrix Systems Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; version 2.1 only. with the special
 * exception on linking described in file LICENSE.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *)
(** Thrown if we can't find the stunnel binary in the prescribed location *)
exception Stunnel_binary_missing
exception Stunnel_error of string
exception Stunnel_verify_error of string

val certificate_path : string
val crl_path : string

val use_new_stunnel : bool ref
val init_stunnel_path : unit -> unit

type pid = 
  | StdFork of int (** we forked and exec'ed. This is the pid *)
  | FEFork of Forkhelpers.pidty (** the forkhelpers module did it for us. *)
  | Nopid

val getpid: pid -> int

(** Represents an active stunnel connection *)
type t = { mutable pid: pid; 
	   fd: Unix.file_descr; 
	   host: string; 
	   port: int;
	   connected_time: float; (** time when the connection opened, for 'early retirement' *)
	   unique_id: int option;
	   mutable logfile: string;
	 }

(** Connects via stunnel (optionally via an external 'close fds' wrapper) to
    a host and port.
    NOTE: this does not guarantee the connection to the remote server actually works.
    For server-side connections, use Xmlrpcclient.get_reusable_stunnel instead.
 *)
val connect :
  ?unique_id:int ->
  ?use_external_fd_wrapper:bool ->
  ?write_to_log:(string -> unit) ->
  ?verify_cert:bool ->
  ?extended_diagnosis:bool ->
  string -> int -> t

(** Disconnects from stunnel and cleans up *)
val disconnect : ?wait:bool -> ?force:bool -> t -> unit

val diagnose_failure : t -> unit

val test : string -> int -> unit
