# Flow — A Toy OCaml Networking Playground

Flow is a small learning project exploring TCP networking and concurrent systems in OCaml.
It currently includes several small executables demonstrating networking primitives, simple protocol handling, and an actor‑based key–value store.

The project is intentionally minimal and experimental, focused on learning rather than production use.

## Features

- Basic TCP server accept-loop
- TCP Echo server
- Simple TCP proxy demonstrating bidirectional piping
- Actor-based in‑memory key–value store
- Multiple storage backends for the KV store
- Modularized library components (`conn`, `utils`, `actor`, `kv_store`)
- Built with dune

## Components

### Echo Server

A minimal TCP server that echoes back whatever the client sends.
Useful for testing the networking utilities and connection handling.

### TCP Proxy

A simple proxy that forwards traffic between a client and an upstream server.
Demonstrates bidirectional stream piping between sockets.

### KV Store Server

A small text‑protocol key–value store built around a single actor managing the store state.
Clients communicate via a simple line-based protocol over TCP.

Supported commands:

SET <key> <value>
GET <key>
DELETE <key>

Example responses:

OK
VALUE <value>
DELETED
NOT_FOUND
ERROR

The server supports multiple storage backends selectable at startup.

#### Backends

List backend
- Simple append‑only association list.
- Educational and easy to inspect.
- Inefficient for large datasets.

Hash table backend
- Uses OCaml `Hashtbl`.
- Faster key lookups.

## Project Structure

flow/
  lib/
    conn.ml / conn.mli        TCP connection helpers
    utils.ml                  small utility helpers
    actor.ml                  lightweight actor abstraction
    kv_actor.ml               actor managing KV store operations
    kv_store.ml / kv_store.mli store interface
    kv_store_list.ml          list-based store backend
    kv_store_hashlib.ml       hashtable-based store backend

  bin/
    echo.ml                   echo server
    proxy.ml                  TCP proxy
    kv.ml                     key-value store server entrypoint

  test/
    test_flow.ml

  dune-project

## Requirements

- OCaml
- opam
- dune

Recommended tools:

- telnet
- netcat

## Build

dune build

## Run

### Echo Server

dune exec flow:echo -- <port>

Example:

dune exec flow:echo -- 9000

Test:

telnet localhost 9000

---

### Proxy Server

dune exec flow:proxy -- <listen_port> <target_host> <target_port>

Example:

dune exec flow:proxy -- 9000 example.com 80

---

### KV Store Server

dune exec flow:kv -- --port <port> --backend <list|hash>

Example:

dune exec flow:kv -- --port 7000 --backend hash

Connect:

telnet localhost 7000

Example session:

SET foo bar
OK
GET foo
VALUE bar
DELETE foo
DELETED
GET foo
NOT_FOUND

You can also test with netcat:

printf "SET a 1\nGET a\n" | nc localhost 7000

## Testing

Example manual testing:

SET key value
GET key
DELETE key

Basic stress testing can be done with netcat or small shell scripts that open multiple concurrent connections.

## Status

Experimental and incomplete. This project is primarily a learning playground for:

- TCP networking in OCaml
- actor-style concurrency
- modular backend design using module types
- simple protocol implementation

Possible future improvements:

- Lwt/async improvements
- better protocol parsing
- persistent storage backend
- sharded KV actors
- improved tests and benchmarking
- better documentation
