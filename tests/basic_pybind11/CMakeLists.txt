include(ECPython)
include(FetchContent)

FetchContent_Declare(
    pybind11
    GIT_REPOSITORY https://github.com/pybind/pybind11.git
    GIT_TAG v3.0.1
)

FetchContent_MakeAvailable(pybind11)

ec_add_python_bindings(basic_pybind11
    BINDING_FRAMEWORK pybind11
)