export
function d $scalarProduct(l %.1, l %.3, w %.5, w %.7) {
        %.2 =l alloc8 8
        storel %.1, %.2
        %.4 =l alloc8 8
        storel %.3, %.4
        %.6 =l alloc4 4
        storew %.5, %.6
        %.8 =l alloc4 4
        storew %.7, %.8
        %.9 =l alloc8 8
        %.11 =l alloc4 4
        %.10 =d swtof 0
        stored %.10, %.9
        storew 0, %.11
        %.12 =w loadw %.11
        %.13 =w loadw %.6
        %.14 =w csltw %.12, %.13
        jnz %.14, @for_body.4, @for_join.6
        %.15 =d loadd %.9
        %.16 =l loadl %.2
        %.17 =w loadw %.11
        %.18 =l extsw %.17
        %.19 =l mul %.18, 8
        %.20 =l add %.16, %.19
        %.21 =d loadd %.20
        %.22 =l loadl %.4
        %.23 =w loadw %.11
        %.24 =l extsw %.23
        %.25 =l mul %.24, 8
        %.26 =l add %.22, %.25
        %.27 =l loadl %.26
        %.28 =w loadw %.8
        %.29 =l extsw %.28
        %.30 =l mul %.29, 8
        %.31 =l add %.27, %.30
        %.32 =d loadd %.31
        %.33 =d mul %.21, %.32
        %.34 =d add %.15, %.33
        stored %.34, %.9
        %.35 =w loadw %.11
        %.36 =w add %.35, 1
        storew %.36, %.11
        jmp @for_cond.3
        %.37 =d loadd %.9
        ret %.37
}
export
function w $mmul(l %.1, l %.3, w %.5, w %.7, w %.9, l %.11) {
        %.2 =l alloc8 8
        storel %.1, %.2
        %.4 =l alloc8 8
        storel %.3, %.4
        %.6 =l alloc4 4
        storew %.5, %.6
        %.8 =l alloc4 4
        storew %.7, %.8
        %.10 =l alloc4 4
        storew %.9, %.10
        %.12 =l alloc8 8
        storel %.11, %.12
        %.13 =l alloc4 4
        %.17 =l alloc4 4
        storew 0, %.13
        %.14 =w loadw %.13
        %.15 =w loadw %.6
        %.16 =w csltw %.14, %.15
        jnz %.16, @for_body.10, @for_join.12
        storew 0, %.17
        %.18 =w loadw %.17
        %.19 =w loadw %.10
        %.20 =w csltw %.18, %.19
        jnz %.20, @for_body.14, @for_join.16
        %.21 =l loadl %.2
        %.22 =w loadw %.13
        %.23 =l extsw %.22
        %.24 =l mul %.23, 8
        %.25 =l add %.21, %.24
        %.26 =l loadl %.25
        %.27 =l loadl %.4
        %.28 =w loadw %.8
        %.29 =w loadw %.17
        %.30 =d call $scalarProduct(l %.26, l %.27, w %.28, w %.29)
        %.31 =l loadl %.12
        %.32 =w loadw %.13
        %.33 =l extsw %.32
        %.34 =l mul %.33, 8
        %.35 =l add %.31, %.34
        %.36 =l loadl %.35
        %.37 =w loadw %.17
        %.38 =l extsw %.37
        %.39 =l mul %.38, 8
        %.40 =l add %.36, %.39
        stored %.30, %.40
        %.41 =w loadw %.17
        %.42 =w add %.41, 1
        storew %.42, %.17
        jmp @for_cond.13
        %.43 =w loadw %.13
        %.44 =w add %.43, 1
        storew %.44, %.13
        jmp @for_cond.9
        ret 0
}
export
function w $mmul2(l %.1, l %.3, w %.5, w %.7, w %.9, l %.11) {
        %.2 =l alloc8 8
        storel %.1, %.2
        %.4 =l alloc8 8
        storel %.3, %.4
        %.6 =l alloc4 4
        storew %.5, %.6
        %.8 =l alloc4 4
        storew %.7, %.8
        %.10 =l alloc4 4
        storew %.9, %.10
        %.12 =l alloc8 8
        storel %.11, %.12
        %.13 =l alloc4 4
        %.17 =l alloc4 4
        %.32 =l alloc8 8
        %.39 =l alloc4 4
        storew 0, %.13
        %.14 =w loadw %.13
        %.15 =w loadw %.6
        %.16 =w csltw %.14, %.15
        jnz %.16, @for_body.20, @for_join.22
        storew 0, %.17
        %.18 =w loadw %.17
        %.19 =w loadw %.10
        %.20 =w csltw %.18, %.19
        jnz %.20, @for_body.24, @for_join.26
        %.21 =d swtof 0
        %.22 =l loadl %.12
        %.23 =w loadw %.13
        %.24 =l extsw %.23
        %.25 =l mul %.24, 8
        %.26 =l add %.22, %.25
        %.27 =l loadl %.26
        %.28 =w loadw %.17
        %.29 =l extsw %.28
        %.30 =l mul %.29, 8
        %.31 =l add %.27, %.30
        stored %.21, %.31
        %.33 =l loadl %.2
        %.34 =w loadw %.13
        %.35 =l extsw %.34
        %.36 =l mul %.35, 8
        %.37 =l add %.33, %.36
        %.38 =l loadl %.37
        storel %.38, %.32
        storew 0, %.39
        %.40 =w loadw %.39
        %.41 =w loadw %.8
        %.42 =w csltw %.40, %.41
        jnz %.42, @for_body.28, @for_join.30
        %.43 =l loadl %.12
        %.44 =w loadw %.13
        %.45 =l extsw %.44
        %.46 =l mul %.45, 8
        %.47 =l add %.43, %.46
        %.48 =l loadl %.47
        %.49 =w loadw %.17
        %.50 =l extsw %.49
        %.51 =l mul %.50, 8
        %.52 =l add %.48, %.51
        %.53 =d loadd %.52
        %.54 =l loadl %.32
        %.55 =w loadw %.39
        %.56 =l extsw %.55
        %.57 =l mul %.56, 8
        %.58 =l add %.54, %.57
        %.59 =d loadd %.58
        %.60 =l loadl %.4
        %.61 =w loadw %.39
        %.62 =l extsw %.61
        %.63 =l mul %.62, 8
        %.64 =l add %.60, %.63
        %.65 =l loadl %.64
        %.66 =w loadw %.17
        %.67 =l extsw %.66
        %.68 =l mul %.67, 8
        %.69 =l add %.65, %.68
        %.70 =d loadd %.69
        %.71 =d mul %.59, %.70
        %.72 =d add %.53, %.71
        stored %.72, %.52
        %.73 =w loadw %.39
        %.74 =w add %.73, 1
        storew %.74, %.39
        jmp @for_cond.27
        %.75 =w loadw %.17
        %.76 =w add %.75, 1
        storew %.76, %.17
        jmp @for_cond.23
        %.77 =w loadw %.13
        %.78 =w add %.77, 1
        storew %.78, %.13
        jmp @for_cond.19
        ret 0
}
