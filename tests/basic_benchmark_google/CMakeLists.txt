include(ECBenchmarks)
include(FetchContent)

set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_GTEST_TESTS OFF CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_INSTALL OFF CACHE BOOL "" FORCE)
set(BENCHMARK_ENABLE_WERROR OFF CACHE BOOL "" FORCE)

FetchContent_Declare(
    benchmark
    GIT_REPOSITORY https://github.com/google/benchmark.git
    GIT_TAG v1.10.0
)
FetchContent_MakeAvailable(benchmark)

# `main()` is generated, benchmarks are spread over multiple files
ec_add_benchmarks(benchmark_google
    BENCHMARK_FRAMEWORK google
)

# `main()` is provided by the sources (`BENCHMARK_MAIN()`)
ec_add_benchmarks(benchmark_google_no_main
    BENCHMARK_FRAMEWORK google
    ROOT_DIR benchmarks_no_main
    NO_MAIN
)
