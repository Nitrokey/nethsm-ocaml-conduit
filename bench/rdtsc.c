#include <stdint.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/fail.h>

#ifndef __unused
#define __unused(x) x __attribute((unused))
#endif
#define __unit() value __unused(unit)

uint64_t
get_tick(__unit ())
{
  unsigned hi, lo;
  __asm__ __volatile__ ("rdtsc" : "=a"(lo), "=d"(hi));

  return (((unsigned long long) lo) | (((unsigned long long) hi) << 32));
}


