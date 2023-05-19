export function w $main() {
@start.1
@body.2
	%.2 =l loadl extern $__stdoutp
	%.1 =w call extern $fprintf(l %.2, l $g4)
	ret
}


# GLOBAL VARIABLES

# STRING CONSTANTS
data $g4 = { b "hello\n", b 0 }
