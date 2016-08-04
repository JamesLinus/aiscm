#include <stdlib.h>
#include <string.h>
#include "ringbuffer.h"

void ringbuffer_init(struct ringbuffer_t *ringbuffer, int size)
{
  ringbuffer->fill = 0;
  ringbuffer->size = size;
  ringbuffer->buffer = malloc(size);
}

void ringbuffer_destroy(struct ringbuffer_t *ringbuffer)
{
}

void ringbuffer_store(struct ringbuffer_t *ringbuffer, const char *data, int n)
{
  memcpy(ringbuffer->buffer, data, n);// TODO: offset
  ringbuffer->fill += n;
}
