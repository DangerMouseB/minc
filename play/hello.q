export function w $main() {
@start.1
@body.2
    %_i =l alloc4 4
    storew 1, %_i
    %.4 =l add extern $fprintf, 0
    storel %.4, $p
    %.6 =l loadl extern $__stdoutp
    storel %.6, $f
    %.8 =l loadl $p
    storel %.8, $p2
    %.10 =l loadl $f
    %.12 =w loadw %_i
    %.13 =l loadl $p2
    %.9 =w call %.13(l %.10, l $s7, ..., w %.12)
    ret
}


# GLOBAL VARIABLES
data $f = { l 0 }
data $p = { l 0 }
data $p2 = { l 0 }

# STRING CONSTANTS
data $s7 = { b "hello %d\n", b 0 }
