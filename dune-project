(lang dune 3.16)

(name flow)

(generate_opam_files true)

(source
 (github srshbhryn/flow))

(authors "Sorush Bahariyan")

(maintainers "Sorush Bahariyan <sorush.bahariyan@gmail.com>")

(license MIT)

(documentation https://srshbhryn.github.io/flow) ; TODO

(package
 (name flow)
 (synopsis "Toy OCaml networking playground (echo + proxy   server)")
 (description
  "A small learning-oriented OCaml project demonstrating basic TCP
   networking primitives, including a simple echo server and a TCP
   proxy server. Designed for experimentation with sockets,
   concurrency, and modular design in OCaml.")
 (depends
  ocaml
  dune
  (base (>= v0.16.0))
 )
 (tags
  (topics networking tcp learning toy)))
