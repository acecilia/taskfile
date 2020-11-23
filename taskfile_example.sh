#!/bin/zsh

set -euo pipefail

name="Andres"

say_hello() {
    surname="$1"
    echo "Hello, I am $name $surname"
}

say_hello_and_bye() {
    say_hello $1
    echo "Bye!"
}

"$@"