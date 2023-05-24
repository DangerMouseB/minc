#ifndef AJ_BUCKETS_C
#define AJ_BUCKETS_C "aj/buckets.c"

#include <stdlib.h>

void nyi(char *msg, ...);

// OPEN: get PAGE_SIZE from the os
unsigned int PAGE_SIZE = 4096;


// buckets are supposed to be fast on allocation and deallocation
// implemented as a singly linked list of buckets, state can be saved and reset thus deallocated en-mass
// buckets can be cleaned for security
// the last allocation can be resized to be bigger or smaller useful when required size is unknown upfront
// Buckets can fit into a cache line e.g. 64 bytes
// Buckets can be used to get a tmp buffer
//  void *buf = allocInBuckets(all_strings, n:1000, align:1);
//  ...
//  reallocInBuckets(all_strings, buf, 0, align:1);

struct Buckets {
    void *first_bucket;     // 8
    void *current_bucket;   // 8
    void *next;             // 8
    void *eoc;              // 8
    void *last_alloc;       // 8
    unsigned short nPages;  // 2
};

struct BucketsCheckpoint {
    void *current_bucket;   // 8
    void *next;             // 8
    void *eoc;              // 8
    void *last_alloc;       // 8
};

struct BucketHeader {
    void *next_chunk;       // 8
    void *eoc;              // 8
};

typedef struct Buckets Buckets;
typedef struct BucketsCheckpoint BucketsCheckpoint;
typedef struct BucketHeader BucketHeader;

void *_nextBucket(Buckets *a, unsigned int n, unsigned int align);
void *_allocBucket(size_t size);


void * initBuckets(Buckets *a, unsigned long chunkSize) {
    a->first_bucket = 0;
    a->current_bucket = 0;
    a->next = 0;
    a->eoc = 0;
    a->nPages = chunkSize / PAGE_SIZE + (chunkSize % PAGE_SIZE > 0);
    return _nextBucket(a, 0, 1);
}

void * allocInBuckets(Buckets *a, unsigned int n, unsigned int align) {
    void *p;
    p = a->next + (align - ((unsigned long)a->next % align));
    if ((p + n) > a->eoc) {
        p = _nextBucket(a, n, align);
        if (!p) return 0;
        p = a->next + (align - ((unsigned long)a->next % align));
    }
    a->last_alloc = p;
    a->next = p + n;
    return p;
}

void * reallocInBuckets(Buckets *a, void* p, unsigned int n, unsigned int align) {
    if (!p  || p != a->last_alloc) return allocInBuckets(a, n, align);
    if ((p + n) > a->eoc) {
        void *chunk = _nextBucket(a, n, align);
        if (!chunk) return 0;
        p = a->next + (align - ((unsigned long)a->next % align));
        a->last_alloc = p;
    }
    a->next = p + n;
    return p;
}

void* _nextBucket(Buckets *a, unsigned int n, unsigned int align) {
    void *p;  BucketHeader *ch;
    if (!a->current_bucket) {
        // OPEN: allocate enough pages to hold size n aligned to align
        // which might mean fast forwarding to a big enough chunk
        p = a->first_bucket = a->current_bucket = _allocBucket(a -> nPages * PAGE_SIZE);
        if (!p) return 0;
    } else {
        ch = (BucketHeader *)a->current_bucket;
        p = ch->next_chunk;
        if (!p) {
            // OPEN: see above
            p = _allocBucket(a -> nPages * PAGE_SIZE);
            if (!p) return 0;
            ch->next_chunk = p;
        }
    }
    a->current_bucket = p;
    a->next = p + sizeof(BucketHeader);
    a->eoc = ((BucketHeader *)p)->eoc;
    return p;
}

void *_allocBucket(size_t size) {
    void *p;  BucketHeader *ch;
    p = malloc(size);                              // OPEN: cache, page and set alignment options
    if (!p) return 0;
    ch = (BucketHeader *)p;
    ch->next_chunk = NULL;
    ch->eoc = p + size - 1;
    return p;
}

void checkpointBuckets(Buckets *a, BucketsCheckpoint *s) {
    s->current_bucket = a->current_bucket;
    s->next = a->next;
    s->eoc = a->eoc;
    s->last_alloc = a->last_alloc;
}

void resetToCheckpoint(Buckets *a, BucketsCheckpoint *s) {
    a->current_bucket = s->current_bucket;
    a->next = s->next;
    a->eoc = s->eoc;
    a->last_alloc = s->last_alloc;
}

void cleanBuckets(void *first_bucket) {
    nyi("cleanBuckets");
}

void freeBuckets(void *first_bucket) {
    void *current, *next;
    current = first_bucket;
    while (current) {
        next = *(void**)current;
        free(current);
        current = next;
    }
}

unsigned long numBuckets(BucketHeader *first_bucket) {
    if (!first_bucket) return 0;
    unsigned long n = 0;
    do {
        n++;
        first_bucket = (BucketHeader *)first_bucket->next_chunk;
    }
    while (first_bucket);
    return n;
}

int inBuckets(Buckets *a, void *p) {
    // answers true if p is in any bucket (dead or alive)
    nyi("inBuckets");
    return 0;
}

int isAlive(Buckets *a, void *p) {
    // answers true if p is alive in an owned bucket
    nyi("isAlive");
    return 0;
}

int isDead(Buckets *a, void *p) {
    // answers true if p is dead in am owned bucket
    nyi("isDead");
    return 0;
}

#endif // AJ_BUCKETS_C
