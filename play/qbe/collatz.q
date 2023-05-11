export function w $main() {
@Lstart.1
@Lbody.2
	%_n =l alloc4 4
	%_nv =l alloc4 4
	%_c =l alloc4 4
	%_cmax =l alloc4 4
	%_mem =l alloc8 8
	%.3 =w mul 8, 4000
	%.2 =l call $malloc(w %.3)
	storel %.2, %_mem
	storew 0, %_cmax
	storew 1, %_nv
@L3
	%.11 =w loadw %_nv
	%.10 =w csltw %.11, 1000
	jnz %.10, @L4, @L5
@L4
	%.14 =w loadw %_nv
	storew %.14, %_n
	storew 0, %_c
@L6
	%.18 =w loadw %_n
	%.17 =w cnew %.18, 1
	jnz %.17, @L7, @L8
@L7
	%.21 =w loadw %_n
	%.22 =w loadw %_nv
	%.20 =w csltw %.21, %.22
	jnz %.20, @L9, @L10
@L9
	%.25 =w loadw %_c
	%.28 =l loadl %_mem
	%.29 =w loadw %_n
	%.30 =l extsw %.29
	%.31 =l extuw %.30
	%.32 =l mul 4, %.31
	%.27 =l add %.28, %.32
	%.26 =w loadw %.27
	%.24 =w add %.25, %.26
	storew %.24, %_c
	jmp @L8
@L10
	%.34 =w loadw %_n
	%.33 =w and %.34, 1
	jnz %.33, @L11, @L12
@L11
	%.40 =w loadw %_n
	%.38 =w mul 3, %.40
	%.37 =w add %.38, 1
	storew %.37, %_n
	jmp @L13
@L12
	%.44 =w loadw %_n
	%.43 =w div %.44, 2
	storew %.43, %_n
@L13
	%.47 =w loadw %_c
	%.46 =w add %.47, 1
	storew %.46, %_c
	jmp @L6
@L8
	%.49 =w loadw %_c
	%.51 =l loadl %_mem
	%.52 =w loadw %_nv
	%.53 =l extsw %.52
	%.54 =l extuw %.53
	%.55 =l mul 4, %.54
	%.50 =l add %.51, %.55
	storew %.49, %.50
	%.57 =w loadw %_cmax
	%.58 =w loadw %_c
	%.56 =w csltw %.57, %.58
	jnz %.56, @L14, @L15
@L14
	%.60 =w loadw %_c
	storew %.60, %_cmax
@L15
	%.62 =w loadw %_nv
	%.61 =w add %.62, 1
	storew %.61, %_nv
	jmp @L3
@L5
	%.65 =w loadw %_cmax
	%.63 =w call $printf(l $g7, ..., w %.65)
	ret
}

data $g7 = { b "should print 178: %d\n", b 0 }
