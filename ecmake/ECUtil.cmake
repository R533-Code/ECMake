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
set(EC_GLOBAL_PROPERTIES "EC_ALL_TARGETS;EC_ALL_EXECUTABLES;EC_ALL_LIBRARIES;EC_ALL_LIBRARIES_STATIC;EC_ALL_LIBRARIES_DYNAMIC;EC_NAMESPACE_STACK;EC_ADD_SUBDIRECTORY_GUARD")

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
    ec_property_get(EC_ALL_TARGETS "${OUT_VAR}")
endmacro()

# Returns the list of current executables defined using ECMake functions.
# OUT_VAR: The name of the variable to which to write the list
macro(ec_list_all_executables OUT_VAR)
    ec_property_get(EC_ALL_EXECUTABLES "${OUT_VAR}")
endmacro()

# Returns the list of current libraries (dynamic and static) defined using ECMake functions.
# OUT_VAR: The name of the variable to which to write the list
macro(ec_list_all_libraries OUT_VAR)
    ec_property_get(EC_ALL_LIBRARIES "${OUT_VAR}")
endmacro()

# Returns the list of current static libraries defined using ECMake functions.
# OUT_VAR: The name of the variable to which to write the list
macro(ec_list_all_libraries_static OUT_VAR)
    ec_property_get(EC_ALL_LIBRARIES_STATIC "${OUT_VAR}")
endmacro()

# Returns the list of current dynamic libraries defined using ECMake functions.
# OUT_VAR: The name of the variable to which to write the list
macro(ec_list_all_libraries_dynamic OUT_VAR)
    ec_property_get(EC_ALL_LIBRARIES_DYNAMIC "${OUT_VAR}")
endmacro()

# ########################
# ADD CMAKE LIBRARY SETUP
# ########################
ec_noop()

# Sets `BUILD_SHARED_LIBS` to a specific value after caching its old one.
# VALUE: TRUE for dynamic libraries or FALSE for static libraries
function(ec_build_dylib VALUE)
    set(OLD_BUILD_SHARED_LIBS "${BUILD_SHARED_LIBS}" CACHE BOOL "" FORCE)
    set(BUILD_SHARED_LIBS "${VALUE}" CACHE BOOL "" FORCE)
endfunction()

# Restores `BUILD_SHARED_LIBS` to its value before the call to `lars_build_dylib`
function(ec_restore_dylib)
    set(BUILD_SHARED_LIBS "${OLD_BUILD_SHARED_LIBS}" CACHE BOOL "" FORCE)
endfunction()

# Adds a CMake subdirectory. This is exactly the same as `add_subdirectory`
# with the only difference being that adding the same subdirectory twice
# only results in a single inclusion.
function(ec_add_subdirectory SUBDIR)
    file(REAL_PATH "${SUBDIR}" _abs_path)
    get_property(_visited GLOBAL PROPERTY EC_ADD_SUBDIRECTORY_GUARD)
    list(FIND _visited "${_abs_path}" _found_index)

    if(_found_index EQUAL -1)
        ec_property_push_back(EC_ADD_SUBDIRECTORY_GUARD "${_abs_path}")
        message(VERBOSE "Adding subdirectory: `${_abs_path}`")

        get_filename_component(_name "${SUBDIR}" NAME)
        add_subdirectory(
            "${SUBDIR}"
            "${CMAKE_BINARY_DIR}/_ec_deps/${_name}"
        )
    else()
        message(VERBOSE "Skipping already-added: `${_abs_path}`")
    endif()
endfunction()

# Adds a subdirectory with `BUILD_SHARED_LIBS` set to false
macro(ec_add_subdirectory_static PATH)
    ec_build_dylib(FALSE)
    ec_add_subdirectory(${PATH})
    ec_restore_dylib()
endmacro()

# Adds a subdirectory with `BUILD_SHARED_LIBS` set to true
macro(ec_add_subdirectory_dynamic PATH)
    ec_build_dylib(TRUE)
    ec_add_subdirectory(${PATH})
    ec_restore_dylib()
endmacro()

