#include <benchmark/benchmark.h>

static void BM_Increment(benchmark::State& state) {
  int x = 0;
  for (auto _ : state)
    benchmark::DoNotOptimize(++x);
}
BENCHMARK(BM_Increment);

BENCHMARK_MAIN();
