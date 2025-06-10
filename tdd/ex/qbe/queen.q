export function $print(l %.1) {
@start.1
    %_board =l alloc8 8
    storel %.1, %_board
@body.2
    %_i =l alloc4 4
    %_j =l alloc4 4
    storew 0, %_j
@while.3.cond
