
# Flow — A Toy OCaml Networking Playground

Flow is a small learning project exploring TCP networking in OCaml.
It currently includes two simple executables:

- **TCP Echo Server** – accepts connections and echoes back what the client sends.
- **TCP Proxy Server** – forwards traffic between a client and an upstream server.

The project is intentionally minimal and in an early, rudimentary stage.

## Features
- Basic TCP server accept-loop
- Echo server
- Simple TCP proxy demonstrating bidirectional piping
- Modularized small library (`conn`, `utils`)
- Built with dune

## Project Structure
```
flow/
  lib/
    conn.ml / conn.mli
    utils.ml
  bin/
    echo.ml
    proxy.ml
  test/
    test_flow.ml
  dune-project
```

## Requirements
- OCaml
- opam
- dune

## Build
```
dune build
```

## Run
### Echo
```
dune exec flow:echo -- <port>
```

### Proxy
```
dune exec flow:proxy -- <listen_port> <target_host> <target_port>
```

## Status
Experimental and incomplete. Future goals include async support, cleanup, and better tests.

