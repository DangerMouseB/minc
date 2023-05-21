export function w $main() {
@start.1
@body.2
    %.2 =l add extern $fprintf, 0
    storel %.2, $p
    %.4 =l loadl extern $__stdoutp
    storel %.4, $f
    %.6 =l loadl $p
    storel %.6, $p2
    %.8 =l loadl $f
    %.10 =l loadl $p2
    %.7 =w call %.10(l %.8, l $s7)
    ret
}


# GLOBAL VARIABLES
data $f = { l 0 }
data $p = { l 0 }
data $p2 = { l 0 }

# STRING CONSTANTS
data $s7 = { b "hello\n", b 0 }
