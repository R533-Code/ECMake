# 3.30 for mature C++ module support
cmake_minimum_required(VERSION 3.30 FATAL_ERROR)

# LANGUAGES NONE as no compiler is needed
project(ECMake VERSION 0.0.0.0
    DESCRIPTION "Easy CMake, utilities to simplify writing cmake."
    LANGUAGES NONE
)

# add `ecmake` directory to the include search path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/ecmake")
include(ECParseArgs)
include(ECMake)
include(ECNamespace)
include(ECExecutable)
include(ECLibraryDynamic)
include(ECLibraryStatic)

if(PROJECT_IS_TOP_LEVEL)
    # also log message(VERBOSE)
    set(CMAKE_MESSAGE_LOG_LEVEL VERBOSE CACHE STRING "" FORCE)
    # change install path to "/dist/CONFIG"
    set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/dist/${CMAKE_BUILD_TYPE}" CACHE PATH "" FORCE)

    # search for all the tests
    file(GLOB_RECURSE ec_all_tests "tests/*/CMakeLists.txt")

    project(ECMakeTest)
    ec_namespace(tests)

    foreach(subdir ${ec_all_tests})
        # strip CMakeLists.txt from name
        cmake_path(GET subdir PARENT_PATH subdir)
        ec_add_subdirectory(${subdir})
    endforeach()

    ec_endnamespace(tests)
endif()