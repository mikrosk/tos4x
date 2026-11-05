#ifndef __STDINT_H__
#define __STDINT_H__ 1

#ifndef __COMPILER_H__
#include <compiler.h>
#endif
#ifndef __SYS_TYPES_H__
#include <types.h>
#endif

typedef __int8_t   int8_t;
typedef __uint8_t  uint8_t;
typedef __int16_t  int16_t;
typedef __uint16_t uint16_t;
typedef __int32_t  int32_t;
typedef __uint32_t uint32_t;

/* Fast types.  */
typedef int8_t             int_fast8_t;
typedef int16_t            int_fast16_t;
typedef int32_t            int_fast32_t;
typedef uint8_t            uint_fast8_t;
typedef uint16_t           uint_fast16_t;
typedef uint32_t           uint_fast32_t;

/* Types for `void *' pointers.  */
typedef __intptr_t         intptr_t;
typedef __uintptr_t        uintptr_t;

/* Largest integral types.  */
typedef int32_t            intmax_t;
typedef uint32_t           uintmax_t;


/* Limits of integral types.  */

/* Minimum of signed integral types.  */
# define INT8_MIN               (-128)
# define INT16_MIN              (-32767-1)
# define INT32_MIN              (-2147483647L-1)
/* Maximum of signed integral types.  */
# define INT8_MAX               (127)
# define INT16_MAX              (32767)
# define INT32_MAX              (2147483647L)

/* Maximum of unsigned integral types.  */
# define UINT8_MAX              (255)
# define UINT16_MAX             (65535)
# define UINT32_MAX             (4294967295L)

#if 0 /* does not work because of 8-chars identifer limit */
/* Values to test for integral types holding `void *' pointer.  */
# define INTPTR_MIN             (-2147483647L-1)
# define INTPTR_MAX             (2147483647L)
# define UINTPTR_MAX            (4294967295L)

/* Minimum for largest signed integral type.  */
# define INTMAX_MIN INT32_MIN
# define INTMAX_MAX INT32_MAX
# define UINTMAX_MAX UINT32_MAX

/* Limits of `ptrdiff_t' type.  */
# define PTRDIFF_MIN            (-2147483647L-1)
# define PTRDIFF_MAX            (2147483647L)
#endif

/* Limit of `size_t' type.  */
# define SIZE_MAX               UINT16_MAX

/* __STDC_CONSTANT_MACROS not implemented */

#endif
