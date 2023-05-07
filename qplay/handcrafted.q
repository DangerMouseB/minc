export function ub $LF() {
@start
    %t =w mul 12, 256
    %t =w add %t, 10
    call $printf(l $gLF, ..., w %t, w %t, ub 10)
    ret %t
}

export function w $LF2() {
@start
    %t =w add 10, 0
    ret %t
}

export function w $main(w %.0, l %.1) {
@start
    # uh version
    %pA =l call $LF()
    call $printf(l $gpA, ..., l %pA, l %pA, ub 10)
    
    %A =w loaduh %pA
    call $printf(l $gA, ..., w %A, w %A, ub 10)
    call $printf(l $gA, ..., uh %A, uh %A, ub 10)
    call $printf(l $gA, ..., ub %A, ub %A, ub 10)

    %B =w extub %A
    call $printf(l $gB, ..., w %B, w %B, ub 10)

    %C =w call $LF2()
    call $printf(l $gC, ..., ub %C, ub %C, ub 10)

    # C version
    %D =ub call $LF3()
    call $printf(l $gD, ..., ub %D, ub %D, ub 10)

    ret 0
}

data $gLF = { b "LF: 0x%.8x %d %c", b 0 }
data $gpA = { b "pA: 0x%.16x %llu %c", b 0 }
data $gA  = { b "A:  0x%.8x %d %c", b 0 }
data $gB  = { b "B:  0x%.8x %d %c", b 0 }
data $gC  = { b "C:  0x%.8x %d %c", b 0 }
data $gD  = { b "D:  0x%.8x %d %c", b 0 }
