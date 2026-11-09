#include <cstdio>

// clang-cl defines _MSC_VER but neither needs nor reports these flags the same way
#if defined(_MSC_VER) && !defined(__clang__)
static_assert(__cplusplus == _MSVC_LANG, "/Zc:__cplusplus should be set by default");
static_assert(_MSVC_TRADITIONAL == 0, "/Zc:preprocessor should be set by default");
#endif

int main()
{
    printf("__cplusplus: %ld\n", static_cast<long>(__cplusplus));
}
