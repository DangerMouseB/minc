export function $print(l %.1) {
@start.1
    %_board =l alloc8 8
    storel %.1, %_board
@body.2
    ret
}

export function w $main() {
@start.3
@body.4
    call $print(w 0)
    ret
}


# GLOBAL VARIABLES

# STRING CONSTANTS
