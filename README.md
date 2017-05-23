# Lwt &nbsp;&nbsp; [![version 3.0.0][version]][releases] [![LGPL][license-img]][copying] [![Gitter chat][gitter-img]][gitter] [![Travis status][travis-img]][travis] [![AppVeyor status][appveyor-img]][appveyor]

[version]:      https://img.shields.io/badge/version-3.0.0-blue.svg
[releases]:     https://github.com/ocsigen/lwt/releases
[license-img]:  https://img.shields.io/badge/license-LGPL-blue.svg
[gitter-img]:   https://img.shields.io/badge/chat-on_gitter-lightgrey.svg
[travis]:       https://travis-ci.org/ocsigen/lwt/branches
[travis-img]:   https://img.shields.io/travis/ocsigen/lwt/master.svg?label=travis
[appveyor]:     https://ci.appveyor.com/project/aantron/lwt/branch/master
[appveyor-img]: https://img.shields.io/appveyor/ci/aantron/lwt/master.svg?label=appveyor

Lwt is OCaml's concurrent programming library. It provides a single data type:
the *promise*, which is a value that will become determined in the future.
Creating a promise spawns a computation. When that computation is I/O, Lwt runs
it in parallel with your OCaml code.

OCaml code, including creating and waiting on promises, is run in a single
thread by default, so you don't have to worry about locking or preemption. You
can detach code to be run in separate threads on an opt-in basis.

Here is a simplistic Lwt program which requests the Google front page, and fails
if the request is not completed in five seconds:

```ocaml
let () =
  let request =
    let%lwt addresses = Lwt_unix.getaddrinfo "google.com" "80" [] in
    let google = (List.hd addresses).Lwt_unix.ai_addr in

    Lwt_io.(with_connection google (fun (incoming, outgoing) ->
      let%lwt () = write outgoing "GET / HTTP/1.1\r\n" in
      let%lwt () = write outgoing "Connection: close\r\n\r\n" in
      let%lwt response = read incoming in
      Lwt.return (Some response)))
  in

  let timeout =
    let%lwt () = Lwt_unix.sleep 5. in
    Lwt.return None
  in

  match Lwt_main.run (Lwt.pick [request; timeout]) with
  | Some response -> print_string response
  | None -> prerr_endline "Request timed out"; exit 1

(* ocamlfind opt -package lwt.unix -package lwt.ppx -linkpkg -o request example.ml
   ./request *)
```

In the program, functions such as `Lwt_io.write` create promises. The
`let%lwt ... in` construct is used to wait for a promise to become determined;
the code after `in` is scheduled to run in a "callback." `Lwt.pick` races
promises against each other, and behaves as the first one to complete.
`Lwt_main.run` forces the whole promise-computation network to be executed. All
the visible OCaml code is run in a single thread, but Lwt internally uses a
combination of worker threads and non-blocking file descriptors to resolve in
parallel the promises that do I/O.

<br/>

## Installing

```
opam install lwt
```

<br/>

## Documentation

The manual can be found [here][manual].

[Concurrent Programming with Lwt][rwo-lwt] is a great source of Lwt examples.
They are translations of code from the excellent Real World OCaml, but they are
just as useful if you are not reading the book.

Some examples are also available in Lwt's [`doc/examples`][examples].

*Note: much of the manual still refers to `'a Lwt.t` as "lightweight threads" or
just "threads." This will be fixed in the new manual. `'a Lwt.t` is a promise,
and has nothing to do with system or preemptive threads.*

[manual]:   http://ocsigen.org/lwt/manual/
[examples]: https://github.com/ocsigen/lwt/tree/master/doc/examples
[rwo-lwt]:  https://github.com/dkim/rwo-lwt#readme

<br/>

## Contact

Open an [issue][issues], visit [Gitter][gitter] chat, ask in [#ocaml][irc],
on [discuss.ocaml.org][discourse], or on [Stack Overflow][so]. Please do ask!
Even apparently simple questions often end up educating other users, not to
mention enlightening the maintainers!

Subscribe to the [announcements issue][announcements] to get news about Lwt
releases. It is less noisy than watching the whole repository. Announcements are
also made in [/r/ocaml][reddit], on the [OCaml mailing list][caml-list], and on
[discuss.ocaml.org][discourse].

[gitter]: https://gitter.im/ocaml-lwt/Lobby
[irc]:    http://webchat.freenode.net/?channels=#ocaml
[so]:     http://stackoverflow.com/questions/ask?tags=ocaml,lwt,ocaml-lwt
[announcements]: https://github.com/ocsigen/lwt/issues/309
[reddit]: https://www.reddit.com/r/ocaml/
[caml-list]: https://sympa.inria.fr/sympa/arc/caml-list
[discourse]: https://discuss.ocaml.org

<br/>

## Contributing

First, thanks for considering it! &nbsp; :tada:

Lwt welcomes contributions of all kinds, from contributors of all experience
levels.

You don't have to fix any messy code! Reading docs, asking any questions – this
helps all users of Lwt, and often educates the maintainers. Whether you are an
experienced OCamler, or are just getting started in open source, if you are
looking for a friendly community to work with, we hope to work with you on Lwt!

Depending on what you want to do, just [open an issue][issues] as you would in
any other project, submit a PR, or find us as descirbed in [Contact](#contact),
and ask us any question at all! Optionally, for details, advice, and a basic
overview of the code base, see [`CONTRIBUTING.md`][contributing-md].

We keep a list of [easy starter issues][easy-issues]. These let you focus on
getting used to the workflow, while still making a meaningful contribution for
everyone that uses Lwt.

We maintain a list of long-term Lwt projects, and a release plan, in a
[roadmap][roadmap] on the Lwt wiki. There, you can find out what the Lwt project
is up to as a whole. [Come ask us](#contact) about the roadmap, or otherwise
discuss it with us!

[roadmap]:  https://github.com/ocsigen/lwt/wiki/Roadmap
[issues]: https://github.com/ocsigen/lwt/issues/new
[easy-issues]: https://github.com/ocsigen/lwt/issues?q=is%3Aissue+is%3Aopen+label%3Aeasy
[contributing-md]: https://github.com/ocsigen/lwt/blob/master/CONTRIBUTING.md

<br/>

## License

Lwt is released under the LGPL, with an OpenSSL linking exception. See
[`COPYING`][copying].

[copying]: https://github.com/ocsigen/lwt/blob/master/doc/COPYING
