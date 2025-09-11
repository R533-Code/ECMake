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

    project(ECMakeTest)
    ec_namespace(tests)
    ec_add_executable(basic ROOT_DIR "tests/basic")
    ec_endnamespace(tests)
endif()