include(ECBenchmarks)
include(FetchContent)

FetchContent_Declare(
    nanobench
    GIT_REPOSITORY https://github.com/martinus/nanobench.git
    GIT_TAG v4.6.0
    GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(nanobench)

# `main()` is generated, benchmarks are spread over multiple files
ec_add_benchmarks(benchmark_nanobench
    BENCHMARK_FRAMEWORK nanobench
)

# `main()` is provided by the sources, using the generated registry
ec_add_benchmarks(benchmark_nanobench_no_main
    BENCHMARK_FRAMEWORK nanobench
    ROOT_DIR benchmarks_no_main
    NO_MAIN
)
