# Contributing to Lwt

Thanks! &nbsp; :+1:

We want to make contributing to Lwt as easy as possible. If you think you
already have a good idea of what to do, you don't have to look at this file. We
want to help you, not burden you! This file is just a bunch of tips and advice,
should you want to make use of it.

Please ask any questions you may have, whether about code, docs, the
contributing process, or anything else. Your questions make us think about
things we overlooked, and thus improve Lwt for everyone. A question is a
contribution! Reach us in [any way][contact] you prefer.

[contact]: https://github.com/ocsigen/lwt#contact


#### Table of contents

- [Easy issues](#Easy_issues)
- [Workflow](#Workflow)
  - [Testing](#Testing)
  - [Getting your change merged](#Getting_your_change_merged)
  - [Making additional changes](#Making_additional_changes)
  - [Cleaning up](#Cleaning_up)
- [Documentation](#Documentation)
- [Code overview](#Code_overview)


<br/>

<a id="Easy_issues"></a>
## Easy issues

The Lwt project maintains a list of [easy starter issues][easy]. Fixing any one
of these would help Lwt and all its users; yet they are all simple enough that
you can focus on getting used to the workflow, and not be overwhelmed by
challenging design decisions or crufty legacy code (which we are removing!).

[easy]: https://github.com/ocsigen/lwt/issues?q=is%3Aissue+is%3Aopen+label%3Aeasy


<br/>

<a id="Workflow"></a>
## Workflow

To get started, fork the Lwt repo by clicking on the "Fork" button in GitHub.
You will now have a repository at `https://github.com/your-user-name/lwt`. Let's
clone it to your machine:

```
git clone https://github.com/your-user-name/lwt.git
cd lwt/
```

Let's use Lwt's own [`opam`][opam-depends] file to install Lwt's dependencies
automatically. Before doing that, you may want to switch to a special OPAM
switch just for Lwt:

```
opam switch 4.04-lwt --alias-of 4.04.1   # optional
eval `opam config env`                   # optional
opam pin add -yn lwt .
opam install --deps-only lwt
```

[opam-depends]: https://github.com/ocsigen/lwt/blob/8bff603ae6d976e69698fa08e8ce08fe9615489d/opam/opam#L35-L43

Now, check out a new branch, and make your changes:

```
git checkout -b my-awesome-change
# code code code!
```

<a id="Testing"></a>
#### Testing

To build Lwt and run its unit tests, first do:

```
ocaml setup.ml -configure --enable-tests
```

After that, each time you are ready to test, just run

```
make test
```

If you want to test your development branch using another OPAM package that
depends on Lwt, install your development copy of Lwt with:

```
opam install lwt
```

If you make further changes, you can install your updated code with:

```
opam upgrade lwt
```

Since Lwt is pinned, these commands will install Lwt from your modified code.
All installed OPAM packages that depend on Lwt will be rebuilt against your
modified code when you run these commands.

<a id="Getting_your_change_merged"></a>
#### Getting your change merged

When you are ready, commit your change:

```
git commit
```

You can see examples of commit messages in the Git log; just run `git log`. Now,
upload your commit(s) to your fork:

```
git push -u origin my-awesome-change
```

Go to the GitHub web interface for your Lwt fork
(`https://github.com/your-user-name/lwt`), and click on the New Pull Request
button. Follow the instructions, write a nice description, and open the pull
request.

This will trigger automatic building and testing on many versions of OCaml and
several operating systems in [Travis][travis-ci] and [AppVeyor][appveyor-ci].
You can even a submit a preliminary PR just to trigger these tests – just tell
us that it's not ready for review!

At about the same time, a (hopefully!) friendly maintainer will review your
change and start a conversation with you. Ultimately, this will result in a
merged PR and an honest "thank you!" from us :smiley: We've all gone through
this process many times, and we know it can be a lot!

<a id="Making_additional_changes"></a>
#### Making additional changes

If additional changes are needed after you open the PR, just make them in your
branch locally, commit them, and run:

```
git push
```

This will push the changes to your fork, and GitHub will automatically update
the PR.

<a id="Cleaning_up"></a>
#### Cleaning up

If you don't want a development Lwt installed in your OPAM switch anymore, you
can do

```
opam remove lwt
```

[travis-ci]: https://travis-ci.org/ocsigen/lwt
[appveyor-ci]: https://ci.appveyor.com/project/aantron/lwt


<br/>

<a id="Documentation"></a>
## Documentation

The `README` has a [list of documentation resources for users][user-docs]. This
section lists documentation resources for contributors; some of them overlap.
For now, we have:

- [The manual][manual], which we are rewriting, as it needs considerable
  improvement.
- If you'd like to understand how Lwt works at the core, don't read the current
  `lwt.ml`. Read [the one in PR #354][new-lwt.ml] instead. This contains a
  thorough explanation of everything. Reviews of [the PR][pr354] would also be
  appreciated :)

We are working on improving all documentation. Please ask any questions you have
about it, give feedback, etc.!

[user-docs]: https://github.com/ocsigen/lwt#documentation
[manual]: https://ocsigen.org/lwt/manual/
[new-lwt.ml]: https://github.com/ocsigen/lwt/blob/fdff5c09d47d2b020d4998ebed922acf383a2e9d/src/core/lwt.ml#L27
[pr354]: https://github.com/ocsigen/lwt/pull/354


<br/>

<a id="Code_overview"></a>
## Code overview

The library is separated into several layers and sub-libraries, grouped by
directory. This list surveys them, roughly in order of importance.

- `src/core/` is the "core" library. It is written in pure OCaml, so it is
  portable across all systems and to JavaScript.

  The major file here is `src/core/lwt.ml`, which implements the main type,
  `'a Lwt.t`. Also here are some pure-OCaml data structures and synchronization
  primitives. Most of the modules besides `Lwt` are relatively trivial – the
  only exception to this is `Lwt_stream`.

  The code in `src/core/` doesn't know how to do I/O.

- `src/ppx/` is the Lwt PPX. It is also portable, but separated into its own
  little code base, as it is an optional separate library.

- `src/unix/` is the Unix binding, i.e. `Lwt_unix`, `Lwt_io`, `Lwt_main`, some
  other related modules, and a bunch of C code. This is what actually does I/O,
  maintains a worker thread pool, etc. Obviously, this is not portable to
  JavaScript. It supports Unix and Windows. We want to write a future pair of
  Node.js and Unix/Windows bindings, so that code using them is portable, even
  if two separate sets of bindings are required.

  Some of the C code in the Unix binding is generated by
  `src/unix/gen_stubs.ml`.

- `src/preemptive/` is like the Unix binding. The Unix binding is available only
  on Unix; similarly, `src/preemptive` is available only if the threaded runtime
  is available on the host system (AFAIK it always is, in practice). If so, this
  dirctory provides `Lwt_preemptive`.

- `src/logger/` provides `Lwt_log`. This library is separated into two portions,
  `Lwt_log_core` is portable, as the Lwt core is, and `Lwt_log` proper assumes
  a Unix system.

- `src/ssl/`, `src/react/`, `src/glib/` provide the separate libraries
  `Lwt_ssl`, `Lwt_react`, `Lwt_glib`, respectively. These are basically
  independent projects that live in the Lwt repo.

- `src/util/` contains various scripts, such as the configure script
  `src/util/discover.ml`, Travis and AppVeyor scripts, etc.

- *deprecated* `src/camlp4/` contains the Camlp4 syntax extension, which is
  deprecated in favor of the PPX (in `src/ppx`).

- *deprecated* `src/simple_top/` contains the Lwt top-level, which is deprecated
  in favor of [utop][utop].

[utop]: https://github.com/diml/utop
