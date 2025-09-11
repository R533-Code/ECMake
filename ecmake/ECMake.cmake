include_guard(GLOBAL)

# Function that does nothing. Usually used as a separator.
function(ec_noop)
    # does nothing
endfunction(ec_noop)

# Asserts that a condition is true, else aborts CMake.
# ERROR_MSG: The error message to print before aborting on assertion failures
# ...: The tokens to evaluate
#
# Example:
# ec_assert("Expected TRUE"
# ${VAR_NAME} STREQUAL "TRUE"
# )
function(ec_assert ERROR_MSG)
    if(NOT(${ARGN}))
        message(FATAL_ERROR "CMake Assertion failed: ${ERROR_MSG}")
    endif()
endfunction()

# version is obtained from the current project, which must be
# "ECMake", created by `add_subdirectory(".../ecmake")`.
ec_assert("Do not include `ECMake.cmake` directly, make use of `add_subdirectory`!"
    ${PROJECT_NAME} STREQUAL "ECMake"
)

# get version information and print
set(EC_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(EC_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(EC_VERSION_TWEAK ${PROJECT_VERSION_TWEAK})
set(EC_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(EC_VERSION_STRING "${EC_VERSION_MAJOR}.${EC_VERSION_MINOR}.${EC_VERSION_TWEAK}.${EC_VERSION_PATCH}")

message(STATUS "Using ECMake v${EC_VERSION_STRING}")

# Parses a version from a string of format `{}.{}.{}.{}`.
# Only the major version is required, the rest is set to 0 if non-existent.
# VERSION: The version string to parse
# PREFIX: The prefix for the output variables
function(ec_parse_version VERSION PREFIX)
    if(NOT "${VERSION}" MATCHES "^([0-9]+)(\\.([0-9]+))?(\\.([0-9]+))?(\\.([0-9]+))?$")
        message(FATAL_ERROR "Invalid version: '${VERSION}'")
    endif()

    set(_MAJOR "${CMAKE_MATCH_1}")
    set(_MINOR "${CMAKE_MATCH_3}")
    set(_PATCH "${CMAKE_MATCH_5}")
    set(_TWEAK "${CMAKE_MATCH_7}")

    if(_MINOR STREQUAL "")
        set(_MINOR 0)
    endif()

    if(_PATCH STREQUAL "")
        set(_PATCH 0)
    endif()

    if(_TWEAK STREQUAL "")
        set(_TWEAK 0)
    endif()

    set(${PREFIX}_MAJOR "${_MAJOR}" PARENT_SCOPE)
    set(${PREFIX}_MINOR "${_MINOR}" PARENT_SCOPE)
    set(${PREFIX}_PATCH "${_PATCH}" PARENT_SCOPE)
    set(${PREFIX}_TWEAK "${_TWEAK}" PARENT_SCOPE)
endfunction()

# ########################
# GLOBAL PROPERTIES UTILS
# ########################
ec_noop()

# Utility function that returns the current value of a global property.
# PROP: The property name
# OUT_VAR: The output variable
macro(ec_property_get PROP OUT_VAR)
    get_property(${OUT_VAR} GLOBAL PROPERTY ${PROP})
endmacro()

# Utility function that pushes a value to a global property.
# PROP: The property name
# VALUE: The value to push back
function(ec_property_push_back PROP VALUE)
    set_property(GLOBAL APPEND PROPERTY "${PROP}" "${VALUE}")
endfunction()

# Utility function that pops a value from a global property.
# PROP: The property name
function(ec_property_pop_back PROP)
    get_property(_has GLOBAL PROPERTY "${PROP}" SET)
    ec_assert("Property '${PROP}' is not set" _has)

    get_property(_lst GLOBAL PROPERTY "${PROP}")
    list(LENGTH _lst _n)
    ec_assert("Pop back on empty property '${PROP}'" _n GREATER 0)

    math(EXPR _i "${_n}-1")
    list(REMOVE_AT _lst ${_i})
    set_property(GLOBAL PROPERTY "${PROP}" "${_lst}")
endfunction()

# Utility function that prints a property
function(ec_property_print PROP)
    get_property(_lst GLOBAL PROPERTY "${PROP}")
    message(STATUS "${_lst}")
endfunction(ec_property_print)

# ########################
# GLOBAL PROPERTIES SETUP
# ########################
ec_noop()

# list of global properties
set(EC_GLOBAL_PROPERTIES "EC_ALL_TARGETS;EC_ALL_EXECUTABLES;EC_ALL_LIBRARIES;EC_ALL_LIBRARIES_STATIC;EC_ALL_LIBRARIES_DYNAMIC;EC_NAMESPACE_STACK")

# initialize all global properties to an empty string
foreach(_ec_global_prop EC_GLOBAL_PROPERTIES)
    set_property(GLOBAL PROPERTY ${_ec_global_prop} "")
endforeach()

# ##########################
# GLOBAL PROPERTIES GETTERS
# ##########################
ec_noop()

# Returns the list of current targets defined using ECMake functions.
# OUT_VAR: The name of the variable to which to write the list
macro(ec_list_all_targets OUT_VAR)
    ec_property_get(EC_ALL_TARGETS OUT_VAR)
endmacro()

# Returns the list of current executables defined using ECMake functions.
# OUT_VAR: The name of the variable to which to write the list
macro(ec_list_all_executables OUT_VAR)
    ec_property_get(EC_ALL_EXECUTABLES OUT_VAR)
endmacro()

# Returns the list of current libraries (dynamic and static) defined using ECMake functions.
# OUT_VAR: The name of the variable to which to write the list
macro(ec_list_all_libraries OUT_VAR)
    ec_property_get(EC_ALL_LIBRARIES OUT_VAR)
endmacro()

# Returns the list of current static libraries defined using ECMake functions.
# OUT_VAR: The name of the variable to which to write the list
macro(ec_list_all_libraries_static OUT_VAR)
    ec_property_get(EC_ALL_LIBRARIES_STATIC OUT_VAR)
endmacro()

# Returns the list of current dynamic libraries defined using ECMake functions.
# OUT_VAR: The name of the variable to which to write the list
macro(ec_list_all_libraries_dynamic OUT_VAR)
    ec_property_get(EC_ALL_LIBRARIES_DYNAMIC OUT_VAR)
endmacro()