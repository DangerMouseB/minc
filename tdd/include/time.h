#define time_t void
#define SIZEOF_TIME_T 8
extern time_t time(time_t *t);
extern char *ctime(time_t *timer);
