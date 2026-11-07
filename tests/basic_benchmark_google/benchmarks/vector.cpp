#include <benchmark/benchmark.h>

#include <vector>

static void BM_VectorPushBack(benchmark::State& state) {
  for (auto _ : state) {
    std::vector<int> values;
    for (int i = 0; i < state.range(0); ++i)
      values.push_back(i);
    benchmark::DoNotOptimize(values.data());
  }
}
BENCHMARK(BM_VectorPushBack)->Arg(8)->Arg(64);
