#include <cstdio>
#include <tests_basic_exec_config.h>

int main()
{
    puts("Hello World from " TESTS_BASIC_EXEC_TARGET_QUALIFIED_NAME
         " v" TESTS_BASIC_EXEC_VERSION_STRING "!");
}
