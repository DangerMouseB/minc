#ifndef AJ_BTYPE_H
#define AJ_BTYPE_H

/*
 type names are symbols
 the typeid is an index into an array
 many types are not named
 for exclusivity each type needs a class or kind etc - 0 is logical, 1 is memory, 2, 4, etc

 nominals - atomic types with a given name
 intersections - sorted list of other types
 sum - tagged unions - sorted list of other types

 product types (statically known size)
 tuples
 structs
 records

 seq
 map
 func


 addressOf and deref


*/


#define _mt = 0
#define _fred = 256
enum btyp{
    B_ILLEGAL = 0,          // to catch bugs
    B_U8  = _mt+1,          // char, unsigned char
    B_U16 = _mt+2,          // unsigned short
    B_U32 = _mt+3,          // signed int
    B_U64 = _mt+4,          // unsigned long, unsigned long int
    B_I8  = _mt+5,          // signed char
    B_I16 = _mt+6,          // short, signed short
    B_I32 = _mt+7,          // int, signed int
    B_I64 = _mt+8,          // long, long int, signed long, signed long int

    B_F32 = _mt+9,          // float
    B_F64 = _mt+10,         // double

    B_CHARS = _mt + 11,     // null terminated uft-8 array, char*
    B_N_CHARS = _mt + 12,   // N**chars, char*argv[], char**
    B_TXT = _mt+13,         // txt (length prefixed, null terminated uft-8 array)
    B_NN_I32 = _mt+14,      // int **, signed int **
    B_N_I32 = _mt+15,       // int *, signed int *
    B_UTMEM = _mt+16,       // void *

    B_VOID = _fred+1,
    B_VARARGS = _fred+2,
    B_U8_S = _fred+3,
    B_N_UTMEM = _fred+4,    // N**UT_MEM


};



struct BTypeManager {
    // containers for the types - structured as SOA to improve hotness
private BTYPE_ID[string] _bTypeId_byName;               // map for finding existing type from name
// SOA - HOT
private DESC_ID[] _sumTypeDescId_byBTypeId;        // we want sum types to be hot hence extracted from the BTypeDesc
private BType[] _sumTypes_byDescId;                      // keep the list of actual sumTypes as a search optimisation
private BSumTypeMembers[] _sumTypeMembers_byDescId;  // SHOULDDO make hotter by using a packed BType array - i.e. two redirects rather than three
// SOA - COLD
private string[] _name_byBTypeId;                         // SHOULDDO merge with BTypeDesc
private string[] _tName_byBTypeId;                        // SHOULDDO merge with BTypeDesc
private BTypeDesc[] _typeDesc_byBTypeId;
private BTaggedExDesc[] _taggedExDesc_byDescId;
private BDetailedExDesc[] _detailedExDesc_byDescId;
private BTupleTypes[] _tupleTypes_byDescId;               // shared between tuples, structs and signatures
private BStructNames[] _structNames_byDescId;
//private BSignatureDesc[] _signatureDescs;
};



#endif // AJ_BTYPE_H
