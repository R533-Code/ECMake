include(ECExecutable)

# checks (at compile time) that the MSVC conformance flags are set by default,
# and that they can be disabled
ec_add_executable("conformant" ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/conformant")
ec_add_executable("non_conformant" ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/non_conformant"
    NO_CONFORMANT_PREPROCESSOR_MSVC NO_CONFORMANT_CPLUSPLUS_MSVC
)
