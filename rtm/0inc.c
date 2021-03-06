#define _SILENCE_CXX17_CODECVT_HEADER_DEPRECATION_WARNING

#include <time.h>
#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>
#include <limits.h>
#include <float.h>
#include <locale>
#include <codecvt>
#include <math.h>
#include <memory>
#include <algorithm>
#include <stack>
#include <string>
#include <cstring>
#include <variant>
#include <vector>
#include <unordered_map>
#include <arrayfire.h>
using namespace af;

#if AF_API_VERSION < 36
#error "Your ArrayFire version is too old."
#endif
#ifdef _WIN32
 #define EXPORT extern "C" __declspec(dllexport)
#elif defined(__GNUC__)
 #define EXPORT extern "C" __attribute__ ((visibility ("default")))
#else
 #define EXPORT extern "C"
#endif
#ifdef _MSC_VER
 #define RSTCT __restrict
#else
 #define RSTCT restrict
#endif
#define S struct
#define Z static
#define R return
#define this_c (*this)
#define VEC std::vector
#define CVEC const std::vector
#define RANK(pp) ((pp)->r)
#define TYPE(pp) ((pp)->t)
#define SHAPE(pp) ((pp)->s)
#define ETYPE(pp) ((pp)->e)
#define DATA(pp) ((V*)&SHAPE(pp)[RANK(pp)])
#define CS(n,x) case n:x;break;
#define DO(n,x) {I _i=(n),i=0;for(;i<_i;++i){x;}}
#define DOB(n,x) {B _i=(n),i=0;for(;i<_i;++i){x;}}
#define MT
#define PUSH(x) s.emplace(x)
#define POP(f,x) x=std::get<f>(s.top());s.pop()
