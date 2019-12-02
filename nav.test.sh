#!/usr/bin/env bash

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
    assert_equal "$(nav which)" "$LAB_DIR"

    ## pin
    nav pin . lab
    nav pin ./Someplace place
    nav pin Someplace/Somewhere where
    nav pin "$LAB_DIR/Someplace/Somewhere/Deep Inside" inside

    assert_equal "$(nav pin invalid-dir dir)" "$(pwd)/invalid-dir is not a directory"
    assert_equal "$(nav pin . "£@invalid-name")" "Alias must only contain alphanumeric characters"

    ## to
    nav to place
    assert_equal "$(pwd)" "$LAB_DIR/Someplace"

    nav to where
    assert_equal "$(pwd)" "$LAB_DIR/Someplace/Somewhere"

    nav to inside
    assert_equal "$(pwd)" "$LAB_DIR/Someplace/Somewhere/Deep Inside"

    nav to lab
    assert_equal "$(pwd)" "$LAB_DIR"

    ## rm
    nav rm where
    nav rm inside
    assert_equal "$(nav to inside)" "No alias found matching inside"

    ## list
    assert_equal "$(nav list)" "$(echo -e "lab=$LAB_DIR\nplace=$LAB_DIR/Someplace")"

    # 3 Destroy lab
    rm -r "$LAB_DIR"
}

run

#5 Print results

if [ "$FAILS" = 0 ]; then
    echo "Pass"
else
    echo "Fail"
fi

echo "$PASSES Successful"
echo "$FAILS Failed"
