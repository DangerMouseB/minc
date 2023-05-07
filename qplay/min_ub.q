export function ub $LF() {
@start
    ret 10
}

export function w $main(w %arg1, l %arg2) {
@start
    %a =ub call $LF()
    call $printf(l $str1, ..., ub %a)
    ret 0
}

data $str1 = { b "Hello world!%c", b 0 }


#.text
#.globl _LF
#_LF:
#	pushq %rbp
#	movq %rsp, %rbp
#	movl $10, %eax
#	leave
#	ret
#/* end function LF */
#
#.text
#.globl _main
#_main:
#	pushq %rbp
#	movq %rsp, %rbp
#	callq _LF
#	movl %eax, %esi
#	leaq _str1(%rip), %rdi
#	movl $0, %eax
#	callq _printf
#	movl $0, %eax
#	leave
#	ret
#/* end function main */
#
#.data
#.balign 8
#_str1:
#	.ascii "Hello world!%c"
#	.byte 0
#/* end data */