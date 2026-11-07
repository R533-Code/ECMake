#define DOCTEST_CONFIG_IMPLEMENT
#include <doctest/doctest.h>

TEST_CASE("custom main") {
  CHECK(1 + 1 == 2);
}

int main(int argc, char** argv) {
  doctest::Context context(argc, argv);
  return context.run();
}
