#ifndef AJ_BTYPE_H
#define AJ_BTYPE_H

#include "arena.h"


// OPEN: add aliases so can do - typedef can automatically add aliased
//<:Symb> lval(<:Node&ptr> n) {
//<:Symb> lval(<:pNode> n) {
// could we do <:unsigned int>

// https://cdecl.org/


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
