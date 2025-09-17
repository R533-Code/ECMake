include(ECTests)
include(FetchContent)

find_package(GTest QUIET)

if(NOT GTest_FOUND)
    message(VERBOSE "GTest not found. Fetching with FetchContent.")

    FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG v1.17.0 # set version
    )

    set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
    set(INSTALL_GMOCK OFF CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)
endif()

ec_add_tests(basic_tests_gtest
    TESTING_FRAMEWORK gtest
)