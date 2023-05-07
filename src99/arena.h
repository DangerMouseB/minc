#ifndef AJ_ARENA_H
#define AJ_ARENA_H

#include <stdlib.h>

void nyi(char *msg, ...);

// OPEN: get PAGE_SIZE from the os
unsigned int PAGE_SIZE = 4096;


// arena is supposed to be fast on allocation and deallocation
// implemented as a singly linked list of chunks, state can be saved and reset thus deallocating en-mass
// chunks can be wiped for security
// the last allocation can be resized to be bigger or smaller useful when required size is unknown upfront but bounded
// the struct should be aligned to fit into a cache line e.g. 64 bytes

struct Arena {
    void *first_chunk;      // 8
    void *current_chunk;    // 8
    void *next;             // 8
    void *eoc;              // 8
    void *last_alloc;       // 8
    unsigned short nPages;  // 2
};

struct ArenaState {
    void *current_chunk;    // 8
    void *next;             // 8
    void *eoc;              // 8
    void *last_alloc;       // 8
};

struct ChunkHeader {
    void *next_chunk;       // 8
    void *eoc;              // 8
};

typedef struct Arena Arena;
typedef struct ArenaState ArenaState;
typedef struct ChunkHeader ChunkHeader;

void *_nextChunk(Arena *a, unsigned int n, unsigned int align);
void *_allocChunk(size_t size);


// ---------------------------------------------------------------------------------------------------------------------
// ARENA
// ---------------------------------------------------------------------------------------------------------------------

void * initArena(Arena *a, unsigned long chunkSize) {
    a->first_chunk = 0;
    a->current_chunk = 0;
    a->next = 0;
    a->eoc = 0;
    a->nPages = chunkSize / PAGE_SIZE + (chunkSize % PAGE_SIZE > 0);
    return _nextChunk(a, 0, 1);
}

void * allocInArena(Arena *a, unsigned int n, unsigned int align) {
    void *p;
    p = a->next + (align - ((unsigned long)a->next % align));
    if ((p + n) > a->eoc) {
        p = _nextChunk(a, n, align);
        if (!p) return 0;
        p = a->next + (align - ((unsigned long)a->next % align));
    }
    a->last_alloc = p;
    a->next = p + n;
    return p;
}

void * reallocInArena(Arena *a, void* p, unsigned int n, unsigned int align) {
    if (!p  || p != a->last_alloc) return allocInArena(a, n, align);
    if ((p + n) > a->eoc) {
        void *chunk = _nextChunk(a, n, align);
        if (!chunk) return 0;
        p = a->next + (align - ((unsigned long)a->next % align));
        a->last_alloc = p;
    }
    a->next = p + n;
    return p;
}

void* _nextChunk(Arena *a, unsigned int n, unsigned int align) {
    void *p;  ChunkHeader *ch;
    if (!a->current_chunk) {
        // OPEN: allocate enough pages to hold size n aligned to align
        // which might mean fast forwarding to a big enough chunk
        p = a->first_chunk = a->current_chunk = _allocChunk(a -> nPages * PAGE_SIZE);
        if (!p) return 0;
    } else {
        ch = (ChunkHeader *)a->current_chunk;
        p = ch->next_chunk;
        if (!p) {
            // OPEN: see above
            p = _allocChunk(a -> nPages * PAGE_SIZE);
            if (!p) return 0;
            ch->next_chunk = p;
        }
    }
    a->current_chunk = p;
    a->next = p + sizeof(ChunkHeader);
    a->eoc = ((ChunkHeader *)p)->eoc;
    return p;
}

void *_allocChunk(size_t size) {
    void *p;  ChunkHeader *ch;
    p = malloc(size);                              // OPEN: cache, page and set alignment options
    if (!p) return 0;
    ch = (ChunkHeader *)p;
    ch->next_chunk = NULL;
    ch->eoc = p + size - 1;
    return p;
}

void saveCheckpoint(Arena *a, ArenaState *s) {
    s->current_chunk = a->current_chunk;
    s->next = a->next;
    s->eoc = a->eoc;
    s->last_alloc = a->last_alloc;
}

void resetToCheckpoint(Arena *a, ArenaState *s) {
    a->current_chunk = s->current_chunk;
    a->next = s->next;
    a->eoc = s->eoc;
    a->last_alloc = s->last_alloc;
}

void wipeChunks(void *first_chunk) {
    nyi("freeChunks");
}

void freeChunks(void *first_chunk) {
    void *current, *next;
    current = first_chunk;
    while (current) {
        next = *(void**)current;
        free(current);
        current = next;
    }
}

unsigned long numChunks(ChunkHeader *first_chunk) {
    if (!first_chunk) return 0;
    unsigned long n = 0;
    do {
        n++;
        first_chunk = (ChunkHeader *)first_chunk->next_chunk;
    }
    while (first_chunk);
    return n;
}

#endif // AJ_ARENA_H
