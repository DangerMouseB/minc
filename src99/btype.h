#ifndef AJ_BTYPE_H
#define AJ_BTYPE_H

#include "arena.h"

#define _hc1 0
#define _hc2 20

// OPEN: add aliases so can do - typedef can automatically add aliased
//<:Symb> lval(<:Node&ptr> n) {
//<:Symb> lval(<:pNode> n) {
// could we do <:unsigned int>

enum btyp{
    B_ILLEGAL = 0,          // to catch bugs
    B_U8  = _hc1+1,         // char, unsigned char
    B_U16 = _hc1+2,         // unsigned short
    B_U32 = _hc1+3,         // signed int
    B_U64 = _hc1+4,         // unsigned long, unsigned long int
    B_I8  = _hc1+5,         // signed char
    B_I16 = _hc1+6,         // short, signed short
    B_I32 = _hc1+7,         // int, signed int
    B_I64 = _hc1+8,         // long, long int, signed long, signed long int

    B_F32 = _hc1+9,         // float
    B_F64 = _hc1+10,        // double

    B_CHARS = _hc1 + 11,    // null terminated uft-8 array, char*
    B_N_CHARS = _hc1 + 12,  // N**chars, char*argv[], char**
    B_TXT = _hc1+13,        // txt (length prefixed, null terminated uft-8 array)
    B_NN_I32 = _hc1+14,     // int **, signed int **
    B_N_I32 = _hc1+15,      // int *, signed int *
    B_UTMEM = _hc1+16,      // void *

    B_VOID = _hc2+1,
    B_VARARGS = _hc2+2,
    B_U8_S = _hc2+3,
    B_N_UTMEM = _hc2+4,     // N**UT_MEM
};

// addressOf and deref - may create new types


enum bmetatype {
    btnom,  // nominal - atomic type with a given name
        // set ops
    btint,  // intersection - sorted list of other types
    btuni,  // union - sorted list of other types
        // product types (statically known size)
    bttup,  // tuple - ordered list of other types
    btstr,  // struct - ordered and named list of other types
    btrec,  // record - sorted named list of other types
        // exponentials
    btseq,  // sequence - tElement
    btmap,  // map / dictionary - tKey, tValue
    btfnc,  // function - argnames, tArgs, tRet, tFunc, num args
        // schemas
    btsvr,  // schema variable
};


typedef unsigned int BTYPE_ID;
#define DESC_ID unsigned int
#define SYM_ID unsigned int

struct BType {
    enum bmetatype meta;            // 4
    DESC_ID descId;                 // 4
};

struct BTInter {
    BTYPE_ID *types;                // 8
};

struct BTUnion {
    BTYPE_ID *types;                // 8
};

struct BTTuple {
    BTYPE_ID *types;                // 8
};

struct BTStruct {
    SYM_ID *names;                  // 8
    BTYPE_ID *types;                // 8
};

struct BTRec {
    SYM_ID *names;                  // 8
    BTYPE_ID *types;                // 8
};

struct BTSeq {
    BTYPE_ID tElem;                 // 8
};

struct BTMap {
    BTYPE_ID tKey;                  // 8
    BTYPE_ID tValue;                // 8
};

struct BTFunc {
    SYM_ID *names;                  // 8
    BTYPE_ID *types;                // 8
    BTYPE_ID tRet;                  // 4
    BTYPE_ID tFn;                   // 4
    unsigned char numargs;          // 1
};

enum bexclusioncat {
    btnone = 0,
    btmemory = 1,
};

struct BTypeManager {
    char **txt_bySymId;                 // strings Arena
    struct map *symid_byName;           // keys are pointers into symtxts Arena
    unsigned int *order_bySymId;
    char **name_byBTypeId;              // names are pointers into symtxts Arena
    struct map *bTypeId_byName;         // keys are pointers into symtxts Arena

    struct BType *bType_byBTypeId;      // for the mo all these can be malloc'd with fixed size
    struct BTInter *btint_byDescId;
    struct BTUnion *btuni_byDescId;
    struct BTTuple *bttup_byDescId;
    struct BTStruct *btstr_byDescId;
    struct BTRec *btrec_byDescId;
    struct BTSeq *btseq_byDescId;
    struct BTMap *btmap_byDescId;
    struct BTFunc *btfnc_byDescId;

    Arena intists;                      // null terminated lists of types and syms
    Arena strings;                      // null terminated char* (utf8)
    enum bexclusioncat *bexclusioncat_byBTypeId;    // this could also be done as a list of types per category which makes adding CCY etc easier
};


#endif // AJ_BTYPE_H
