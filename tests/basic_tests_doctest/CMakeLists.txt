include(ECTests)
include(FetchContent)

FetchContent_Declare(
    doctest
    GIT_REPOSITORY https://github.com/doctest/doctest.git
    GIT_TAG v2.4.12
)
FetchContent_MakeAvailable(doctest)

ec_add_tests(basic_tests_doctest
    TESTING_FRAMEWORK doctest
)