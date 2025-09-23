#ifndef __HG_INTER_EXEC_DYLIB
#define __HG_INTER_EXEC_DYLIB

#include <tests_inter_exec_with_deps_dylib_export.h>

namespace test
{
  TESTS_INTER_EXEC_WITH_DEPS_DYLIB_EXPORT
  int sum(int a, int b, int c);
}

#endif // !__HG_INTER_EXEC_DYLIB