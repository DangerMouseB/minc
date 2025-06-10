export function sb $lf() {
@start.1
@body.2
    ret 10
}

export function w $main() {
@start.3
@body.4
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
    %.13 =sb call $lf()
    %.14 =l loadl $p2
    %.9 =w call %.14(l %.10, l $.s1, ..., w %.12, sb %.13)
    ret
}


# GLOBAL VARIABLES
data $f = { l 0 }
data $p = { l 0 }
data $p2 = { l 0 }

# STRING CONSTANTS
data $.s1 = { b "hello %d%c", b 0 }

# TYPE LANG
export data $t_lf = { b "void^i8", b 0 }
export data $t_main = { b "void^i32", b 0 }