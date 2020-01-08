#!/usr/bin/env bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

FAILS=0
PASSES=0

assert_equal () {
    if test "$1" == "$2"; then
        ((++PASSES))
    else
        ((++FAILS))
        echo "Failed to assert that $1 is equal to $2"
    fi
}

exec_nav () {
    NO_ACTION_MESSAGES="true" FORMAT="false" nav "$@"
}

run () {
    # 1 Setup lab
    LAB_DIR="$DIR/lab"
    mkdir "$LAB_DIR"
    cd "$LAB_DIR"

    NAV="$LAB_DIR/nav"
    NAV_CONFIG="$LAB_DIR/.nav.config"
    cp "$DIR/nav" "$NAV"

    source "$NAV"

    # 2 Define tests

    mkdir -p "$LAB_DIR/Someplace/Somewhere/Deep Inside"

    ## which
    assert_equal "$(exec_nav which)" "$LAB_DIR"

    ## pin
    exec_nav pin . lab
    exec_nav pin ./Someplace/ place
    exec_nav pin Someplace/Somewhere where
    exec_nav pin "$LAB_DIR/Someplace/Somewhere/Deep Inside" inside

    assert_equal "$(exec_nav pin invalid-dir dir)" "'$(pwd)/invalid-dir' is not a directory"
    assert_equal "$(exec_nav pin . "£@invalid-name")" "Alias must only contain alphanumeric characters"

    ## to
    exec_nav to place
    assert_equal "$(pwd)" "$LAB_DIR/Someplace"

    exec_nav to where
    assert_equal "$(pwd)" "$LAB_DIR/Someplace/Somewhere"

    exec_nav to inside
    assert_equal "$(pwd)" "$LAB_DIR/Someplace/Somewhere/Deep Inside"

    exec_nav to lab
    assert_equal "$(pwd)" "$LAB_DIR"

    ## rm
    exec_nav rm where
    exec_nav rm inside
    assert_equal "$(exec_nav to inside)" "No alias found matching 'inside'"

    ## list
    assert_equal "$(exec_nav list)" "$(echo -e "lab=$LAB_DIR\nplace=$LAB_DIR/Someplace")"

    # 3 Destroy lab
    rm -r "$LAB_DIR"
}

run

echo "$PASSES Successful"
echo "$FAILS Failed"

if [ ! "$FAILS" = 0 ]; then
    exit 1
fi
