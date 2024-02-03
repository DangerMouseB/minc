#include <stdlib.h>
#include <stdalign.h>
#include "../../coppertop/bk/include/bk/bk.h"
#include "../../coppertop/bk/include/bk/rst.h"


/*

+ => add(lhs, rhs)
 lhs is ptr, rhs is int
 lhs is int, rhs is ptr
 lhs is int, rhs is int

 t3 = add(t1, t2)

 %t3 =w add %t1, %t2
 %t3 =l add %t1, %t2
 %t3 =s add %t1, %t2
 %t3 =d add %t1, %t2

 + will need to zero or sign extend

 */


// doing bones and C here to stretch the design - C is pass by value, bones is pass by ref, C allows mutation,
// bones does not, C allocs and frees memory directly, bones uses a CoW memory manager
// both can compile to QBE, MIR, LLVM and BVM (BVM, JBC, BBC?), both use the C ABI, and bones needs exceptions,
// both should be debuggable (at least in the BVM). The BVM should expose a C ABI and thus be easily embeddable.
// Jones should provide gc, arenas, scratch, borrow and CoW support. The BVM speaks the debugger protocol.



int main(int argc, char*argv[]) {
    Buckets a; smbase *sm;
    rst *n1, *n2, *n3, *n4, *n5, *n6, *n7, *n8, *n9, *n10, *n11, *n12; bscope *locals; bscope *fns;

    initBuckets(&a, 4096);

    locals = mklocalscope(&a);
    fns = mkfnscope(&a);
    sm = allocInBuckets(&a, sizeof(smbase), bk_alignof(smbase));

    // C source
    //
    // int main() {
    //     int a;
    //     a = 1;
    //     a += 1;
    //     return a;
    // }

    // bones source
    // main: {:i32
    //     a: 1
    //     a: a + 1
    //     ^ a
    // }

    // target QBE
    //
    // export function w $main() {
    // @start.1
    // @body.2
    //     %_a =l alloc4 4
    //     storew 1, %_a
    //     %.5 =w loadw %_a
    //     %.4 =w add %.5, 1
    //     storew %.4, %_a
    //     %.7 =w loadw %_a
    //     ret %.7
    // }

    // typed rst (reduced-syntax-tree) - C and bones
    //       ________________________________ seq _________________________________
    //      /               |                              |                       \
    // stalloc("a", TBI)   bindto(locals, "a")          bindto(locals, "a")        ret
    //                      ||                             |                       |||
    //                    litint(1)        _____________ apply ____              get(locals, "a")
    //                                    /           ||           \
    //                           get(locals, "a")   litint(1)    getoverload("add", 2)


    // advantage of binary tree is we can add variables to the node struct simplifying memory management, actually
    // can do that also by storing structs with pointers to nodes rather than just pointers to nodes
    // advantage of the array format is potentially cache friendliness but more importantly random access
    // in bones we know the sizes of all groups after the first pass

    // in the C code the type of a is set to be a i32, in bones the return type is i32 but the type of a is inferred to
    // be a lit in
    // in C litints are cast on the bind and on the add, the "||" symbols above
    // in bones we could also to that, but we delay it until the last possible moment i.e. on the return, "|||" above
    // should the weakening be explicit in the bst? in bones it is the outcome of type analysis.

    // seq and apply both are variable size - in the code that generates the rst we could track them by reallocing a
    // variable size in a scratch arena and copying it  once the size is known, can't traverse the nodes twice as we
    // would then need the pointer to the new node - this was done in the minic qbe emission by mutating nodes so they
    // know the Symb (temp variable of their input node, i.e an expression node)

    // fns
    // add_2; litint*litint ^ litint

    n1 = mkstalloc(&a, 1, "a", B_I32);

    // exponentials need to grow and shrink
    // garbage collectors need to be able to traverse a network easily - does it look like a pointer
    // conservative (mustn't accidentally mess with program data)
    // if we have type data we have more freedom around collection but that means every object must be
    // typed - we don't need to tag everything but the gc must have access to the type if not
    // stack and scratch data don't need gcing so we don't need their types (however they might be the roots
    // arena based gc - generational / copying gc doesn't need a bucket system
    // tracing gc does

    // we want to parameterise behaviour e.g. use gc memory for this and arena memory for that
    // malloc and free are rather inefficient? but could track things to free in a bucket and do as a batch
    //


    // when we grow we have to copy

    // it's all about tracking closure - deep copy, buckets, etc
    // a tree is like a linked list
    // a syntax tree is a tagged linked list
    // things that grow - local variables (in a pass) types of globals, the overal program state
    // tracing and refcounting gc assume known sized boxes - either fixed (pool) or variable (mallo et al)

    // we need to keep templates and a growing list of compiled code lists
    // some things don't move well, stuff with external references, object table (layer of indirection
    // cache locality is problematic, hence MIRs thunk
    // in bones we believe that immutability is a price worth paying - two approaches
    // reduce aliases - context, borrow checking
    // copy on write
    // this will create a lot of garbabge - trace, track (count / borrow) or copy?

    // in python (ie with exponentials) I can inefficiently yet easily simulate a CoW memory manager
    // by using dicts - the C api is very verbose

    // in the kernel rsts are likly long lived (schemas), interpreted (for debugging)
    // also dispatch structures will be long lived
    // given their simplicity we can type the structs for a gc scheme (so the gc can traverse the pointers)
    // pointer detection - assume pointers are aligned, last 3 bits must be zero, must point into managed memory
    // must point to beginning of object - all possible sources of error
    // meta types - array of lengths / types
    // m8, m16, m32, m64, p64, struct, and every struct needs a memory type
    // tracing is cache destroying, copying is cache destroying (maybe less work overall) as don't need pools (that track fee slots)
    // but copying cannot work with external references (and how do we count external references anyway?)

    // third party gc looks interesting now
    // memory management of a compiler is easier than that of a kernel (thus faster)
    // the ideal language provides access to many lifetimestyles to the expert programmer
    // and a simple one for the novice

    // memory management is a meta programming problem and aided by a reflective type system
    // QUESTION: what types can the bones type system not describe? nominal inheritence?
    // that's a (misconceived) behavioural system that expects answers of a type system that
    // shouldn't and can't be answered, i.e. trying to call something a type error that isn't,
    // or call something not a type that is. can a cheeta live in an animal house.

    // general containers need void*, and concrete casts


    // PLAN
    // flesh out the MM interface using this test + the orient algo
    // bones objects are immutable - so we need a copy fn
    // compiler can use dirty buckets
    // start of with an infinite bump allocator
    // then conservative copying (marking pages as kept)
    // then reuse page for cache locality with line level init
    // can we avoid read and write barriers for bones
    // do we need barriers for C?

    // Low-Latency, High-Throughput Garbage Collection (Extended Version) - p2
    // C4, Shenandoah and ZGC use concurrent evacuation to optimize pause times, adding high overheads (Table 1).
    // They reclaim space only when a region is empty: when all objects eventually die or they evacuate live objects.
    // Evacuation perturbs the memory hierarchy, using caches and DRAM bandwidth. Worse, concurrent evacuation requires
    // expensive barriers to prevent mutator and collector races, which is intrinsically more expensive than
    // stop-the-world evacuation [35]. LXR avoids these overheads with the Immix heap structure [11] and reference
    // counting with remembered sets, reclaiming most memory without copying, only j

    // bones need the refcount for CoW optimisation
    // bones, being immutable, can't have cycles so doesn't need the cycle detection. However, C is not immutable so
    // it will need cycle-detection.
    // can we reuse https://www.mmtk.io/
    // can use code from https://www.imperial.ac.uk/media/imperial-college/faculty-of-engineering/computing/public/1920-ug-projects/Aurel-B%C3%ADl%C3%BD.pdf
    //   and https://github.com/HaxeFoundation/hashlink/pull/372 especially techniques to get the stack and register
    //   roots (will need to handle pointer to the middle of structs)
    // bones will have a scratch?

    // j_alloc(size, align)
    // j_drop(ptr)                      we know it's dropped
    // j_alloc_no_gc(size, align)       why not just malloc?
    // j_allocDirty(size, align)        the buckets allocator - preserves locality without cleaning
    // j_allocClean(size, align)        the buckets allocator - preserves locality with cleaning
    // j_allocDScratch(size, align)     the DAG Scratch allocator
    // j_addRef
    // j_decRef
    // j_pin(ptr)
    // j_unpin(ptr)
    // j_addRoot(ptr, btype)
    // j_castRoot(ptr, btype)
    // j_dropRoot(ptr)
    // j_addPRoot(pRoot, btype)
    // j_castPRoot(pRoot, btype)
    // j_dropPRoot(pRoot)
    // j_resetDScratch(hNursary)
    // j_pausingGC()
    // j_gcCycles()
    // j_init(initialVMSize)   - e.g. 1TB

    // any object with rc == 1 or 0 can be easily moved
    // do we need arena's with RCImmix?

    // - generally bones types don't need gc but may need to point to objects that do - so we don't need to trace them
    //   but do need to keep the roots and if the object moves the type object will need updating
    // - must return memory to the OS

    // Fast Conservative Garbage Collection - p14
    // Despite RC Immixcons having the mutator-time burden of maintaining an object map and a write barrier, its
    // locality advantages are enough to deliver better mutator performance than BDW.

    // rst compiler will use jones_om, bones obviously does, c can. We can easily (ish) add bones types to C, but is
    // it possible/easy/desirable to add managed objects

    // do we want bones to be a long-running analytics server? design for the future, implement for the now?

    // IMPORTANT
    // the jones vm provides
    //  arena
    //  object manager api (i.e. with moving, gc, pinning, CoW optimisation)
    //  type system (with type lang)
    //  multi-dispatch
    //  inference over a reduced syntax tree
    //  code generation from rst to QBE (later MIR, LLVM)
    //  debugger - i.e. stepping and inspection


    // in bones we are immutable
    // the bones compiler (post parse) must insert CoW write barriers where necessary, the vm OM must support CoW
    // so every bones object must have a reference count for immutability rather than gc
    // so even nursary objects need RC meta data but it doesn't need touching until a write happens

    // at the end of a function the nursary can be compacted? it must have been market at the start of the function
    // roots are all new variables on stack + any assignments to context, module or globals.
    // 105GB query - there's no point in returning memory back to os in middle of query as we might need it again, but
    // if we hit our allowed limit we might need to gc (evacuate / compact) in middle


    // real goal is high performance analytics at the algo level rather than the operation level - like kdb
    // CoW

    n2 = mklitint(&a, 1);
    n3 = mkbindto(&a, n2, locals, "a");

    n4 = mkget(&a, locals, "a");
    n5 = mklitint(&a, 1);
    n6 = mkgetoverload(&a, fns, "add", 2);
    n7 = mkapply(&a, n6, 2, n4, n5);
    n8 = mkbindto(&a, n7, locals, "a");

    n9 = mkget(&a, locals, "a");
    n10 = mkret(&a, n9, locals);

    n11 = mkseq(&a, 4, n1, n3, n8, n10);

    emitqbe(n11, sm);

}





































