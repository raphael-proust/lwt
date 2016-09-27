set -e
set -x

if [ $SYSTEM != msvc ]
then
    TEST=--build-test
else
    TEST=
fi

opam install -y $TEST --keep-build-dir --verbose lwt
