#ifndef AJ_BUCKETS_H
#define AJ_BUCKETS_H "aj/buckets.h"

#define SIZEOF_BUCKETS 42
#define Buckets void

//struct Buckets {
//    void *first_bucket;     // 8
//    void *current_bucket;   // 8
//    void *next;             // 8
//    void *eoc;              // 8
//    void *last_alloc;       // 8
//    unsigned short nPages;  // 2
//};

#define SIZEOF_BUCKETS_CHECKPOINTY 32
#define BucketsCheckpoint void

//struct BucketsCheckpoint {
//    void *current_bucket;   // 8
//    void *next;             // 8
//    void *eoc;              // 8
//    void *last_alloc;       // 8
//};

#define SIZEOF_BUCKET_HEADER 16
#define BucketHeader void

//struct BucketHeader {
//    void *next_chunk;       // 8
//    void *eoc;              // 8
//};

//typedef struct Buckets Buckets;
//typedef struct BucketsCheckpoint BucketsCheckpoint;
//typedef struct BucketHeader BucketHeader;

void * initBuckets(Buckets *a, unsigned long chunkSize);
void * allocInBuckets(Buckets *a, unsigned int n, unsigned int align);
void * reallocInBuckets(Buckets *a, void* p, unsigned int n, unsigned int align);
void checkpointBuckets(Buckets *a, BucketsCheckpoint *s);
void resetToCheckpoint(Buckets *a, BucketsCheckpoint *s);
void cleanBuckets(void *first_bucket);
void freeBuckets(void *first_bucket);
unsigned long numBuckets(BucketHeader *first_bucket);
int inBuckets(Buckets *a, void *p);
int isAlive(Buckets *a, void *p);
int isDead(Buckets *a, void *p);


#endif // AJ_BUCKETS_H
