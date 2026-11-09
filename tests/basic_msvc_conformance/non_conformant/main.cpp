#include <cstdio>

// clang-cl defines _MSC_VER but neither needs nor reports these flags the same way
#if defined(_MSC_VER) && !defined(__clang__)
static_assert(__cplusplus == 199711L, "NO_CONFORMANT_CPLUSPLUS_MSVC should disable /Zc:__cplusplus");
static_assert(_MSVC_TRADITIONAL == 1, "NO_CONFORMANT_PREPROCESSOR_MSVC should disable /Zc:preprocessor");
#endif

int main()
{
    printf("__cplusplus: %ld\n", static_cast<long>(__cplusplus));
}