# ########################
# COMMON BINARY SETUP
# ########################
ec_noop()

# Registers a target and its alias globally.
# If ALIAS does not exist, it is created.
# TARGET: The target name
# ALIAS: The alias name
function(ec_register_target TARGET ALIAS)
    get_target_property(libtype ${TARGET} TYPE)

    if(libtype STREQUAL "SHARED_LIBRARY")
        if(NOT TARGET ALIAS)
            add_library("${ALIAS}" ALIAS "${TARGET}")
        endif()

        ec_property_push_back(EC_ALL_LIBRARIES "${ALIAS}")
        ec_property_push_back(EC_ALL_LIBRARIES_DYNAMIC "${ALIAS}")
    elseif(libtype STREQUAL "STATIC_LIBRARY")
        if(NOT TARGET ALIAS)
            add_library("${ALIAS}" ALIAS "${TARGET}")
        endif()

        ec_property_push_back(EC_ALL_LIBRARIES "${ALIAS}")
        ec_property_push_back(EC_ALL_LIBRARIES_STATIC "${ALIAS}")
    elseif(libtype STREQUAL "EXECUTABLE")
        if(NOT TARGET ALIAS)
            add_executable("${ALIAS}" ALIAS "${TARGET}")
        endif()

        ec_property_push_back(EC_ALL_EXECUTABLES "${ALIAS}")
    endif()

    ec_property_push_back(EC_ALL_TARGETS "${ALIAS}")
endfunction(ec_register_target)

# Returns the name of the aliased target.
# If the target is not an alias, ALIAS is returned.
# ALIAS: The alias name
# OUT_VAR: The output variable
function(ec_get_aliased_target ALIAS OUT_VAR)
    ec_assert("Expected an alias target name!" TARGET "${ALIAS}")

    get_property(_has TARGET "${ALIAS}" PROPERTY ALIASED_TARGET SET)

    if(${has})
        get_target_property(_t "${ALIAS}" ALIASED_TARGET)
        set(${OUT_VAR} "${_t}" PARENT_SCOPE)
    else()
        set(${OUT_VAR} "${ALIAS}" PARENT_SCOPE)
    endif()
endfunction()

function(ec_get_linked_shared_targets ROOT_TARGET OUT)
    set(seen)
    set(hit)

    function(_walk t)
        if(NOT TARGET "${t}")
            return()
        endif()

        ec_get_aliased_target(${t} t)

        if("${t}" IN_LIST seen)
            return()
        endif()

        list(APPEND seen "${t}")

        get_target_property(_type "${t}" TYPE)

        if(_type STREQUAL "SHARED_LIBRARY")
            list(APPEND hit "${t}")
        endif()

        foreach(prop IN ITEMS LINK_LIBRARIES INTERFACE_LINK_LIBRARIES)
            get_target_property(_deps "${t}" ${prop})

            foreach(d IN LISTS _deps)
                if(TARGET "${d}")
                    _walk("${d}")
                endif()
            endforeach()
        endforeach()

        set(seen "${seen}" PARENT_SCOPE)
        set(hit "${hit}" PARENT_SCOPE)
    endfunction()

    _walk("${ROOT_TARGET}")
    list(REMOVE_DUPLICATES hit)
    set(${OUT} "${hit}" PARENT_SCOPE)
endfunction()

