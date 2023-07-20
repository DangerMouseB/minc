#ifndef AJ_BTYPE_H
#define AJ_BTYPE_H "aj/btype.h"

#include "aj/buckets.h"


// OPEN: add aliases so can do - typedef can automatically add aliased
//<:Symb> lval(<:Node&ptr> n) {
//<:Symb> lval(<:pNode> n) {
// could we do <:unsigned int>

// https://cdecl.org/


// addressOf and deref - may create new types


// first do intersections - need to be able to do hash map of btyp *, null terminated just like strings - use the one
//      I found last year
// need exclusions for M8, M16, M32, M64 -> i8: m8 & i8_ or poss i8: m8_ & i & signed, etc
// second syms and nominals
// ptr1, const1, ptr2, const2, ptr3, const3, extern, the basic c types
// also need a test framework - python?
// need counting sort too


// https://stackoverflow.com/questions/6159677/gcc-clang-msvc-extension-for-specifying-c-enum-size
enum bmetatype : unsigned char {
    btnom = 1,  // nominal - atomic type with a given name
        // set ops
    btint = 2,  // intersection - sorted list of other types
    btuni = 3,  // union - sorted list of other types
        // product types (statically known size)
    bttup = 4,  // tuple - ordered list of other types
    btstr = 5,  // struct - ordered and named list of other types
    btrec = 6,  // record - sorted named list of other types
        // exponentials
    btseq = 7,  // sequence - tElement
    btmap = 8,  // map / dictionary - tKey, tValue
    btfnc = 9,  // function - argnames, tArgs, tRet, tFunc, num args
        // schemas
    btsvr = 10,  // schema variable
};
// typedef enum bmetatype : unsigned char Tristate;


#define BTYPE_TYPE unsigned int

typedef enum : BTYPE_TYPE {
    _nat = 0,           // not a type - i.e. an error code
    _m8 = 1,
    _m16 = 2,
    _m32 = 3,
    _m64 = 4,
    _p64 = 5,
    _i32 = 6,
    _litint = 7,
    _null = 8,          // empty set
} btype;

#define DESC_ID unsigned int
#define SYM_ID unsigned int

struct BType {
    enum bmetatype meta;            // 1 OPEN: could do 4 bits + 28 bits for type
    DESC_ID descId;                 // 4
};

typedef struct {
    BTYPE_TYPE n;                   // 4
    btype ts[];                     // n * 4
} BTypeList;

struct BTIntersection {
    BTypeList types;                // 4 + n * 4
};

struct BTUnion {
    BTypeList types;                // 4 + n * 4
};

struct BTTuple {
    BTypeList types;                // 4 + n * 4
};

struct BTStruct {
    SYM_ID *names;                  // 8
    BTypeList types;                // 4 + n * 4
};

struct BTRec {
    SYM_ID *names;                  // 8
    BTypeList types;                // 4 + n * 4
};

struct BTSeq {
    btype tElem;                    // 4
};

struct BTMap {
    btype tKey;                     // 4
    btype tValue;                   // 4
};

struct BTFunc {
    btype tRet;                     // 4
    btype tFn;                      // 4
    SYM_ID *names;                  // 8
    BTypeList *argtypes;            // 4 + n * 4
};

enum bexclusioncat {
    btnone = 0,
    btmemory = 1,
};


// ---------------------------------------------------------------------------------------------------------------------
// SType - StructuralType
// ---------------------------------------------------------------------------------------------------------------------
// the following is a reduced physical description of structs / tuples and c arrays for tracing and copying - can be
// generated for ctypes and btypes - there will be less stypes than btypes / ctypes but don't know how many


enum fieldtype : char {
    ptrToShallow = 1,       // offset to ptr to an object that contains no pointers
    ptrToDeep = 2,          // offset to ptr to object with pointers
    ptrToVariable = 3,      // offset to ptr to variable size object
    ptrToUnknown = 4,       // offset to void* (not managed)
    firstShallowElement = 5,
    firstPtrToShallowElement = 6,
    firstPtrToDeepElement = 7,
    firstPtrToVariableElement = 8,
    firstPtrToUnknownElement = 9,
};

struct fielddesc {
    unsigned short offset;      // 2
    enum fieldtype type;            // 1 + 1 padding
};

enum countType : char {
    given = 0,
    m8 = 1,
    m16 = 2,
    m32 = 3,
    m64 = 4,
};

struct fields {
    unsigned short numfields;           // 2 + 2 padding
    struct fielddesc fielddescs[];      // numfields * 4
};

