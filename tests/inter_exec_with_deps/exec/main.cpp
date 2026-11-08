#include <sum.h>
#include <mul.h>

int main()
{
  // exit code 0 on success, so that the test can be checked by CTest
  const bool ok = test::sum(10, 10, 10) == 30 && test::mul(2, 3, 4) == 24;
  return ok ? 0 : 1;
}