# Writes a configuration file containing target/version information.
# ALIAS_NAME: The namespace qualified name of the target, '::' will be replaced with '_'
# TARGET_NAME: The target name
#
# VERSION_MAJOR: The major version of the target
# VERSION_MINOR: The minor version of the target
# VERSION_TWEAK: The tweak version of the target
# VERSION_PATCH: The patch version of the target
#
# DIR_PATH: The directory where to write the `.h` and `.cpp` files
#
# EXPORT_MACRO: The optional export macro used for the compiled version getter function
# EXPORT_INCLUDE_FILE: The file to include (e.g. `libexample_export.h`)
#
# OUT_FILE_NAMES: If not empty, variable to which to write the path of the generated `.h` and `.cpp` as a list
function(ec_target_write_config ALIAS_NAME TARGET_NAME
    VERSION_MAJOR VERSION_MINOR VERSION_TWEAK VERSION_PATCH
    DIR_PATH
    EXPORT_MACRO EXPORT_INCLUDE_FILE
    OUT_FILE_NAMES
)
    string(REPLACE "::" "_" NAME "${ALIAS_NAME}")
    string(TOUPPER "${NAME}" full_name)
    string(TOLOWER "${NAME}" lower_full_name)

    # the file that defines the EXPORT_MACRO
    if(EXPORT_INCLUDE_FILE)
        string(STRIP ${EXPORT_INCLUDE_FILE} EXPORT_INCLUDE_FILE)
        set(EXPORT_INCLUDE_FILE "\n#include <${EXPORT_INCLUDE_FILE}>\n")
    endif()

    if(EXPORT_MACRO)
        string(STRIP ${EXPORT_MACRO} EXPORT_MACRO)
        set(EXPORT_MACRO "${EXPORT_MACRO}\n")
    endif()

    file(WRITE "${DIR_PATH}/${NAME}_config.h"
        "// clang-format off\n\n"
        "// config file generated by ECMake for target `${ALIAS_NAME}`\n"
        "#ifndef __ECMAKE_HG_${full_name}\n"
        "#define __ECMAKE_HG_${full_name}\n"
        "${EXPORT_INCLUDE_FILE}"
        "\n"
        "#define ${full_name}_VERSION_MAJOR ${VERSION_MAJOR}U\n"
        "#define ${full_name}_VERSION_MINOR ${VERSION_MINOR}U\n"
        "#define ${full_name}_VERSION_TWEAK ${VERSION_TWEAK}U\n"
        "#define ${full_name}_VERSION_PATCH ${VERSION_PATCH}U\n"
        "#define ${full_name}_VERSION_STRING \"${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${VERSION_TWEAK}\"\n"
        "\n"
        "#define ${full_name}_TARGET_NAME \"${TARGET_NAME}\"\n"
        "#define ${full_name}_TARGET_QUALIFIED_NAME \"${ALIAS_NAME}\"\n"
        "\n"
        "#ifdef __cplusplus\n"
        "extern \"C\" {\n"
        "#endif\n"
        "\n"
        "${EXPORT_MACRO}"
        "/// @brief Returns the compiled version of `${ALIAS_NAME}`\n"
        "/// @param major Optional pointer to where to write the major version\n"
        "/// @param minor Optional pointer to where to write the minor version\n"
        "/// @param patch Optional pointer to where to write the patch version\n"
        "/// @param tweak Optional pointer to where to write the tweak version\n"
        "void ec_get_version_${lower_full_name}(unsigned* major, unsigned* minor, unsigned* patch, unsigned* tweak);\n"
        "\n"
        "/// @brief Compare the runtime compiled version of `${ALIAS_NAME}` against the header macros.\n"
        "/// This function is only useful for shared libraries."
        "/// @param compare_major Non-zero to compare the major field, 0 to ignore\n"
        "/// @param compare_minor Non-zero to compare the minor field, 0 to ignore\n"
        "/// @param compare_patch Non-zero to compare the patch field, 0 to ignore\n"
        "/// @param compare_tweak Non-zero to compare the tweak field, 0 to ignore\n"
        "/// @return -1 if runtime < macro, 1 if runtime > macro, 0 if equal, only selected fields are compared\n"
        "static inline int ec_compare_version_${lower_full_name}(int compare_major, int compare_minor, int compare_patch, int compare_tweak) {\n"
        "  unsigned vmaj, vmin, vpat, vtwk;\n"
        "  ec_get_version_${lower_full_name}(&vmaj, &vmin, &vpat, &vtwk);\n"
        "  \n"
        "  if (compare_major)\n"
        "    if (vmaj != ${full_name}_VERSION_MAJOR)\n"
        "      return (vmaj < ${full_name}_VERSION_MAJOR) ? -1 : 1;\n"
        "  if (compare_minor)\n"
        "    if (vmin != ${full_name}_VERSION_MINOR)\n"
        "      return (vmin < ${full_name}_VERSION_MINOR) ? -1 : 1;\n"
        "  if (compare_patch)\n"
        "    if (vpat != ${full_name}_VERSION_PATCH)\n"
        "      return (vpat < ${full_name}_VERSION_PATCH) ? -1 : 1;\n"
        "  if (compare_tweak)\n"
        "    if (vtwk != ${full_name}_VERSION_TWEAK)\n"
        "      return (vtwk < ${full_name}_VERSION_TWEAK) ? -1 : 1;\n"
        "  return 0;\n"
        "}\n"
        "\n"
        "#ifdef __cplusplus\n"
        "}\n"
        "#endif\n"
        "\n"
        "#endif // !__ECMAKE_HG_${full_name}\n\n"
        "// clang-format on\n"
    )

    file(WRITE "${DIR_PATH}/${NAME}_config.cpp"
        "// clang-format off\n\n"
        "#include \"${NAME}_config.h\"\n"
        "\n"
        "void ec_get_version_${lower_full_name}(unsigned* major, unsigned* minor, unsigned* patch, unsigned* tweak) {\n"
        "  if (major) *major = ${full_name}_VERSION_MAJOR;\n"
        "  if (minor) *minor = ${full_name}_VERSION_MINOR;\n"
        "  if (patch) *patch = ${full_name}_VERSION_PATCH;\n"
        "  if (tweak) *tweak = ${full_name}_VERSION_TWEAK;\n"
        "}\n\n"
        "// clang-format on\n"
    )

    if(OUT_FILE_NAMES)
        set(${OUT_FILE_NAMES} "${DIR_PATH}/${NAME}_config.h;${DIR_PATH}/${NAME}_config.cpp" PARENT_SCOPE)
    endif()
