#ifndef __EC_HG_TESTS_BASIC_DYLIB
#define __EC_HG_TESTS_BASIC_DYLIB

#include <basic_dylib_export.h>

namespace test::ec
{
    BASIC_DYLIB_EXPORT
    int sum(int a, int b) noexcept;
}

#endif // !__EC_HG_TESTS_BASIC_DYLIB