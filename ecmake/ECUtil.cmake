# Copyright (c) 2026 Raphael Dib Nehme
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
ec_assert("Do not include ECMake modules directly, make use of `add_subdirectory`!"
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
# OUT_VAR: Optional output variable receiving the popped value
function(ec_property_pop_back PROP)
    get_property(_has GLOBAL PROPERTY "${PROP}" SET)
    ec_assert("Property '${PROP}' is not set" _has)

    get_property(_lst GLOBAL PROPERTY "${PROP}")
    list(LENGTH _lst _n)
    ec_assert("Pop back on empty property '${PROP}'" _n GREATER 0)

    math(EXPR _i "${_n}-1")
    list(GET _lst ${_i} _value)
    list(REMOVE_AT _lst ${_i})
    set_property(GLOBAL PROPERTY "${PROP}" "${_lst}")

    if(ARGC GREATER 1)
        set(${ARGV1} "${_value}" PARENT_SCOPE)
    endif()
endfunction()

# Writes CONTENT to PATH, only touching the file if its content changed.
# This avoids needless recompilation of generated sources on every reconfigure.
# PATH: The file to write
# CONTENT: The content of the file
function(ec_write_file_if_changed PATH CONTENT)
    if(EXISTS "${PATH}")
        file(READ "${PATH}" _old_content)

        if(_old_content STREQUAL CONTENT)
            return()
        endif()
    endif()

    file(WRITE "${PATH}" "${CONTENT}")
endfunction()

# Links ITEMS to TARGET using the keyword signature of `target_link_libraries`.
# If ITEMS does not start with PUBLIC, PRIVATE or INTERFACE, DEFAULT_SCOPE is used.
# Always using the keyword signature avoids mixing errors with other calls.
# TARGET: The target to link to
# DEFAULT_SCOPE: The scope to use when ITEMS does not start with a scope keyword
# ...: The items to link (as passed to LINK_WITH)
function(ec_target_link_with TARGET DEFAULT_SCOPE)
    set(_items ${ARGN})

    if(NOT _items OR _items STREQUAL "<none>")
        return()
    endif()

    list(GET _items 0 _first)

    if(NOT _first MATCHES "^(PUBLIC|PRIVATE|INTERFACE)$")
        list(PREPEND _items ${DEFAULT_SCOPE})
    endif()

    target_link_libraries(${TARGET} ${_items})
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
foreach(_ec_global_prop IN LISTS EC_GLOBAL_PROPERTIES)
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

# Sets `BUILD_SHARED_LIBS` to a specific value in the current scope, after saving
# its old value on a stack (calls can be nested).
# Only a normal variable is set: the cache is never modified.
# Must be paired with `ec_restore_dylib` in the same scope.
# VALUE: TRUE for dynamic libraries or FALSE for static libraries
macro(ec_build_dylib VALUE)
    if(DEFINED BUILD_SHARED_LIBS)
        ec_property_push_back(EC_BUILD_SHARED_LIBS_STACK "DEFINED:${BUILD_SHARED_LIBS}")
    else()
        ec_property_push_back(EC_BUILD_SHARED_LIBS_STACK "UNDEFINED")
    endif()

    set(BUILD_SHARED_LIBS ${VALUE})
endmacro()

# Restores `BUILD_SHARED_LIBS` to its value before the matching call to `ec_build_dylib`
macro(ec_restore_dylib)
    ec_property_pop_back(EC_BUILD_SHARED_LIBS_STACK _ec_old_build_shared_libs)

    if(_ec_old_build_shared_libs STREQUAL "UNDEFINED")
        unset(BUILD_SHARED_LIBS)
    else()
        string(REGEX REPLACE "^DEFINED:" "" _ec_old_build_shared_libs "${_ec_old_build_shared_libs}")
        set(BUILD_SHARED_LIBS "${_ec_old_build_shared_libs}")
    endif()

    unset(_ec_old_build_shared_libs)
endmacro()

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

        # the binary directory includes a hash of the absolute path, so that two
        # different directories with the same name (e.g. `a/utils` and `b/utils`)
        # do not collide
        get_filename_component(_name "${_abs_path}" NAME)
        string(SHA1 _hash "${_abs_path}")
        string(SUBSTRING "${_hash}" 0 8 _hash)
        add_subdirectory(
            "${SUBDIR}"
            "${CMAKE_BINARY_DIR}/_ec_deps/${_name}-${_hash}"
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
        if(NOT TARGET "${ALIAS}")
            add_library("${ALIAS}" ALIAS "${TARGET}")
        endif()

        ec_property_push_back(EC_ALL_LIBRARIES "${ALIAS}")
        ec_property_push_back(EC_ALL_LIBRARIES_DYNAMIC "${ALIAS}")
    elseif(libtype STREQUAL "STATIC_LIBRARY")
        if(NOT TARGET "${ALIAS}")
            add_library("${ALIAS}" ALIAS "${TARGET}")
        endif()

        ec_property_push_back(EC_ALL_LIBRARIES "${ALIAS}")
        ec_property_push_back(EC_ALL_LIBRARIES_STATIC "${ALIAS}")
    elseif(libtype STREQUAL "EXECUTABLE")
        if(NOT TARGET "${ALIAS}")
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

    if(${_has})
        get_target_property(_t "${ALIAS}" ALIASED_TARGET)
        set(${OUT_VAR} "${_t}" PARENT_SCOPE)
    else()
        set(${OUT_VAR} "${ALIAS}" PARENT_SCOPE)
    endif()
endfunction()

function(ec_get_linked_shared_targets ROOT_TARGET OUT)
    set(_queue "${ROOT_TARGET}")
    set(_seen "")
    set(_hit "")

    while(_queue)
        # Dequeue the front item.
        list(POP_FRONT _queue _current)

        # Resolve alias to real target name.
        ec_get_aliased_target("${_current}" _current)

        # Skip if already visited.
        if("${_current}" IN_LIST _seen)
            continue()
        endif()

        list(APPEND _seen "${_current}")

        if(NOT TARGET "${_current}")
            continue()
        endif()

        get_target_property(_type "${_current}" TYPE)

        if(_type STREQUAL "SHARED_LIBRARY")
            list(APPEND _hit "${_current}")
        endif()

        # Enqueue all linked dependencies.
        foreach(_prop IN ITEMS LINK_LIBRARIES INTERFACE_LINK_LIBRARIES)
            get_target_property(_deps "${_current}" ${_prop})

            if(NOT _deps)
                continue()
            endif()

            foreach(_dep IN LISTS _deps)
                # CMake records private dependencies of static libraries as
                # `$<LINK_ONLY:dep>` in INTERFACE_LINK_LIBRARIES: unwrap them
                if(_dep MATCHES "^\\$<LINK_ONLY:(.+)>$")
                    set(_dep "${CMAKE_MATCH_1}")
                endif()

                if(TARGET "${_dep}" AND NOT "${_dep}" IN_LIST _seen)
                    list(APPEND _queue "${_dep}")
                endif()
            endforeach()
        endforeach()
    endwhile()

    list(REMOVE_DUPLICATES _hit)
    set(${OUT} "${_hit}" PARENT_SCOPE)
endfunction()

# Adds a POST_BUILD command that copies all the runtime DLLs ROOT_TARGET depends
# on (directly or indirectly) next to ROOT_TARGET's own binary.
#
# The list of DLLs is computed at generation time (`$<TARGET_RUNTIME_DLLS>`), so
# links added after this call, private dependencies of static libraries and
# imported shared libraries are all taken into account.
# This only does something on DLL platforms (Windows): on other platforms the
# build tree RPATH already allows finding shared libraries.
# ROOT_TARGET: The target next to which to copy the DLLs
# EXCLUDE_REGEX: Optional, DLLs whose path matches this regex are not copied
# (must not contain `,` or `>`)
function(ec_copy_dependencies ROOT_TARGET)
    cmake_parse_arguments(COPY "" "EXCLUDE_REGEX" "" ${ARGN})

    # ROOT_TARGET must be a known CMake target
    ec_assert(
        "ec_copy_dependencies: ROOT_TARGET must be a valid target"
        TARGET ${ROOT_TARGET}
    )

    # ROOT_TARGET must have a runtime directory (executable or shared/module library)
    get_target_property(_type ${ROOT_TARGET} TYPE)
    ec_assert(
        "ec_copy_dependencies: ROOT_TARGET must be EXECUTABLE, SHARED_LIBRARY or MODULE_LIBRARY"
        _type STREQUAL "EXECUTABLE" OR _type STREQUAL "SHARED_LIBRARY" OR _type STREQUAL "MODULE_LIBRARY"
    )

    set(_dlls "$<TARGET_RUNTIME_DLLS:${ROOT_TARGET}>")

    if(COPY_EXCLUDE_REGEX)
        set(_dlls "$<FILTER:${_dlls},EXCLUDE,${COPY_EXCLUDE_REGEX}>")
    endif()

    add_custom_command(
        TARGET ${ROOT_TARGET}
        POST_BUILD

        # `copy_if_different` fails without files, so do nothing when there are no DLLs
        COMMAND "$<IF:$<BOOL:${_dlls}>,${CMAKE_COMMAND};-E;copy_if_different;${_dlls};$<TARGET_FILE_DIR:${ROOT_TARGET}>,${CMAKE_COMMAND};-E;true>"
        COMMAND_EXPAND_LISTS
        VERBATIM
    )
endfunction()

# Writes a configuration file containing target/version information.
# ALIAS_NAME: The namespace qualified name of the target, '::' will be replaced with '_'
# TARGET_NAME: The target name
#
# VERSION_MAJOR: The major version of the target
# VERSION_MINOR: The minor version of the target
# VERSION_PATCH: The patch version of the target
# VERSION_TWEAK: The tweak version of the target
#
# DIR_PATH: The directory where to write the `.h` and `.cpp` files
#
# EXPORT_MACRO: The optional export macro used for the compiled version getter function
# EXPORT_INCLUDE_FILE: The file to include (e.g. `libexample_export.h`)
#
# OUT_FILE_NAMES: If not empty, variable to which to write the path of the generated `.h` and `.cpp` as a list
function(ec_target_write_config ALIAS_NAME TARGET_NAME
    VERSION_MAJOR VERSION_MINOR VERSION_PATCH VERSION_TWEAK
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

    string(CONCAT _header_content
        "// clang-format off\n\n"
        "// config file generated by ECMake for target `${ALIAS_NAME}`\n"
        "#ifndef ECMAKE_HG_${full_name}\n"
        "#define ECMAKE_HG_${full_name}\n"
        "${EXPORT_INCLUDE_FILE}"
        "\n"
        "#define ${full_name}_VERSION_MAJOR ${VERSION_MAJOR}U\n"
        "#define ${full_name}_VERSION_MINOR ${VERSION_MINOR}U\n"
        "#define ${full_name}_VERSION_PATCH ${VERSION_PATCH}U\n"
        "#define ${full_name}_VERSION_TWEAK ${VERSION_TWEAK}U\n"
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
        "/// This function is only useful for shared libraries.\n"
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
        "#endif // !ECMAKE_HG_${full_name}\n\n"
        "// clang-format on\n"
    )
    ec_write_file_if_changed("${DIR_PATH}/${NAME}_config.h" "${_header_content}")

    string(CONCAT _source_content
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
    ec_write_file_if_changed("${DIR_PATH}/${NAME}_config.cpp" "${_source_content}")

    if(OUT_FILE_NAMES)
        set(${OUT_FILE_NAMES} "${DIR_PATH}/${NAME}_config.h;${DIR_PATH}/${NAME}_config.cpp" PARENT_SCOPE)
    endif()
endfunction()

# Sets the ECMake default properties for a specific target.
# NAME: The target name
# CXX_VERSION: The C++ version to use when compiling the target
# C_VERSION: The C version to use when compiling the target
# Options (pass explicitly, not the caller's ARGN):
# NO_CONFORMANT_PREPROCESSOR_MSVC, NO_CONFORMANT_CPLUSPLUS_MSVC, NO_DEBUG_POSTFIX, NO_PIC
function(ec_target_set_default_properties NAME CXX_VERSION C_VERSION)
    cmake_parse_arguments("INT"
        "NO_CONFORMANT_PREPROCESSOR_MSVC;NO_CONFORMANT_CPLUSPLUS_MSVC;NO_DEBUG_POSTFIX;NO_PIC"
        ""
        ""
        ${ARGN}
    )
    ec_assert("ec_target_set_default_properties: unknown argument(s) `${INT_UNPARSED_ARGUMENTS}`"
        NOT DEFINED INT_UNPARSED_ARGUMENTS
    )

    if(INT_NO_PIC)
        set(_pic FALSE)
    else()
        set(_pic TRUE)
    endif()

    set_target_properties(${NAME} PROPERTIES
        CXX_STANDARD "${CXX_VERSION}"
        CXX_STANDARD_REQUIRED TRUE

        C_STANDARD "${C_VERSION}"
        C_STANDARD_REQUIRED TRUE

        # do not export functions if no EXPORT macro is used
        C_VISIBILITY_PRESET hidden
        CXX_VISIBILITY_PRESET hidden
        VISIBILITY_INLINES_HIDDEN ON

        # build position independent code unless NO_PIC
        # (shared libraries are always position independent)
        POSITION_INDEPENDENT_CODE ${_pic}

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

    set(_msvc_flags)

    foreach(_flag IN ITEMS NO_CONFORMANT_PREPROCESSOR_MSVC NO_CONFORMANT_CPLUSPLUS_MSVC)
        if(INT_${_flag})
            list(APPEND _msvc_flags ${_flag})
        endif()
    endforeach()

    ec_target_set_msvc_conformance(${NAME} ${_msvc_flags})
endfunction()

# Makes MSVC behave in a standard conformant way for a specific target.
# Does nothing for other compilers.
# NAME: The target name
# Options (pass explicitly, not the caller's ARGN):
# NO_CONFORMANT_PREPROCESSOR_MSVC: do not use the conformant preprocessor (`/Zc:preprocessor`)
# NO_CONFORMANT_CPLUSPLUS_MSVC: do not make `__cplusplus` report the C++ version in use (`/Zc:__cplusplus`)
function(ec_target_set_msvc_conformance NAME)
    cmake_parse_arguments("INT"
        "NO_CONFORMANT_PREPROCESSOR_MSVC;NO_CONFORMANT_CPLUSPLUS_MSVC"
        ""
        ""
        ${ARGN}
    )
    ec_assert("ec_target_set_msvc_conformance: unknown argument(s) `${INT_UNPARSED_ARGUMENTS}`"
        NOT DEFINED INT_UNPARSED_ARGUMENTS
    )

    if(NOT MSVC)
        return()
    endif()

    if(NOT INT_NO_CONFORMANT_PREPROCESSOR_MSVC)
        # This forces MSVC to use the conformant preprocessor,
        # which should really be a default for portable code.
        # only for C/C++ sources: other compilers (e.g. nvcc for CUDA) do not accept it
        target_compile_options(${NAME} PRIVATE "$<$<COMPILE_LANGUAGE:C,CXX>:/Zc:preprocessor>")
        message(VERBOSE "Adding conformant preprocessor (for MSVC)")
    endif()

    if(NOT INT_NO_CONFORMANT_CPLUSPLUS_MSVC)
        # By default MSVC always defines `__cplusplus` as 199711L, whatever the
        # C++ version in use (which is only reported by `_MSVC_LANG`).
        # only for C++ sources: the macro does not exist in C, and other
        # compilers (e.g. nvcc for CUDA) do not accept it
        target_compile_options(${NAME} PRIVATE "$<$<COMPILE_LANGUAGE:CXX>:/Zc:__cplusplus>")
        message(VERBOSE "Adding conformant __cplusplus (for MSVC)")
    endif()
endfunction()

# Collects the options accepted by `ec_target_set_default_properties` that were
# set by a caller which parsed its arguments with PREFIX.
# PREFIX: The prefix used when parsing the caller's arguments
# OUT_VAR: The output variable, containing the list of set options
function(ec_get_default_property_flags PREFIX OUT_VAR)
    set(_flags)

    foreach(_flag IN ITEMS NO_CONFORMANT_PREPROCESSOR_MSVC NO_CONFORMANT_CPLUSPLUS_MSVC NO_DEBUG_POSTFIX NO_PIC)
        if(${PREFIX}_${_flag})
            list(APPEND _flags ${_flag})
        endif()
    endforeach()

    set(${OUT_VAR} "${_flags}" PARENT_SCOPE)
endfunction()

# Asserts that the CUDA language is enabled.
# `enable_language(CUDA)` cannot be called from inside an ECMake function: it
# must be called at file scope, otherwise the variables it sets (such as the
# CUDA runtime library to link) are lost, resulting in link errors.
function(ec_assert_cuda_enabled)
    get_property(_languages GLOBAL PROPERTY ENABLED_LANGUAGES)

    if(NOT "CUDA" IN_LIST _languages)
        message(FATAL_ERROR
            "WITH_CUDA requires the CUDA language to be enabled before creating the target.
"
            "Add CUDA to `project(... LANGUAGES ... CUDA)`, or call `enable_language(CUDA)` "
            "at file scope (not inside a function) before this call."
        )
    endif()
endfunction()
