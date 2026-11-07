#include <ec_nanobench.h>

#include <list>
#include <vector>

static void BM_Containers(ankerl::nanobench::Bench& bench) {
  bench.relative(true).batch(64).unit("push_back");

  bench.run("std::vector", [] {
    std::vector<int> values;
    for (int i = 0; i < 64; ++i)
      values.push_back(i);
    ankerl::nanobench::doNotOptimizeAway(values.data());
  });

  bench.run("std::list", [] {
    std::list<int> values;
    for (int i = 0; i < 64; ++i)
      values.push_back(i);
    ankerl::nanobench::doNotOptimizeAway(values.size());
  });
}
BENCHMARK(BM_Containers);
