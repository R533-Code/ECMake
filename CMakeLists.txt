# 3.30 for mature C++ module support
cmake_minimum_required(VERSION 3.30 FATAL_ERROR)

# LANGUAGES NONE as no compiler is needed
project(ECMake VERSION 0.0.0.0
    DESCRIPTION "Easy CMake, utilities to simplify writing cmake."
    LANGUAGES NONE
)

# get version information and print
set(EC_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(EC_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(EC_VERSION_TWEAK ${PROJECT_VERSION_TWEAK})
set(EC_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(EC_VERSION_STRING "${EC_VERSION_MAJOR}.${EC_VERSION_MINOR}.${EC_VERSION_TWEAK}.${EC_VERSION_PATCH}")

set(EC_VERSION_MAJOR ${PROJECT_VERSION_MAJOR} PARENT_SCOPE)
set(EC_VERSION_MINOR ${PROJECT_VERSION_MINOR} PARENT_SCOPE)
set(EC_VERSION_TWEAK ${PROJECT_VERSION_TWEAK} PARENT_SCOPE)
set(EC_VERSION_PATCH ${PROJECT_VERSION_PATCH} PARENT_SCOPE)
set(EC_VERSION_STRING "${EC_VERSION_MAJOR}.${EC_VERSION_MINOR}.${EC_VERSION_TWEAK}.${EC_VERSION_PATCH}" PARENT_SCOPE)

option(EC_SET_FETCHCONTENT_DIR
    "Allow ECMake to override the directory in which FetchContent downloads."
    TRUE
)

# add `ecmake` directory to the include search path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/ecmake")
include(ECParseArgs)
include(ECUtil)
include(ECTests)
include(ECNamespace)
include(ECExecutable)
include(ECLibrary)
include(ECPython)

if(${EC_SET_FETCHCONTENT_DIR})
    set(FETCHCONTENT_BASE_DIR "${CMAKE_SOURCE_DIR}/.build_cache/fetch_content/"
        CACHE PATH "Directory in which FetchContent downloads" FORCE
    )
endif()

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

    ec_list_all_targets(all_targets)
    ec_list_all_executables(all_executables)
    ec_list_all_libraries(all_libraries)
    ec_list_all_libraries_dynamic(all_libraries_dynamic)
    ec_list_all_libraries_static(all_libraries_static)
    message(VERBOSE "Found targets: ${all_targets}")
    message(VERBOSE "Found executables: ${all_executables}")
    message(VERBOSE "Found libraries: ${all_libraries}")
    message(VERBOSE "Found dynamic libraries: ${all_libraries_dynamic}")
    message(VERBOSE "Found static libraries: ${all_libraries_static}")

    ec_endnamespace(tests)
endif()