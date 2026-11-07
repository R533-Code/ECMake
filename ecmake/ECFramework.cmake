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

include(ECUtil)
include(ECNamespace)
include(ECParseArgs)

# Internal helper shared by `ec_add_tests` and `ec_add_benchmarks`: creates an
# executable from all the `.cpp` files of a directory, linked with a framework
# (testing, benchmarking, ...), with an optionally generated `main()`.
#
# FUNCTION_NAME: The name of the public function (used in error messages)
# FRAMEWORK_ARG: The name of the argument selecting the framework (e.g. `TESTING_FRAMEWORK`)
# DEFAULT_DIR: The default source directory and install sub-directory (e.g. `tests`)
# GENERATOR: The function generating the framework specific files, called as:
# GENERATOR(<framework> <full_target_name> <generated_dir> <no_main>
# <out_sources> <out_libraries> <out_include_dirs>)
# It must write its files (in <generated_dir>) and set the 3 output variables
# in its PARENT_SCOPE: the generated sources to compile, the framework
# libraries to link (checked to be existing targets) and the include
# directories to add. It aborts on an unknown framework.
# EXEC_NAME: The name of the executable
# ...: The arguments of the public function
#
# Sets the OUT variable (if passed) in the PARENT_SCOPE: the public functions
# are macros forwarding to this function, so that is the caller's scope.
function(_ec_add_framework_executable FUNCTION_NAME FRAMEWORK_ARG DEFAULT_DIR GENERATOR EXEC_NAME)
    # This must happen before parsing the defaults so that
    # ${CMAKE_INSTALL_BINDIR} expands to a non-empty string
    include(GNUInstallDirs)

    ec_parse_with_defaults(FW
        "ROOT_DIR;${CMAKE_CURRENT_SOURCE_DIR}/${DEFAULT_DIR};CXX_VERSION;20;C_VERSION;99;INSTALL_BINDIR;${CMAKE_INSTALL_BINDIR}/${DEFAULT_DIR};INSTALL_COMPONENT;Runtime;LINK_WITH;<none>;OUT;<none>" # defaults
        "NO_MAIN;NO_INSTALL;NO_PIC;NO_CONFORMANT_PREPROCESSOR_MSVC;NO_DEBUG_POSTFIX;NO_COPY_DEPENDENCIES" # options
        "ROOT_DIR;CXX_VERSION;C_VERSION;${FRAMEWORK_ARG};INSTALL_BINDIR;INSTALL_COMPONENT;OUT" # one value
        "LINK_WITH" # multi value
        ${ARGN}
    )

    string(STRIP "${EXEC_NAME}" EXEC_NAME)
    ec_namespace_get(_namespace_dots "::")
    ec_namespace_get(_namespace_dash "-")
    set(_alias_name "${_namespace_dots}${EXEC_NAME}")
    set(_full_name "${_namespace_dash}${EXEC_NAME}")

    string(TOLOWER "${FW_${FRAMEWORK_ARG}}" _framework)

    # generate the framework specific files
    set(_generated_dir "${CMAKE_CURRENT_BINARY_DIR}/_ec_generated/${_full_name}")
    cmake_language(CALL ${GENERATOR}
        "${_framework}" "${_full_name}" "${_generated_dir}" "${FW_NO_MAIN}"
        _generated_sources _framework_libraries _generated_include_dirs
    )

    foreach(_library IN LISTS _framework_libraries)
        if(NOT TARGET "${_library}")
            message(FATAL_ERROR
                "${FUNCTION_NAME}: could not find target `${_library}` required for the `${_framework}` framework!\n"
                "Make the framework available (e.g. using `FetchContent` or `find_package`) before calling `${FUNCTION_NAME}`."
            )
        endif()
    endforeach()

    file(GLOB_RECURSE _sources CONFIGURE_DEPENDS
        "${FW_ROOT_DIR}/*.cpp"
    )

    if(NOT _sources)
        message(FATAL_ERROR "${FUNCTION_NAME}: no source files found in the '${FW_ROOT_DIR}' directory. Add `.cpp` files to that folder!")
    endif()

    add_executable(${_full_name} ${_sources} ${_generated_sources})

    # register the target globally so that it is accessible through
    # the global properties
    ec_register_target(${_full_name} ${_alias_name})

    # set properties for better defaults
    ec_get_default_property_flags(FW _flags)
    ec_target_set_default_properties(${_full_name} ${FW_CXX_VERSION} ${FW_C_VERSION}
        ${_flags}
    )

    target_include_directories(${_full_name} PRIVATE "${FW_ROOT_DIR}" ${_generated_include_dirs})

    target_link_libraries(${_full_name} PRIVATE ${_framework_libraries})

    # defaults to PRIVATE if no scope keyword is given
    ec_target_link_with(${_full_name} PRIVATE ${FW_LINK_WITH})

    if(NOT FW_OUT STREQUAL "<none>")
        set(${FW_OUT} ${_full_name} PARENT_SCOPE)
    endif()

    if(NOT FW_NO_COPY_DEPENDENCIES)
        ec_copy_dependencies(${_full_name})
    endif()

    if(NOT FW_NO_INSTALL)
        # install the target
        install(TARGETS ${_full_name}
            RUNTIME DESTINATION "${FW_INSTALL_BINDIR}"
            BUNDLE DESTINATION "${FW_INSTALL_BINDIR}"
            COMPONENT ${FW_INSTALL_COMPONENT}
        )
    endif()
endfunction()
