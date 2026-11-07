#include <benchmark/benchmark.h>

#include <string>

static void BM_StringCreation(benchmark::State& state) {
  for (auto _ : state) {
    std::string created_string("hello");
    benchmark::DoNotOptimize(created_string);
  }
}
BENCHMARK(BM_StringCreation);

static void BM_StringCopy(benchmark::State& state) {
  std::string x = "hello";
  for (auto _ : state) {
    std::string copy(x);
    benchmark::DoNotOptimize(copy);
  }
}
BENCHMARK(BM_StringCopy);
