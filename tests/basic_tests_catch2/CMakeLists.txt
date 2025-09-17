include(ECTests)
include(FetchContent)

FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG        v3.10.0
)
FetchContent_MakeAvailable(Catch2)

ec_add_tests(basic_tests_catch2
    TESTING_FRAMEWORK catch2
)