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

function(ec_add_executable NAME)
    # This must happen before parsing the defaults so that
    # ${CMAKE_INSTALL_BINDIR} expands to a non-empty string
    include(GNUInstallDirs)

    ec_parse_with_defaults(EXEC
        "VERSION;0.0.0.0;ROOT_DIR;${CMAKE_CURRENT_SOURCE_DIR}/src;CXX_VERSION;20;C_VERSION;99;INSTALL_BINDIR;${CMAKE_INSTALL_BINDIR};INSTALL_COMPONENT;Runtime;LINK_WITH;<none>;OUT;<none>" # defaults
        "NO_CONFIG;NO_INSTALL;NO_PIC;NO_CONFORMANT_PREPROCESSOR_MSVC;NO_DEBUG_POSTFIX;WITH_CUDA;NO_COPY_DEPENDENCIES" # options
        "VERSION;ROOT_DIR;CXX_VERSION;C_VERSION;INSTALL_BINDIR;INSTALL_COMPONENT;OUT" # one value
        "LINK_WITH" # multi value
        ${ARGN}
    )

    string(STRIP "${NAME}" NAME)

    ec_namespace_get(current_namespace_dot "::")
    ec_namespace_get(current_namespace_dash "-")
    ec_namespace_get(current_namespace_us "_")
    set(FULL_NAME "${current_namespace_dash}${NAME}")
    set(FULL_ALIAS_DOTS "${current_namespace_dot}${NAME}")
    set(FULL_ALIAS_UNDERSCORES "${current_namespace_us}${NAME}")
    message(VERBOSE "Creating executable ${FULL_NAME} v${EXEC_VERSION} with root dir `${EXEC_ROOT_DIR}`, (C++${EXEC_CXX_VERSION})...")

    string(TOLOWER "${FULL_ALIAS_UNDERSCORES}" _exec_name_lower)
    string(TOUPPER "${FULL_ALIAS_UNDERSCORES}" _exec_name_upper)

    ec_parse_version("${EXEC_VERSION}" EXEC_VERSION)

    if(${EXEC_WITH_CUDA})
        enable_language(CUDA)
        file(GLOB_RECURSE _exec_cpp "${EXEC_ROOT_DIR}/*.cpp" "${EXEC_ROOT_DIR}/*.c" "${EXEC_ROOT_DIR}/*.cu")
        file(GLOB_RECURSE _exec_hpp "${EXEC_ROOT_DIR}/*.hpp" "${EXEC_ROOT_DIR}/*.h" "${EXEC_ROOT_DIR}/*.cuh")
    else()
        file(GLOB_RECURSE _exec_cpp "${EXEC_ROOT_DIR}/*.cpp" "${EXEC_ROOT_DIR}/*.c")
        file(GLOB_RECURSE _exec_hpp "${EXEC_ROOT_DIR}/*.hpp" "${EXEC_ROOT_DIR}/*.h")
    endif()

    if(NOT EXEC_NO_CONFIG)
        message(VERBOSE "Writing `${_exec_name_lower}_config.h/cpp`...")
        ec_target_write_config("${FULL_ALIAS_DOTS}" "${NAME}"
            ${EXEC_VERSION_MAJOR} ${EXEC_VERSION_MINOR} ${EXEC_VERSION_PATCH} ${EXEC_VERSION_TWEAK}
            "${CMAKE_CURRENT_BINARY_DIR}" "" "" _exec_extra
        )
    endif()

    add_executable(${FULL_NAME} ${_exec_cpp} ${_exec_hpp} ${_exec_extra})

    # register the target globally so that it is accessible through
    # the global properties
    ec_register_target(${FULL_NAME} ${FULL_ALIAS_DOTS})

    target_include_directories(${FULL_NAME} SYSTEM PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
    target_include_directories(${FULL_NAME} PUBLIC "${EXEC_ROOT_DIR}")

    # set properties for better defaults
    ec_target_set_default_properties(${FULL_NAME} ${EXEC_CXX_VERSION} ${EXEC_C_VERSION}
        ${ARGN}
    )

    if(NOT EXEC_NO_INSTALL)
        # install the target
        install(TARGETS ${FULL_NAME}
            RUNTIME DESTINATION ${EXEC_INSTALL_BINDIR}
            BUNDLE DESTINATION ${EXEC_INSTALL_BINDIR}
            COMPONENT ${EXEC_INSTALL_COMPONENT}
        )
    endif()

    if(NOT EXEC_LINK_WITH STREQUAL "<none>")
        target_link_libraries(${FULL_NAME} ${EXEC_LINK_WITH})
    endif()

    if(NOT EXEC_OUT STREQUAL "<none>")
        set(${EXEC_OUT} ${FULL_NAME} PARENT_SCOPE)
    endif()

    if (NOT EXEC_NO_COPY_DEPENDENCIES)
        ec_copy_dependencies(${FULL_NAME})
    endif()

    message(VERBOSE "Created executable ${FULL_ALIAS_DOTS}.")
endfunction(ec_add_executable)
