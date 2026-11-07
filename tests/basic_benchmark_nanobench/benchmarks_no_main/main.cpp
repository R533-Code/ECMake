#include <ec_nanobench.h>

#include <iostream>

static void BM_Increment(ankerl::nanobench::Bench& bench) {
  int x = 0;
  bench.run("++x", [&] { ankerl::nanobench::doNotOptimizeAway(++x); });
}
BENCHMARK(BM_Increment);

int main(int argc, char** argv) {
  std::cout << "custom main\n";
  return ::ecmake::nanobench::run(argc, argv);
}
