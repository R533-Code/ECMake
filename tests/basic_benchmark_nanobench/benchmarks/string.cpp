#include <ec_nanobench.h>

#include <string>

static void BM_String(ankerl::nanobench::Bench& bench) {
  bench.run("creation", [] {
    std::string created_string("hello");
    ankerl::nanobench::doNotOptimizeAway(created_string);
  });

  const std::string x = "hello";
  bench.run("copy", [&] {
    std::string copy(x);
    ankerl::nanobench::doNotOptimizeAway(copy);
  });
}
BENCHMARK(BM_String);