endfunction()

# Sets the ECMake default properties for a specific target.
# NAME: The target name
# CXX_VERSION: The C++ version to use when compiling the target
function(ec_target_set_default_properties NAME CXX_VERSION C_VERSION)
    cmake_parse_arguments("INT"
        "NO_PIC;NO_CONFORMANT_PREPROCESSOR_MSVC;NO_DEBUG_POSTFIX"
        ""
        ""
        ${ARGN}
    )

    set_target_properties(${NAME} PROPERTIES
        CXX_STANDARD "${CXX_VERSION}"
        CXX_STANDARD_REQUIRED TRUE
        
        C_STANDARD "${C_VERSION}"
        C_STANDARD_REQUIRED TRUE

        # do not export functions if no EXPORT macro is used
        C_VISIBILITY_PRESET hidden
        CXX_VISIBILITY_PRESET hidden
        VISIBILITY_INLINES_HIDDEN hidden

        # no lib prefix on linux
        PREFIX ""
    )

    if(NOT INT_NO_DEBUG_POSTFIX)
        # add a 'd' at the end of the resulting binary on debug
        # configuration
        set_target_properties(${NAME} PROPERTIES
            DEBUG_POSTFIX "d"
        )
        message(VERBOSE "Adding debug postfix")
    endif()

    get_target_property(libtype ${NAME} TYPE)

    if(libtype STREQUAL "SHARED_LIBRARY")
        if(NOT INT_NO_PIC)
            set_target_properties(${NAME} PROPERTIES
                POSITION_INDEPENDENT_CODE TRUE
            )
            message(VERBOSE "Adding position independent code")
        else()
            # shared libraries must always be compiled with POSITION_INDEPENDENT_CODE
            # set to true.
            message(WARNING "Dynamic libraries cannot have the NO_PIC option present!")
        endif()
    endif()

    if(NOT INT_NO_CONFORMANT_PREPROCESSOR_MSVC AND MSVC)
        # This forces MSVC to use the conformant preprocessor,
        # which should really be a default for portable code.
        target_compile_options(${NAME} PRIVATE "/Zc:preprocessor")
        message(VERBOSE "Adding conformant preprocessor (for MSVC)")
    endif()
endfunction()