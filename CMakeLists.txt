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
set(EC_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(EC_VERSION_TWEAK ${PROJECT_VERSION_TWEAK})
set(EC_VERSION_STRING "${EC_VERSION_MAJOR}.${EC_VERSION_MINOR}.${EC_VERSION_PATCH}.${EC_VERSION_TWEAK}")

if(NOT PROJECT_IS_TOP_LEVEL)
    set(EC_VERSION_MAJOR ${PROJECT_VERSION_MAJOR} PARENT_SCOPE)
    set(EC_VERSION_MINOR ${PROJECT_VERSION_MINOR} PARENT_SCOPE)
    set(EC_VERSION_PATCH ${PROJECT_VERSION_PATCH} PARENT_SCOPE)
    set(EC_VERSION_TWEAK ${PROJECT_VERSION_TWEAK} PARENT_SCOPE)
    set(EC_VERSION_STRING "${EC_VERSION_MAJOR}.${EC_VERSION_MINOR}.${EC_VERSION_PATCH}.${EC_VERSION_TWEAK}" PARENT_SCOPE)
endif()

# Off by default for projects using ECMake: the directory is in the source tree
# of the top-level project, and FetchContent also puts its build directories
# there, which are then shared by all the build directories of that project.
option(EC_SET_FETCHCONTENT_DIR
    "Allow ECMake to override the directory in which FetchContent downloads (`<source>/.build_cache/fetch_content`)."
    ${PROJECT_IS_TOP_LEVEL}
)

# add `ecmake` directory to the include search path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/ecmake")
if(NOT PROJECT_IS_TOP_LEVEL)
    # also allow `include(ECExecutable)`, ... in the project using ECMake
    set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" PARENT_SCOPE)
endif()
include(ECParseArgs)
include(ECUtil)
include(ECTests)
include(ECNamespace)
include(ECExecutable)
include(ECLibrary)
include(ECPython)
include(ECvcpkg)

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

    # tests requiring CUDA or Python are skipped if those are not available
    include(CheckLanguage)
    check_language(CUDA)
    find_package(Python QUIET COMPONENTS Interpreter Development.Module)

    foreach(subdir ${ec_all_tests})
        unset(_test_namespace)

        # strip CMakeLists.txt from name
        cmake_path(GET subdir PARENT_PATH subdir)
        cmake_path(GET subdir FILENAME subdir_name)

        if(subdir_name MATCHES "cuda" AND NOT CMAKE_CUDA_COMPILER)
            message(STATUS "Skipping test `${subdir_name}`: no CUDA compiler found")
            continue()
        endif()
        if(subdir_name MATCHES "(nanobind|pybind11)" AND NOT Python_FOUND)
            message(STATUS "Skipping test `${subdir_name}`: Python (Interpreter, Development.Module) not found")
            continue()
        endif()

        if(subdir_name MATCHES "basic_.*")
            set(_test_namespace basic)
        elseif(subdir_name MATCHES "inter_.*")
            set(_test_namespace inter)
        endif()

        if (DEFINED _test_namespace)
            ec_namespace(${_test_namespace})
            ec_add_subdirectory(${subdir})
            ec_endnamespace(${_test_namespace})
        else()
            ec_add_subdirectory(${subdir})
        endif()
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