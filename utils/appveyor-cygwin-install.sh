set -e
set -x

ocamlc -version

if [ $SYSTEM = msvc ]
then
    BRANCH=oasis-free-build
    git diff --name-only $BRANCH~ $BRANCH | xargs git checkout $BRANCH --
fi

DIRECTORY=$(pwd)

# AppVeyor does not cache empty subdirectories of .opam, such as $SWITCH/build.
# To get around that, create a tar archive of .opam.
CACHE=$DIRECTORY/../opam-cache-$SYSTEM-$COMPILER.tar

if [ ! -f $CACHE ]
then
    opam init -y --auto-setup
    eval `opam config env`

    opam pin add -y --no-action .
    opam install -y --deps-only lwt

    if [ $SYSTEM != msvc ]
    then
        opam install -y ounit
    fi

    ( cd ~ ; tar cf $CACHE .opam )
else
    ( cd ~ ; tar xf $CACHE )
    eval `opam config env`
fi
