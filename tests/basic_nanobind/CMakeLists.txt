include(ECPython)
include(FetchContent)

FetchContent_Declare(
    nanobind
    GIT_REPOSITORY https://github.com/wjakob/nanobind.git
    GIT_TAG v2.9.2
)

FetchContent_MakeAvailable(nanobind)

ec_add_python_bindings(basic_nanobind
    BINDING_FRAMEWORK nanobind
)