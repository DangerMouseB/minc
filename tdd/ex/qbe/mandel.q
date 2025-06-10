export function $plot(w %.1, w %.2) {
@start.1
    %_x =l alloc4 4
    storew %.1, %_x
    %_y =l alloc4 4
    storew %.2, %_y
@body.2
    %_n =l alloc4 4
    %_fx =l alloc4 4
    %_fy =l alloc4 4
    %_zx =l alloc4 4
    %_zy =l alloc4 4
    %_nx =l alloc4 4
    %_ny =l alloc4 4
    %.7 =w loadw %_x
    %.9 =w loadw $W
    %.8 =w div %.9, 2
    %.6 =w sub %.7, %.8
    %.5 =w mul %.6, 4000
    %.12 =w loadw $W
    %.4 =w div %.5, %.12
    storew %.4, %_fx
    %.17 =w loadw %_y
    %.19 =w loadw $H
    %.18 =w div %.19, 2
    %.16 =w sub %.17, %.18
    %.15 =w mul %.16, 4000
    %.22 =w loadw $H
    %.14 =w div %.15, %.22
    storew %.14, %_fy
    %.24 =w loadw %_fx
    storew %.24, %_zx
    %.26 =w loadw %_fy
    storew %.26, %_zy
    storew 0, %_n
@while.cond.3
    %.30 =w loadw %_n
    %.29 =w csltw %.30, 200
    jnz %.29, @while.body.4, @while.end.5
@while.body.4
@if.6
    %.36 =w loadw %_zx
    %.37 =w loadw %_zx
    %.35 =w mul %.36, %.37
    %.39 =w loadw %_zy
    %.40 =w loadw %_zy
    %.38 =w mul %.39, %.40
    %.34 =w add %.35, %.38
    %.32 =w csltw 4000000, %.34
    jnz %.32, @true.7, @false.8
@true.7
    jmp @while.end.5
@false.8
    %.46 =w loadw %_zx
    %.47 =w loadw %_zx
    %.45 =w mul %.46, %.47
    %.44 =w div %.45, 1000
    %.51 =w loadw %_zy
    %.52 =w loadw %_zy
    %.50 =w mul %.51, %.52
    %.49 =w div %.50, 1000
    %.43 =w sub %.44, %.49
    %.54 =w loadw %_fx
    %.42 =w add %.43, %.54
    storew %.42, %_nx
    %.59 =w loadw %_zx
    %.60 =w loadw %_zy
    %.58 =w mul %.59, %.60
    %.57 =w div %.58, 500
    %.62 =w loadw %_fy
    %.56 =w add %.57, %.62
    storew %.56, %_ny
    %.64 =w loadw %_nx
    storew %.64, %_zx
    %.66 =w loadw %_ny
    storew %.66, %_zy
    %.68 =w loadw %_n
    %.67 =w add %.68, 1
    storew %.67, %_n
    jmp @while.cond.3
@while.end.5
    %.72 =l loadl $col
    %.73 =w loadw %_n
    %.74 =l extsw %.73
    %.75 =l mul 4, %.74
    %.71 =l add %.72, %.75
    %.70 =w loadw %.71
    storew %.70, %_n
    %.77 =l loadl $rnd
    %.79 =w loadw %_n
    %.80 =w loadw %_n
    %.76 =w call extern $SDL_SetRenderDrawColor(l %.77, w 100, w %.79, w %.80, w 255)
    %.83 =l loadl $rnd
    %.84 =w loadw %_x
    %.85 =w loadw %_y
    %.82 =w call extern $SDL_RenderDrawPoint(l %.83, w %.84, w %.85)
    ret
}