struct SType {
    unsigned short basicSizeOf;         // 2 - size of the object without the array
    unsigned short elementSize;         // 2 - size of each array element
    unsigned short numElementsOffset;   // 2 - offset to the element count or the actual count
    enum countType numElementsType;     // 1
    char isDeep;                        // 1
    struct fields *fields;              // 8 - OPEN: could make this an id into an array reducing to 12 bytes
};                                      // 16

// object size is layout.basicSizeOf + &(layout.numElementsOffset) * layout.elementSize

// passing pointers to heap objects means the dispatch can work as can get type from pre area
// tagged unions can't be pass in registers but only in boxes that are at least 16 bytes for a double
// pass pointers to temporaries?


struct SType* stypes[0xFFFF];
typedef unsigned short stype;


// managed mode
enum managedmode : char {
    none = 0,           // nothing (0 bytes) is placed before aligned object
    moving = 2,         // stype (2 bytes) is placed before aligned object
    multi = 4,          // box by placing the btype (4 bytes) before aligned object
};

// boxing on stack - a 16 byte struct is passed

// https://stackoverflow.com/questions/74832688/how-to-determine-the-correct-way-to-pass-the-struct-parameters-in-arm64-assembly
// https://github.com/ARM-software/abi-aa/blob/2982a9f3b512a5bfdc9e3fea5d3b298f9165c36b/aapcs64/aapcs64.rst#parameter-passing-rules
// https://developer.apple.com/documentation/xcode/writing-arm64-code-for-apple-platforms
// https://github.com/ARM-software/abi-aa/blob/2982a9f3b512a5bfdc9e3fea5d3b298f9165c36b/aapcs64/aapcs64.rst#arm-c-and-c-language-mappings
// https://github.com/ARM-software/abi-aa/blob/2982a9f3b512a5bfdc9e3fea5d3b298f9165c36b/aapcs64/aapcs64.rst#the-base-procedure-call-standard

// https://github.com/ARM-software/abi-aa/releases

//https://github.com/ivmai/bdwgc/


struct box8 {
    int pad;
    btype btype;        // type is held in upper 4 bytes to match heap organisation
    union {
        double d;
        long l;
        void *p;
    };
};                      // 16

struct box4 {
    btype btype;        // type is held in upper 4 bytes to match heap organisation
    union {
        char c;
        short s;
        int i;
        float f;
    };
};                      // 8

//add_2(a:*double+err, b:*double+err) -> double+err
//add_2(a:double+err, b:double+err) -> double+err


// calling add_2(a:*double+err, b:*double+err) -> double+err with 2 doubles
//
// stack
// ------- a -------
// m32 pad
// m32 btype
// double a    <- *a
// ------- b -------
// m32 pad
// m32 btype
// double b    <- *b
// -----------------

// calling add_2(a:double, b:double) -> double with 2 doubles
// get put in registers

// CONCLUSION for moment bones just uses pointers for calling - can optimise to registers later (and we should)

// my qbe code will need to allocate 16 bytes for doubles / longs, 8 bytes for ints, shorts, chars

// https://stackoverflow.com/questions/68369577/how-to-control-the-abi-for-unions
// https://www.open-std.org/jtc1/sc22/wg14/www/docs/n2289.pdf - exceptions proposal
// discussion on above - https://news.ycombinator.com/item?id=17922715
// arm abi - https://github.com/ARM-software/abi-aa/releases

// calling add_2(a:double+err, b:double+err) -> double+err with 2 doubles
//
// stack
// ------- a -------
// m32 pad
// m32 btype
// double a    <- *a
// ------- b -------
// m32 pad
// m32 btype
// double b    <- *b
// -----------------


struct BTypeManager {
    char **txt_bySymId;                 // kept in string Buckets
    struct map *symid_byName;           // keys are pointers into symtxts Buckets
    unsigned int *order_bySymId;
    char **name_byBTypeId;              // names are pointers into symtxts Buckets
    struct map *bTypeId_byName;         // keys are pointers into symtxts Buckets

    struct BType *bType_byBTypeId;      // for the mo all these can be malloc'd with fixed size
    struct stype *stype_byBTypeId;
    struct BTYPE_TYPE *inter;
    struct BTYPE_TYPE *union;
    struct BTYPE_TYPE *tuple;
    struct BTYPE_TYPE *struct;
    struct BTYPE_TYPE *record;
    struct BTSeq *btseq_byDescId;
    struct BTMap *btmap_byDescId;
    struct BTFunc *btfnc_byDescId;

    Buckets intists;                    // null terminated lists of types and syms
    Buckets strings;                    // null terminated char* (utf8)
    enum bexclusioncat *bexclusioncat_byBTypeId;    // this could also be done as a list of types per category which makes adding CCY etc easier
};




#endif // AJ_BTYPE_H