export function w $main() {
@start.9
@body.10
    %_c =l alloc4 4
    %_n =l alloc4 4
    %_x =l alloc4 4
    %_y =l alloc4 4
    %_ie =l alloc8 8
    %_e =l alloc8 8
    %_win =l alloc8 8
    storew 800, $W
    storew 800, $H
    %.5 =w call extern $SDL_Init(w 32)
    %.12 =w loadw $W
    %.13 =w loadw $H
    %.8 =l call extern $SDL_CreateWindow(l $.s1, w 0, w 0, w %.12, w %.13, w 0)
    storel %.8, %_win
    %.17 =l loadl %_win
    %.19 =w sub 0, 1
    %.16 =l call extern $SDL_CreateRenderer(l %.17, w %.19, w 0)
    storel %.16, $rnd
    %.24 =l call extern $malloc(w 56)
    storel %.24, %_e
    %.27 =l loadl %_e
    storel %.27, %_ie
    %.30 =w mul 201, 8
    %.29 =l call extern $malloc(w %.30)
    storel %.29, $col
    storew 20, %_c
    storew 0, %_n
@while.cond.11
    %.38 =w loadw %_n
    %.37 =w csltw %.38, 200
    jnz %.37, @while.body.12, @while.end.13
@while.body.12
    %.41 =w loadw %_c
    %.43 =l loadl $col
    %.44 =w loadw %_n
    %.45 =l extsw %.44
    %.46 =l mul 4, %.45
    %.42 =l add %.43, %.46
    storew %.41, %.42
    %.49 =w loadw %_c
    %.53 =w loadw %_c
    %.51 =w sub 255, %.53
    %.50 =w div %.51, 8
    %.48 =w add %.49, %.50
    storew %.48, %_c
    %.56 =w loadw %_n
    %.55 =w add %.56, 1
    storew %.55, %_n
    jmp @while.cond.11
@while.end.13
    %.60 =l loadl $col
    %.61 =w loadw %_n
    %.62 =l extsw %.61
    %.63 =l mul 4, %.62
    %.59 =l add %.60, %.63
    storew 30, %.59
    %.65 =l loadl $rnd
    %.64 =w call extern $SDL_RenderClear(l %.65)
    storew 0, %_x
@while.cond.14
    %.69 =w loadw %_x
    %.70 =w loadw $W
    %.68 =w csltw %.69, %.70
    jnz %.68, @while.body.15, @while.end.16
@while.body.15
    storew 0, %_y
@while.cond.17
    %.74 =w loadw %_y
    %.75 =w loadw $H
    %.73 =w csltw %.74, %.75
    jnz %.73, @while.body.18, @while.end.19
@while.body.18
    %.77 =w loadw %_x
    %.78 =w loadw %_y
    call $plot(w %.77, w %.78)
    %.80 =w loadw %_y
    %.79 =w add %.80, 1
    storew %.79, %_y
    jmp @while.cond.17
@while.end.19
    %.82 =w loadw %_x
    %.81 =w add %.82, 1
    storew %.81, %_x
    jmp @while.cond.14
@while.end.16
    %.84 =l loadl $rnd
    call extern $SDL_RenderPresent(l %.84)
@while.cond.20
    jnz 1, @while.body.21, @while.end.22
@while.body.21
@if.23
    %.87 =l loadl %_e
    %.86 =w call extern $SDL_PollEvent(l %.87)
    jnz %.86, @true.24, @false.25
@true.24
@if.26
    %.91 =l loadl %_ie
    %.90 =l add %.91, 0
    %.89 =w loadw %.90
    %.88 =w ceqw %.89, 769
    jnz %.88, @true.27, @false.28
@true.27
    jmp @while.end.22
@false.28
@false.25
    jmp @while.cond.20
@while.end.22
    %.95 =l loadl $rnd
    call extern $SDL_DestroyRenderer(l %.95)
    %.97 =l loadl %_win
    call extern $SDL_DestroyWindow(l %.97)
    call extern $SDL_Quit()
    ret
}


# GLOBAL VARIABLES
data $rnd = { l 0 }
data $W = { w 0 }
data $H = { w 0 }
data $col = { l 0 }

# STRING CONSTANTS
data $.s1 = { b "Mandelbrot", b 0 }
